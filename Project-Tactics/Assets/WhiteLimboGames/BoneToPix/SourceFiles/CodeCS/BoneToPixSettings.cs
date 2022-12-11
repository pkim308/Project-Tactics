using UnityEngine;

namespace WhiteLimboGames
{

    [CreateAssetMenu(fileName = "BoneToPixSettings", menuName = "WhiteLimboGames/BoneToPixSettings", order = 99)]
    public class BoneToPixSettings : ScriptableObject
    {
        [Tooltip("Local starting from project assets folder")]
        public string OutputPath = "BoneToPix/Output";


        [Space]

        [Tooltip("Should BoneToPix auto-run the pallette editor on your converted sprite after conversion completes? The Pallette editor can also be run separately from Window > WhiteLimboGames > PalletteEditor")]
        public bool AutoRunPalletteEditor = true;

        [Space]

        [Range(1, 144)] [Tooltip("Target framerate for the output animations. If the framerate of the generated animation is higher than the target, frames will be removed until hitting the target. If the output framerate is lower than the target, it will stay the same since there is not enough animation data to get to the target framerate")]
        public int TargetFramerate = 30;

        [Space]

        [Tooltip("Output texture Pixels Per Unit")]
        public int SpritePPU = 32;

        [Space]

        [Tooltip("Higher values make filter more permissive to noise. Lower values make it more strict against noise.")]
        [Range(1f, 50f)] public float filterAbsColorThreshold = 5f;

        [Tooltip("Color difference threshold for 'consolidating' two colors in the generated pallette. When 2 similar colors get consolidated, the less used one is removed from the pallette.")]
        [Range(1f, 100f)] public float palletteColorConsolidationThreshold = 15f;

        [Tooltip("Stray/Orphan pixel filter")]
        public bool UseFilter = true;

        [Space]

        [Tooltip("Use dithering to output preview material from Albedo/Normal conversions")]
        public bool UseDithering = true;
        [Tooltip("Amount of dithering")]
        [Range(0f, 1f)] public float DitheringPower;
        [Tooltip("Matrix / lookup texture used for dithering")]
        public Texture2D DitheringLookupTexture;

        [Tooltip("Use dithering when pallette snapping. Doesn't apply to albedo texture in albedo/normal conversions.")]
        public bool UseDithering_ForPalletteSnapping = true;
        [Tooltip("Amount of dithering for pallette snapping")]
        [Range(0f, 1f)] public float DitheringPower_ForPalletteSnapping;
        [Tooltip("Matrix / lookup texture used for dithering in pallette snapping")]
        public Texture2D DitheringLookupTexture_ForPalletteSnapping;

        [Space]

        [Tooltip("When using outlines and doing an albedo/normal conversion, should the outline be affected by lighting?")]
        public bool UseLightingOnOutline = false;
        [Tooltip("Outline color")]
        public Color OutlineColor = Color.black;

        [Tooltip("Apply cell shading directly to normalMap output.")]
        public bool CellShadeNormalOutput = false;
        [Tooltip("LookupTexture for normalMap cell shading. Fewer colors in the lookup result in a more cartoony/chunky look. Look in SourceFiles/LookupTextures for examples.")]
        public Texture2D NormalMapCellShadingLookup;

        [Tooltip("Lookup texture for CellShaded Lighting conversions. Fewer colors result in chunkier looks. Look in SourceFiles/LookupTextures for examples.")]
        public Texture2D CellShadedLookup;

        [Tooltip("Allows converting models inside of SRP / URP / HDRP projects. Note that this is an experimental features and requires dynamically switching your projects rendering pipeline.")]
        public bool AllowConversionInAllPipelines = true;

        [Tooltip("Also create a URP material.")]
        public bool AlsoCreateURPMaterial = true;

        [Tooltip("_Intensity value assigned to generated preview materials, for the default Built-In render pipeline version. Higher values result in sharper normal-mapped lighting")]
        public float PreviewMaterialHighlightsIntensity_BuiltIn = 0.5f;
        [Tooltip("_Intensity value assigned to generated preview materials, for the URP material version. Higher values result in sharper normal-mapped lighting")]
        public float PreviewMaterialHighlightsIntensity_URP = 0.5f;
        [Tooltip("_Intensity2 value assigned to generated preview materials, for the default Built-In render pipeline version. Higher values result in over-all brighter sprites.")]
        public float PreviewMaterialUniversalIntensity_BuiltIn = 0.1f;
        [Tooltip("_Intensity2 value assigned to generated preview materials, for the URP material version. Higher values result in over-all brighter sprites.")]
        public float PreviewMaterialUniversalIntensity_URP = 0.4f;

        [Tooltip("Determines wheter or not to apply a custom render queue value on output materials.")]
        public bool ForceRenderQueueValueOnPreviewMaterials = false;
        public int ForcedRenderQueueValue = 2222;

        public Material normalMapMaterial;
        public Material albedoMaterial;
        public Material cellLitMaterial;


        public Shader dynamicLitShader;
        public Shader dynamicLitShader_URP;


        public Shader snapPalletteShader;

        [Tooltip("Angles used to render base for our pallette sourcing texture")]
        public Vector3[] palletteSourcingPoseAngles;

        public bool showExtraDebugInformation;
    }


}