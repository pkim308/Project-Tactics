using UnityEngine;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using System;
using System.IO;


namespace WhiteLimboGames
{
    [ExecuteAlways]
    public class PalletteEditor : EditorWindow
    {

        const float COLOR_ELEMENT_WIDTH = 135.0f;
        const float COLOR_COLUMN_WIDTH = COLOR_ELEMENT_WIDTH + 10.0f;
        public const string RESOURCES_SETTINGS_NAME = "PalletteEditorSettings";
        const float COLOR_REMOVE_COLUMN_WIDTH = 110.0f;
        const float COLOR_TOTAL_WIDTH = COLOR_COLUMN_WIDTH + COLOR_REMOVE_COLUMN_WIDTH;

        const int COLORS_COLUMN_INDEX = 0;
        const int COLORS_REMOVE_BUTTONS_COLUMN_INDEX = COLORS_COLUMN_INDEX + 1;

        const float SPRITE_TOOLBAR_HEIGHT = 50.0f;

        const float SPRITE_INDEX_BUTTON_WIDTH = 25.0f;
        const float SPRITE_INDEX_BUTTON_HEIGHT = 20.0f;
        const float SPRITE_INT_FIELD_WIDTH = 50.0f;
        const float SPRITE_INT_FIELD_HEIGHT = 20.0f;

        const float SPRITE_TOOLBAR_APROX_WIDTH = 650.0f;


        static TextureFormat[] uncompressedTextureFormats = {
        TextureFormat.Alpha8        ,
        TextureFormat.ARGB4444      ,
        TextureFormat.RGB24         ,
        TextureFormat.RGBA32        ,
        TextureFormat.ARGB32        ,
        TextureFormat.RGB565        ,
        TextureFormat.R16           ,
        TextureFormat.RGBA4444      ,
        TextureFormat.BGRA32        ,
        TextureFormat.RHalf         ,
        TextureFormat.RGHalf        ,
        TextureFormat.RGBAHalf      ,
        TextureFormat.RFloat        ,
        TextureFormat.RGFloat       ,
        TextureFormat.RGBAFloat     ,
        TextureFormat.YUY2          ,
        TextureFormat.RGB9e5Float   ,
        TextureFormat.R8            ,
        TextureFormat.RGB48         ,
        TextureFormat.RGBA64        ,
        TextureFormat.DXT5          ,
        };


        Rect fullTextureRect;
        Color spriteToolbarBackgroundColor;

        /// Color stuff

        MultiColumnHeaderState multiColumnHeaderState;
        MultiColumnHeader multiColumnHeader;
        MultiColumnHeaderState.Column[] columns;

        Color[] currentPalette = { Color.green, Color.blue, Color.yellow };
        Vector2 scrollPosition;


        Vector2Int renderTextureDimesnions;

        /// Image stuff

        public enum ImageMode
        {
            Texture2D = 1,
            Sprite = 2,
        }
        ImageMode imgMode;

        //

        string sourceAssetPath;

        int spriteIndex = 0;
        int spriteNr;
        Sprite[] sprites;
        Rect[] normalizedSpriteRects;

        bool animate;
        float fps = 16.0f;
        float frameTimer = 0.0f;
        float frameDuration;

        //
        Texture2D displayTexture;
        float displayTextureAspectRatio;


        //
        static RenderTexture s_spriteDisplayRenderTex;
        PalletteEditorSettings settings;
        Material blitMaterial;

        Texture2D ignoreMap;


        bool isInitialized;

        public static PalletteEditor Open(string sourcePath, Texture2D startingPalette, Texture2D ignoreMap, ImageMode mode, int framerate = -1)
        {
            if(startingPalette == null)
            {
                PalletteEditorSettings sett = Resources.Load(RESOURCES_SETTINGS_NAME) as PalletteEditorSettings;
                if(sett.useArrayForDefaultPallette || sett.defaultStartingPalletteTexture == null)
                {
                    return Open(sourcePath, sett.defaultStartingPalletteArray, ignoreMap, mode, framerate);
                }
                else
                {
                    startingPalette = sett.defaultStartingPalletteTexture;
                }
            }

            PalletteUtilities.ValidatePaletteSettingsAndNotifyUser(startingPalette);
            Color[] startingColors = PalletteUtilities.GetColorArrayFromPalletteTexture(startingPalette);
            return Open(sourcePath, startingColors, ignoreMap, mode, framerate);
        }

        public static PalletteEditor Open(string sourcePath, Color[] startingPalette, Texture2D ignoreMap, ImageMode mode, int framerate = -1)
        {
            Texture2D sourceTex = AssetDatabase.LoadAssetAtPath<Texture2D>(sourcePath);

            PalletteEditor window = EditorWindow.GetWindow<PalletteEditor>(
                title: "Pallette Editor",
                focus: true
            );

            window.minSize = new Vector2(x: 650.0f, y: 300.0f);

            window.Show();

            window.currentPalette = startingPalette;
            window.imgMode = mode;
            window.sourceAssetPath = sourcePath;
            window.ignoreMap = ignoreMap;
            if(mode == ImageMode.Texture2D)
            {
                if(Array.Exists(uncompressedTextureFormats, element => element == sourceTex.format) == false) // We won't be able to save the compressed file types back to disk later on. 
                {
                    Debug.LogError("Compressed texture formats are not currently supported for the pallette editor! Try changing your texture to an uncompressed format!");
                    window.displayTexture = null;
                    return null;
                }
                else
                {
                    window.displayTexture = sourceTex;
                    window.renderTextureDimesnions = new Vector2Int(sourceTex.width, sourceTex.height);
                }
            }
            else // ImageMode.Sprite
            {
                UnityEngine.Object[] texAssets = AssetDatabase.LoadAllAssetsAtPath(sourcePath);

                Texture2D spritesheet = null;
                for(int i = 0; i < texAssets.Length; i++)
                {
                    if(texAssets[i] is Texture2D)
                    {
                        spritesheet = texAssets[i] as Texture2D;
                        break;
                    }
                }
                window.renderTextureDimesnions = new Vector2Int(spritesheet.width, spritesheet.height);
                int spriteSheetWidth = spritesheet.width;
                int spriteSheetHeight = spritesheet.height;

                if(Array.Exists(uncompressedTextureFormats, element => element == spritesheet.format) == false) // We won't be able to save the compressed file types back to disk later on.
                {
                    Debug.LogError("Compressed texture formats are not currently supported! Try changing your texture to an uncompressed format!");
                    window.sprites = null;
                    return null;
                }

                window.spriteNr = texAssets.Length - 1;
                if(window.spriteNr == 0)
                {
                    Debug.LogError("Your selected texture is NOT a spritesheet. Try again in texture mode.");
                    return null;
                }
                window.sprites = new Sprite[window.spriteNr];
                window.normalizedSpriteRects = new Rect[window.spriteNr];
                window.animate = true;
                int spriteIndex = 0;
                for(int i = 0; i < texAssets.Length; i++) 
                {
                    if(texAssets[i].GetType() != typeof(Sprite))
                    {
                        continue;
                    }
                    window.sprites[spriteIndex] = texAssets[i] as Sprite;
                    window.normalizedSpriteRects[spriteIndex] = new Rect(
                        window.sprites[spriteIndex].textureRect.x / spriteSheetWidth,
                        window.sprites[spriteIndex].textureRect.y / spriteSheetHeight,
                        window.sprites[spriteIndex].textureRect.width / spriteSheetWidth,
                        window.sprites[spriteIndex].textureRect.height / spriteSheetHeight);
                    spriteIndex++;
                }
                window.fps = framerate;
            }

            window.isInitialized = false;

            return window;
        }


        void Initialize()
        {
            fullTextureRect = new Rect(0, 0, 1.0f, 1.0f);
            spriteToolbarBackgroundColor = new Color(0.05f, 0.05f, 0.05f, 1.0f);

            columns = new MultiColumnHeaderState.Column[]
            {
                new MultiColumnHeaderState.Column() // Colors
                {
                    allowToggleVisibility = false,
                    autoResize = true,
                    minWidth = COLOR_COLUMN_WIDTH,
                    maxWidth = COLOR_COLUMN_WIDTH,
                    canSort = false,
                    sortingArrowAlignment = TextAlignment.Right,
                    headerContent = new GUIContent("Pallette Colors"),
                    headerTextAlignment = TextAlignment.Center,
                },
                new MultiColumnHeaderState.Column() // Color remove buttons
                {
                    allowToggleVisibility = false,
                    autoResize = true,
                    minWidth = COLOR_REMOVE_COLUMN_WIDTH,
                    maxWidth = COLOR_REMOVE_COLUMN_WIDTH,
                    canSort = false,
                    sortingArrowAlignment = TextAlignment.Center,
                    headerContent = new GUIContent("Remove colors"),
                    headerTextAlignment = TextAlignment.Center,
                }
            };

            multiColumnHeaderState = new MultiColumnHeaderState(columns: columns);
            multiColumnHeader = new MultiColumnHeader(state: multiColumnHeaderState);
            // When we change visibility of the column we resize columns to fit in the window.
            multiColumnHeader.visibleColumnsChanged += (multiColumnHeader) => multiColumnHeader.ResizeToFit();
            // Initial resizing of the content.
            multiColumnHeader.ResizeToFit();

            ///

            if(s_spriteDisplayRenderTex != null && s_spriteDisplayRenderTex.IsCreated())
            {
                s_spriteDisplayRenderTex.Release();
            }

            if(renderTextureDimesnions.x == 0 || renderTextureDimesnions.y == 0)
            {
                Close();
                return;
            }
            s_spriteDisplayRenderTex = new RenderTexture(renderTextureDimesnions.x, renderTextureDimesnions.y, 1);
            s_spriteDisplayRenderTex.filterMode = FilterMode.Point;
            s_spriteDisplayRenderTex.Create();

            isInitialized = true;
        }

        static void CloseWindows(PlayModeStateChange state)
        {
            if(state == PlayModeStateChange.ExitingEditMode)
            {
                EditorApplication.playModeStateChanged -= CloseWindows;
                GetWindow<PalletteEditor>().Close();
            }
        }

        private void Update()
        {
            if(animate == true)
            {
                fps = Mathf.Clamp(fps, 0.1f, 100.0f);
                frameDuration = (1.0f / fps) * 2.0f;
                frameTimer += Time.unscaledDeltaTime;
                if(frameTimer > frameDuration) // Specifically not making this a while in order to not skip frames. 
                {
                    frameTimer -= frameDuration;
                    spriteIndex++;
                    if(spriteIndex >= spriteNr)
                    {
                        spriteIndex = 0;
                    }
                    Repaint();
                }
            }
        }

        private void OnGUI()
        {

            if(isInitialized == false)
            {
                Initialize();
            }

            /// ===== Window ===== /// ============================================================================================

            GUILayout.FlexibleSpace();
            Rect windowRect = GUILayoutUtility.GetLastRect();
            windowRect.width = this.position.width;
            windowRect.height = this.position.height;

            if((imgMode == ImageMode.Texture2D && displayTexture == null) ||
               (imgMode == ImageMode.Sprite && sprites == null))
            {
                GUILayout.Label("Compressed texture formats are not currently supported! Try changing your texture to an uncompressed format!");
                return;
            }


            /// ===== Pallette ====== /// ============================================================================================

            float columnHeight = EditorGUIUtility.singleLineHeight;

            Rect columnRectPrototype = new Rect(source: windowRect)
            {
                height = columnHeight,
            };
            this.multiColumnHeader.OnGUI(rect: columnRectPrototype, xScroll: 0.0f);


            Rect cellSize = this.multiColumnHeader.GetCellRect(visibleColumnIndex: 0, this.multiColumnHeader.GetColumnRect(visibleColumnIndex: 0));
            float totalLength = cellSize.height * (currentPalette.Length + 1 + 1.5f);

            Rect viewWindowRect = new Rect(0.0f, 0.0f, COLOR_TOTAL_WIDTH, windowRect.height);
            Rect scrollColumnRect = new Rect(0, 0, 100.0f, totalLength);
            this.scrollPosition = GUI.BeginScrollView(
                position: viewWindowRect,
                scrollPosition: this.scrollPosition,
                viewRect: scrollColumnRect,
                alwaysShowHorizontal: false,
                alwaysShowVertical: false
            );

            for(int i = 0; i < this.currentPalette.Length; i++)
            {

                // Pallette colors
                Rect rowRect = new Rect(source: columnRectPrototype);

                rowRect.y += columnHeight * (i + 1);

                int visibleColorColumnIndex = this.multiColumnHeader.GetVisibleColumnIndex(COLORS_COLUMN_INDEX);
                Rect colorColumnRect = this.multiColumnHeader.GetColumnRect(visibleColumnIndex: COLORS_COLUMN_INDEX);

                colorColumnRect.y = rowRect.y;
                this.currentPalette[i] = EditorGUI.ColorField(
                    position: this.multiColumnHeader.GetCellRect(visibleColumnIndex: visibleColorColumnIndex, colorColumnRect),
                    label: GUIContent.none,
                    value: this.currentPalette[i],
                    showEyedropper: true,
                    showAlpha: false,
                    hdr: false
                    );


                // Remove color buttons
                int visibleRemoveColumnIndex = this.multiColumnHeader.GetVisibleColumnIndex(COLORS_REMOVE_BUTTONS_COLUMN_INDEX);
                Rect removeColumnRect = this.multiColumnHeader.GetColumnRect(visibleColumnIndex: COLORS_REMOVE_BUTTONS_COLUMN_INDEX);

                removeColumnRect.y = rowRect.y;
                if(GUI.Button(this.multiColumnHeader.GetCellRect(visibleColumnIndex: visibleRemoveColumnIndex, removeColumnRect), "Remove"))
                {
                    RemoveAt(ref currentPalette, i); // Remove color at index i;
                }

            }

            // Add color button
            int addColorButtonCellIndex = this.currentPalette.Length + 1;
            int addColorVisibleColumnIndex = this.multiColumnHeader.GetVisibleColumnIndex(COLORS_COLUMN_INDEX);
            Rect addColorColumnRect = this.multiColumnHeader.GetColumnRect(visibleColumnIndex: COLORS_COLUMN_INDEX);

            Rect addColorRowRect = new Rect(source: columnRectPrototype);
            addColorRowRect.y += columnHeight * (addColorButtonCellIndex + 0.5f);
            addColorColumnRect.y = addColorRowRect.y;
            if(GUI.Button(this.multiColumnHeader.GetCellRect(visibleColumnIndex: addColorVisibleColumnIndex, addColorColumnRect), "Add Color"))
            {
                if(currentPalette.Length == 0)
                {
                    currentPalette = new Color[1];
                }
                else
                {
                    DuplicateAtEnd(ref currentPalette);
                }
                scrollPosition.y = scrollColumnRect.height;
            }



            GUI.EndScrollView(handleScrollWheel: true);


            Rect availableSpace = new Rect();
            availableSpace.x = windowRect.x + COLOR_TOTAL_WIDTH;
            availableSpace.y = windowRect.y + cellSize.height;
            availableSpace.width = windowRect.width - COLOR_TOTAL_WIDTH;
            availableSpace.height = windowRect.height - cellSize.height - SPRITE_TOOLBAR_HEIGHT;

            /// Sprite control toolbar
            Rect toolBarSpace = new Rect();
            toolBarSpace.x = availableSpace.x;
            toolBarSpace.y = availableSpace.y + availableSpace.height;
            toolBarSpace.width = availableSpace.width;
            toolBarSpace.height = SPRITE_TOOLBAR_HEIGHT;
            EditorGUI.DrawRect(toolBarSpace, spriteToolbarBackgroundColor);

            Rect spriteIndexButtonRect1 = toolBarSpace;
            spriteIndexButtonRect1.x = spriteIndexButtonRect1.x + (toolBarSpace.width - SPRITE_TOOLBAR_APROX_WIDTH) / 2;
            spriteIndexButtonRect1.width = SPRITE_INDEX_BUTTON_WIDTH;
            spriteIndexButtonRect1.height = SPRITE_INDEX_BUTTON_HEIGHT;
            spriteIndexButtonRect1.y = toolBarSpace.y + (toolBarSpace.height - spriteIndexButtonRect1.height) - 5.5f;

            Rect spriteTextLabelRect = toolBarSpace;
            spriteTextLabelRect.x = spriteTextLabelRect.x + (toolBarSpace.width - SPRITE_TOOLBAR_APROX_WIDTH) / 2 - 5.0f;
            spriteTextLabelRect.width = SPRITE_INDEX_BUTTON_WIDTH * 2 + SPRITE_INT_FIELD_WIDTH + 50.0f;
            spriteTextLabelRect.height = SPRITE_INDEX_BUTTON_HEIGHT + 5.0f;
            spriteTextLabelRect.y = spriteTextLabelRect.y;

            Rect spriteIndexField = spriteIndexButtonRect1;
            spriteIndexField.x = spriteIndexField.x + 30.0f;
            spriteIndexField.width = SPRITE_INT_FIELD_WIDTH;
            spriteIndexField.height = SPRITE_INT_FIELD_HEIGHT;
            spriteIndexField.y = toolBarSpace.y + (toolBarSpace.height - spriteIndexField.height) - 5.5f;

            Rect spriteIndexButtonRect2 = toolBarSpace;
            spriteIndexButtonRect2.x = spriteIndexField.x + spriteIndexField.width + 5.0f;
            spriteIndexButtonRect2.width = SPRITE_INDEX_BUTTON_WIDTH;
            spriteIndexButtonRect2.height = SPRITE_INDEX_BUTTON_HEIGHT;
            spriteIndexButtonRect2.y = toolBarSpace.y + (toolBarSpace.height - spriteIndexButtonRect2.height) - 5.5f;

            Rect animateToggleRect = spriteIndexField;
            animateToggleRect.x = animateToggleRect.x + 100.0f;
            animateToggleRect.y = animateToggleRect.y - 10.0f;
            animateToggleRect.width = 75.0f;

            Rect fpsFieldRect = animateToggleRect;
            fpsFieldRect.x = fpsFieldRect.x + 100.0f;
            fpsFieldRect.y = spriteIndexField.y;
            fpsFieldRect.width = 50.0f;

            Rect fpsLabelRect = fpsFieldRect;
            fpsLabelRect.y = spriteIndexField.y - 22.5f;

            Rect applyButtonRect1 = animateToggleRect;
            applyButtonRect1.x = applyButtonRect1.x + 180.0f;
            applyButtonRect1.width = 140.0f;
            applyButtonRect1.y = animateToggleRect.y;

            Rect applyButtonRect2 = applyButtonRect1;
            applyButtonRect2.x = applyButtonRect2.x + 150.0f;
            applyButtonRect2.width = 200.0f;

            /// ===== Sprite ====== /// ============================================================================================

            GL.sRGBWrite = true;
            if(imgMode == ImageMode.Texture2D)
            {
                RefreshMaterialProperties();
                DrawTexture(displayTexture, availableSpace, s_spriteDisplayRenderTex, blitMaterial, fullTextureRect);
            }
            else if(imgMode == ImageMode.Sprite)
            {
                /// Sprite Controls in toolbar
                GUI.Label(spriteTextLabelRect, "Sprite / Frame index:");

                if(GUI.Button(spriteIndexButtonRect1, "<"))
                {
                    spriteIndex--;
                }
                spriteIndex = EditorGUI.IntField(spriteIndexField, spriteIndex);
                if(GUI.Button(spriteIndexButtonRect2, ">"))
                {
                    spriteIndex++;
                }

                animate = GUI.Toggle(animateToggleRect, animate, "Animate");
                if(animate)
                {
                    fps = EditorGUI.FloatField(fpsFieldRect, fps);
                    GUI.Label(fpsLabelRect, "FPS:");
                }

                /// Rendering the sprite
                spriteIndex = Mathf.Clamp(spriteIndex, 0, spriteNr - 1);
                Texture2D spriteTexture = sprites[spriteIndex].texture;
                Rect normalizedSpriteRect = normalizedSpriteRects[spriteIndex];

                RefreshMaterialProperties();
                DrawTexture(spriteTexture, availableSpace, s_spriteDisplayRenderTex, blitMaterial, normalizedSpriteRect);
            }


            if(GUI.Button(applyButtonRect1, "Save and overwrite"))
            {
                if(imgMode == ImageMode.Texture2D)
                {
                    OverWriteToDisk(ref s_spriteDisplayRenderTex, ref displayTexture);
                }
                else // Sprite
                {
                    Texture2D spriteSheetTex = sprites[spriteIndex].texture;
                    OverWriteToDisk(ref s_spriteDisplayRenderTex, ref spriteSheetTex);
                }
            }

            if(GUI.Button(applyButtonRect2, "Save Changes to new texture"))
            {
                string path = BoneToPixUtilities.GetSavePathNoOverwrite(sourceAssetPath);
                SaveToDisk(path);
            }


        }


        void SaveToDisk(string path)
        {
            Texture2D tex;
            if(imgMode == ImageMode.Texture2D)
            {
                tex = ToTexture2D(ref s_spriteDisplayRenderTex, displayTexture);
            }
            else // Sprite
            {
                tex = ToTexture2D(ref s_spriteDisplayRenderTex, sprites[spriteIndex].texture);
            }

            AssetDatabase.DeleteAsset(path);
            AssetDatabase.Refresh();

            Byte[] encodedTex = tex.EncodeToPNG();
            File.WriteAllBytes(path, encodedTex);
            AssetDatabase.Refresh();
            Debug.Log("Saved to: " + path);
        }

        // Doing a ReadPixels directly on the original overwrites it to disk as well.
        Texture2D ToTexture2D(ref RenderTexture rTex, Texture2D tex)
        {
            Texture2D newTex = new Texture2D(tex.width, tex.height, tex.format, false);
            Color[] originalColors = tex.GetPixels(0);
            newTex.SetPixels(originalColors);

            RenderTexture old_rt = RenderTexture.active;

            //Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.RGB24, false);
            RenderTexture.active = rTex; // ReadPixels looks at the active RenderTexture.
            newTex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
            newTex.Apply();

            RenderTexture.active = old_rt;
            return newTex;
        }

        void OverWriteToDisk(ref RenderTexture rTex, ref Texture2D tex)
        {
            RenderTexture old_rt = RenderTexture.active;

            //Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.RGB24, false);
            RenderTexture.active = rTex; // ReadPixels looks at the active RenderTexture.
            tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
            tex.Apply();

            RenderTexture.active = old_rt;
        }


        void RefreshMaterialProperties()
        {
            settings = Resources.Load(RESOURCES_SETTINGS_NAME) as PalletteEditorSettings;
            blitMaterial = new Material(settings.colorReplacementSpriteShader);
            Texture2D generatedPalletteTexture = DrawPallette(currentPalette);
            blitMaterial.SetTexture("_Pallette", generatedPalletteTexture);
            if(ignoreMap != null)
            {
                blitMaterial.SetFloat("_UseIgnoreMap", 1);
                blitMaterial.EnableKeyword("useIgnoreMap");

                blitMaterial.SetTexture("_IgnoreMap", ignoreMap);
            }
            else
            {
                blitMaterial.SetFloat("_UseIgnoreMap", 0);
                blitMaterial.DisableKeyword("_UseIgnoreMap");
            }
        }


        public void DrawTexture(Texture2D texture, Rect availableSpace, RenderTexture rTex, Material blMat, Rect spriteRect) 
        {
            displayTextureAspectRatio = (float)texture.width / (float)texture.height;

            Rect textureRect = GetImageFit(availableSpace, displayTextureAspectRatio);

            Graphics.Blit(texture, rTex, blMat);
            RenderTexture.active = null;
            GUI.DrawTextureWithTexCoords(textureRect, rTex, spriteRect);
        }


        public static Rect GetImageFit(Rect availableSpace, float displayTextureAspectRatio)
        {
            float outputWidth = availableSpace.height * displayTextureAspectRatio;
            float outputHeight = availableSpace.height;
            if(outputWidth > availableSpace.width)
            {
                float reduceRatio = (outputWidth / availableSpace.width);
                outputHeight = outputHeight / reduceRatio;
                outputWidth = outputWidth / reduceRatio;
            }

            float freeSpaceDown = availableSpace.height - outputHeight;
            float freeSpaceRight = availableSpace.width - outputWidth;

            return new Rect(availableSpace.x + freeSpaceRight / 2, availableSpace.y + freeSpaceDown / 2, outputWidth, outputHeight);
        }

        public static void RemoveAt<T>(ref T[] arr, int index)
        {
            for(int a = index; a < arr.Length - 1; a++)
            {
                arr[a] = arr[a + 1];
            }
            Array.Resize(ref arr, arr.Length - 1);
        }

        public static void DuplicateAtEnd<T>(ref T[] arr)
        {
            T[] newArr = new T[arr.Length + 1];
            for(int i = 0; i < arr.Length; i++)
            {
                newArr[i] = arr[i];
            }
            newArr[arr.Length] = arr[arr.Length - 1];

            arr = newArr;
        }

        public Texture2D DrawPallette(Color[] source)
        {
            Texture2D output = new Texture2D(source.Length, 1, TextureFormat.ARGB32, false, false);
            output.filterMode = FilterMode.Point;
            output.wrapMode = TextureWrapMode.Clamp;
            output.SetPixels(source);
            output.Apply();
            return output;
        }


    }
}