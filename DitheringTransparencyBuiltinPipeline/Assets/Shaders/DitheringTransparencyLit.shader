Shader "DitheringTransparency/DitheringTransparencyLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DitheringTex ("Dithering Texture", 2D) = "white" {}
        [ShowAsVector2] _DitheringScale ("Dithering Scale", Vector) = (4, 4, 0, 0)
        _CutOut ("Cut Out", Range(0, 1)) = 0.5
        _Alpha ("Alpha", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="true" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _Alpha;
        half _Glossiness;
        half _Metallic;
        sampler2D _DitheringTex;
        float2 _DitheringScale;
        fixed4 _Color;
        // float _CutOut;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float2 screenUV = IN.screenPos.xy / max(0.0001, IN.screenPos.w);
            float2 ditheringUV = screenUV * _ScreenParams.xy / _DitheringScale;
            float ditherValue = tex2D(_DitheringTex, ditheringUV).r;

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            float ditherAlpha = lerp(
                ditherValue - 1,
                ditherValue,
                _Alpha
            );
            float clipValue = o.Alpha * ditherAlpha;
            float _test = clipValue;
            o.Alpha = clipValue;
            // clip(_test);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
