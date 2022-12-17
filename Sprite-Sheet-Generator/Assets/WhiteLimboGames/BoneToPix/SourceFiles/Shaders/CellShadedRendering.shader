Shader "Custom/BoneToPix/CellShadedRendering"
{
    Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_CellLookup("Lighting cell lookup", 2D) = "white" {}
		_AmbientLight("AmbientLight", Vector) = (0,0,0)
	}
	
	SubShader {
		
			Pass{
				
				Tags{
					"LightMode" = "ForwardBase"
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
					float3 normal : NORMAL;
				};
					
				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 col : COLOR0;
					float3 viewNormal : NORMAL;
					float4 worldPos : TEXCOORD2;
					float3 viewDir : TEXCOORD3;
				};
				

				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.col = v.col;
					o.viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
					return o;
				}
					
				sampler2D _MainTex;
				sampler2D _CellLookup;
				uniform float4 _LightColor0;
				uniform Vector _AmbientLight;

				fixed4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_MainTex, i.uv);

					float3 normal = normalize(i.viewNormal);
					float ndotl = dot(normal, _WorldSpaceLightPos0);

					float3 lookUpVal = tex2D(_CellLookup, float2(ndotl, 0)); 

					float3 directDiffuse = lookUpVal * _LightColor0;

					fixed4 col = texCol;
					col.rgb *= directDiffuse + _AmbientLight.rgb;
					col *= i.col;
					return  col;
				}
				
				ENDCG
				
			}
				
			Pass{

				Tags{
					"LightMode" = "ForwardAdd"
				}

				Blend One One
				ZWrite Off

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
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 col : COLOR0;
					float3 viewNormal : TEXCOORD2;
					float3 viewDir : TEXCOORD3;
					float3 worldPos : TEXCOORD4;
				};


				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.col = v.col;
					o.viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
					return o;
				}

				sampler2D _MainTex;
				sampler2D _CellLookup;
				uniform float4 _LightColor0;
				uniform Vector _AmbientLight;

				fixed4 frag(v2f i) : SV_Target
				{
					float4 texCol = tex2D(_MainTex, i.uv);

					float3 normal = normalize(i.viewNormal);

					float3 light = float3(_WorldSpaceLightPos0.x, _WorldSpaceLightPos0.y, _WorldSpaceLightPos0.z);
					float3 lightVector = float3(light.x - i.worldPos.x, light.y - i.worldPos.y, light.z - i.worldPos.z);
					float3 lightNormal = normalize(lightVector);

					float ndotl = dot(normal, lightNormal);

					float3 lookUpVal = tex2D(_CellLookup, float2(1 - ndotl, 0));

					float3 directDiffuse = lookUpVal * _LightColor0;

					fixed4 col = texCol;
					col.rgb *= directDiffuse + directDiffuse / 10;
					col *= i.col;
					return  col;
				}

				ENDCG

			}


		}
}
