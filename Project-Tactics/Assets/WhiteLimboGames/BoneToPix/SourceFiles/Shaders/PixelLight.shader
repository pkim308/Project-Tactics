// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/PixelLight"
{
    Properties {
		
		_MainTex("Main Texture", 2D) = "white"
		_Normal("Normal Map", 2D) = "white"
		_CellLookup("Cellshading lookup Texture", 2D) = "white"
		_Intensity("Light Intensity Factor", Float) = 1
		_Intensity2("Universal Light Intensity Factor", Float) = 0.1
		_AssetPixelWorldSize("World size of one asset/texture pixel (1 / Asset PixelsPerUnit)", Float) = 0.03125 // Can't use _TexelSize with sprite sheets sadly. Main UV's are in sprite space, but _TexelSize is still in Texture space

		[Toggle(ignoreMap)]
		_IgnoreMap("Ignore map", Float) = 0

		[Toggle(useDithering)]
		_UseDithering("Use Dithering", Float) = 0
		_DitheringLookup("Lookup pattern texture for dithering", 2D) = "gray"
		_DitherPower("Dither Power", Float) = 0.075
	}
	
	SubShader {
		
			Pass{
				
				Tags{
					"LightMode" = "ForwardBase"
					//"DisableBatching" = "True"
				}
				
			
				Blend SrcAlpha OneMinusSrcAlpha
			
				
				ZWrite Off
				Cull Off
				
				CGPROGRAM

				#include "UnityCG.cginc"
				#include "AutoLight.cginc"
				
				#pragma vertex vert
				#pragma fragment frag

				#pragma shader_feature_local ignoreMap
				#pragma shader_feature_local useDithering

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
				
				
				uniform float _AssetPixelWorldSize;
				uniform float _SpriteW;
				uniform float _SpriteH;

				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.col = v.col;
					return o;
				}
					
				sampler2D _MainTex;
				sampler2D _Normal;
				sampler2D _CellLookup;
				uniform float4 _LightColor0;
				uniform float _Intensity;
				uniform float _Intensity2;
#ifdef useDithering
				sampler2D _DitheringLookup;
				uniform float4 _MainTex_TexelSize;
				uniform float4 _DitheringLookup_TexelSize;
				uniform float _DitherPower;
#endif

				fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
				{

					float4 col = tex2D(_MainTex, i.uv); 
					float4 normalSample = tex2D(_Normal, i.uv);
					float3 rgbNormal = normalSample.xyz * 2 - 1;
					rgbNormal.z *= facing;

					float3 normal = normalize(rgbNormal);
					normal = mul(normal, unity_WorldToObject);


					
					float lookupOffset;
#ifdef useDithering
					float2 gridSnappedUV = i.uv * (_MainTex_TexelSize.zw / _DitheringLookup_TexelSize.zw);
					gridSnappedUV = gridSnappedUV - (gridSnappedUV - _AssetPixelWorldSize * floor(gridSnappedUV / _AssetPixelWorldSize));

					lookupOffset = tex2D(_DitheringLookup, gridSnappedUV).r;
					lookupOffset = (lookupOffset * 2.66666666) - 1; // [0,0.75] -> [-1,1]
					lookupOffset = lookupOffset * _DitherPower;
#else
					lookupOffset = 0;
#endif

					float3 lightDir = float3(-_WorldSpaceLightPos0.r, -_WorldSpaceLightPos0.g, _WorldSpaceLightPos0.b);
					float dotProd = ((dot(normal, lightDir) + 1.0) / 2.0);
					dotProd = tex2D(_CellLookup, float2(dotProd + lookupOffset, 0));
					dotProd = dotProd * 2 - 1;
					
					half averageLightColor = max(_LightColor0.r, _LightColor0.g);
					averageLightColor = max(averageLightColor, _LightColor0.b) / 2;
					float3 desaturatedLightColor = float3(min(1.25, (averageLightColor * 9 + _LightColor0.r) / 10), min(1.25,(averageLightColor * 9 + _LightColor0.g) / 10),
														min(1.25, (averageLightColor * 9 + _LightColor0.b) / 10));
					
					float3 highlights = _Intensity * dotProd * _LightColor0.rgb;
					
					
					float3 retLight = highlights.rgb + desaturatedLightColor.rgb;
					float3 retBaseCol = col.rgb * i.col.rgb;

#ifdef ignoreMap
					return float4( ((retLight * retBaseCol) * normalSample.a + retBaseCol * (1-normalSample.a)).rgb, col.a );
#else
					return float4((retLight * retBaseCol).rgb, col.a);
#endif

				}
				
				ENDCG
				
			}
		
			
			Pass{
				
				Tags{
					"LightMode" = "ForwardAdd"
					//"DisableBatching" = "True"
				}
				
				Blend One One
				Cull Off
				ZWrite Off
				
				CGPROGRAM
				
				#include "AutoLight.cginc"
				
				#pragma vertex vert
				#pragma fragment frag

				#pragma shader_feature_local ignoreMap
				#pragma shader_feature_local useDithering

				
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
					float3 gridSnappedWorldVertex : TEXCOORD1;
					float4 col : COLOR0;
					float4 gridSnappedLocalPos : TEXCOORD3;
				};	
				
				uniform float _AssetPixelWorldSize;
				uniform float _SpriteW;
				uniform float _SpriteH;

				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);

					float2 pozVert = v.vertex.xy;
					o.gridSnappedLocalPos.xy = pozVert - (pozVert - (_AssetPixelWorldSize) * floor(pozVert / (_AssetPixelWorldSize)));
					o.gridSnappedLocalPos.zw = v.vertex.zw;

					o.uv = v.uv;
					o.col = v.col;
					
					return o;
				}
					
				sampler2D _MainTex;
				sampler2D _Normal;
				sampler2D _CellLookup;
				uniform float4 _LightColor0;
				uniform float4 _LightAtten;
				uniform float _Intensity;
				uniform float _Intensity2;
				uniform float4x4 unity_WorldToLight;
#ifdef useDithering
				sampler2D _DitheringLookup;
				uniform float4 _DitheringLookup_TexelSize;
				uniform float4 _MainTex_TexelSize;
				uniform float _DitherPower;
#endif

				fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
				{
					
					float4 col = tex2D(_MainTex, i.uv);
					float4 normalSample = tex2D(_Normal, i.uv);
					float3 rgbNormal = normalSample.xyz * 2 - 1;
					rgbNormal.z *= facing;

					float3 fragmentGridSnappedLocalPos = i.gridSnappedLocalPos - (i.gridSnappedLocalPos - _AssetPixelWorldSize * floor(i.gridSnappedLocalPos / _AssetPixelWorldSize));
					float3 fragmentGridSnappedWorldPos = mul(unity_ObjectToWorld, float4(fragmentGridSnappedLocalPos.xyz,1));

					// Now we get our direction to light, shared for all fragments in the same art-pixel!
					float3 lightVector = fragmentGridSnappedWorldPos - _WorldSpaceLightPos0.xyz;


					
					float3 normal = normalize(rgbNormal);

					normal = mul(normal, unity_WorldToObject);
					
					
					float distance = length(float3(lightVector.x, lightVector.y, lightVector.z));
					float lightRange = 1.0 / unity_WorldToLight;
					float distPrc = distance / lightRange;
					float attenuation = max(_LightColor0.w * (1.0 - distPrc*distPrc), 0) ;

					float3 lightNormal = normalize(lightVector);
					

					float lookupOffset;				
#ifdef useDithering
					lookupOffset = 0;
					float2 gridSnappedUV = i.uv * (_MainTex_TexelSize.zw / _DitheringLookup_TexelSize.zw);
					gridSnappedUV = gridSnappedUV - (gridSnappedUV - _AssetPixelWorldSize * floor(gridSnappedUV / _AssetPixelWorldSize));

					lookupOffset = tex2D(_DitheringLookup, gridSnappedUV).r;
					lookupOffset = (lookupOffset * 2.66666666) - 1; // [0,0.75] -> [-1,1]
					lookupOffset = lookupOffset * _DitherPower;
#else
					lookupOffset = 0;
#endif


					float dotProd = ((dot(normal, lightNormal) + 1.0) / 2.0);
					dotProd = tex2D(_CellLookup, float2(dotProd + lookupOffset, 0)).r;
					dotProd = dotProd * 2 - 1;

					float averageLightColor = _LightColor0.w / 2;
					float3 desaturatedLightColor = _Intensity2 * float3(min(1.25,(averageLightColor * 9 + _LightColor0.r) / 10), min(1.25,(averageLightColor * 9 + _LightColor0.g) / 10),
														min(1.25 , (averageLightColor * 9 + _LightColor0.b) / 10));

					float3 highlights = float3(_Intensity * dotProd * _LightColor0.rgb);

					float3 retLight = highlights.rgb + desaturatedLightColor.rgb;
					float3 retBaseCol = col.rgb * i.col.rgb;
#ifdef ignoreMap

					return float4(((retLight * attenuation * retBaseCol) * normalSample.a).rgb * col.a, col.a);
#else
					return float4((retLight * attenuation * retBaseCol).rgb * col.a, col.a);
#endif
				}
				
				ENDCG
				
			} 
			
			
		}
}
