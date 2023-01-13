using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;




namespace WhiteLimboGames
{
    public class StandalonePalletteEditorSelection : EditorWindow
    {

        Texture2D selectedTexture;

        Texture2D startingPallette;

        Texture2D ignoreMapTexture;

        string[] radioBoxOptions = { "TextureMode", "Spritesheet / Animation mode" };
        int radioSelectedValue = 1;


        bool showNullTextureErrorMessage = false;

        PalletteEditorSettings settings;

        [MenuItem("Window/WhiteLimboGames/PalletteEditor")]
        public static StandalonePalletteEditorSelection Open()
        {
            StandalonePalletteEditorSelection window = EditorWindow.GetWindow<StandalonePalletteEditorSelection>(
                    title: "Pallette Editor Launcher",
                    focus: true
                );

            window.minSize = new Vector2(x: 175.0f, y: 75.0f);
            window.Show();
            window.settings = Resources.Load(PalletteEditor.RESOURCES_SETTINGS_NAME) as PalletteEditorSettings;
            return window;
        }


        private void OnGUI()
        {
            EditorGUILayout.LabelField("Main texture to replace pallette on. Use a spritesheet if using sprite mode:");
            selectedTexture = EditorGUILayout.ObjectField(selectedTexture, typeof(Texture2D), false) as Texture2D;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("The starting palette. If null, the default starting palette in the settings scriptable object is used.");
            startingPallette = EditorGUILayout.ObjectField(startingPallette, typeof(Texture), false) as Texture2D;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("The A field of this texture is used as a measure for ignoring certain pixels from the replacement process.");
            EditorGUILayout.LabelField("An A value of 0 ( transparent ), means that pixel is ommitted from pallette swapping. ");
            EditorGUILayout.LabelField("An A value of 1 ( Opaque ), means it is fully replaced by the pallette:");
            ignoreMapTexture = EditorGUILayout.ObjectField(ignoreMapTexture, typeof(Texture2D), false) as Texture2D;
            
            EditorGUILayout.Space();

            radioSelectedValue = GUILayout.SelectionGrid(radioSelectedValue, radioBoxOptions, 2, "toggle");

            EditorGUILayout.Space();

            if(GUILayout.Button("Open Pallette editor"))
            {
                if(selectedTexture == null)
                {
                    showNullTextureErrorMessage = true;
                    Debug.LogError("No texture/spritesheet asset selected!");
                    return;
                }

                string path = AssetDatabase.GetAssetPath(selectedTexture);
                TextureImporter texImporter = TextureImporter.GetAtPath(path) as TextureImporter;
                if(texImporter.textureCompression != TextureImporterCompression.Uncompressed && selectedTexture.format != TextureFormat.RGBA32)
                {
                    Debug.LogError("Your main input texture is compressed. This will result in an inacurate pallette replacement. Go into your main texture import settings and make sure the texture format is 'RGBA 32bit'");
                }
                if(texImporter.filterMode != FilterMode.Point)
                {
                    Debug.LogError("Your main input texture has the wrong filter mode.This will result in an inacurate pallette replacement. Go into your main texture import settings and make sure the texture filter mode is set to 'Point'");
                }

                if(radioSelectedValue == 0)
                {
                    PalletteEditor.Open(path, startingPallette, ignoreMapTexture, PalletteEditor.ImageMode.Texture2D);
                }
                else // radioSelectedValue == 1
                {
                    PalletteEditor.Open(path, startingPallette, ignoreMapTexture, PalletteEditor.ImageMode.Sprite, settings.defaultFramerate);
                }

                Close();
            }

            if(showNullTextureErrorMessage)
            {
                GUILayout.Label("================================ \n No texture/spritesheet asset selected! \n================================");
            }

        }



    }
}

