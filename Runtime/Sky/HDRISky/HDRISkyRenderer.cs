namespace UnityEngine.Rendering.Universal
{
    public class HDRISkyRenderer : SkyRenderer
    {
        private Material m_SkyHDRIMaterial;
        private MaterialPropertyBlock m_PropertyBlock;

        public HDRISkyRenderer()
        {
            SupportDynamicSunLight = false;
        }

        /// <summary>
        /// Create materials.
        /// </summary>
        public override void Build()
        {
            if (m_SkyHDRIMaterial == null)
            {
                m_SkyHDRIMaterial = CoreUtils.CreateEngineMaterial(UniversalRenderPipelineGlobalSettings.instance.renderPipelineRuntimeResources.shaders.hdriSkyPS);
            }

            m_PropertyBlock = new MaterialPropertyBlock();
        }

        /// <summary>
        /// Clean up resources.
        /// </summary>
        public override void Cleanup()
        {
            CoreUtils.Destroy(m_SkyHDRIMaterial);
        }

        public override void RenderSky(CommandBuffer cmd, ref RenderingData renderingData, SkySettings skySettings, bool renderForCubemap)
        {
            HDRISky hdriSky = skySettings as HDRISky;

            float intensity = GetSkyIntensity(skySettings);
            float phi = -Mathf.Deg2Rad * hdriSky.rotation.value;
            
            
            m_SkyHDRIMaterial.SetTexture(ShaderConstants._Cubemap, hdriSky.hdriSky.value != null ? hdriSky.hdriSky.value
                                                                    : UniversalRenderPipelineGlobalSettings.instance.renderPipelineRuntimeResources.textures.defaultHDRISky);
            m_SkyHDRIMaterial.SetVector(ShaderConstants._SkyParam, new Vector4(intensity, 0.0f, Mathf.Cos(phi), Mathf.Sin(phi)));
            m_PropertyBlock.SetMatrix(ShaderConstants._PixelCoordToViewDirWS, renderingData.cameraData.GetPixelCoordToViewDirWSMatrix());

            CoreUtils.DrawFullScreen(cmd, m_SkyHDRIMaterial, m_PropertyBlock, renderForCubemap ? 0 : 1);
        }

        static class ShaderConstants
        {
            public static readonly int _Cubemap = Shader.PropertyToID("_Cubemap");
            public static readonly int _SkyParam = Shader.PropertyToID("_SkyParam");
            public static readonly int _PixelCoordToViewDirWS = Shader.PropertyToID("_PixelCoordToViewDirWS");
        }
    }

}
