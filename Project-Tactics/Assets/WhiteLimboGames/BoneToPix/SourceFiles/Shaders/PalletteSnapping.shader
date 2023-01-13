Shader "Custom/BoneToPix/AutoPalletteSnapping"
{
    Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_Pallette("Pallette", 2D) = "white"{}  // Note: Pallette should always be set to clamp and no filter (point)

		[Toggle(useDithering)]
		_UseDithering("Use Dithering", Float) = 0
		_DitheringLookup("Lookup pattern texture for dithering", 2D) = "gray"
		_DitherPower("Dither Power", Float) = 0.075

		[Toggle(useIgnoreMap)]
		_UseIgnoreMap("Use IgnoreMap", Float) = 0
		_IgnoreMap("Ignore Map. Alpha channel is used to determine ignore amount.", 2D) = "white" {}
		

	}
	
	SubShader {
		
		Pass{

			Tags{
			}

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Always Cull Off ZWrite Off
			
				
			CGPROGRAM
			#pragma target 4.0 // need 4.0 to get real for-loops.

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"


			#pragma vertex vert
			#pragma fragment frag
				
			#pragma shader_feature_local useDithering
			#pragma shader_feature_local useIgnoreMap


			float3 rgb_to_hsv_no_clip(float3 RGB)
			{
				float3 HSV;

				float minChannel, maxChannel;
				if (RGB.x > RGB.y) {
					maxChannel = RGB.x;
					minChannel = RGB.y;
				}
				else {
					maxChannel = RGB.y;
				 	minChannel = RGB.x;
				}

				if (RGB.z > maxChannel) maxChannel = RGB.z;
				if (RGB.z < minChannel) minChannel = RGB.z;

				HSV.xy = 0;
				HSV.z = maxChannel;
				float delta = maxChannel - minChannel;             //Delta RGB value
				if (delta != 0) {                    // If gray, leave H  S at zero
					HSV.y = delta / HSV.z;
					float3 delRGB;
					delRGB = (HSV.zzz - RGB + 3 * delta) / (6.0 * delta);
					if (RGB.x == HSV.z) HSV.x = delRGB.z - delRGB.y;
					else if (RGB.y == HSV.z) HSV.x = (1.0 / 3.0) + delRGB.x - delRGB.z;
					else if (RGB.z == HSV.z) HSV.x = (2.0 / 3.0) + delRGB.y - delRGB.x;
				}
				return (HSV);
			}

			float3 hsv_to_rgb(float3 HSV)
			{
				float3 RGB = HSV.z;

				float var_h = HSV.x * 6;
				float var_i = floor(var_h);   // Or ... var_i = floor( var_h )
				float var_1 = HSV.z * (1.0 - HSV.y);
				float var_2 = HSV.z * (1.0 - HSV.y * (var_h - var_i));
				float var_3 = HSV.z * (1.0 - HSV.y * (1 - (var_h - var_i)));
				if (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
				else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
				else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
				else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
				else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
				else { RGB = float3(HSV.z, var_1, var_2); }

				return (RGB);
			}


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 col : COLOR;
			};
					
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 col : COLOR0;
			};
				

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.col = v.col;
				return o;
			}
					
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;  // 1/width, 1/height, width, height for _MainTex
			sampler2D _Pallette;
			float4 _Pallette_TexelSize; // 1/width, 1/height, width, height for for _Pallette
#ifdef useDithering
			sampler2D _DitheringLookup;
			uniform float4 _DitheringLookup_TexelSize;
			uniform float _DitherPower;
#endif

#ifdef useIgnoreMap
			sampler2D _IgnoreMap;
#endif


			float4 frag(v2f i) : SV_Target
			{
				float4 texCol = tex2D(_MainTex, i.uv);
				if (texCol.a < 0.999) {
					return float4(0, 0, 0, 0);
				}


#ifdef useDithering
				float2 gridSnappedUV = i.uv - (i.uv - _MainTex_TexelSize.xy * floor(i.uv / _MainTex_TexelSize.xy));
				gridSnappedUV = (gridSnappedUV * _MainTex_TexelSize.zw) / _DitheringLookup_TexelSize.zw;

				float lookupOffset = tex2D(_DitheringLookup, gridSnappedUV).r;
				lookupOffset = (lookupOffset * 2.66666666) - 1; // [0,0.75] -> [-1,1]
				lookupOffset = lookupOffset * _DitherPower;

				float3 colHSV = rgb_to_hsv_no_clip(texCol.rgb);
				colHSV.z = colHSV.z + lookupOffset;
				//float3 backToRGB = hsv_to_rgb(colHSV);
				texCol.rgb = hsv_to_rgb(colHSV);
#endif

				float diff;
				float3 palletteSampleI;
				float minDiff = 99999;
				int minDiffIndex = 0;

				float distR, distG, distB;

				[loop]
				for (int index = 0; index < _Pallette_TexelSize.z; index++) {
					// doing a basic non-human eye hue sensitivity weighted approach here, should be good enough since pallette elements are gonna be pretty distinct anyways.
					palletteSampleI = tex2D(_Pallette, float2(index * _Pallette_TexelSize.r + 0.00001f, 0)); // Make sure pallette texture is set to Clamp, otherwise this fails from the 0.00001f. We're adding it to avoid floating point errors giving us the wrong pixel.
					distR = texCol.r - palletteSampleI.r;
					distG = texCol.g - palletteSampleI.g;
					distB = texCol.b - palletteSampleI.b;
					diff = sqrt(distR*distR + distG*distG + distB*distB);
					if (diff < minDiff) {
						minDiff = diff;
						minDiffIndex = index;
					}
				}

				float3 sampledPallette = tex2D(_Pallette, float2(minDiffIndex * _Pallette_TexelSize.r + 0.00001f, 0));

#ifdef useIgnoreMap
				half ignoreVal = tex2D(_IgnoreMap, i.uv).a;
				return float4(sampledPallette.rgb * ignoreVal + texCol.rgb * (1 - ignoreVal), 1.0);
#else
				return float4(sampledPallette.rgb, 1);
#endif
			}
				
			ENDCG
				
		}
				
			
	}


}
