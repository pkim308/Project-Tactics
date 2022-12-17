using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace WhiteLimboGames
{
    public class BoneToPixUtilities : MonoBehaviour
    {
        static public Texture2D DrawPallette(Color[] source)
        {
            Texture2D output = new Texture2D(source.Length, 1, TextureFormat.ARGB32, false, false);
            output.filterMode = FilterMode.Point;
            output.wrapMode = TextureWrapMode.Clamp;
            output.SetPixels(source);
            output.Apply();
            return output;
        }
        static public Texture2D DrawPallette32(Color32[] source)
        {
            Texture2D output = new Texture2D(source.Length, 1, TextureFormat.ARGB32, false, false);
            output.filterMode = FilterMode.Point;
            output.wrapMode = TextureWrapMode.Clamp;
            output.SetPixels32(source);
            output.Apply();
            return output;
        }



        public struct PalElement
        {
            public Color32 col;
            public int count;
        }
        static public Color32[] ConsolidatePallette(Dictionary<Color32, int> palletteIn, float thresh)
        {
            PalElement[] palletteArr = new PalElement[palletteIn.Count];

            int index = 0;
            foreach(KeyValuePair<Color32, int> pair in palletteIn)
            {
                palletteArr[index].col = pair.Key;
                palletteArr[index].count = pair.Value;
                index++;
            }

            System.Array.Sort(palletteArr, ComparePalElementDescending); // Sorting in descending order so pallette entries with more apparitions get priority over those with fewer.
            List<PalElement> palletteList = new List<PalElement>();
            for(int i = 0; i < palletteArr.Length; i++)
            {
                palletteList.Add(palletteArr[i]);
            }

            for(int i = 0; i < palletteList.Count; i++)
            {
                for(int j = i + 1; j < palletteList.Count; j++)
                {
                    float colDif = PalletteUtilities.ColorDiff(palletteList[i].col, palletteList[j].col);
                    if(colDif <= thresh)
                    {
                        palletteList.RemoveAt(j);
                        j--;
                    }
                }
            }

            Color32[] output = new Color32[palletteList.Count];
            for(int i = 0; i < palletteList.Count; i++)
            {
                output[i] = palletteList[i].col;
            }

            return output;
        }

        static int ComparePalElementDescending(PalElement a, PalElement b)
        {
            return b.count - a.count;
        }


        static public void LimitPallette(ref Texture2D target, ref Texture2D pallette, ref RenderTexture blitRendTexture, BoneToPix.ConversionStyle currentStyle, BoneToPixSettings advancedSettings)
        {
            if(blitRendTexture && blitRendTexture.IsCreated())
            {
                RenderTexture.active = null;
                blitRendTexture.Release();
            }
            blitRendTexture = new RenderTexture(target.width, target.height, 0, RenderTextureFormat.ARGB32, 0);
            blitRendTexture.filterMode = FilterMode.Bilinear;
            blitRendTexture.antiAliasing = 16;
            blitRendTexture.Create();


            Material blitMat = new Material(advancedSettings.snapPalletteShader);
            blitMat.SetTexture("_MainTex", target);
            blitMat.SetTexture("_Pallette", pallette);

            if(advancedSettings.UseDithering_ForPalletteSnapping && currentStyle != BoneToPix.ConversionStyle.albedoAndNormal)
            { // We don't want to apply pallette limiting to albedo in albedo/normal conversions, since we apply it w/lighting.
                blitMat.SetFloat("_UseDithering", 1);
                blitMat.EnableKeyword("useDithering");

                blitMat.SetTexture("_DitheringLookup", advancedSettings.DitheringLookupTexture_ForPalletteSnapping);
                blitMat.SetFloat("_DitherPower", advancedSettings.DitheringPower_ForPalletteSnapping);
            }
            else
            {
                blitMat.SetFloat("_UseDithering", 0);
                blitMat.DisableKeyword("_UseDithering");
            }
            Graphics.Blit(target, blitRendTexture, blitMat);


            RenderTexture savedActive = RenderTexture.active;
            RenderTexture.active = blitRendTexture;
            target.ReadPixels(new Rect(0, 0, blitRendTexture.width, blitRendTexture.height), 0, 0);
            target.Apply();
            RenderTexture.active = savedActive;
            blitRendTexture.Release();
        }


        static public void CalculateCellSizes(ref int cellsPerRow, ref int rowN, ref Vector2Int finalTextureSize, bool singleFrameMode, int cellWidth, int cellHeight, int totalCellCount, bool showExtraDebugInfo)
        {
            if(singleFrameMode)
            {
                finalTextureSize = new Vector2Int(cellWidth, cellHeight);
            }
            else
            {
                // Computing what size our output texture needs to be. 
                int currentSizeCheck = 64;
                while(true)
                {
                    cellsPerRow = currentSizeCheck / cellWidth;
                    rowN = currentSizeCheck / cellHeight;
                    if(cellsPerRow * rowN >= totalCellCount)
                    {
                        finalTextureSize = new Vector2Int(currentSizeCheck, currentSizeCheck);
                        int wastedCells = cellsPerRow * rowN - totalCellCount;
                        if(showExtraDebugInfo)
                        {
                            Debug.Log("Wasted cell count: " + wastedCells.ToString() + " -- " + wastedCells * cellWidth * cellHeight + " Pixels");
                        }
                        break;
                    }
                    else
                    {
                        currentSizeCheck *= 2;
                    }
                }
            }
        }

        public static int ToFlat(int i, int j, int width)
        {
            return i * width + j;
        }




        public static string GetSavePathNoOverwrite(string sourceAssetPath)
        {
            int extraVersionsCounter = 0;
            string bPath, ext;
            SplitAwayExtension(sourceAssetPath, out bPath, out ext);
            while(true)
            {
                string path = bPath + "_" + extraVersionsCounter.ToString() + ext;

                Texture2D found = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                if(found == null)
                {
                    return path;
                }
                extraVersionsCounter++;
            }
        }

        public static int GetSaveCounterNoOverwrite(string sourceAssetPath)
        {
            int extraVersionsCounter = 0;
            string bPath, ext;
            SplitAwayExtension(sourceAssetPath, out bPath, out ext);
            while(true)
            {
                string path = bPath + "_" + extraVersionsCounter.ToString() + ext;

                Texture2D found = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                if(found == null)
                {
                    return extraVersionsCounter;
                }
                extraVersionsCounter++;
            }
        }

        public static void SplitAwayExtension(string s, out string basePathName, out string extension)
        {
            for(int i = s.Length - 1; i >= 0; i--)
            {
                if(s[i] == '.')
                {
                    basePathName = s.Substring(0, i);
                    extension = s.Substring(i);
                    return;
                }
            }

            Debug.LogError("String doesn't have an extension");
            basePathName = "";
            extension = "";
            return;
        }



    }
}



