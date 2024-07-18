Shader "DanbaidongRP/PBRToon/Face"
{
    Properties
    {
        [FoldoutBegin(_FoldoutTexEnd)]_FoldoutTex("Textures", float) = 0
            _BaseColor                      ("BaseColor", Color)                    = (1,1,1,1)
            _BaseMap                        ("BaseMap_d", 2D)                       = "white" {}
        [FoldoutEnd]_FoldoutTexEnd("_FoldoutEnd", float) = 0

        [FoldoutBegin(_FoldoutPBRPropEnd)]_FoldoutPBRProp("PBR Properties", float) = 0
            _Metallic                       ("Metallic",Range(0,1))                 = 0.5
            _Smoothness                     ("Smoothness",Range(0,1))               = 0.5
            _Occlusion                      ("Occlusion",Range(0,1))                = 1
        [FoldoutEnd]_FoldoutPBRPropEnd("_FoldoutPBRPropEnd", float) = 0

        [FoldoutBegin(_FoldoutDirectLightEnd)]_FoldoutDirectLight("Direct Light", float) = 0
            [HDR]_SelfLight                 ("SelfLight", Color)                    = (1,1,1,1)
            _MainLightColorLerp             ("Unity Light or SelfLight", Range(0,1))= 0
            _DirectOcclusion                ("DirectOcclusion",Range(0,1))          = 0.1
            
            [NoScaleOffset]
            _FaceLightMap                    ("FaceLightMap", 2D)                    = "white" {}

            [Title(Shadow)]
            _ShadowColor                    ("ShadowColor", Color)                  = (0,0,0,1)
            _ShadowOffset                   ("ShadowOffset",Range(-1,1))            = 0.5
            _ShadowSmoothNdotL              ("ShadowSmoothNdotL", Range(0,1))       = 0.25
            _ShadowSmoothScene              ("ShadowSmoothScene", Range(0,1))       = 0.1
            _ShadowStrength                 ("ShadowStrength", Range(0,1))          = 1.0

            [Title(Specular)]
            [HDR]_NoseSpecColor                ("NoseSpecColor", Color)                = (1,1,1,1)
            [RangeSlider(_NoseSpecMin, _NoseSpecMax)]_NoseSpecSlider("Range:Shadow to Light", Range(0, 1)) = 0
            _NoseSpecMin("NoseSpecMin", float) = 0
            _NoseSpecMax("NoseSpecMax", float) = 0.5

        [FoldoutEnd]_FoldoutDirectLightEnd("_FoldoutEnd", float) = 0


        // Ramp
        [FoldoutBegin(_FoldoutShadowRampEnd, _SHADOW_RAMP)]_FoldoutShadowRamp("ShadowRamp", float) = 0
        [HideInInspector]_SHADOW_RAMP("_SHADOW_RAMP", float) = 0
            [Ramp]_ShadowRampTex            ("ShadowRampTex", 2D)                   = "white" { }
        [FoldoutEnd]_FoldoutShadowRampEnd("_FoldoutEnd", float) = 0


        // Indirect Light
        [FoldoutBegin(_FoldoutIndirectLightEnd)]_FoldoutIndirectLight("Indirect Light", float) = 0
            [Title(Diffuse)]
            [HDR]_SelfEnvColor              ("SelfEnvColor", Color)                 = (0.5,0.5,0.5,0.5)
            _EnvColorLerp                   ("Unity SH or SelfEnv", Range(0,1))     = 0.5
            _IndirDiffUpDirSH               ("IndirDiffUpDirSH", Range(0,1))        = 0.0
            _IndirDiffIntensity             ("IndirDiffIntensity", Range(0,1))      = 1.0
            [Title(Specular)]
            [Toggle(_INDIR_CUBEMAP)]_INDIR_CUBEMAP("_INDIR_CUBEMAP", Float)         = 0
            [NoScaleOffset]
            _IndirSpecCubemap               ("SpecCube", cube)                      = "black" {}

            _IndirSpecCubeWeight            ("SpecCubeWeight", Range(0,1))          = 0.5
            _IndirSpecIntensity             ("IndirSpecIntensity", Range(0.01,5))   = 1.0

        [FoldoutEnd]_FoldoutIndirectLightEnd("_FoldoutEnd", float) = 0

        // Emission, Rim, etc.
        [FoldoutBegin(_FoldoutEmissRimEnd)]_FoldoutEmissRim("Emission, Rim, etc.", float) = 0

            [Title(Emission)]
            [HDR]_EmissionCol               ("EmissionCol", color)                  = (1,1,1,1)

            [Title(RimLight)]
            [HDR]_DirectRimFrontCol         ("DirectRimFrontCol", color)            = (1,1,1,0.5)
            [HDR]_DirectRimBackCol          ("DirectRimBackCol", color)             = (0.2,0.2,0.2,0.5)
            _DirectRimWidth                 ("DirectRimWidth", Range(0, 10))        = 2.5
            _PunctualRimWidth               ("PunctualRimWidth", Range(0, 10))      = 2.75
        [FoldoutEnd]_FoldoutEmissRimEnd("_FoldoutEnd", float) = 0

        // Outline
        [FoldoutBegin(_FoldoutOutlineEnd, PassSwitch, CharacterOutline)]_FoldoutOutline("Outline", float) = 0
            [KeysEnum(SN_VertColor, SN_VertNormal)]
            _OutLineNormalSource            ("Smooth Normal Source", float)         = 0
            _OutlineColor                   ("Outline Color", Color)                = (0, 0, 0, 0.8)
            _OutlineWidth                   ("Width", Range(0, 10))                 = 1.0
            _OutlineClampScale              ("ClampScale", Range(0.01, 5))          = 1
            [Title(Lighting)]
            [HDR]_OutlineDirectLightingColor    ("DirectColor", color)              = (1,1,1,0.5)
            _OutlineDirectLightingOffset        ("DirectOffset", Range(-1, 1))      = 0.0
            [HDR]_OutlinePunctualLightingColor  ("PunctualColor", color)            = (1,1,1,0.5)
            _OutlinePunctualLightingOffset      ("PunctualOffset", Range(-1, 1))    = 0.0

        [FoldoutEnd]_FoldoutOutlineEnd("_FoldoutEnd", float) = 0

        // EyelashOutter
        [FoldoutBegin(_FoldoutEyelashEnd, PassSwitch, CharacterTransparent)]_FoldoutEyelash("Eyelash", float) = 0
            _BaseColorOutter                ("BaseColor", Color)                    = (1,1,1,1)
            _BaseMapOutter                  ("BaseMap_d", 2D)                       = "white" {}
            _AlphaOutter                    ("Alpha", Range(0, 1))                  = 1
        [FoldoutEnd]_FoldoutEyelashEnd("_FoldoutEnd", float) = 0

        // Other Settings
        [Space(10)]
        [KeysEnum(FLAG_HAIRSHADOW, FLAG_EYELASH, FLAG_HAIRMASK)]
        _ToonFlagsKeywords                  ("ToonFlags", float)                    = -1
        [Enum(UnityEngine.Rendering.CullMode)] 
        _Cull                               ("Cull Mode", Float)                    = 2
        _AlphaClip                          ("AlphaClip", Range(0, 1))              = 1
        _AlphaClip2                          ("AlphaClip", Range(0, 1))              = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Geometry-110"
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Character"
        }
        LOD 300

        // GBuffer: write depth and normal
        UsePass "DanbaidongRP/PBRToon/Base/GBufferBase"

        // CharacterForward: shading
        Pass
        {
            Name "CharacterForward"
            Tags
            {
                "LightMode" = "CharacterForward"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite Off
            ZTest Equal
            Cull [_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // -------------------------------------
            // Shader Stages
            #pragma vertex ForwardToonVert
            #pragma fragment ForwardToonFrag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _SHADOW_RAMP
            #pragma shader_feature_local _INDIR_CUBEMAP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _PEROBJECT_SCREEN_SPACE_SHADOW
            #pragma multi_compile _ _GPU_LIGHTS_CLUSTER
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #include_with_pragmas "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/DeclareDepthTexture.hlsl"

            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/GPUCulledLights.hlsl"
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/PreIntegratedFGD.hlsl"
            #include "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/PerObjectShadows.hlsl"

            #include "Packages/com.unity.render-pipelines.danbaidong/Shaders/Material/PBRToon/PBRToon.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float3  _BaseColor;
            float4  _BaseMap_ST;

            // PBR Properties
            float   _Metallic;
            float   _Smoothness;
            float   _Occlusion;

            // Direct Light
            float4  _SelfLight;
            float   _MainLightColorLerp;
            float   _DirectOcclusion;

            // Shadow
            float4  _ShadowColor;
            float   _ShadowOffset;
            float   _ShadowSmoothNdotL;
            float   _ShadowSmoothScene;
            float   _ShadowStrength;

            // Specular
            float4  _NoseSpecColor;
            float   _NoseSpecMin;
            float   _NoseSpecMax;

            // Indirect
            float4  _SelfEnvColor;
            float   _EnvColorLerp;
            float   _IndirDiffUpDirSH;
            float   _IndirDiffIntensity;
            float   _IndirSpecCubeWeight;
            float   _IndirSpecIntensity;

            // Emission
            float4  _EmissionCol;
            // RimLight
            float4  _DirectRimFrontCol;
            float4  _DirectRimBackCol;
            float   _DirectRimWidth;
            float   _PunctualRimWidth;

            // FaceDirection
            float3 _FaceRightDirWS;
            float3 _FaceFrontDirWS;

            CBUFFER_END


            TEXTURE2D_X(_GBuffer0); // Toon Flags

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_FaceLightMap);
            SAMPLER(sampler_FaceLightMap);

            TEXTURE2D(_ShadowRampTex);
            SAMPLER(sampler_ShadowRampTex);

            TEXTURECUBE(_IndirSpecCubemap);

            struct Attributes
            {
                float4 vertex       :POSITION;
                float3 normal       :NORMAL;
                float4 tangent      :TANGENT;
                float4 color        :COLOR;
                float2 uv0          :TEXCOORD0;
                float2 uv1          :TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };
            struct Varyings 
            {
                float4 positionHCS      :SV_POSITION;
                float3 positionWS       :TEXCOORD0;
                float3 normalWS         :TEXCOORD1;
                float3 tangentWS        :TEXCOORD2;
                float3 biTangentWS      :TEXCOORD3;
                float4 color            :TEXCOORD4;
                float4 uv               :TEXCOORD5;// xy:uv0 zw:uv1
                float2 faceLightDot     :TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings ForwardToonVert(Attributes v)
            {
                Varyings o = (Varyings)0;
                
                UNITY_SETUP_INSTANCE_ID(v); 
                UNITY_TRANSFER_INSTANCE_ID(v,o); 
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.positionHCS = TransformObjectToHClip(v.vertex.xyz);
                o.positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.tangentWS = TransformObjectToWorldDir(v.tangent.xyz);
                o.biTangentWS = cross(o.normalWS,o.tangentWS) * v.tangent.w * GetOddNegativeScale();
                o.color = v.color;
                o.uv.xy = v.uv0.xy;
                o.uv.zw = v.uv1.xy;

                // Face lightmap dot value
                Light mainLight = GetMainLight();
                float3 lightDirWS = mainLight.direction;
                lightDirWS.xz = normalize(lightDirWS.xz);
                _FaceRightDirWS.xz = normalize(_FaceRightDirWS.xz);
                o.faceLightDot.x = dot(lightDirWS.xz, _FaceRightDirWS.xz);
                o.faceLightDot.y = saturate(dot(-lightDirWS.xz, _FaceFrontDirWS.xz) * 0.5 + _ShadowOffset);

                return o;
            }


            float4 ForwardToonFrag(Varyings i) : SV_Target0
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float  depth = i.positionHCS.z;
                float2 UV = i.uv.xy;
                float2 UV1 = i.uv.zw;
                float3 positionWS = i.positionWS;
                float2 screenUV = i.positionHCS.xy / _ScreenParams.xy;
                TransformScreenUV(screenUV);

                float2 faceLightMapUV = UV1;
                faceLightMapUV.x = 1 - faceLightMapUV.x;
                faceLightMapUV.x = i.faceLightDot.x < 0 ? 1 - faceLightMapUV.x : faceLightMapUV.x;

                // Tex Sample
                float4 mainTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, UV);
                float4 faceLightMap = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, faceLightMapUV);

                // Property prepare
                float emission               = 1 - mainTex.a;
                float metallic               = _Metallic;
                float smoothness             = _Smoothness;
                float occlusion              = _Occlusion;
                float directOcclusion        = 1;
                float3 albedo = mainTex.rgb * _BaseColor.rgb;

                float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
                float roughness           = PerceptualRoughnessToRoughness(perceptualRoughness);
                float roughnessSquare     = max(roughness * roughness, FLT_MIN);

                float faceSDF = faceLightMap.r;
                float faceShadowArea = faceLightMap.a;

                float3 normalWS = SafeNormalize(i.normalWS);

                // Rim Light
                float3 normalVS = TransformWorldToViewNormal(normalWS);
                normalVS = SafeNormalize(normalVS);

                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                float NdotV = dot(normalWS, viewDirWS);
                float clampedNdotV = ClampNdotV(NdotV);

                float3 directDiffuse = 0;
                float3 directSpecular = 0;
                float3 indirectDiffuse = 0;
                float3 indirectSpecular = 0;
                float3 rimColor = 0;

                float3 diffuseColor = ComputeDiffuseColor(albedo, metallic);
                float3 fresnel0 = ComputeFresnel0(albedo, metallic, DEFAULT_SPECULAR_VALUE);

                float3 specularFGD;
                float  diffuseFGD;
                float  reflectivity;
                GetPreIntegratedFGDGGXAndDisneyDiffuse(clampedNdotV, perceptualRoughness, fresnel0, specularFGD, diffuseFGD, reflectivity);
                float energyCompensation = 1.0 / reflectivity - 1.0;

                float directRimArea = GetCharacterDirectRimLightArea(normalVS, screenUV, depth, _DirectRimWidth);

                float hairShadowArea = 1;
                float4 gbuffer0 = SAMPLE_TEXTURE2D_X_LOD(_GBuffer0, sampler_PointClamp, screenUV, 0);
                uint toonFlags = DecodeToonFlags(gbuffer0.r);
                if ((toonFlags & kToonFlagHairShadow) != 0)
                {
                    hairShadowArea = 0;
                }

                // Accumulate Direct
                // Directional Lights
                uint dirLightIndex = 0;
                for (dirLightIndex = 0; dirLightIndex < _DirectionalLightCount; dirLightIndex++)
                {
                    DirectionalLightData dirLight = g_DirectionalLightDatas[dirLightIndex];

                    dirLight.lightColor = lerp(dirLight.lightColor, _SelfLight.rgb, _MainLightColorLerp);

                    #ifdef _LIGHT_LAYERS
                    if (IsMatchingLightLayer(dirLight.lightLayerMask, meshRenderingLayers))
                    #endif
                    {
                        float3 lightDirWS = dirLight.lightDirection;
                        float NdotL = dot(normalWS, lightDirWS);
                        
                        float clampedNdotL = saturate(NdotL);
                        float halfLambert = NdotL * 0.5 + 0.5;
                        float clampedRoughness = max(roughness, dirLight.minRoughness);

                        float LdotV, NdotH, LdotH, invLenLV;
                        GetBSDFAngle(viewDirWS, lightDirWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);
                        float3 lightDirVS = TransformWorldToViewDir(lightDirWS);
                        lightDirVS = SafeNormalize(lightDirVS);

                        // Shadow
                        // Remap Shadow area for NPR diffuse, but we should use clampedNdotL for PBR specular.
                        float shadowAttenuation = 1;
                        if (dirLightIndex == 0)
                        {
                            // Apply Shadows
                            // TODO: add different direct light shadowmap
                            shadowAttenuation = SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture, sampler_PointClamp, screenUV).x;
                            // #ifdef _PEROBJECT_SCREEN_SPACE_SHADOW
                            // shadowAttenuation = min(shadowAttenuation, SamplePerObjectScreenSpaceShadowmap(screenUV));
                            // #endif
                        }
                        
                        float shadowNdotL = SigmoidSharp(halfLambert, _ShadowOffset, _ShadowSmoothNdotL * 5);
                        float faceMapShadow = SigmoidSharp(faceSDF, i.faceLightDot.y, _ShadowSmoothNdotL * 5) * faceShadowArea;
                        float shadowScene = SigmoidSharp(shadowAttenuation, 0.5, _ShadowSmoothScene * 5);
                        float shadowArea = min(faceMapShadow, shadowScene);
                        shadowArea = min(shadowArea, hairShadowArea);
                        shadowArea = lerp(1, shadowArea, _ShadowStrength);

                        float3 shadowRamp = lerp(_ShadowColor.rgb, float3(1, 1, 1), shadowArea);
                        #ifdef _SHADOW_RAMP
                        shadowRamp = SampleDirectShadowRamp(TEXTURE2D_ARGS(_ShadowRampTex, sampler_ShadowRampTex), shadowArea).xyz;
                        #endif

                        // BRDF
                        float3 F = F_Schlick(fresnel0, LdotH);
                        float DV = DV_SmithJointGGX(NdotH, abs(NdotL), clampedNdotV, clampedRoughness);
                        float3 specTerm = F * DV;
                        float diffTerm = Lambert();

                        #ifdef _SHADOW_RAMP
                        float specRange = saturate(DV);
                        float3 specRampCol = SampleDirectSpecularRamp(TEXTURE2D_ARGS(_ShadowRampTex, sampler_ShadowRampTex), specRange).xyz;
                        specTerm = F * clamp(specRampCol.rgb + DV, 0, 10);
                        #endif

                        // Direct Rim Light
                        float3 frontRimCol = lerp(_DirectRimFrontCol.rgb, _DirectRimFrontCol.rgb * dirLight.lightColor,  _DirectRimFrontCol.a);
                        float3 backRimCol = lerp(_DirectRimBackCol.rgb, _DirectRimBackCol.rgb * dirLight.lightColor,  _DirectRimBackCol.a);
                        float3 directRim = GetRimColor(directRimArea, diffuseColor, normalVS, lightDirVS, shadowArea, frontRimCol, backRimCol);

                        // Nose Spec
                        float faceSpecStep = clamp(i.faceLightDot.y, 0.001, 0.999);
                        faceLightMapUV.x = 1 - faceLightMapUV.x;
                        faceLightMap = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, faceLightMapUV);
                        float noseSpecArea1 = step(faceSpecStep, faceLightMap.g);
                        float noseSpecArea2 = step(1 - faceSpecStep, faceLightMap.b);
                        float noseSpecArea = noseSpecArea1 * noseSpecArea2 * smoothstep(_NoseSpecMin, _NoseSpecMax, 1 - i.faceLightDot.y);
                        float3 noseSpecColor = _NoseSpecColor.rgb * _NoseSpecColor.a * noseSpecArea;

                        // Accumulate
                        directDiffuse += diffuseColor * diffTerm * shadowRamp * dirLight.lightColor * directOcclusion;
                        directSpecular += specTerm * clampedNdotL * shadowScene * dirLight.lightColor * directOcclusion + noseSpecColor;
                        rimColor += directRim;
                    }
                }

                // Punctual Lights
                uint lightCategory = LIGHTCATEGORY_PUNCTUAL;
                uint lightStart;
                uint lightCount;
                PositionInputs posInput = GetPositionInput(screenUV * _ScreenSize.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V, uint2(0, 0));
                GetCountAndStart(posInput, lightCategory, lightStart, lightCount);
                uint v_lightListOffset = 0;
                uint v_lightIdx = lightStart;

                if (lightCount > 0) // avoid 0 iteration warning.
                {
                    while (v_lightListOffset < lightCount)
                    {
                        v_lightIdx = FetchIndex(lightStart, v_lightListOffset);
                        if (v_lightIdx == -1)
                            break;

                        GPULightData gpuLight = FetchLight(v_lightIdx);

                        #ifdef _LIGHT_LAYERS
                        if (IsMatchingLightLayer(gpuLight.lightLayerMask, meshRenderingLayers))
                        #endif
                        {
                            float3 lightVector = gpuLight.lightPosWS - positionWS.xyz;
                            float distanceSqr = max(dot(lightVector, lightVector), FLT_MIN);
                            float3 lightDirection = float3(lightVector * rsqrt(distanceSqr));
                            float shadowMask = 1;

                            float distanceAtten = DistanceAttenuation(distanceSqr, gpuLight.lightAttenuation.xy) * AngleAttenuation(gpuLight.lightDirection.xyz, lightDirection, gpuLight.lightAttenuation.zw);
                            float shadowAtten = gpuLight.shadowType == 0 ? 1 : AdditionalLightShadow(gpuLight.shadowLightIndex, positionWS, lightDirection, shadowMask, gpuLight.lightOcclusionProbInfo);
                            float attenuation = distanceAtten * shadowAtten;

                            float3 lightDirWS = lightDirection;
                            float NdotL = dot(normalWS, lightDirWS);
                            
                            float clampedNdotL = saturate(NdotL);
                            float clampedRoughness = max(roughness, gpuLight.minRoughness);

                            float LdotV, NdotH, LdotH, invLenLV;
                            GetBSDFAngle(viewDirWS, lightDirWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);


                            float3 F = F_Schlick(fresnel0, LdotH);
                            float DV = DV_SmithJointGGX(NdotH, abs(NdotL), clampedNdotV, clampedRoughness);
                            float3 specTerm = F * DV;
                            float diffTerm = Lambert();

                            diffTerm *= clampedNdotL;
                            specTerm *= clampedNdotL;

                            // Punctual Rim Light
                            float3 lightDirVS = TransformWorldToViewDir(lightDirWS);
                            lightDirVS = SafeNormalize(lightDirVS);
                            float punctualRimArea = GetCharacterPunctualRimLightArea(lightDirVS, screenUV, depth, _PunctualRimWidth);
                            float3 punctualRim = GetRimColor(punctualRimArea, diffuseColor, normalVS, lightDirVS, 1, gpuLight.lightColor, float3(0,0,0));

                            directDiffuse += diffuseColor * diffTerm * gpuLight.lightColor * attenuation * gpuLight.baseContribution;
                            directSpecular += specTerm * gpuLight.lightColor * attenuation * gpuLight.baseContribution;
                            rimColor += punctualRim * attenuation * gpuLight.rimContribution;

                        }

                        v_lightListOffset++;
                    }
                }

                // Accumulate Indirect
                // Indirect Diffuse
                float3 SHNormal = lerp(normalWS, float3(0,1,0), _IndirDiffUpDirSH);
                float3 SHColor = SampleSH9(_AmbientProbeData, SHNormal); //EvaluateAmbientProbe(normalWS);
                SHColor = lerp(SHColor, _SelfEnvColor.rgb, _EnvColorLerp);

                indirectDiffuse += diffuseFGD * SHColor * diffuseColor;

                // Indirect Specular
                float3 reflectDirWS = reflect(-viewDirWS, normalWS);
                float reflectionHierarchyWeight = 0.0; // Max: 1.0

                #if defined(_INDIR_CUBEMAP)
                {
                    float weight = _IndirSpecCubeWeight;
                    UpdateLightingHierarchyWeights(reflectionHierarchyWeight, weight);
                    float mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
                    float3 cubeReflection = SAMPLE_TEXTURECUBE_LOD(_IndirSpecCubemap, sampler_LinearRepeat, reflectDirWS, mip).xyz;
                    indirectSpecular += specularFGD * cubeReflection * weight;
                }
                #endif

                // Evaluate SkyEnvironment
                {
                    float weight = 1.0;
                    UpdateLightingHierarchyWeights(reflectionHierarchyWeight, weight);
                    float3 skyReflection = SampleSkyEnvironment(reflectDirWS, perceptualRoughness);
                    indirectSpecular += specularFGD * skyReflection * weight;
                }


                // Apply ambient occlusion.
                indirectDiffuse *= occlusion;
                indirectSpecular *= occlusion;

                // Emission
                float3 emissResult = emission * lerp(_EmissionCol.rgb, _EmissionCol.rgb * albedo.rgb, _EmissionCol.a);
                
                float3 resultColor = directDiffuse + directSpecular 
                                    + indirectDiffuse * _IndirDiffIntensity + indirectSpecular * _IndirSpecIntensity 
                                    + emissResult + rimColor;


                return float4(resultColor, 1);
            }
            ENDHLSL

        }
        
        // EyelashOutter
        UsePass "DanbaidongRP/Helpers/CharacterEyelashOutter/CharacterTransparent"

        // Outline
        UsePass "DanbaidongRP/Helpers/Outline/ForwardOutline"

        // ShadowCaster
        UsePass "DanbaidongRP/PBRToon/Base/ShadowCaster"

        // DepthOnly
        UsePass "DanbaidongRP/PBRToon/Base/DepthOnly"

        // // DepthNormals
        // UsePass "DanbaidongRP/PBRToon/Base/DepthNormals"

    }

    CustomEditor "UnityEditor.DanbaidongGUI.DanbaidongGUI"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}