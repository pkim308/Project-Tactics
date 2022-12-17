Shader "Custom/BoneToPix/NormalMapRendering"
{
    Properties {
		_MainTex("MainTex", 2D) = "white"
		_CellLookup("Cell shading lookup", 2D) = "white"
		[Toggle(cellShadeNormal)]
		_CellShadeNormal("CellShadeNormal", Float) = 0


	}
	
	SubShader {
		
			Pass{
				
				Tags{
				}
				
				Blend One Zero 
			
				
				CGPROGRAM

				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				#pragma vertex vert
				#pragma fragment frag
				
				#pragma shader_feature_local cellShadeNormal
				#pragma shader_feature_local Zforward

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};
					
				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					half3 viewNormal : NORMAL;
				};
				

				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					//o.worldNormal = (UnityObjectToWorldNormal(v.normal) * 0.5) + 0.5;
					o.viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
					o.uv = v.uv;
					return o;
				}
					
				sampler2D _CellLookup;
				sampler2D _MainTex;

				fixed4 frag(v2f i) : SV_Target
				{
					float4 bump = tex2D(_MainTex, i.uv);


#ifdef cellShadeNormal
					float r = tex2D(_CellLookup, 1.0 - ((i.viewNormal.r + 1) / 2));
					float g = tex2D(_CellLookup, 1.0 - ((i.viewNormal.g + 1) / 2));
					float b = tex2D(_CellLookup, 1.0 - ((i.viewNormal.b + 1) / 2));
					return float4(r,g,b, 1.0) * bump;
#else
					return float4((i.viewNormal.rgb + 1) / 2, bump.a);
#endif
				}
				
				ENDCG
				
			}
				
			
		}
}
