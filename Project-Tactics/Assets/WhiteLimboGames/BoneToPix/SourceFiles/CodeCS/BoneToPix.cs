using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using UnityEngine.Rendering;


namespace WhiteLimboGames
{

    [ExecuteAlways]
    public class BoneToPix : MonoBehaviour
    {


        [Tooltip("Target object to convert. Can use an imported model with built-in animations or object with a pre-defined animator.")]
        public GameObject conversionTarget;

        public BoneToPixSettings advancedSettings;

        public Camera cam;

        [Tooltip("Output width of cells in pixels.")]
        public int cellWidth = 64;

        [Tooltip("Output width of cells in pixels.")]
        public int cellHeight = 64;

        [Tooltip("Draw a black outline around your sprite.")]
        public bool drawOutline;

        Vector2Int finalTextureSize;


        public enum PalletteStyles
        {
            autoGen = 0,
            dontUse = 1,
            manual = 2,
        }
        [HideInInspector] public static PalletteStyles palletteStyle;
        string palletteTypeString;

        [HideInInspector] public static Texture2D manualPallette;
        [HideInInspector] public static int palletteColorCount = 16;

        Renderer[] renderers;
        bool cachedSkinnedMeshStatus = false; List<bool> cachedSkinnedMeshUpdateOffscreenValues;
        bool createdCopyStatus = false; GameObject targetObjectCopy;
        float modelBoundsMinX, modelBoundsMinY;
        float modelBoundsMaxX, modelBoundsMaxY;
        bool boundsCalculationFirstFrame;


        [HideInInspector] public Texture2D generatedPallette;
        private Texture2D palletteSourcingTexture;


        string[] styleFolderNames = { "AlbedoAndNormal", "CellShaded", "Generic" };
        public enum ConversionStyle
        {
            albedoAndNormal = 0,
            cellShaded = 1,
            defaultLit = 2,
        }
        ConversionStyle currentStyle;
        bool isSingleFrameMode;


        [HideInInspector] public bool conversionIsRunning = false;
        [HideInInspector] public bool snappingFrameIsRunning = false;
        [HideInInspector] public bool palletteGenerationIsRunning = false;
        bool albedoConversion = false;
        bool normalMapConversion = false;


        RenderTexture downscaleRendTex;
        RenderTexture blitRendTexture;

        Animator originalAnimator;
        Animator copyAnimator;
        string[] stateNames;

        bool didWeCacheEventStatus = false; bool cachedFireEventsValue;
        bool didWeCacheAnimatorApplyRootMotion = false; bool cachedAnimatorApplyRootMotionValue;

        private Texture2D generatedAlbedoPath;
        private Texture2D generatedNormal;

        class ClipBaseData
        {
            public List<float> KeyFrameNormalizedTimes;
            public bool IsLooping;
            public float FrameRate;
            public float ClipLength; // Not normalized

            public List<bool> KeyFramesToKeepMask;
            public int KeptFrameCount;
            public int CulledFrameCount;
            public ClipBaseData(float dur, float fr = 12f, bool luup = false)
            {
                KeyFrameNormalizedTimes = new List<float>();
                IsLooping = luup;
                FrameRate = fr;
                ClipLength = dur;
            }
        }
        Dictionary<string, ClipBaseData> clipData; // state names to keyFrameTimes for said clip

        int totalCellCount;
        int cellsPerRow, rowN;
        int stateIndex = 0;
        int keyFrameIndex = 0;
        int firstConversionFrame = 0;
        bool finishFlag = false;
        int cellX, cellY;


        Texture2D currentWorkingTexture = null;

        string fullOutputFolderPath;
        string localOutputFolderPath;

        string fullAlbedoOutputFilePath;
        string localAlbedoOutputFilePath;

        string fullNormalOutputFilePath;
        string localNormalOutputFilePath;

        RenderPipelineAsset cachedRenderPipeline;

        int placeholderOutputFPS; // Actual clips may have different FPS from each other. This value just holds the fps of the last clip rendered, for the purpose of plugging it into the pallette editor ( Pallette editor doesn't support animating different clips with different FPS ) 

        private void Awake()
        {
            conversionIsRunning = false;
            snappingFrameIsRunning = false;
            albedoConversion = false;
            normalMapConversion = false;

        }

        private void OnEnable()
        {
            UnityEditor.EditorApplication.update += EditorUpdate;
        }


        private void EditorUpdate()
        {
            try
            {
                if(snappingFrameIsRunning)
                {
                    SnapFrameUpdate();
                }
                else if(conversionIsRunning)
                {
                    ConversionUpdate();
                }
                else if(palletteGenerationIsRunning)
                {
                    PalletteSourcingUpdate();
                }
            }
            catch(System.Exception e)
            {
                Debug.LogError(e);
                Debug.LogError(e.StackTrace);
                conversionIsRunning = false;
                snappingFrameIsRunning = false;
                albedoConversion = false;
                normalMapConversion = false;
                RevertAllModifiedValues();
            }
        }



        public void InitialSetup(int style, bool isSingleFrame)
        {
            if(conversionTarget.scene.name == null)
            {
                Debug.LogError("ERROR: Conversion Target must be an object in a loaded scene. Try dragging your prefab into the scene, select it from the hierarchy, and run again!");
                targetObjectCopy = null;
                return;
            }

            if(palletteStyle == PalletteStyles.autoGen)
            {
                if(palletteColorCount < 1)
                {
                    Debug.LogError("ERROR: Need at least 1 color for pallette");
                    return;
                }
                if(palletteColorCount > 256)
                {
                    Debug.LogError("ERROR: Pallette color count is waaay too big. Try 256/fewer colors or use the noPalletteOption");
                    return;
                }
            }
            else if(palletteStyle == PalletteStyles.manual)
            {
                if(manualPallette == null)
                {
                    Debug.LogError("ERROR: No manual pallette texture selected. Hint: Make a 1 pixel height texture with all the colors you want to use and select it in the manual Pallette field. ");
                    return;
                }
                if(manualPallette.width > 512)
                {
                    Debug.LogError("ERROR: Manual pallette color count is waaay too big. Try 512/fewer colors or use the noPalletteOption");
                    return;
                }

                PalletteUtilities.ValidatePaletteSettingsAndNotifyUser(manualPallette);
            }

            palletteTypeString = "";
            if(palletteStyle == PalletteStyles.manual)
            {
                palletteTypeString = "_ManualPallette(" + manualPallette.name + ")";
            }
            else if(palletteStyle == PalletteStyles.autoGen)
            {
                palletteTypeString = "_" + palletteColorCount + "ColorsAutoPallette";
            }
            else if(palletteStyle == PalletteStyles.autoGen)
            {
                palletteTypeString = "_" + "NoPallette";
            }

            currentStyle = (ConversionStyle)style;
            isSingleFrameMode = isSingleFrame;

            localOutputFolderPath = "Assets/" + advancedSettings.OutputPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString();
            fullOutputFolderPath = Application.dataPath + "/" + advancedSettings.OutputPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString();
            if(isSingleFrameMode)
            {
                localOutputFolderPath += "/" + styleFolderNames[style];
                fullOutputFolderPath += "/" + styleFolderNames[style];
            }
            else
            {
                localOutputFolderPath += "_SingleFrame_";
                fullOutputFolderPath += "_SingleFrame_";
            }
            localOutputFolderPath += palletteTypeString;
            fullOutputFolderPath += palletteTypeString;


            if(!Directory.Exists(fullOutputFolderPath))
            {
                Directory.CreateDirectory(fullOutputFolderPath);
            }

            if(isSingleFrameMode == false) // Single frame mode just snaps a single frame of whatver the camera is looking at and converts it. A bunch of this stuff is no longer necessary / doesn't make sense. 
            {
                conversionTarget.transform.position = new Vector3(conversionTarget.transform.position.x, conversionTarget.transform.position.y, 0.0f);
                if(SetupObjectAnimatorAndClips() == false)
                {
                    RevertAllModifiedValues();
                    return;
                }
                renderers = conversionTarget.GetComponentsInChildren<Renderer>();
                if(renderers.Length == 0)
                {
                    RevertAllModifiedValues();
                    Debug.LogError("ERROR: No renderers found in animatable object");
                    return;
                }

                cachedSkinnedMeshUpdateOffscreenValues = new List<bool>();
                cachedSkinnedMeshStatus = true;
                for(int i = 0; i < renderers.Length; i++)
                {
                    if(renderers[i] is SkinnedMeshRenderer)
                    {
                        cachedSkinnedMeshUpdateOffscreenValues.Add((renderers[i] as SkinnedMeshRenderer).updateWhenOffscreen);
                        (renderers[i] as SkinnedMeshRenderer).updateWhenOffscreen = true; // If this is false Unity fails to update renderer bounds during animations, so we temp tick it to true
                    }
                }

            }

            BoneToPixUtilities.CalculateCellSizes(ref cellsPerRow, ref rowN, ref finalTextureSize, isSingleFrameMode, cellWidth, cellHeight, totalCellCount, advancedSettings.showExtraDebugInformation);

            if(downscaleRendTex && downscaleRendTex.IsCreated())
            {
                downscaleRendTex.Release();
            }
            // Since outlines are done at the end, and potentially add another pixel in every direction, we need to slice off 1 pixel in each direction so we don't end up with our outline inside a different sprite frame
            if(drawOutline == true)
            {
                downscaleRendTex = new RenderTexture(cellWidth - 2, cellHeight - 2, 0, RenderTextureFormat.ARGB32);
            }
            else
            {
                downscaleRendTex = new RenderTexture(cellWidth, cellHeight, 0, RenderTextureFormat.ARGB32);
            }

            if(cam == null)
            {
                cam = Camera.main;
            }

            downscaleRendTex.filterMode = FilterMode.Point;
            downscaleRendTex.Create();
            cam.targetTexture = downscaleRendTex;

            if(isSingleFrame)
            {
                PalletteSourcingSetup();
                PalletteSourcingUpdate();
                PalletteSourcingFinish();
                CreateMainConversionTexture();
                RenderConversionFrame(cellx: 0, celly: 0);
                FinishConversion();
            }
            else
            {
                stateIndex = 0;
                keyFrameIndex = -1;
                snappingFrameIsRunning = true;
                boundsCalculationFirstFrame = true;
            }

            if(GraphicsSettings.renderPipelineAsset != null) // this is null in built-in renderPipeline projects. If it isn't null then we are in URP / HDRP / SRP
            {
                if(advancedSettings.AllowConversionInAllPipelines == true)
                {
                    if(Application.isPlaying)
                    {
                        Debug.LogError("ERROR: Application is in Play Mode. Try exiting play mode and try again.");
                        return;
                    }
                    else
                    {
                        Debug.Log("Starting conversion in compatibility mode. Note that you may see some shader-related errors once conversion is completed, this is normal and follows from the pipeline-switching.");
                        cachedRenderPipeline = GraphicsSettings.renderPipelineAsset;
                        GraphicsSettings.renderPipelineAsset = null;
                    }
                }
                else
                {
                    Debug.LogError("ERROR: This project is not using the built-in render pipeline. You can enable \"AllowConversionInAllPipelines\" in advanced settings to allow conversions to work in this project.");
                    return;
                }
            }
        }


        // ============================ FRAME SNAPPING =========================== //

        void SnapFrameUpdate()
        {
            keyFrameIndex++;

            string stateName = stateNames[stateIndex];
            List<float> keys = clipData[stateName].KeyFrameNormalizedTimes;

            if(keyFrameIndex >= keys.Count)
            {     // next animation
                keyFrameIndex = -1;
                stateIndex++;
                if(stateIndex >= stateNames.Length)
                { // Went through everything, finalizing current render
                    snappingFrameIsRunning = false;
                    FinishSnapFrame();
                }
                return;
            }

            float currentKey = keys[keyFrameIndex];

            originalAnimator.Play(stateName, 0, currentKey);
            originalAnimator.Update(999999f);


            UnityEditor.EditorApplication.QueuePlayerLoopUpdate();
            UnityEditor.SceneView.RepaintAll();

            cam.Render();


            float currentCompositeBoundsMinX = renderers[0].bounds.min.x; float currentCompositeBoundsMinY = renderers[0].bounds.min.y;
            float currentCompositeBoundsMaxX = renderers[0].bounds.max.x; float currentCompositeBoundsMaxY = renderers[0].bounds.max.y;
            for(int i = 1; i < renderers.Length; i++)
            {
                currentCompositeBoundsMinX = Mathf.Min(currentCompositeBoundsMinX, renderers[i].bounds.min.x);
                currentCompositeBoundsMinY = Mathf.Min(currentCompositeBoundsMinY, renderers[i].bounds.min.y);
                currentCompositeBoundsMaxX = Mathf.Max(currentCompositeBoundsMaxX, renderers[i].bounds.max.x);
                currentCompositeBoundsMaxY = Mathf.Max(currentCompositeBoundsMaxY, renderers[i].bounds.max.y);
            }


            if(boundsCalculationFirstFrame)
            {
                boundsCalculationFirstFrame = false;
                modelBoundsMinX = currentCompositeBoundsMinX;
                modelBoundsMinY = currentCompositeBoundsMinY;
                modelBoundsMaxX = currentCompositeBoundsMaxX;
                modelBoundsMaxY = currentCompositeBoundsMaxY;
            }
            else
            {
                modelBoundsMinX = Mathf.Min(modelBoundsMinX, currentCompositeBoundsMinX);
                modelBoundsMinY = Mathf.Min(modelBoundsMinY, currentCompositeBoundsMinY);
                modelBoundsMaxX = Mathf.Max(modelBoundsMaxX, currentCompositeBoundsMaxX);
                modelBoundsMaxY = Mathf.Max(modelBoundsMaxY, currentCompositeBoundsMaxY);
            }

            DrawRect(new Vector2(modelBoundsMinX, modelBoundsMinY), new Vector2(modelBoundsMaxX, modelBoundsMaxY), Color.red, 1f);

        }

        public void DrawRect(Vector2 min, Vector2 max, Color color, float duration = 0.0f, bool depthTest = false)
        {
            Debug.DrawLine(new Vector2(min.x, min.y), new Vector2(max.x, min.y), color, duration, depthTest);
            Debug.DrawLine(new Vector2(min.x, min.y), new Vector2(min.x, max.y), color, duration, depthTest);
            Debug.DrawLine(new Vector2(max.x, max.y), new Vector2(max.x, min.y), color, duration, depthTest);
            Debug.DrawLine(new Vector2(max.x, max.y), new Vector2(min.x, max.y), color, duration, depthTest);
        }


        void FinishSnapFrame()
        {
            RevertSkinnedMeshStatus();

            float width = (modelBoundsMaxX - modelBoundsMinX) * 1.01f;
            float height = (modelBoundsMaxY - modelBoundsMinY) * 1.01f;
            float aspectRatio = width / height;

            float targetRatio = cellWidth / cellHeight;

            if(aspectRatio < targetRatio)
            {
                width = width = targetRatio * height;
            }
            else
            {
                height = width / targetRatio;
            }

            //width = width - height * aspectRatio + height * targetRatio; // ensuring aspect ratio of camera will match the aspect ratio of cellW / cellH.
            //aspectRatio = width / height;

            if(cam.orthographic != true)
            {
                cam.orthographic = true;
                Debug.LogError("Your camera projection mode was set to \"projection\". It needs to be set to \"orthographic\". Auto-resetting to orthographic mode.");
            }
            Vector3 camPos = new Vector3((modelBoundsMinX + modelBoundsMaxX) / 2f, (modelBoundsMinY + modelBoundsMaxY) / 2f, -500.0f);
            cam.farClipPlane = 1000.0f;
            cam.nearClipPlane = 0.3f;
            cam.transform.position = camPos;
            cam.aspect = targetRatio;
            cam.orthographicSize = height / 2f;

            

            if(cam.transform.rotation.eulerAngles != Vector3.zero)
            {
                Debug.LogError("Your camera transform had a rotation applied to it. The camera rotation needs to be (0,0,0). If you want to get different angles in your conversion, rotate the model instead of the camera. The camera's rotation has been reset, so you will likely get different angles than expected.");
                cam.transform.rotation = Quaternion.identity;
            }

            if(palletteStyle == PalletteStyles.autoGen)
            { // Generate our pallette first
                PalletteSourcingSetup();
            }
            else
            {
                ConversionSetup();
            }
        }



        // ====================== PALLETTE SOURCING ========================= /

        void PalletteSourcingSetup()
        {
            if(isSingleFrameMode == false)
            {
                if(currentStyle == ConversionStyle.albedoAndNormal)
                {
                    CreateCopyObject(MaterialStyle.flatColor);
                }
                else if(currentStyle == ConversionStyle.cellShaded)
                {
                    CreateCopyObject(MaterialStyle.cellLit);
                }
                else if(currentStyle == ConversionStyle.defaultLit)
                {
                    CreateCopyObject(MaterialStyle.defaultLit);
                }
                originalRotation = targetObjectCopy.transform.rotation.eulerAngles;

                cam.orthographicSize = cam.orthographicSize * 1.5f;
                palletteGenerationIsRunning = true;
            }

            palletteSourcingCellIndex = 0;


            int palletteSourcingWidth;
            if(isSingleFrameMode)
            {
                palletteSourcingWidth = cellWidth;
            }
            else
            {
                palletteSourcingWidth = cellWidth * advancedSettings.palletteSourcingPoseAngles.Length;
            }
            palletteSourcingTexture = new Texture2D(palletteSourcingWidth, cellHeight, TextureFormat.ARGB32, false);
            palletteSourcingTexture.filterMode = FilterMode.Point;
        }

        int palletteSourcingCellIndex = 0;
        Vector3 originalRotation;
        void PalletteSourcingUpdate()
        {
            RenderPalletteSourcingFrame(isSingleFrameMode);

            if(palletteSourcingCellIndex >= advancedSettings.palletteSourcingPoseAngles.Length)
            {
                // rendered all poses
                PalletteSourcingFinish();
            }
        }
        void RenderPalletteSourcingFrame(bool isSingleFrame)
        {
            if(isSingleFrame == false)
            {
                targetObjectCopy.transform.rotation = Quaternion.Euler(originalRotation + advancedSettings.palletteSourcingPoseAngles[palletteSourcingCellIndex]);
            }
            cam.Render();

            RenderTexture.active = downscaleRendTex;
            if(drawOutline)
            {
                // Since outlines are done at the end, and potentially add another pixel in every direction, we need to slice off 1 pixel in each direction so we don't end up with our outline inside a different sprite frame
                palletteSourcingTexture.ReadPixels(new Rect(0, 0, cellWidth - 2, cellHeight - 2), palletteSourcingCellIndex * cellWidth, 0);
            }
            else
            {
                palletteSourcingTexture.ReadPixels(new Rect(0, 0, cellWidth, cellHeight), palletteSourcingCellIndex * cellWidth, 0);
            }

            if(isSingleFrame == false)
            {
                palletteSourcingCellIndex++;
            }

            RenderTexture.active = null;
        }


        void PalletteSourcingFinish()
        {
            if(advancedSettings.UseFilter)
            {
                CoolFilterPass(ref palletteSourcingTexture);
            }

            if(isSingleFrameMode == false)
            {
                cam.orthographicSize = cam.orthographicSize / 1.5f; // reverting increased camera size
                targetObjectCopy.transform.rotation = Quaternion.Euler(originalRotation); // reverting to original rotation
            }

            palletteSourcingTexture.Apply();
            byte[] encodedPalletteSourcingTex = palletteSourcingTexture.EncodeToPNG();
            File.WriteAllBytes(fullOutputFolderPath + "/PalletteSourcing.png", encodedPalletteSourcingTex);

            Color32[] limited = PalletteUtilities.GenerateLimitedPallette(palletteSourcingTexture, palletteColorCount);
            Texture2D limitedPalletteTex = BoneToPixUtilities.DrawPallette32(limited);
            BoneToPixUtilities.LimitPallette(ref palletteSourcingTexture, ref limitedPalletteTex, ref blitRendTexture, currentStyle, advancedSettings);

            // counting apparitions for each pallette color in the sourcing texture
            Color32[] limitedSourcingTexColData = palletteSourcingTexture.GetPixels32();
            Dictionary<Color32, int> limitedApparations = new Dictionary<Color32, int>();
            for(int i = 0; i < limited.Length; i++)
            {
                limitedApparations.Add(limited[i], 0);
            }
            for(int i = 0; i < limitedSourcingTexColData.Length; i++)
            {
                if(limitedSourcingTexColData[i].a == 255)
                {
                    limitedApparations[limitedSourcingTexColData[i]] = limitedApparations[limitedSourcingTexColData[i]] + 1;
                }
            }


            Color32[] consolidated = BoneToPixUtilities.ConsolidatePallette(limitedApparations, advancedSettings.palletteColorConsolidationThreshold);

            //write from finalPallette into texture
            if(consolidated.Length < palletteColorCount)
            {
                Debug.LogWarning("Sourcing for limited pallette generated less than " + palletteColorCount.ToString() + " colors. Final pallette will have " + consolidated.Length + " colors");
            }

            generatedPallette = BoneToPixUtilities.DrawPallette32(consolidated);

            byte[] encodedPalletteTex = generatedPallette.EncodeToPNG();
            File.WriteAllBytes(localOutputFolderPath + "/GeneratedPallette.png", encodedPalletteTex);

            AssetDatabase.Refresh();

            TextureImporter texImporter = TextureImporter.GetAtPath(localOutputFolderPath + "/GeneratedPallette.png") as TextureImporter;
            texImporter.filterMode = FilterMode.Point;
            texImporter.textureCompression = TextureImporterCompression.Uncompressed;
            texImporter.wrapMode = TextureWrapMode.Clamp;
            texImporter.mipmapEnabled = false;
            texImporter.isReadable = true;

            TextureImporterSettings settings = new TextureImporterSettings();
            texImporter.ReadTextureSettings(settings);
            settings.npotScale = TextureImporterNPOTScale.None;
            texImporter.SetTextureSettings(settings);

            if(isSingleFrameMode == false)
            {
                palletteGenerationIsRunning = false;
                ConversionSetup();
            }
        }



        // ======================== CONVERSION ============================= //

        void ConversionSetup()
        {
            stateIndex = 0;
            keyFrameIndex = -1;
            firstConversionFrame = 0;

            if(currentStyle == ConversionStyle.albedoAndNormal)
            {
                advancedSettings.normalMapMaterial.SetTexture("_CellLookup", advancedSettings.NormalMapCellShadingLookup);
                CreateCopyObject(MaterialStyle.flatColor);
            }
            else if(currentStyle == ConversionStyle.cellShaded)
            {
                advancedSettings.cellLitMaterial.SetTexture("_CellLookup", advancedSettings.CellShadedLookup);
                CreateCopyObject(MaterialStyle.cellLit);
            }
            else if(currentStyle == ConversionStyle.defaultLit)
            {
                CreateCopyObject(MaterialStyle.defaultLit);
            }

            conversionIsRunning = true;
            albedoConversion = true;
            normalMapConversion = false;
            finishFlag = false;
            firstConversionFrame = 0;

            CreateMainConversionTexture();

            cellX = 0; cellY = 0;
        }
        void CreateMainConversionTexture()
        {
            currentWorkingTexture = new Texture2D(finalTextureSize.x, finalTextureSize.y, TextureFormat.ARGB32, false, false);
            currentWorkingTexture.filterMode = FilterMode.Point;
        }

        void ConversionUpdate()
        {
            if(finishFlag)
            {
                FinishConversion();
                return;
            }

            string stateName = stateNames[stateIndex];
            List<float> keys = clipData[stateName].KeyFrameNormalizedTimes;

            keyFrameIndex++;

            if(firstConversionFrame < 5)
            {
                // Animator.Play seems to give us one frame of blending when switching between states even when updating with a large value, so we're skipping the first frame ( 5 times to be sure, only 1 doesn't seem to do it! )
                copyAnimator.Play(stateNames[stateIndex], 0, keys[0]);
                copyAnimator.Update(9999999f);
                cam.Render();
                firstConversionFrame++;
                if(firstConversionFrame != 5)
                {
                    keyFrameIndex--;
                }
                return;
            }

            if(keyFrameIndex >= keys.Count)
            {     // next animation
                keyFrameIndex = -1;
                stateIndex++;
                if(stateIndex >= stateNames.Length)
                { // Went through everything, finalizing current render
                    finishFlag = true; // doing one last render, since our renders are always one frame behind.
                }
                if(finishFlag == false)
                {
                    //Animator.Play seems to give us one frame of blending when switching between states even when updating with a large value, so we're skipping for one frame on transitions.
                    copyAnimator.Play(stateNames[stateIndex], 0, clipData[stateNames[stateIndex]].KeyFrameNormalizedTimes[0]);
                    copyAnimator.Update(9999999f);
                    cam.Render();
                    keyFrameIndex++;
                    return;
                }
            }


            if((keyFrameIndex >= 0) && (clipData[stateNames[stateIndex]].KeyFramesToKeepMask[keyFrameIndex] == false))
            {
                return; // Skip this frame 
            }


            if(finishFlag == false)
            {
                float currentKey = keys[keyFrameIndex];
                copyAnimator.Play(stateName, 0, currentKey);
                copyAnimator.Update(9999999f);
            }

            RenderConversionFrame(cellX, cellY);

            cellX++;
            if(cellX >= cellsPerRow)
            {
                cellX = 0;
                cellY++;
            }

            RenderTexture.active = null;
        }

        void RenderConversionFrame(int cellx, int celly)
        {
            cam.Render();
            RenderTexture.active = downscaleRendTex;
            if(drawOutline)
            {
                // Since outlines are done at the end, and potentially add another pixel in every direction, we need to slice off 1 pixel in each direction so we don't end up with our outline inside a different sprite frame
                currentWorkingTexture.ReadPixels(new Rect(0, 0, cellWidth - 2, cellHeight - 2), cellx * cellWidth + 1, finalTextureSize.y - (celly + 1) * cellHeight + 1);
            }
            else
            {
                currentWorkingTexture.ReadPixels(new Rect(0, 0, cellWidth, cellHeight), cellx * cellWidth, finalTextureSize.y - (celly + 1) * cellHeight);
            }
        }

        void FinishConversion()
        {
            if(albedoConversion || isSingleFrameMode)
            { // Finalizing albedo.

                currentWorkingTexture.Apply();

                if(palletteStyle == PalletteStyles.autoGen)
                {
                    BoneToPixUtilities.LimitPallette(ref currentWorkingTexture, ref generatedPallette, ref blitRendTexture, currentStyle, advancedSettings);
                }
                else if(palletteStyle == PalletteStyles.manual)
                {
                    BoneToPixUtilities.LimitPallette(ref currentWorkingTexture, ref manualPallette, ref blitRendTexture, currentStyle, advancedSettings);
                }
                else if(palletteStyle == PalletteStyles.dontUse)
                {
                    //
                }

                if(advancedSettings.UseFilter)
                {
                    CoolFilterPass(ref currentWorkingTexture);
                }

                if(drawOutline)
                {
                    DrawOutlinePass(ref currentWorkingTexture);
                }

                currentWorkingTexture.Apply();
                byte[] encodedTex = currentWorkingTexture.EncodeToPNG();



                if(isSingleFrameMode)
                {
                    localAlbedoOutputFilePath = localOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + palletteTypeString + "SingleFrame.png";
                    int noOverwriteCounter = BoneToPixUtilities.GetSaveCounterNoOverwrite(localAlbedoOutputFilePath);

                    localAlbedoOutputFilePath = localOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + palletteTypeString + "SingleFrame_" + noOverwriteCounter.ToString() + ".png";
                    fullAlbedoOutputFilePath = fullOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + palletteTypeString + "SingleFrame_" + noOverwriteCounter.ToString() + ".png";
                }
                else
                {
                    localAlbedoOutputFilePath = localOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + conversionTarget.name + palletteTypeString + "_FlatColor.png";
                    fullAlbedoOutputFilePath = fullOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + conversionTarget.name + palletteTypeString + "_FlatColor.png";
                }

                BoneToPixUtilities.GetSaveCounterNoOverwrite(localAlbedoOutputFilePath);

                if(File.Exists(fullAlbedoOutputFilePath + ".meta"))
                {
                    File.Delete(fullAlbedoOutputFilePath + ".meta"); // Unity doesn't seem to let us update importerSettings if they're already set, so we're just replacing the meta.
                }
                File.WriteAllBytes(fullAlbedoOutputFilePath, encodedTex);
                AssetDatabase.Refresh();

                TextureImporter texImporter = TextureImporter.GetAtPath(localAlbedoOutputFilePath) as TextureImporter;
                texImporter.filterMode = FilterMode.Point;
                texImporter.textureCompression = TextureImporterCompression.Uncompressed;
                texImporter.wrapMode = TextureWrapMode.Clamp;
                texImporter.mipmapEnabled = false;
                texImporter.isReadable = true;


                if(isSingleFrameMode == false)
                {
                    if(currentStyle == ConversionStyle.albedoAndNormal)
                    { // Move on to normal map pass
                        CreateCopyObject(MaterialStyle.normal);

                        downscaleRendTex.Release(); // Redoing rendTexture with sRGB off.
                                                    // Since outlines are done at the end, and potentially add another pixel in every direction, we need to slice off 1 pixel in each direction so we don't end up with our outline inside a different sprite frame
                        RenderTextureDescriptor descriptor;
                        if(drawOutline)
                        {
                            descriptor = new RenderTextureDescriptor(cellWidth - 2, cellHeight - 2, RenderTextureFormat.ARGB32, 1, 1);
                        }
                        else
                        {
                            descriptor = new RenderTextureDescriptor(cellWidth, cellHeight, RenderTextureFormat.ARGB32, 1, 1);
                        }
                        descriptor.sRGB = false;
                        downscaleRendTex = new RenderTexture(descriptor);
                        descriptor.msaaSamples = 0;
                        downscaleRendTex.filterMode = FilterMode.Point;
                        downscaleRendTex.Create();
                        cam.allowMSAA = false;
                        cam.targetTexture = downscaleRendTex;

                        albedoConversion = false;
                        normalMapConversion = true;
                        firstConversionFrame = 0;
                        finishFlag = false;
                        stateIndex = 0;
                        keyFrameIndex = -1;

                        currentWorkingTexture = new Texture2D(finalTextureSize.x, finalTextureSize.y, TextureFormat.ARGB32, false, true);
                        currentWorkingTexture.filterMode = FilterMode.Point;

                        cellX = 0; cellY = 0;
                    }
                    else
                    { // finish
                        FinishAll();
                    }
                }

            }
            else if(normalMapConversion)
            { // Finalizing normal. 

                if(advancedSettings.UseFilter == true)
                {
                    CoolFilterPass(ref currentWorkingTexture);
                }
                if(drawOutline && (advancedSettings.UseLightingOnOutline == false))
                {
                    DrawOutlineNormalPass(currentWorkingTexture);
                }

                currentWorkingTexture.Apply();
                byte[] encodedTex = currentWorkingTexture.EncodeToPNG();
                localNormalOutputFilePath = localOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + conversionTarget.name + palletteTypeString + "_Normal.png";
                fullNormalOutputFilePath = fullOutputFolderPath + "/" + cellWidth.ToString() + "x" + cellHeight.ToString() + "_" + conversionTarget.name + palletteTypeString + "_Normal.png";

                if(File.Exists(fullNormalOutputFilePath + ".meta"))
                {
                    File.Delete(fullNormalOutputFilePath + ".meta"); // Unity doesn't seem to let us update importerSettings if they're already set, so we're just replacing the meta.
                }
                File.WriteAllBytes(fullNormalOutputFilePath, encodedTex);


                FinishAll();
            }
        }


        void FinishAll()
        {
            DestroyCopies();
            conversionIsRunning = false;
            albedoConversion = false;
            normalMapConversion = false;

            List<AnimationClip> clips = SliceSheetsSetupAnimationsAndApplyImporterSettings();
            if(currentStyle == ConversionStyle.albedoAndNormal)
            {
                CreatePreviewAnimatorAndSprite(localOutputFolderPath, "PreviewMaterial", clips, generatedNormal);
            }
            else
            {
                CreatePreviewAnimatorAndSprite(localOutputFolderPath, "PreviewMaterial", clips);
            }

            AssetDatabase.Refresh();
            if(advancedSettings.AutoRunPalletteEditor == true)
            {
                Texture2D pallette;
                if(palletteStyle == PalletteStyles.autoGen)
                {
                    pallette = generatedPallette;
                }
                else if(palletteStyle == PalletteStyles.manual)
                {
                    pallette = manualPallette;
                }
                else // dontUse
                {
                    pallette = null;
                }


                if(currentStyle == ConversionStyle.albedoAndNormal)
                {
                    PalletteEditor.Open(localAlbedoOutputFilePath, pallette, generatedNormal, PalletteEditor.ImageMode.Sprite, placeholderOutputFPS);
                }
                else
                {
                    PalletteEditor.Open(localAlbedoOutputFilePath, pallette, null, PalletteEditor.ImageMode.Sprite, placeholderOutputFPS);
                }
            }
        }


        // =========================== ASSET CREATION AND MANIPULATION ============================ //

        List<AnimationClip> SliceSheetsSetupAnimationsAndApplyImporterSettings()
        {
            AssetDatabase.Refresh();

            List<AnimationClip> clips = new List<AnimationClip>();

            // Slicing spritesheet // Note: if importerSettings already exists we need to delete them first.
            TextureImporter texImporter = TextureImporter.GetAtPath(localAlbedoOutputFilePath) as TextureImporter;
            texImporter.textureType = TextureImporterType.Sprite;
            texImporter.spriteImportMode = SpriteImportMode.Multiple;
            texImporter.maxTextureSize = 16384;
            texImporter.filterMode = FilterMode.Point;
            texImporter.wrapMode = TextureWrapMode.Clamp;
            texImporter.textureCompression = TextureImporterCompression.Uncompressed;
            texImporter.spritePixelsPerUnit = advancedSettings.SpritePPU;

            TextureImporterSettings textureImporterSettings = new TextureImporterSettings();
            texImporter.ReadTextureSettings(textureImporterSettings);
            textureImporterSettings.spriteMeshType = SpriteMeshType.FullRect;
            texImporter.SetTextureSettings(textureImporterSettings);


            if(currentStyle == ConversionStyle.albedoAndNormal)
            {
                AssetDatabase.Refresh();
                TextureImporter normalTexImporter;
                normalTexImporter = TextureImporter.GetAtPath(localNormalOutputFilePath) as TextureImporter;
                normalTexImporter.textureType = TextureImporterType.Sprite;
                normalTexImporter.maxTextureSize = 16384;
                normalTexImporter.filterMode = FilterMode.Point;
                normalTexImporter.wrapMode = TextureWrapMode.Clamp;
                normalTexImporter.textureCompression = TextureImporterCompression.Uncompressed;
                normalTexImporter.sRGBTexture = false;
                normalTexImporter.spritePixelsPerUnit = advancedSettings.SpritePPU;

                TextureImporterSettings normalTextureImporterSettings = new TextureImporterSettings();
                normalTexImporter.ReadTextureSettings(normalTextureImporterSettings);
                normalTextureImporterSettings.spriteMeshType = SpriteMeshType.FullRect;
                normalTexImporter.SetTextureSettings(normalTextureImporterSettings);

                normalTexImporter.SaveAndReimport();
                generatedNormal = (Texture2D)AssetDatabase.LoadAssetAtPath(localNormalOutputFilePath, typeof(Texture2D));
            }


            SpriteMetaData[] sheetData = new SpriteMetaData[totalCellCount];
            for(int i = 0; i < rowN; i++)
            {
                for(int j = 0; j < cellsPerRow; j++)
                {
                    int sheetCellIndex = i * rowN + j;
                    if(sheetCellIndex >= totalCellCount)
                    {
                        break;
                    }
                    sheetData[sheetCellIndex].alignment = 0;
                    sheetData[sheetCellIndex].border = new Vector4(0, 0, 0, 0);
                    sheetData[sheetCellIndex].name = conversionTarget.name + "_" + (sheetCellIndex).ToString();
                    sheetData[sheetCellIndex].pivot = new Vector2(0.5f, 0.5f);
                    sheetData[sheetCellIndex].rect = new Rect(j * cellWidth, finalTextureSize.y - (i + 1) * cellHeight, cellWidth, cellHeight);
                }
            }
            texImporter.spritesheet = sheetData;

            AssetDatabase.Refresh();
            texImporter.SaveAndReimport();
            AssetDatabase.Refresh();


            //Creating animations
            Object[] texAssets = AssetDatabase.LoadAllAssetsAtPath(localAlbedoOutputFilePath);
            int cellIndex = 0;
            foreach(KeyValuePair<string, ClipBaseData> pair in clipData)
            {
                string animName = pair.Key;
                List<float> keyFrames = pair.Value.KeyFrameNormalizedTimes;

                for(int i = 0; i < keyFrames.Count; i++)
                {
                    keyFrames[i] *= pair.Value.ClipLength; // Un-normalizing
                }

                AnimationClip anim = new AnimationClip();
                anim.name = animName;
                AnimationClipSettings settings = AnimationUtility.GetAnimationClipSettings(anim);
                settings.loopTime = pair.Value.IsLooping;
                AnimationUtility.SetAnimationClipSettings(anim, settings);
                anim.frameRate = pair.Value.FrameRate;


                EditorCurveBinding binding = new EditorCurveBinding();
                binding.path = "";
                binding.propertyName = "m_Sprite";
                binding.type = typeof(SpriteRenderer);


                List<ObjectReferenceKeyframe> objKeysList = new List<ObjectReferenceKeyframe>(pair.Value.KeptFrameCount);
                for(int i = 0; i < keyFrames.Count - 1; i++)
                {
                    if(pair.Value.KeyFramesToKeepMask[i] == false)
                    {
                        continue; // Skip this one
                    }

                    ObjectReferenceKeyframe objKey = new ObjectReferenceKeyframe();
                    objKey.time = keyFrames[i];
                    while(texAssets[cellIndex].GetType() != typeof(Sprite)) // MOST of the time the texture is the first asset and then the sprite. But sometimes Unity screws up and and texture asset isn't first, because of course it does
                    {
                        cellIndex++;
                    }
                    objKey.value = texAssets[cellIndex];
                    objKeysList.Add(objKey);

                    cellIndex++;
                }

                ObjectReferenceKeyframe[] objKeysArray = new ObjectReferenceKeyframe[objKeysList.Count];
                for(int i = 0; i < objKeysArray.Length; i++)
                {
                    objKeysArray[i] = objKeysList[i];
                }
                AnimationUtility.SetObjectReferenceCurve(anim, binding, objKeysArray);

                if(!Directory.Exists(localOutputFolderPath + "/Animations"))
                {
                    Directory.CreateDirectory(localOutputFolderPath + "/Animations");
                }
                AssetDatabase.CreateAsset(anim, localOutputFolderPath + "/Animations/" + animName + ".anim");
                clips.Add(anim);
            }

            RevertFireEvents();
            RevertAllModifiedValues();

            return clips;
        }


        bool SetupObjectAnimatorAndClips()
        {

            if(conversionTarget == null)
            {
                RevertAllModifiedValues();
                Debug.LogError("ERROR: No object selected for conversion");
                return false;
            }
            if(conversionTarget.activeInHierarchy == false)
            {
                RevertAllModifiedValues();
                Debug.LogError("ERROR: Selected object is inactive");
                return false;
            }

            // Gathering clips built-in to object.
            List<AnimationClip> clips = new List<AnimationClip>();
            Object[] objects = AssetDatabase.LoadAllAssetsAtPath(PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(conversionTarget));
            foreach(Object obj in objects)
            {
                AnimationClip clip = obj as AnimationClip;
                if(clip != null && !clip.name.Contains("__preview__"))
                {
                    clips.Add(clip);
                }
            }

            AnimatorStateMachine rootStateMachine;
            if(clips.Count != 0)
            {  // bone model object with built-in animations; Creating a controller with all anims.
                originalAnimator = conversionTarget.GetComponent<Animator>();

                if(originalAnimator)
                {
                    DestroyImmediate(originalAnimator);
                }

                originalAnimator = conversionTarget.AddComponent<Animator>();
                originalAnimator.applyRootMotion = false;

                if(!Directory.Exists(localOutputFolderPath))
                {
                    Directory.CreateDirectory(localOutputFolderPath);
                }
                AnimatorController createdController = AnimatorController.CreateAnimatorControllerAtPath(localOutputFolderPath + "/" + conversionTarget.name + "_ConversionAnimator.controller");

                rootStateMachine = createdController.layers[0].stateMachine;
                originalAnimator.runtimeAnimatorController = createdController;

                // Gathering state data from our animator.
                stateNames = new string[clips.Count];

                // clearing out invalid characters from state names
                char[] invalidPathChars = Path.GetInvalidPathChars();
                char[] invalidChars = new char[invalidPathChars.Length + 1];
                for(int i = 0; i < invalidPathChars.Length; i++)
                {
                    invalidChars[i] = invalidPathChars[i];
                }
                invalidChars[invalidChars.Length - 1] = '.';
                for(int i = 0; i < clips.Count; i++)
                {
                    System.Text.StringBuilder parsedName = new System.Text.StringBuilder();
                    for(int j = 0; j < clips[i].name.Length; j++)
                    {
                        bool ok = true;
                        for(int z = 0; z < invalidChars.Length; z++)
                        {
                            if(clips[i].name[j] == invalidChars[z])
                            {
                                ok = false;
                                break;
                            }
                        }
                        if(ok == true)
                        {
                            parsedName.Append(clips[i].name[j]);
                        }
                        else
                        {
                            parsedName.Append("_");
                        }
                    }

                    string parsedNameString = parsedName.ToString();
                    var state = rootStateMachine.AddState(parsedNameString);
                    state.motion = clips[i];
                    stateNames[i] = parsedNameString;
                }
            }
            else
            { // native unity animation, look for clips on animator
                originalAnimator = conversionTarget.GetComponent<Animator>();

                didWeCacheEventStatus = true;
                cachedAnimatorApplyRootMotionValue = originalAnimator.applyRootMotion;
                originalAnimator.applyRootMotion = false;

                didWeCacheEventStatus = true;
                cachedFireEventsValue = originalAnimator.fireEvents;
                originalAnimator.fireEvents = false;
                if(originalAnimator == null)
                {
                    RevertAllModifiedValues();
                    Debug.LogError("ERROR: Selected object contains no model with animations or native unity animator.");
                    return false;
                }
                AnimatorController controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(AssetDatabase.GetAssetPath(originalAnimator.runtimeAnimatorController));
                if(controller == null)
                {
                    RevertAllModifiedValues();
                    Debug.LogError("ERROR: Selected object animator component contains no controller");
                    return false;
                }
                rootStateMachine = controller.layers[0].stateMachine;

                stateNames = new string[rootStateMachine.states.Length];
                for(int i = 0; i < rootStateMachine.states.Length; i++)
                {
                    Motion motion = rootStateMachine.states[i].state.motion;
                    if(motion is BlendTree)
                    {
                        RevertAllModifiedValues();
                        Debug.LogError("ERROR: Blend trees not currently supported for Unity native animation conversion. You are using a blend tree in this animator state: " + rootStateMachine.states[i].state.name);
                        return false;
                    }
                    if(motion == null)
                    {
                        RevertAllModifiedValues();
                        Debug.LogError("ERROR: Animator contains states with null clip; Check this state: " + rootStateMachine.states[i].state.name); return false;
                    }
                    clips.Add(motion as AnimationClip);
                    stateNames[i] = rootStateMachine.states[i].state.name;
                }

            }


            // Gathering clip data & keyframe data from our animator.
            clipData = new Dictionary<string, ClipBaseData>();
            totalCellCount = 0;

            for(int z = 0; z < clips.Count; z++)
            {
                clipData.Add(stateNames[z], new ClipBaseData(clips[z].length, clips[z].frameRate, clips[z].isLooping));
                List<float> currentStateKeyFrameTimes = clipData[stateNames[z]].KeyFrameNormalizedTimes;

                EditorCurveBinding[] curveBindings = AnimationUtility.GetCurveBindings(clips[z]);

                for(int i = 0; i < curveBindings.Length; i++)
                {
                    AnimationCurve curve = AnimationUtility.GetEditorCurve(clips[z], curveBindings[i]);
                    for(int j = 0; j < curve.keys.Length; j++)
                    {
                        if(!currentStateKeyFrameTimes.Contains(curve.keys[j].time / clips[z].length))
                        {
                            currentStateKeyFrameTimes.Add(curve.keys[j].time / clips[z].length);
                        }
                    }
                }

                EditorCurveBinding[] objectCurveBindings = AnimationUtility.GetObjectReferenceCurveBindings(clips[z]);
                for(int i = 0; i < objectCurveBindings.Length; i++)
                {
                    ObjectReferenceKeyframe[] keyframes = AnimationUtility.GetObjectReferenceCurve(clips[z], objectCurveBindings[i]);
                    for(int j = 0; j < keyframes.Length; j++)
                    {
                        if(currentStateKeyFrameTimes.Contains(keyframes[j].time / clips[z].length))
                        {
                            currentStateKeyFrameTimes.Add(keyframes[j].time / clips[z].length);
                        }
                    }
                }

                currentStateKeyFrameTimes.Sort();

                //Removing duplicate keyframe times. Partly because of separate curveBindings for obj and generic from Unity, partly because of floating point errors on .Contains comparasions.
                for(int i = 0; i < currentStateKeyFrameTimes.Count - 1; i++)
                {
                    while((i < currentStateKeyFrameTimes.Count - 1) && (Mathf.Abs(currentStateKeyFrameTimes[i] - currentStateKeyFrameTimes[i + 1]) <= 0.001f))
                    {
                        currentStateKeyFrameTimes.RemoveAt(i + 1);
                    }
                }


                float generatedFramerate = clipData[stateNames[z]].FrameRate;
                float keepEveryN = -1.0f;
                if(advancedSettings.TargetFramerate < generatedFramerate && advancedSettings.TargetFramerate > 0)
                {
                    keepEveryN = generatedFramerate / advancedSettings.TargetFramerate;
                    placeholderOutputFPS = advancedSettings.TargetFramerate;
                }
                else
                {
                    placeholderOutputFPS = (int)generatedFramerate;
                }

                float keepFrameCounter = keepEveryN;
                clipData[stateNames[z]].KeyFramesToKeepMask = new List<bool>();
                for(int k = 0; k < currentStateKeyFrameTimes.Count; k++)
                {
                    if(keepFrameCounter >= keepEveryN)
                    {
                        keepFrameCounter -= keepEveryN;
                        clipData[stateNames[z]].KeyFramesToKeepMask.Add(true); // keep
                        clipData[stateNames[z]].KeptFrameCount++;
                    }
                    else
                    {
                        clipData[stateNames[z]].KeyFramesToKeepMask.Add(false); // drop
                        clipData[stateNames[z]].CulledFrameCount++;
                    }
                    keepFrameCounter++;
                }

                totalCellCount += clipData[stateNames[z]].KeptFrameCount;
            }

            //originalAnimator.speed = 0f;

            return true;
        }

        enum MaterialStyle
        {
            flatColor,
            normal,
            cellLit,
            defaultLit,
        }
        void CreateCopyObject(MaterialStyle style)
        {
            createdCopyStatus = true;

            if(targetObjectCopy != null)
            {
                DestroyImmediate(targetObjectCopy);
            }

            targetObjectCopy = GameObject.Instantiate(conversionTarget);
            conversionTarget.SetActive(false);
            targetObjectCopy.SetActive(true);

            MeshRenderer[] meshes = targetObjectCopy.GetComponentsInChildren<MeshRenderer>();
            SkinnedMeshRenderer[] skinnedMeshes = targetObjectCopy.GetComponentsInChildren<SkinnedMeshRenderer>();

            copyAnimator = targetObjectCopy.GetComponent<Animator>();
            copyAnimator.fireEvents = false;
            copyAnimator.applyRootMotion = false;

            if(style == MaterialStyle.defaultLit)
            { // using default materials.
                return;
            }

            for(int i = 0; i < meshes.Length; i++)
            {
                ConvertMaterial(meshes[i], style);
            }
            for(int i = 0; i < skinnedMeshes.Length; i++)
            {
                ConvertMaterial(skinnedMeshes[i], style);
            }

        }


        void ConvertMaterial(Renderer rend, MaterialStyle newStyle)
        {

            Material[] originals = rend.sharedMaterials;
            Material[] newMats = new Material[rend.sharedMaterials.Length];

            for(int i = 0; i < originals.Length; i++)
            {

                Material newMaterial = null;
                MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
                rend.GetPropertyBlock(propertyBlock, i);

                if(newStyle == MaterialStyle.cellLit)
                {
                    newMaterial = advancedSettings.cellLitMaterial;

                    if(originals[i].shader.name == "Standard" || originals[i].shader.name == "SpritesDefault")
                    {
                        Texture tex = originals[i].GetTexture("_MainTex");
                        Color col = originals[i].GetColor("_Color");

                        if(tex) propertyBlock.SetTexture("_MainTex", tex);
                        propertyBlock.SetColor("_Color", col);
                    }
                    else
                    {   // Trying our best to find the property on whatever random shader is being used. 
                        if(originals[i].shader.FindPropertyIndex("_MainTex") > -1)
                        {
                            Texture mainTex = originals[i].GetTexture("_MainTex");
                            if(mainTex) propertyBlock.SetTexture("_MainTex", mainTex);
                        }
                        else
                        {
                            if(advancedSettings.showExtraDebugInformation)
                            {
                                Debug.Log("Couldn't find _MainTex property on " + originals[i].name + " material. Using default ");
                            }
                        }

                        int propIndex = originals[i].shader.FindPropertyIndex("_Color");
                        if(propIndex > -1)
                        {
                            ShaderPropertyType type = originals[i].shader.GetPropertyType(propIndex);
                            if(type == ShaderPropertyType.Color)
                            {
                                Color col = originals[i].GetColor("_Color");
                                propertyBlock.SetColor("_Color", col);
                            }
                            else if(type == ShaderPropertyType.Vector)
                            {
                                Vector4 colAsVec = originals[i].GetVector("_Color");
                                Color col = new Color(colAsVec.x, colAsVec.y, colAsVec.z, colAsVec.w);
                                propertyBlock.SetColor("_Color", col);
                            }
                        }
                        else
                        {
                            if(advancedSettings.showExtraDebugInformation)
                            {
                                Debug.Log("Couldn't find _Color property on " + originals[i].name + " material. Using default ");
                            }
                        }
                    }
                }


                else if(newStyle == MaterialStyle.flatColor)
                {
                    newMaterial = advancedSettings.albedoMaterial;

                    if(originals[i].shader.name == "Standard" || originals[i].shader.name == "SpritesDefault")
                    {
                        Texture tex = originals[i].GetTexture("_MainTex");
                        Color col = originals[i].GetColor("_Color");

                        if(tex) propertyBlock.SetTexture("_MainTex", tex);
                        propertyBlock.SetColor("_Color", col);
                    }
                    else
                    {   // Trying our best to find the property on whatever random shader is being used. 
                        if(originals[i].shader.FindPropertyIndex("_MainTex") > -1)
                        {
                            Texture mainTex = originals[i].GetTexture("_MainTex");
                            if(mainTex) propertyBlock.SetTexture("_MainTex", mainTex);
                        }
                        else
                        {
                            if(advancedSettings.showExtraDebugInformation)
                            {
                                Debug.Log("Couldn't find _MainTex property on " + originals[i].name + " material. Using default ");
                            }
                        }

                        int propIndex = originals[i].shader.FindPropertyIndex("_Color");
                        if(propIndex > -1)
                        {
                            ShaderPropertyType type = originals[i].shader.GetPropertyType(propIndex);
                            if(type == ShaderPropertyType.Color)
                            {
                                Color col = originals[i].GetColor("_Color");
                                propertyBlock.SetColor("_Color", col);
                            }
                            else if(type == ShaderPropertyType.Vector)
                            {
                                Vector4 colAsVec = originals[i].GetVector("_Color");
                                Color col = new Color(colAsVec.x, colAsVec.y, colAsVec.z, colAsVec.w);
                                propertyBlock.SetColor("_Color", col);
                            }
                        }
                        else
                        {
                            if(advancedSettings.showExtraDebugInformation)
                            {
                                Debug.Log("Couldn't find _Color property on " + originals[i].name + " material. Using deafault ");
                            }
                        }
                    }
                }


                else if(newStyle == MaterialStyle.normal)
                {
                    newMaterial = advancedSettings.normalMapMaterial;
                    if(advancedSettings.CellShadeNormalOutput)
                    {
                        newMaterial.EnableKeyword("cellShadeNormal");
                        newMaterial.SetFloat("_CellShadeNormal", 1);
                    }
                    else
                    {
                        newMaterial.DisableKeyword("cellShadeNormal");
                        newMaterial.SetFloat("_CellShadeNormal", 0);
                    }


                    if(originals[i].shader.name == "Standard")
                    {
                        Texture bumpTex = originals[i].GetTexture("_BumpMap");
                        if(bumpTex != null)
                        {
                            propertyBlock.SetTexture("_MainTex", bumpTex);
                        }
                    }
                    else if(originals[i].shader.name == "SpritesDefault")
                    {
                        // no bump map in sprites default, we leave the white texture in     
                    }
                    else
                    {   // Trying our best to find the property on whatever random shader is being used. 
                        if(originals[i].shader.FindPropertyIndex("_BumpMap") > -1)
                        {
                            Texture bmp = originals[i].GetTexture("_BumpMap");
                            if(bmp) propertyBlock.SetTexture("_MainTex", bmp);
                        }
                        else if(originals[i].shader.FindPropertyIndex("_NormalMap") > -1)
                        {
                            Texture bmp = originals[i].GetTexture("_NormalMap");
                            if(bmp) propertyBlock.SetTexture("_MainTex", bmp);
                        }
                        else
                        {
                            if(advancedSettings.showExtraDebugInformation)
                            {
                                Debug.Log("Couldn't find _BumpMap property on " + originals[i].name + " material. Using default ");
                            }
                        }
                    }
                }

                newMats[i] = newMaterial;
                rend.SetPropertyBlock(propertyBlock, i);

            }


            rend.sharedMaterials = newMats;

        }






        // ======================== FILTERS ======================= //

        bool[] outlinePixels;
        void DrawOutlinePass(ref Texture2D target)
        {

            Color32[] pixelData = target.GetPixels32(0);
            outlinePixels = new bool[pixelData.Length];
            int w = target.width; int h = target.height;

            /*Task[] tasks = new Task[h];
            for(int i = 0; i < tasks.Length; i++) {
                tasks[i] = Task.Run(() => OutlineCheckLinePass(pixelData, i, w, h));
            }
            Task.WaitAll();
            */

            for(int i = 0; i < h; i++)
            {
                OutlineCheckLinePass(pixelData, i, w, h);
            }

            int count = 0;
            for(int i = 0; i < outlinePixels.Length; i++)
            {
                if(outlinePixels[i] == true)
                {
                    pixelData[i] = advancedSettings.OutlineColor;
                    count++;
                }
            }

            target.SetPixels32(pixelData);
            target.Apply();
        }
        void DrawOutlineNormalPass(Texture2D target)
        { // Setting pixels ignoreMap values for the normal map.
            Color32[] pixelData = target.GetPixels32(0);
            Color32 ignorableColor = new Color32();
            ignorableColor.r = 255; ignorableColor.g = 255; ignorableColor.b = 255;
            ignorableColor.a = 0;

            for(int i = 0; i < outlinePixels.Length; i++)
            {
                if(outlinePixels[i] == true)
                {
                    pixelData[i] = ignorableColor;
                }
            }
            target.SetPixels32(pixelData);
            target.Apply();
        }
        void OutlineCheckLinePass(Color32[] pixelData, int i, int w, int h)
        {
            Color32 nullCol = new Color32();
            nullCol.r = 0; nullCol.g = 0; nullCol.b = 0; nullCol.a = 0;

            for(int j = 0; j < w; j++)
            {

                Color32 col = pixelData[BoneToPixUtilities.ToFlat(i, j, w)];
                if(col.a > Mathf.Epsilon)
                {
                    continue;
                }
                // 0 1 2 
                Color32[] surroundingCol = new Color32[8];  // 3 X 4
                                                            // 5 6 7
                /*
                if (i > 0 && j > 0) {
                    surroundingCol[0] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j - 1, w)];
                }
                else { surroundingCol[0] = nullCol; }
                */

                if(j > 0)
                {
                    surroundingCol[1] = pixelData[BoneToPixUtilities.ToFlat(i, j - 1, w)];
                }
                else { surroundingCol[1] = nullCol; }

                /*
                if (i < (h-1) && j > 0) {
                    surroundingCol[2] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j - 1, w)];
                }
                else { surroundingCol[2] = nullCol; }
                */

                if(i > 0)
                {
                    surroundingCol[3] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j, w)];
                }
                else { surroundingCol[3] = nullCol; }

                if(i < (h - 1))
                {
                    surroundingCol[4] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j, w)];
                }
                else { surroundingCol[4] = nullCol; }

                /*
                if (i > 0 && j < (w-1)) {
                    surroundingCol[5] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j + 1, w)];
                }
                else { surroundingCol[5] = nullCol; }
                */

                if(j < (w - 1))
                {
                    surroundingCol[6] = pixelData[BoneToPixUtilities.ToFlat(i, j + 1, w)];
                }
                else { surroundingCol[6] = nullCol; }

                /*
                if (i < (h-1) && j < (w-1)) {
                    surroundingCol[7] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j + 1, w)];
                }
                else { surroundingCol[7] = nullCol; }
                */

                for(int z = 0; z < surroundingCol.Length; z++)
                {
                    if(surroundingCol[z].a > Mathf.Epsilon)
                    {
                        outlinePixels[BoneToPixUtilities.ToFlat(i, j, w)] = true;
                        break;
                    }
                }
            }

        }

        void CoolFilterPass(ref Texture2D target)
        {
            Color32[] pixelData = target.GetPixels32(0);
            int w = target.width; int h = target.height;

            // doing even columns followed by odd columns to avoid race conditions on writing/reading data; Since we only read from neighbours there won't be any race conditions happening.
            Task[] tasks = new Task[(h - 1) / 2];
            int taskIndex = 0;
            int i = 1;
            while(i < (h - 1))
            {
                int copyI = i;// stuff inside the lambda is already happening inside the thread, so we need to copy our I value to make sure it doesn't get modified before thread actually starts.
                tasks[taskIndex] = Task.Run(() => ColPass(pixelData, copyI, w, h));
                taskIndex++;
                i += 2;
            }
            Task.WaitAll(tasks);

            taskIndex = 0;
            i = 2;
            while(i < (h - 1))
            {
                int copyI = i; // stuff inside the lambda is already happening inside the thread, so we need to copy our I value to make sure it doesn't get modified before thread actually starts.
                tasks[taskIndex] = Task.Run(() => ColPass(pixelData, copyI, w, h));
                taskIndex++;
                i += 2;
            }
            Task.WaitAll(tasks);

            target.SetPixels32(pixelData);
            target.Apply();
        }

        void ColPass(Color32[] pixelData, int i, int w, int h)
        {
            for(int j = 1; j < (w - 1); j++)
            {

                Color32 col = pixelData[BoneToPixUtilities.ToFlat(i, j, w)];
                // 0 1 2 
                float[] colorDifs = new float[8]; // 3 X 4
                                                  // 5 6 7
                colorDifs[0] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i - 1, j - 1, w)], col);
                colorDifs[1] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i, j - 1, w)], col);
                colorDifs[2] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i + 1, j - 1, w)], col);

                colorDifs[3] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i - 1, j, w)], col);
                colorDifs[4] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i + 1, j, w)], col);

                colorDifs[5] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i - 1, j + 1, w)], col);
                colorDifs[6] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i, j + 1, w)], col);
                colorDifs[7] = PalletteUtilities.ColorDiff(pixelData[BoneToPixUtilities.ToFlat(i + 1, j + 1, w)], col);

                bool ok = false;
                for(int z = 0; z < colorDifs.Length; z++)
                {
                    if(colorDifs[z] <= advancedSettings.filterAbsColorThreshold)
                    {
                        ok = true;
                        break;
                    }
                }

                if(ok == false)
                {
                    float min = colorDifs[0];
                    int minIndex = 0;
                    for(int z = 1; z < colorDifs.Length; z++)
                    {
                        if(colorDifs[z] <= min)
                        {
                            min = colorDifs[z];
                            minIndex = z;
                        }
                    }
                    if(minIndex == 0) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j - 1, w)]; }
                    else
                    if(minIndex == 1) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i, j - 1, w)]; }
                    else
                    if(minIndex == 2) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j - 1, w)]; }
                    else
                    if(minIndex == 3) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j, w)]; }
                    else
                    if(minIndex == 4) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j, w)]; }
                    else
                    if(minIndex == 5) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i - 1, j + 1, w)]; }
                    else
                    if(minIndex == 6) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i, j + 1, w)]; }
                    else
                    if(minIndex == 7) { pixelData[BoneToPixUtilities.ToFlat(i, j, w)] = pixelData[BoneToPixUtilities.ToFlat(i + 1, j + 1, w)]; }
                }

            }
        }



        // ================================== UNITY SHENANIGANS ================================ // 


        void RevertAllModifiedValues()
        {
            if(createdCopyStatus)
            {
                DestroyCopies();
            }
            if(didWeCacheEventStatus)
            {
                RevertFireEvents();
            }
            if(didWeCacheAnimatorApplyRootMotion)
            {
                RevertAnimatorApplyRootMotion();
            }
            if(cachedSkinnedMeshStatus)
            {
                RevertSkinnedMeshStatus();
            }
            if(cachedRenderPipeline != null)
            {
                GraphicsSettings.renderPipelineAsset = cachedRenderPipeline;
            }
        }


        void DestroyCopies()
        {
            DestroyImmediate(targetObjectCopy, false);
            conversionTarget.SetActive(true);
            createdCopyStatus = false;
        }

        void RevertFireEvents()
        {
            originalAnimator.fireEvents = cachedFireEventsValue;
            didWeCacheEventStatus = false;
        }

        void RevertAnimatorApplyRootMotion()
        {
            originalAnimator.applyRootMotion = cachedAnimatorApplyRootMotionValue;
            didWeCacheAnimatorApplyRootMotion = false;
        }

        void RevertSkinnedMeshStatus()
        {
            int revertIndex = 0;
            for(int i = 0; i < renderers.Length; i++)
            {
                if(renderers[i] is SkinnedMeshRenderer)
                {
                    (renderers[i] as SkinnedMeshRenderer).updateWhenOffscreen = cachedSkinnedMeshUpdateOffscreenValues[revertIndex]; // reverting updateWhenOffscreen.
                    revertIndex++;
                }
            }
            cachedSkinnedMeshStatus = false;
        }


        void CreatePreviewAnimatorAndSprite(string basePath, string name, List<AnimationClip> clips, Texture2D normal = null)
        {
            string animationPath = basePath + "/Animations/Animator.controller";
            AnimatorController controller = CreateAnimator(animationPath, clips);

            Material mat = null;
            if(currentStyle == ConversionStyle.albedoAndNormal)
            {
                mat = CreateAndSaveMaterial(basePath, name, normal, false);
            }
            if(advancedSettings.AlsoCreateURPMaterial)
            {
                CreateAndSaveMaterial(basePath, name, normal, true); // URP version doesn't get assigned, we're just creating it and saving it in the assets folder. 
            }

            Object[] texAssets = AssetDatabase.LoadAllAssetsAtPath(localAlbedoOutputFilePath);
            for(int i = 0; i < texAssets.Length; i++)
            {
                if(texAssets[i] is Sprite)
                {
                    CreateTestObject((Sprite)texAssets[i], controller, mat);
                    break;
                }
            }
        }

        Material CreateAndSaveMaterial(string basePath, string name, Texture2D normal, bool isURPversion)
        {
            Material mat;
            if(isURPversion)
            {
                mat = new Material(advancedSettings.dynamicLitShader_URP);
            }
            else
            {
                mat = new Material(advancedSettings.dynamicLitShader);
            }

            mat.SetTexture("_Normal", normal);
            mat.SetTexture("_CellLookup", advancedSettings.CellShadedLookup);

            float intensityValue = isURPversion ? advancedSettings.PreviewMaterialHighlightsIntensity_URP : advancedSettings.PreviewMaterialHighlightsIntensity_BuiltIn;
            mat.SetFloat("_Intensity", intensityValue);
            float intensityValue2 = isURPversion ? advancedSettings.PreviewMaterialUniversalIntensity_URP : advancedSettings.PreviewMaterialUniversalIntensity_BuiltIn;
            mat.SetFloat("_Intensity2", intensityValue2);

            mat.SetFloat("_AssetPixelWorldSize", 1f / advancedSettings.SpritePPU);



            string ditheringPropertyName = isURPversion ? "_DITHERING" : "_UseDithering";
            if(advancedSettings.UseDithering)
            {
                mat.EnableKeyword("useDithering");
                mat.SetFloat(ditheringPropertyName, 1);
            }
            else
            {
                mat.DisableKeyword("useDithering");
                mat.SetFloat(ditheringPropertyName, 0);
            }

            string ignoreMapPropertyName = isURPversion ? "_IGNORE_MAP" : "_IgnoreMap";
            if(!advancedSettings.UseLightingOnOutline)
            {
                mat.EnableKeyword("ignoreMap");
                mat.SetFloat(ignoreMapPropertyName, 1);
            }
            else
            {
                mat.DisableKeyword("ignoreMap");
                mat.SetFloat(ignoreMapPropertyName, 0);
            }

            if(advancedSettings.ForceRenderQueueValueOnPreviewMaterials)
            {
                mat.renderQueue = advancedSettings.ForcedRenderQueueValue;
            }

            mat.SetTexture("_DitheringLookup", advancedSettings.DitheringLookupTexture);
            mat.SetFloat("_DitherPower", advancedSettings.DitheringPower);

            if(isURPversion)
            {
                name += "_URP";
            }

            name += ".mat";

            string matPath = basePath + "/" + name;
            var old = AssetDatabase.LoadAssetAtPath(matPath, typeof(Material));
            AssetDatabase.DeleteAsset(matPath);
            AssetDatabase.Refresh();
            AssetDatabase.CreateAsset(mat, matPath);

            return mat;
        }

        public AnimatorController CreateAnimator(string path, List<AnimationClip> clips)
        {
            var old = AssetDatabase.LoadAssetAtPath(path, typeof(AnimatorController));
            if(old) { AssetDatabase.DeleteAsset(path); AssetDatabase.Refresh(); }
            AnimatorController controller = AnimatorController.CreateAnimatorControllerAtPath(path);
            AnimatorStateMachine rootStateMachine = controller.layers[0].stateMachine;

            for(int i = 0; i < clips.Count; i++)
            {
                AnimatorState state = rootStateMachine.AddState(clips[i].name);
                state.motion = clips[i];
            }

            return controller;
        }

        public void CreateTestObject(Sprite mainSprite, AnimatorController controller, Material mat)
        {
            GameObject previewObject = new GameObject(mainSprite.name.Substring(0, mainSprite.name.Length - 2) + "_Preview");
            previewObject.transform.position = Vector3.zero;

            SpriteRenderer spriteRend = previewObject.AddComponent<SpriteRenderer>();
            if(mat != null)
            { // else we leave it as Sprites-Default
                spriteRend.material = mat;
            }

            spriteRend.sprite = mainSprite;

            Animator anim = previewObject.AddComponent<Animator>();
            anim.runtimeAnimatorController = controller;
        }


    }


}