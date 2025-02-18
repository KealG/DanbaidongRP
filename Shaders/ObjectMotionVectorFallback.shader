Shader "Hidden/Universal Render Pipeline/ObjectMotionVectorFallback"
{
    SubShader
    {
        Pass
        {
            Name "MotionVectors"

            Tags{ "LightMode" = "MotionVectors" }

            HLSLPROGRAM
            #include_with_pragmas "Packages/com.unity.render-pipelines.danbaidong/ShaderLibrary/ObjectMotionVectors.hlsl"
            ENDHLSL
        }
    }
}
