using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace WhiteLimboGames
{

    [CustomEditor(typeof(BoneToPix))]
    public class BoneToPixCustomEditor : Editor
    {

        [SerializeField]
        int selectedOption;

        public override void OnInspectorGUI()
        {
            BoneToPix script = (target as BoneToPix);


            if(script.conversionIsRunning || script.snappingFrameIsRunning || script.palletteGenerationIsRunning)
            {
                GUILayout.Label("Cooking your pixel art! :)");
                return;
            }

            DrawDefaultInspector();

            GUILayout.Space(20f);
            GUILayout.Label("Pallette type:");
            var autoGenPalletteText = new string[] { "  Auto-Generate pallette", "  Don't Use Restricted Pallette", "  Manual Pallette" };
            BoneToPix.palletteStyle = (BoneToPix.PalletteStyles)GUILayout.SelectionGrid((int)BoneToPix.palletteStyle, autoGenPalletteText, 1, EditorStyles.radioButton);

            if(BoneToPix.palletteStyle == BoneToPix.PalletteStyles.autoGen)
            {  // Auto gen
                GUILayout.BeginHorizontal();
                GUILayout.Label("Auto Pallette Color Count:");
                BoneToPix.palletteColorCount = EditorGUILayout.IntField(BoneToPix.palletteColorCount);
                GUILayout.EndHorizontal();
            }
            else if(BoneToPix.palletteStyle == BoneToPix.PalletteStyles.dontUse)
            {  // Don't use
               //
            }
            else if(BoneToPix.palletteStyle == BoneToPix.PalletteStyles.manual)
            { // Manual
                GUILayout.Label("Manual Pallette:");
                BoneToPix.manualPallette = EditorGUILayout.ObjectField(BoneToPix.manualPallette, typeof(UnityEngine.Texture2D), false) as Texture2D; // Only accepting manual pallettes if we're not auto generating
            }


            GUILayout.Space(20f);
            GUILayout.Label("Lighting Type:");
            var styleText = new string[] { "  Flat Color + Normal Maps", "  Cell Shaded Lighting", "  Generic Lighting" };
            selectedOption = GUILayout.SelectionGrid(selectedOption, styleText, 1, EditorStyles.radioButton);

            GUILayout.Space(20f);

            if(GUILayout.Button("Begin Converting Animation"))
            {
                script.InitialSetup(selectedOption, isSingleFrame: false);
            }

            if(GUILayout.Button("Convert Single Frame"))
            {
                script.InitialSetup(selectedOption, isSingleFrame: true);
            }

        }

    }


}