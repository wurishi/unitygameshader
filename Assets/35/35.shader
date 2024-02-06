Shader "Custom/35"
{
    Properties
    {
        _SColor ("spec Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _SpecPower ("Spec power", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf BRDFLighting

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _SColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) ;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        float _SpecPower;

        #define PI 3.1415926

        half4 LightingBRDFLighting(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            float3 H = normalize(lightDir + viewDir);
            float3 N = normalize(s.Normal);
            float d = (_SpecPower + 2) * pow(dot(N, H), _SpecPower) / 8.0;
            float f = _SColor + (1 - _SColor) * pow(1 - (dot(H, N)), 5);
            float k = 2 / sqrt(PI * (_SpecPower + 2));
            float v = 1 / (dot(N, lightDir) * (1 - k) + k) * (dot(N, viewDir) * (1 - k) + k);
            float all = d * f * v;

            float diff = dot(lightDir, N);
            float tmpResult = all + (1 - all) * diff;

            half4 finalColor = 0;

            finalColor.rgb = tmpResult * s.Albedo * _LightColor0.rgb;
            finalColor.a = s.Alpha;

            return finalColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
