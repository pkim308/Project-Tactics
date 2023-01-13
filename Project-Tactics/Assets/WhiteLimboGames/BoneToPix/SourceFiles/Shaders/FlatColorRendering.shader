Shader "Custom/BoneToPix/FlatColorRendering"
{
    Properties {
		_MainTex("Albedo", 2D) = "white" {}
	}
	
	SubShader {
		
			Pass{
				
				Tags{
				}
				
				Blend SrcAlpha OneMinusSrcAlpha 
			
				
				CGPROGRAM

				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				#pragma vertex vert
				#pragma fragment frag
				

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

				fixed4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_MainTex, i.uv);
					return texCol * i.col;
				}
				
				ENDCG
				
			}
				
			
		}
}
