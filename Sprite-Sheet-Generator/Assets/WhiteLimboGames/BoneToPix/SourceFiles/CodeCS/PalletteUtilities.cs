using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace WhiteLimboGames
{
    public class PalletteUtilities
    {

        public static Color32[] GenerateLimitedPallette(Texture2D source, int palletteCount)
        {
            if(source.isReadable == false)
            {
                Debug.LogError("The selected palette texture isn't readable! Make sure read/write is enabled in the unity texture import settings");
            }

            Color32[] fullPallette = GetOpaqueFullPallette(source);
            int[] assignedCentroid = new int[fullPallette.Length];
            float[] currentColorDiff = new float[fullPallette.Length];
            for(int i = 0; i < currentColorDiff.Length; i++)
            {
                currentColorDiff[i] = float.MaxValue;
            }

            Color32[] finalPallette;
            if(fullPallette.Length <= palletteCount)
            {
                if(fullPallette.Length == 0)
                {
                    Debug.LogError("Pallette sourcing texture has no opaque colors. If you're trying to use single-frame mode, make sure the camera is actually rendering your intended target(s).");
                    Color32[] errorPallette = new Color32[1];
                    return errorPallette;
                }
                else
                {
                    return fullPallette;
                }
            }
            else
            { // K-means
                finalPallette = new Color32[palletteCount];
                Color32[] centroids = new Color32[palletteCount];
                System.Array.Sort(fullPallette, RandomSortHelper<Color32>); // shuffling full pallette to pick first palletteColorCount colors at random
                for(int i = 0; i < centroids.Length; i++)
                { // Initing centroids with randomly picked colors from fullPallette.
                    centroids[i] = fullPallette[i];
                    assignedCentroid[i] = i;
                    currentColorDiff[i] = ColorDiff(fullPallette[i], centroids[assignedCentroid[i]]);
                }

                int centroidSwitches;
                int[] centroidElements = new int[centroids.Length];
                do
                {
                    //Switching centroids
                    centroidSwitches = 0;
                    for(int i = 0; i < fullPallette.Length; i++)
                    {
                        bool changedCentroid = false;
                        for(int j = 0; j < centroids.Length; j++)
                        {
                            float dif = ColorDiff(fullPallette[i], centroids[j]);
                            if(currentColorDiff[i] > dif)
                            {
                                changedCentroid = true;
                                currentColorDiff[i] = dif;
                                assignedCentroid[i] = j;
                            }
                        }
                        if(changedCentroid) { centroidSwitches++; }
                    }
                    //Updating centroid values
                    for(int i = 0; i < centroidElements.Length; i++)
                    { // resetting element count for all centroids
                        centroidElements[i] = 0;
                    }
                    for(int i = 0; i < centroids.Length; i++)
                    { // reseting centroid values
                        centroids[i] = new Color32();
                    }
                    for(int i = 0; i < assignedCentroid.Length; i++)
                    { // updating centroid avg values 
                        int index = assignedCentroid[i];
                        centroids[index] = UpdateAverage(centroids[index], centroidElements[index], fullPallette[i]);
                    }

                } while(centroidSwitches != 0);


                return centroids;
            }
        }



        static Color32 UpdateAverage(Color32 currentAverage, int currentElementCount, Color32 newElement)
        {
            if(currentElementCount == 0)
            {
                return newElement;
            }

            float currentAvgR = currentAverage.r;
            float currentAvgG = currentAverage.g;
            float currentAvgB = currentAverage.b;

            float newElemR = newElement.r;
            float newElemG = newElement.g;
            float newElemB = newElement.b;

            float newR = UpdateAverage(currentAvgR, currentElementCount, newElemR);
            float newG = UpdateAverage(currentAvgG, currentElementCount, newElemG);
            float newB = UpdateAverage(currentAvgB, currentElementCount, newElemB);

            Color32 ret = new Color32();
            ret.r = (byte)newR;
            ret.g = (byte)newG;
            ret.b = (byte)newB;
            ret.a = 255;
            return ret;
        }
        static Color32 CalculateAverage(List<Color32> cols)
        {
            float rSum = 0, gSum = 0, bSum = 0;
            for(int i = 0; i < cols.Count; i++)
            {
                rSum += cols[i].r;
                gSum += cols[i].g;
                bSum += cols[i].b;
            }
            Color32 ret = new Color32();
            ret.r = (byte)(rSum / cols.Count);
            ret.g = (byte)(gSum / cols.Count);
            ret.b = (byte)(bSum / cols.Count);
            ret.a = 255;
            return ret;
        }

        static float UpdateAverage(float currentAverage, int currentElements, float newElement)
        {
            if(currentElements == 0)
            {
                return newElement;
            }
            return (currentAverage * currentElements + newElement) / (currentElements + 1);
        }
        static float CalculateAverage(List<float> elems)
        {
            float s = 0;
            for(int i = 0; i < elems.Count; i++)
            {
                s += elems[i];
            }
            return s / elems.Count;
        }


        public static Color32[] GetOpaqueFullPallette(Texture2D tex)
        {
            Color32[] pixelData = tex.GetPixels32(0);
            Dictionary<Color32, int> colorApparitions = new Dictionary<Color32, int>();
            for(int i = 0; i < pixelData.Length; i++)
            {
                if(pixelData[i].a > 250)
                { // Skips pixels with relevant transparency
                    if(colorApparitions.ContainsKey(pixelData[i]))
                    {
                        colorApparitions[pixelData[i]] = colorApparitions[pixelData[i]] + 1;
                    }
                    else
                    {
                        colorApparitions.Add(pixelData[i], 1);
                    }
                }
            }

            Color32[] colors = new Color32[colorApparitions.Count];
            int indx = 0;
            foreach(KeyValuePair<Color32, int> pair in colorApparitions)
            {
                Color32 col = new Color32();
                col.r = pair.Key.r;
                col.g = pair.Key.g;
                col.b = pair.Key.b;
                col.a = 255;
                colors[indx] = col;
                indx++;
            }
            return colors;
        }


        public static float ColorDiff(Color32 x, Color32 y)
        {
            float rdif = x.r - y.r;
            float gdif = x.g - y.g;
            float bdif = x.b - y.b;
            float adif = x.a - y.a;
            return Mathf.Sqrt((rdif * rdif) + (gdif * gdif) + (bdif * bdif) + (adif * adif));
        }


        public static bool ValidatePaletteSettingsAndNotifyUser(Texture2D paletteTex)
        {
            bool isOk = true;
            string manualPallettePath = AssetDatabase.GetAssetPath(paletteTex);
            TextureImporter texImporter = TextureImporter.GetAtPath(manualPallettePath) as TextureImporter;
            if(texImporter == null)
            {
                return true;
            }

            if(texImporter.sRGBTexture == false)
            {
                Debug.LogError("Your selected palette is not configured as sRGB. This will result in inacurrate colors. Go into your palette import settings and make sure 'sRGB (Color Texture)' is enabled");
                isOk = false;
            }
            if((Mathf.IsPowerOfTwo(paletteTex.width) == false) && (texImporter.npotScale != TextureImporterNPOTScale.None))
            {
                Debug.LogError("Your selected palette has the wrong Non-Power of 2 setting. This will result in inacurrate colors. Go into your palette import settings and make sure 'Non-Power of 2' is set to 'None'");
                isOk = false;
            }
            if(texImporter.isReadable == false)
            {
                Debug.LogError("Your selected palette is not readable. This will result in an error. Go into your palette import settings and make sure 'Read/Write Enabled' is enabled");
                isOk = false;
            }
            if(texImporter.streamingMipmaps == true)
            {
                Debug.LogError("Your selected palette has streaming mipmaps enabled. This will result in inacurrate colors. Go into your palette import settings and make sure 'Streaming Mipmaps' is disabled");
                isOk = false;
            }
            if(texImporter.vtOnly == true)
            {
                Debug.LogError("Your selected palette is a virtual texture only. This will result in an error. Go into your palette import settings and make sure 'Virtual Texture Only' is disabled");
                isOk = false;
            }
            if(texImporter.mipmapEnabled == true)
            {
                Debug.LogError("Your selected palette has mip maps enabled. This will result in inacurrate colors. Go into your palette import settings and make sure 'Generate Mip Maps' is disabled");
                isOk = false;
            }
            if(texImporter.wrapMode != TextureWrapMode.Clamp)
            {
                Debug.LogError("Your selected palette has the wrong wrap mode. This will result in inacurrate colors. Go into your palette import settings and make sure 'Wrap Mode' is set to 'Clamp'");
                isOk = false;
            }
            if(texImporter.filterMode != FilterMode.Point)
            {
                Debug.LogError("Your selected palette has the wrong filter mode. This will result in inacurrate colors. Go into your palette import settings and make sure 'Filter Mode' is set to 'Point(No Filter)'");
                isOk = false;
            }
            if(texImporter.textureCompression != TextureImporterCompression.Uncompressed)
            {
                Debug.LogError("Your selected palette has the wrong format. This will result in inacurrate colors. Go into your palette import settings and make sure 'Format' is set to 'RGBA 32 bit'");
                isOk = false;
            }

            return isOk;
        }

        public static Color[] GetColorArrayFromPalletteTexture(Texture2D palletteTex)
        {
            Color[] ret = new Color[palletteTex.width];
            for(int i = 0; i < palletteTex.width; i++)
            {
                ret[i] = palletteTex.GetPixel(x : i, y : 0, mipLevel : 0);
            }
            return ret;
        }


        static int RandomSortHelper<T>(T a, T b)
        {
            return Random.Range(-1, 2);
        }



    }
}
