#define CUSTOM_LIGHTING_INCLUDED

struct CustomLightingData
{
	float4 normalWS;
	
	float3 gridSnappedPositionWS;

	float4 albedo;

	UnityTexture2D  cellLookup;
	UnitySamplerState cellLookupSamplerState;

	float highlightsIntensity; 
	float desaturatedLightIntensity;

	float4 VertexColor;

	half4 ignoreMap;

	float DitheringLookupOffset;

	UnityTexture2D ditheringLookup;
	UnitySamplerState ditheringLookupSamplerState;
	float2 uv;
	float assetPixelWorldSize;
	float ditherPower;

};


#ifndef SHADERGRAPH_PREVIEW

float4 CustomLightHandling(CustomLightingData d, Light light, float distanceAttenuation, float baseColorMultiplier)
{
	float lookupOffset;				
#if _DITHERING_ON
	lookupOffset = 0;
	float2 gridSnappedUV = d.uv * (_MainTex_TexelSize.zw / DitheringLookup_TexelSize.zw);
	gridSnappedUV = gridSnappedUV - (gridSnappedUV - d.assetPixelWorldSize * floor(gridSnappedUV / d.assetPixelWorldSize));

	lookupOffset = d.ditheringLookup.Sample(d.ditheringLookupSamplerState, gridSnappedUV).r;
	lookupOffset = (lookupOffset * 2.66666666) - 1; // [0,0.75] -> [-1,1]
	lookupOffset = lookupOffset * d.ditherPower;
#else
	lookupOffset = 0;
#endif

	float dotProd = (dot(d.normalWS.xyz, -light.direction) + 1.0) / 2.0;
	dotProd = d.cellLookup.Sample(d.cellLookupSamplerState, float2(dotProd + lookupOffset,0)).r;
	dotProd = dotProd * 2 - 1;

	// Note: Slightly different layout here compared to built-in render pipeline, since URP pre-mulitplies light intensity and gives no method for 
	float aproximateLightIntensity = (light.color.r + light.color.g + light.color.b) / 3;
	float averageLightColor = (light.color.r + light.color.g + light.color.b) / 2;

	half3 desaturatedLightColor = d.desaturatedLightIntensity * half3(min(1.25, (averageLightColor * 9 + light.color.r) / 10),
																	min(1.25, (averageLightColor * 9 + light.color.g) / 10),
																	min(1.25, (averageLightColor * 9 + light.color.b) / 10));

	half3 highlights = half3(d.highlightsIntensity * dotProd * light.color.rgb);
	
	float3 retLight = highlights.rgb + desaturatedLightColor.rgb;
	float4 retBaseCol = d.albedo * d.VertexColor;

#if _IGNORE_MAP_ON
	return float4(((retLight * distanceAttenuation * retBaseCol) * d.normalWS.a + retBaseCol * baseColorMultiplier * (1 - d.normalWS.a)).rgb * d.albedo.a, d.albedo.a);
#else
	return float4((retLight * distanceAttenuation * retBaseCol).rgb * d.albedo.a, d.albedo.a);
#endif
}

float4 CustomPointLightHandling(CustomLightingData d, Light light, float3 lightPositionWS, float lightRange)
{
	float distanceToLight = length(d.gridSnappedPositionWS - lightPositionWS);
	float distancePrc = distanceToLight / lightRange;
	float customAttenuation = max(1.0 - (distancePrc * distancePrc), 0);

	return CustomLightHandling(d, light, customAttenuation, 0.0);
}

float4 CustomDirectionalLightHandling(CustomLightingData d, Light light)
{
	return CustomLightHandling(d, light, 1.0, 1.0);
}

#endif

float4 CalculateCustomLighting(CustomLightingData d)
{
#ifdef SHADERGRAPH_PREVIEW
	float3 lightDir = float3(0.5, 0.5, 0);
	float intensity = saturate(dot(d.normalWS.xyz, lightDir));
	return d.albedo * intensity;
#else

	Light mainLight = GetMainLight();
	
	float4 color = 0;
	color += CustomDirectionalLightHandling(d, mainLight);

	#ifdef _ADDITIONAL_LIGHTS
	uint numAdditionalLights = GetAdditionalLightsCount();
	for (uint lightI = 0; lightI < numAdditionalLights; lightI++) 
	{
		uint lightIndexInBuffer = GetPerObjectLightIndex(lightI);

#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
		float4 lightPositionWS = _AdditionalLightsBuffer[lightIndexInBuffer].position;
		float lightRange = rsqrt(_AdditionalLightsBuffer[lightIndexInBuffer].attenuation);
#else
		float4 lightPositionWS = _AdditionalLightsPosition[lightIndexInBuffer];
		float lightRange = rsqrt(_AdditionalLightsAttenuation[lightIndexInBuffer]);
#endif

		Light light = GetAdditionalLight(lightI, d.gridSnappedPositionWS, 1);
		color += CustomPointLightHandling(d, light, lightPositionWS, lightRange);
	}
	#endif

	return float4(color.rgb, d.albedo.a);
#endif
}


void CalculateCustomLighting_float(float3 GridSnappedWorldSpacePos, float4 Albedo, float4 NormalIn, UnityTexture2D CellLookup, UnitySamplerState cellLookupSampleState, 
								   float hlIntensity, float desIntensity, float4 vertexColor, UnityTexture2D ditheringLookup, UnitySamplerState ditheringLookupSamplerState,
								   float2 uv, float assetPixelWorldSize, float ditherPower, out float4 Color)
{
	CustomLightingData d;
	d.normalWS = NormalIn; // Note this is already in [-1,1]
	d.gridSnappedPositionWS = GridSnappedWorldSpacePos;
	d.albedo = Albedo;
	d.cellLookup = CellLookup;
	d.cellLookupSamplerState = cellLookupSampleState;
	d.highlightsIntensity = hlIntensity;
	d.desaturatedLightIntensity = desIntensity;
	d.VertexColor = vertexColor;
	d.ditheringLookup = ditheringLookup;
	d.ditheringLookupSamplerState = ditheringLookupSamplerState;
	d.uv = uv;
	d.assetPixelWorldSize = assetPixelWorldSize;
	d.ditherPower = ditherPower;

	Color = CalculateCustomLighting(d);
}


