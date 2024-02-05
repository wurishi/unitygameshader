Shader "Custom/30"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal ("Normal", 2D) = "white" {}
        _A ("A", Float) = 2.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Normal;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Normal;

            float3 viewDir;
        };

        fixed4 _Color;
        float _A;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            // float3 tmpNormal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
            float3 tmpNormal = tex2D(_Normal, IN.uv_Normal);
            o.Normal = tmpNormal;
            float tmpFloat = 1 - clamp(dot(IN.viewDir, tmpNormal), 0, 1);
            o.Emission = _Color * pow(tmpFloat , _A);
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
