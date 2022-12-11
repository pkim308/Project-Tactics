Shader "PixelLight ShaderGraph"
{
    Properties
    {
        [NoScaleOffset]_MainTex("_MainTex", 2D) = "white" {}
        [NoScaleOffset]_Normal("Normal", 2D) = "white" {}
        [NoScaleOffset]_CellLookup("CellLookup", 2D) = "white" {}
        _Intensity("LightIntensityFactor", Float) = 0
        _Intensity2("UniversalLightIntensityFactor", Float) = 0
        _AssetPixelWorldSize("AssetWorldPixelSize", Float) = 0.03125
        [NoScaleOffset]_DitheringLookup("DitheringLookup", 2D) = "white" {}
        _DitherPower("DitheringPower", Float) = 0.075
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle(ignoreMap)]_IGNORE_MAP("ignoreMap", Float) = 0
        [Toggle(useDithering)]_DITHERING("useDithering", Float) = 0
    }
    SubShader
    {
        PackageRequirements
        {
            "com.unity.render-pipelines.universal": "1.0.0"
        }
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "DisableBatching" = "True"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_490e8421be664a68bcab348753ff7235_Out_0 = float3(_Split_588ef485a0a0471a958bbf1786b0de45_R_1, _Split_588ef485a0a0471a958bbf1786b0de45_G_2, _Split_588ef485a0a0471a958bbf1786b0de45_B_3);
            #endif
            surface.BaseColor = _Vector3_490e8421be664a68bcab348753ff7235_Out_0;
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        PackageRequirements
        {
            "com.unity.render-pipelines.universal": "1.0.0"
        }
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includess
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_490e8421be664a68bcab348753ff7235_Out_0 = float3(_Split_588ef485a0a0471a958bbf1786b0de45_R_1, _Split_588ef485a0a0471a958bbf1786b0de45_G_2, _Split_588ef485a0a0471a958bbf1786b0de45_B_3);
            #endif
            surface.BaseColor = _Vector3_490e8421be664a68bcab348753ff7235_Out_0;
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"


        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"


        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma multi_compile_local _ _IGNORE_MAP_ON
        #pragma multi_compile_local _ _DITHERING_ON
        #pragma multi_compile _ _ADDITIONAL_LIGHTS

        #if defined(_IGNORE_MAP_ON) && defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_IGNORE_MAP_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_DITHERING_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_COLOR
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TEXCOORD0
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_COLOR
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp3 : TEXCOORD3;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp4 : TEXCOORD4;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Normal_TexelSize;
        float4 _CellLookup_TexelSize;
        float _Intensity;
        float _Intensity2;
        float _AssetPixelWorldSize;
        float4 _DitheringLookup_TexelSize;
        float _DitherPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Point_Clamp);
        SAMPLER(SamplerState_Point_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);
        TEXTURE2D(_CellLookup);
        SAMPLER(sampler_CellLookup);
        TEXTURE2D(_DitheringLookup);
        SAMPLER(sampler_DitheringLookup);

            // Graph Functions
            
        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float3(float3 In, out float3 Out)
        {
            Out = floor(In);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        // 2d813917eccd7f74c60027c8bd7603fd
        #include "Assets/WhiteLimboGames/BoneToPix/SourceFiles/URP/CustomLighting.hlsl"

        struct Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817
        {
        };

        void SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(float3 Vector3_cc18d3ee542f4e7db7fac69c631d4292, float4 Vector4_55b97e64b4e245f09162b0e62002240c, float4 Vector4_8e804d8463e940e3a7ab264d5b21dc67, UnityTexture2D Texture2D_c3c1444927224f36ac467039a63eaab9, UnitySamplerState SamplerState_985058fc33664fbdb5ae7389060fb195, float Vector1_adb65d965f3b4398ae8f0396be129549, float Vector1_f414e33e60264d16bfce1267d3caf88d, float4 Vector4_ebeec5904d4849aca9761413851a625b, UnityTexture2D Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b, UnitySamplerState SamplerState_464f57901cf043db92bae7f2ce8c3cad, float2 Vector2_aceea9e98a134ffa8fcaf556a590a58b, float Vector1_50ff51a069a14828ade2a19c6439baae, float Vector1_98d733b407654b79a799fd246cc4bc32, Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 IN, out float4 Out_1)
        {
            float3 _Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0 = Vector3_cc18d3ee542f4e7db7fac69c631d4292;
            float4 _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0 = Vector4_55b97e64b4e245f09162b0e62002240c;
            float4 _Property_703ab59dd70c438a8969b12c25dfca61_Out_0 = Vector4_8e804d8463e940e3a7ab264d5b21dc67;
            UnityTexture2D _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0 = Texture2D_c3c1444927224f36ac467039a63eaab9;
            UnitySamplerState _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0 = SamplerState_985058fc33664fbdb5ae7389060fb195;
            float _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0 = Vector1_adb65d965f3b4398ae8f0396be129549;
            float _Property_6f251456fbf44636b265fa242140f89f_Out_0 = Vector1_f414e33e60264d16bfce1267d3caf88d;
            float4 _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0 = Vector4_ebeec5904d4849aca9761413851a625b;
            UnityTexture2D _Property_f3bed49dce34412191fc10c203c18041_Out_0 = Texture2D_3af1dd3fc2b04b7db7977e845a47cd0b;
            UnitySamplerState _Property_9aa2d55688dd4fa188d074845a30edac_Out_0 = SamplerState_464f57901cf043db92bae7f2ce8c3cad;
            float2 _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0 = Vector2_aceea9e98a134ffa8fcaf556a590a58b;
            float _Property_570fd395f0a443ce95c868f146c85e74_Out_0 = Vector1_50ff51a069a14828ade2a19c6439baae;
            float _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0 = Vector1_98d733b407654b79a799fd246cc4bc32;
            float4 _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
            CalculateCustomLighting_float(_Property_1f5fc8014e4b48f7b51bab3c64d81b25_Out_0, _Property_a0e4eda884a54411bce2d0ddd30bb9d4_Out_0, _Property_703ab59dd70c438a8969b12c25dfca61_Out_0, _Property_bbbb47c6c3e942e1abb097303ccf67a0_Out_0, _Property_cbdeefb35d914e668817bd3e9a6878e0_Out_0, _Property_de243a2fbea046f98c2dde882b62aa0f_Out_0, _Property_6f251456fbf44636b265fa242140f89f_Out_0, _Property_f25892b8d5844fc3b28c7bd75592474a_Out_0, _Property_f3bed49dce34412191fc10c203c18041_Out_0, _Property_9aa2d55688dd4fa188d074845a30edac_Out_0, _Property_ba0b5e0fc6fe4d52880ba77869b89145_Out_0, _Property_570fd395f0a443ce95c868f146c85e74_Out_0, _Property_89c2efb7a53e4e3ca02c9ee9232c2e48_Out_0, _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1);
            Out_1 = _CalculateCustomLightingCustomFunction_221a3cd32ffa4f7e93dbbb6b16624911_Color_1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2;
            Unity_Divide_float3(IN.ObjectSpacePosition, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1;
            Unity_Floor_float3(_Divide_da45bf173ce046788b3cdc8a61cd5216_Out_2, _Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2;
            Unity_Multiply_float(_Floor_bb8d7f98bdaa43199fd8dbbeb70ea517_Out_1, (_Property_c717cd9d06ac422d93bd8aafa0f3a04e_Out_0.xxx), _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_925184264cf9496998393d46ccdec81f_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Multiply_b7c03f709d5147e68dfb46da436c5b3e_Out_2, _Subtract_925184264cf9496998393d46ccdec81f_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2;
            Unity_Subtract_float3(IN.ObjectSpacePosition, _Subtract_925184264cf9496998393d46ccdec81f_Out_2, _Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2;
            Unity_Divide_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Floor_25392426689e46bbb569eefb3f2e821e_Out_1;
            Unity_Floor_float3(_Divide_cb6cf082976c4966ae30127a0ee364c6_Out_2, _Floor_25392426689e46bbb569eefb3f2e821e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2;
            Unity_Multiply_float(_Floor_25392426689e46bbb569eefb3f2e821e_Out_1, (_Property_b9a0a2ec4fd74ea3a43b98b2c9e9feef_Out_0.xxx), _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_0464f596411543068909baf6e5a71137_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Multiply_fed6d2f8c8c54055b841c7abc3edd794_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_176bd00b5461430f95596068d3dacbad_Out_2;
            Unity_Subtract_float3(_Subtract_103d5c9a2a4a4b6cbd15788fd95ff938_Out_2, _Subtract_0464f596411543068909baf6e5a71137_Out_2, _Subtract_176bd00b5461430f95596068d3dacbad_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_6d599add31c44a468670186e16a0dace_Out_1 = TransformObjectToWorld(_Subtract_176bd00b5461430f95596068d3dacbad_Out_2.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a82c5934a5c44d9d86f4c58a66c5879d_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_R_4 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.r;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_G_5 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.g;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_B_6 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.b;
            float _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_A_7 = _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0 = UnityBuildTexture2DStructNoScale(_Normal);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4a30a4425b7d43dd95e7aeefbb1d8aa2_Out_0.tex, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp).samplerstate, IN.uv0.xy);
            _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.rgb = UnpackNormalRGB(_SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0);
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_R_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.r;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_G_5 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.g;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_B_6 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.b;
            float _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_A_7 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[0];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[1];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[2];
            float _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4 = _SampleTexture2D_e6daeb5a632547e58e5e081b894928e8_RGBA_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_52c40d2323254b91bc915450488f8b10_Out_0 = float3(_Split_919eccdcc6d74881a4a8797ad3bc23a9_R_1, _Split_919eccdcc6d74881a4a8797ad3bc23a9_G_2, _Split_919eccdcc6d74881a4a8797ad3bc23a9_B_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1 = TransformObjectToWorldDir(_Vector3_52c40d2323254b91bc915450488f8b10_Out_0.xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[0];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[1];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3 = _Transform_3735c11875be48b79ce71f6b05ba7cf8_Out_1[2];
            float _Split_e9ef3409544d4ccaa6360fc749ca8e81_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0 = float4(_Split_e9ef3409544d4ccaa6360fc749ca8e81_R_1, _Split_e9ef3409544d4ccaa6360fc749ca8e81_G_2, _Split_e9ef3409544d4ccaa6360fc749ca8e81_B_3, _Split_919eccdcc6d74881a4a8797ad3bc23a9_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0 = UnityBuildTexture2DStructNoScale(_CellLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0 = _Intensity;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_1430774c57164d38a67afc28f0b0ef32_Out_0 = _Intensity2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0 = UnityBuildTexture2DStructNoScale(_DitheringLookup);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_ae176341f83d48739d600ed451ada52c_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0 = _AssetPixelWorldSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_96b3e728282c455f908e14aa14537fb8_Out_0 = _DitherPower;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e;
            float4 _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1;
            SG_CustomPixelLighting_ce4c5c9da18912348b7afac69af75817(_Transform_6d599add31c44a468670186e16a0dace_Out_1, _SampleTexture2D_7c54f477341d49e5bcda3f303cf694ed_RGBA_0, _Vector4_e90443edeb50426cb90c7dd1c8d1a01d_Out_0, _Property_a5d956ec6cbd43aaa8e85e40f61e0061_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Clamp), _Property_a9f82548a1cb44cdb0e9b5abdd4ce684_Out_0, _Property_1430774c57164d38a67afc28f0b0ef32_Out_0, IN.VertexColor, _Property_81db98d5c4b7421c998eedf7dc62d99c_Out_0, UnityBuildSamplerStateStruct(SamplerState_Point_Repeat), (_UV_ae176341f83d48739d600ed451ada52c_Out_0.xy), _Property_ada8009dfc3d4cb99b85ffc49dfdb6b4_Out_0, _Property_96b3e728282c455f908e14aa14537fb8_Out_0, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e, _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_588ef485a0a0471a958bbf1786b0de45_R_1 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[0];
            float _Split_588ef485a0a0471a958bbf1786b0de45_G_2 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[1];
            float _Split_588ef485a0a0471a958bbf1786b0de45_B_3 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[2];
            float _Split_588ef485a0a0471a958bbf1786b0de45_A_4 = _CustomPixelLighting_0aea70af43c64679b636932e7d731d3e_Out_1[3];
            #endif
            surface.Alpha = _Split_588ef485a0a0471a958bbf1786b0de45_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // use bitangent on the fly like in hdrp
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // This is explained in section 2.2 in "surface gradient based bump mapping framework"
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         renormFactor*bitang;
        #endif


        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv0 =                         input.texCoord0;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.VertexColor =                 input.color;
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}