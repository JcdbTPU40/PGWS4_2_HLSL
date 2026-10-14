Shader "Custom/NewUnlitUniversalRenderPipelineShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 頂点シェーダーの入力
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            // 頂点シェーダーの出力
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            // テクスチャー
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            // マテリアルのプロパティ
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            // 頂点シェーダー
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            // フラグメントシェーダー
            half4 frag(Varyings IN) : SV_Target
                {
                    half3 rainbow[6] = {
                        half3(1, 0, 0),   // 赤
                        half3(1, 1, 0),   // 黄
                        half3(0, 1, 0),   // 緑
                        half3(0, 1, 1),   // 水色
                        half3(0, 0, 1),   // 青
                        half3(1, 0, 1)    // 紫(マゼンタ)
                    };

                    float t = normalize(IN.normalWS).x * 0.5 + 0.5;   // 0〜1
                    float x = t * 5.0;                                // 0〜5
                    int i = min((int)floor(x), 4);                    // 区間の番号 0〜4
                    float f = x - i;                                  // 区間内の位置 0〜1

                    half3 rgb = lerp(rainbow[i], rainbow[i + 1], f);
                    return half4(rgb, 1);
                }
            ENDHLSL
        }
    }
}
