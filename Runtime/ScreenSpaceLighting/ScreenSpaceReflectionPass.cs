using System;
using UnityEngine.Experimental.Rendering;

namespace UnityEngine.Rendering.Universal
{
    internal class ScreenSpaceReflectionPass : ScriptableRenderPass
    {
        // Profiling tag
        private static string m_SSRTracingProfilerTag = "SSRTracing";
        private static string m_SSRReprojectionProfilerTag = "SSRReprojection";
        private static string m_SSRAccumulateProfilerTag = "SSRAccumulate";
        private static ProfilingSampler m_SSRTracingProfilingSampler = new ProfilingSampler(m_SSRTracingProfilerTag);
        private static ProfilingSampler m_SSRReprojectionProfilingSampler = new ProfilingSampler(m_SSRReprojectionProfilerTag);
        private static ProfilingSampler m_SSRAccumulateProfilingSampler = new ProfilingSampler(m_SSRAccumulateProfilerTag);

        // Public Variables

        // Private Variables
        private ComputeShader m_Compute;
        private ScreenSpaceReflectionSettings m_CurrentSettings;
        private int m_BlueNoiseTexArrayIndex;

        private RTHandle m_SSRHitPointTexture;
        private RTHandle m_SSRLightingTexture;

        private int m_SSRTracingKernel;
        private int m_SSRReprojectionKernel;
        private int m_SSRAccumulateKernel;
        private ScreenSpaceReflection m_volumeSettings;
        private UniversalRenderer m_Renderer;
        private HistoryFrameRTSystem m_CurCameraHistoryRTSystem;

        // Constants

        // Statics
        private static Vector2 s_accumulateTextureScaleFactor = Vector2.one;

        internal ScreenSpaceReflectionPass(ComputeShader computeShader)
        {
            m_CurrentSettings = new ScreenSpaceReflectionSettings();
            m_Compute = computeShader;

            m_SSRTracingKernel = m_Compute.FindKernel("ScreenSpaceReflectionsTracing");
            m_SSRReprojectionKernel = m_Compute.FindKernel("ScreenSpaceReflectionsReprojection");
            m_SSRAccumulateKernel = m_Compute.FindKernel("ScreenSpaceReflectionsAccumulate");

            m_BlueNoiseTexArrayIndex = 0;
        }

        /// <summary>
        /// Setup controls per frame shouldEnqueue this pass.
        /// </summary>
        /// <param name="settings"></param>
        /// <param name="renderingData"></param>
        /// <returns></returns>
        internal bool Setup(ScreenSpaceReflectionSettings settings, UniversalRenderer renderer)
        {
            m_CurrentSettings = settings;
            m_Renderer = renderer;

            var stack = VolumeManager.instance.stack;
            m_volumeSettings = stack.GetComponent<ScreenSpaceReflection>();

            // Let renderer know we need history color.
            ConfigureInput(ScriptableRenderPassInput.HistoryColor | ScriptableRenderPassInput.Motion);

            return m_Compute != null && m_volumeSettings != null;
        }

        static RTHandle HistoryAccumulateTextureAllocator(GraphicsFormat graphicsFormat, string viewName, int frameIndex, RTHandleSystem rtHandleSystem)
        {
            frameIndex &= 1;

            return rtHandleSystem.Alloc(Vector2.one * s_accumulateTextureScaleFactor, TextureXR.slices, colorFormat: graphicsFormat,
                 filterMode: FilterMode.Point, enableRandomWrite: true,  useDynamicScale: true,
                name: string.Format("{0}_SSRAccumTexture{1}", viewName, frameIndex));
        }

        internal void ReAllocatedAccumulateTextureIfNeeded(HistoryFrameRTSystem historyRTSystem, CameraData cameraData)
        {
            var curTexture = historyRTSystem.GetCurrentFrameRT(HistoryFrameType.ScreenSpaceReflectionAccumulation);

            if (curTexture == null)
            {
                historyRTSystem.ReleaseHistoryFrameRT(HistoryFrameType.ScreenSpaceReflectionAccumulation);
                
                historyRTSystem.AllocHistoryFrameRT((int)HistoryFrameType.ScreenSpaceReflectionAccumulation, cameraData.camera.name
                                                            , HistoryAccumulateTextureAllocator, GraphicsFormat.R16G16B16A16_SFloat, 2);
            }

        }

        /// <inheritdoc/>
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            m_CurCameraHistoryRTSystem = HistoryFrameRTSystem.GetOrCreate(renderingData.cameraData.camera);
            var desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0;
            desc.msaaSamples = 1;
            desc.graphicsFormat = GraphicsFormat.R16G16_UNorm;
            desc.enableRandomWrite = true;

            RenderingUtils.ReAllocateIfNeeded(ref m_SSRHitPointTexture, desc, FilterMode.Point, TextureWrapMode.Clamp, name: "_SSRHitPointTexture");


            desc.graphicsFormat = GraphicsFormat.R16G16B16A16_SFloat;
            RenderingUtils.ReAllocateIfNeeded(ref m_SSRLightingTexture, desc, FilterMode.Point, TextureWrapMode.Clamp, name: "_SSRLightingTexture");

            if (m_volumeSettings.usedAlgorithm == ScreenSpaceReflectionAlgorithm.PBRAccumulation)
            {
                ReAllocatedAccumulateTextureIfNeeded(m_CurCameraHistoryRTSystem, renderingData.cameraData);
            }
        }

        /// <inheritdoc/>
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Compute == null)
            {
                Debug.LogErrorFormat("{0}.Execute(): Missing computeShader. ScreenSpaceReflection pass will not execute.", GetType().Name);
                return;
            }

            var cmd = renderingData.commandBuffer;
            using (new ProfilingScope(cmd, ProfilingSampler.Get(URPProfileId.SSR)))
            {

                // Default Approximation we use lighingTexture as ssrReprojection handle.
                var ssrReprojectionHandle = m_SSRLightingTexture;
                var currAccumHandle = m_CurCameraHistoryRTSystem.GetCurrentFrameRT(HistoryFrameType.ScreenSpaceReflectionAccumulation);
                var prevAccumHandle = m_CurCameraHistoryRTSystem.GetPreviousFrameRT(HistoryFrameType.ScreenSpaceReflectionAccumulation);

                if (m_volumeSettings.usedAlgorithm == ScreenSpaceReflectionAlgorithm.Approximation)
                {
                    cmd.EnableShaderKeyword("SSR_APPROX");
                }
                else
                {
                    // TODO: Clear accum and accum prev
                    ssrReprojectionHandle = currAccumHandle;

                    cmd.DisableShaderKeyword("SSR_APPROX");
                }

                using (new ProfilingScope(cmd, m_SSRTracingProfilingSampler))
                {
                    cmd.SetRenderTarget(m_SSRHitPointTexture);
                    cmd.ClearRenderTarget(RTClearFlags.Color, Color.black, 0, 0);

                    var stencilBuffer = renderingData.cameraData.renderer.cameraDepthTargetHandle.rt.depthBuffer;
                    float n = renderingData.cameraData.camera.nearClipPlane;
                    float f = renderingData.cameraData.camera.farClipPlane;
                    float thickness = m_volumeSettings.depthBufferThickness.value;
                    float thicknessScale = 1.0f / (1.0f + thickness);
                    float thicknessBias = -n / (f - n) * (thickness * thicknessScale);

                    // ColorPyramidSize 
                    Vector4 colorPyramidUvScaleAndLimitPrev = RenderingUtils.ComputeViewportScaleAndLimit(m_CurCameraHistoryRTSystem.rtHandleProperties.previousViewportSize, m_CurCameraHistoryRTSystem.rtHandleProperties.previousRenderTargetSize);

                    var blueNoise = BlueNoiseSystem.TryGetInstance();
                    if (blueNoise != null)
                    {
                        m_BlueNoiseTexArrayIndex = (m_BlueNoiseTexArrayIndex + 1) % BlueNoiseSystem.blueNoiseArraySize;
                        blueNoise.BindSTBNVec2Texture(cmd, m_BlueNoiseTexArrayIndex);
                    }

                    cmd.SetComputeTextureParam(m_Compute, m_SSRTracingKernel, "_SSRHitPointTexture", m_SSRHitPointTexture);

                    // Constant Params
                    // TODO: Should use ConstantBuffer
                    // ConstantBuffer.Push(ctx.cmd, data.cb, cs, HDShaderIDs._ShaderVariablesScreenSpaceReflection);
                    {
                        // Wtf? It seems that Unity has not setted this jittered matrix (or changed by something)?
                        // We will transfer our own Temporal AA jittered matrices and use it in SSR compute.
                        Matrix4x4 viewMatrix = renderingData.cameraData.GetViewMatrix();
                        // Jittered, non-gpu
                        //Matrix4x4 projectionMatrix = renderingData.cameraData.GetProjectionMatrix();
                        // Jittered, gpu
                        Matrix4x4 gpuProjectionMatrix = renderingData.cameraData.GetGPUProjectionMatrix(renderingData.cameraData.IsCameraProjectionMatrixFlipped());
                        Matrix4x4 viewAndProjectionMatrix = gpuProjectionMatrix * viewMatrix;
                        Matrix4x4 inverseViewMatrix = Matrix4x4.Inverse(viewMatrix);
                        Matrix4x4 inverseProjectionMatrix = Matrix4x4.Inverse(gpuProjectionMatrix);
                        Matrix4x4 inverseViewProjection = inverseViewMatrix * inverseProjectionMatrix;

                        cmd.SetComputeMatrixParam(m_Compute, "_SSR_MATRIX_VP", viewAndProjectionMatrix);
                        cmd.SetComputeMatrixParam(m_Compute, "_SSR_MATRIX_I_VP", inverseViewProjection);

                        cmd.SetComputeIntParam(m_Compute, "_SsrStencilBit", (int)(1 << 3));
                        cmd.SetComputeFloatParam(m_Compute, "_SsrRoughnessFadeEnd", 1 - m_volumeSettings.minSmoothness);
                        cmd.SetComputeIntParam(m_Compute, "_SsrDepthPyramidMaxMip", m_Renderer.depthBufferMipChainInfo.mipLevelCount - 1);
                        cmd.SetComputeIntParam(m_Compute, "_SsrReflectsSky", m_volumeSettings.reflectSky.value ? 1 : 0);
                        cmd.SetComputeIntParam(m_Compute, "_SsrIterLimit", m_volumeSettings.rayMaxIterations);
                        cmd.SetComputeFloatParam(m_Compute, "_SsrThicknessScale", thicknessScale);
                        cmd.SetComputeFloatParam(m_Compute, "_SsrThicknessBias", thicknessBias);
                        cmd.SetComputeFloatParam(m_Compute, "_SsrPBRBias", m_volumeSettings.biasFactor.value);
                        cmd.SetComputeVectorParam(m_Compute, "_ColorPyramidUvScaleAndLimitPrevFrame", colorPyramidUvScaleAndLimitPrev);

                        cmd.SetComputeBufferParam(m_Compute, m_SSRTracingKernel, "_DepthPyramidMipLevelOffsets", m_Renderer.depthBufferMipChainInfo.GetOffsetBufferData(m_Renderer.depthPyramidMipLevelOffsetsBuffer));
                    }


                    cmd.DispatchCompute(m_Compute, m_SSRTracingKernel, RenderingUtils.DivRoundUp(m_SSRHitPointTexture.rt.width, 8), RenderingUtils.DivRoundUp(m_SSRHitPointTexture.rt.height, 8), 1);
                }

                using (new ProfilingScope(cmd, m_SSRReprojectionProfilingSampler))
                {
                    cmd.SetRenderTarget(ssrReprojectionHandle);
                    cmd.ClearRenderTarget(RTClearFlags.Color, new Color(0, 0, 0, 0), 0, 0);

                    cmd.SetComputeTextureParam(m_Compute, m_SSRReprojectionKernel, "_SSRHitPointTexture", m_SSRHitPointTexture);
                    cmd.SetComputeIntParam(m_Compute, "_SsrColorPyramidMaxMip", m_Renderer.colorPyramidHistoryMipCount - 1);
                    cmd.SetComputeTextureParam(m_Compute, m_SSRReprojectionKernel, "_ColorPyramidTexture", HistoryFrameRTSystem.GetOrCreate(renderingData.cameraData.camera).GetPreviousFrameRT(HistoryFrameType.ColorBufferMipChain));
                    cmd.SetComputeTextureParam(m_Compute, m_SSRReprojectionKernel, "_SSRAccumTexture", ssrReprojectionHandle);
                    cmd.SetComputeTextureParam(m_Compute, m_SSRReprojectionKernel, "_CameraMotionVectorsTexture", m_Renderer.m_MotionVectorColor);

                    // Constant Params
                    {
                        float ssrRoughnessFadeEnd = 1 - m_volumeSettings.minSmoothness;
                        float roughnessFadeStart = 1 - m_volumeSettings.smoothnessFadeStart;
                        float roughnessFadeLength = ssrRoughnessFadeEnd - roughnessFadeStart;

                        cmd.SetComputeFloatParam(m_Compute, "_SsrEdgeFadeRcpLength", Mathf.Min(1.0f / m_volumeSettings.screenFadeDistance.value, float.MaxValue));
                        cmd.SetComputeFloatParam(m_Compute, "_SsrRoughnessFadeRcpLength", (roughnessFadeLength != 0) ? (1.0f / roughnessFadeLength) : 0);
                        cmd.SetComputeFloatParam(m_Compute, "_SsrRoughnessFadeEndTimesRcpLength", ((roughnessFadeLength != 0) ? (ssrRoughnessFadeEnd * (1.0f / roughnessFadeLength)) : 1));
                    }

                    cmd.DispatchCompute(m_Compute, m_SSRReprojectionKernel, RenderingUtils.DivRoundUp(ssrReprojectionHandle.rt.width, 8), RenderingUtils.DivRoundUp(ssrReprojectionHandle.rt.height, 8), 1);
                }

                if (m_volumeSettings.usedAlgorithm == ScreenSpaceReflectionAlgorithm.PBRAccumulation)
                {
                    using (new ProfilingScope(cmd, m_SSRAccumulateProfilingSampler))
                    {
                        cmd.SetComputeTextureParam(m_Compute, m_SSRAccumulateKernel, "_SSRHitPointTexture", m_SSRHitPointTexture);
                        cmd.SetComputeTextureParam(m_Compute, m_SSRAccumulateKernel, "_SSRAccumTexture", currAccumHandle);
                        cmd.SetComputeTextureParam(m_Compute, m_SSRAccumulateKernel, "_SsrAccumPrev", prevAccumHandle);
                        cmd.SetComputeTextureParam(m_Compute, m_SSRAccumulateKernel, "_SsrLightingTexture", m_SSRLightingTexture);
                        cmd.SetComputeTextureParam(m_Compute, m_SSRAccumulateKernel, "_CameraMotionVectorsTexture", m_Renderer.m_MotionVectorColor);

                        cmd.DispatchCompute(m_Compute, m_SSRAccumulateKernel, RenderingUtils.DivRoundUp(m_SSRLightingTexture.rt.width, 8), RenderingUtils.DivRoundUp(m_SSRLightingTexture.rt.height, 8), 1);
                    }
                }


                cmd.SetGlobalTexture("_SsrLightingTexture", m_SSRLightingTexture);
            }

        }

        /// <inheritdoc/>
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null)
                throw new ArgumentNullException("cmd");

            // Clean Keyword if need
            //CoreUtils.SetKeyword(cmd, ShaderKeywordStrings, false);
        }

        /// <summary>
        /// Clean up resources used by this pass.
        /// </summary>
        public void Dispose()
        {
            m_SSRHitPointTexture?.Release();
            m_SSRLightingTexture?.Release();
        }
    }
}