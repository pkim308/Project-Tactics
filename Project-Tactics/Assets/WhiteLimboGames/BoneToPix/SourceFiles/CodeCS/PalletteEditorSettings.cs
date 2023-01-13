using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace WhiteLimboGames
{
    [CreateAssetMenu(fileName = "PalletteEditorSettings", menuName = "WhiteLimboGames/PalletteEditorSettings", order = 100)]
    public class PalletteEditorSettings : ScriptableObject
    {
        public Shader colorReplacementSpriteShader;
        public int defaultFramerate = 20;


        public bool useArrayForDefaultPallette = true;
        public Texture2D defaultStartingPalletteTexture;
        public Color[] defaultStartingPalletteArray = { Color.cyan, Color.red, Color.yellow };

    }
}