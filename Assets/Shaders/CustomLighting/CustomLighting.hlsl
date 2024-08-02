void GetMainLight_half(half3 WorldPos, out half3 Direction, out half3 Color, 
	out half DistanceAtten, out half ShadowAtten)
{
#if SHADERGRAPH_PREVIEW
    Direction = float3(0.5, 0.5, 0);
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
#if SHADOWS_SCREEN
    float4 clipPos = TransformWorldToHClip(WorldPos);
    float4 shadowCoord = ComputeScreenPos(clipPos);
#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif
    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void GetAdditionalLight_half(int index, half3 worldpos, out half3 direction, out half3 color, out half distanceatten, out half shadowatten)
{

#ifdef SHADERGRAPH_PREVIEW
    direction = float3(0.5, 0.5, 0);
    color = 1;
    distanceatten = 1;
    shadowatten = 1;
#else
    Light light = GetAdditionalLight(index, worldpos);
    direction = light.direction;
    color = light.color;
    distanceatten = light.distanceAttenuation;
    shadowatten = light.shadowAttenuation;
#endif
}



void GetAdditionalLightCount_half(out int pixelLightCount)
{
#ifdef SHADERGRAPH_PREVIEW
    pixelLightCount = 0;
#else
    pixelLightCount = GetAdditionalLightsCount();
#endif
}




void LambertDiffuse_half(half3 color, half3 direction, half3 worldNormal, out half3 Out)
{
#if SHADERGRAPH_PREVIEW
    Out = 0;
#else
    Out = LightingLambert(color, direction, worldNormal);
#endif
}


void DirectSpecular_half(half3 Specular, half Smoothness, half3 Direction, half3 Color, half3 WorldNormal, half3 WorldView, out half3 Out)
{
#if SHADERGRAPH_PREVIEW
    Out = 0;
#else
    Smoothness = exp2(10 * Smoothness + 1);
    WorldNormal = normalize(WorldNormal);
    WorldView = SafeNormalize(WorldView);
    Out = LightingSpecular(Color, Direction, WorldNormal, WorldView, half4(Specular, 0), Smoothness);
#endif
}




void CalculateAdditionalLights_half(half3 SpecColor, half Smoothness, half3 WorldPosition, half3 WorldNormal, half3 WorldView, out half3 Diffuse, out half3 Specular)
{
    half3 diffuseColor = 0;
    half3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
    Smoothness = exp2(10 * Smoothness + 1);
    WorldNormal = normalize(WorldNormal);
    WorldView = SafeNormalize(WorldView);
    int pixelLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
        specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);
    }
#endif
    Diffuse = diffuseColor;
    Specular = specularColor;
}

