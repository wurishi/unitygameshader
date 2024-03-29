Shader "Custom/34"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _FogStart ("FogStart", float) = 1
        _FogEnd ("FogEnd", float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert vertex:MyVertex finalcolor:FinalColor

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;

            float fogData;
        };

        fixed4 _Color;
        float _FogStart;
        float _FogEnd;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void MyVertex(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float tmpZ = length(UnityObjectToViewPos(v.vertex).xyz); // 顶点到相机的距离

            o.fogData = (_FogEnd - tmpZ) / (_FogEnd - _FogStart);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        void FinalColor(Input IN, SurfaceOutput o, inout fixed4 color)
        {
            color = lerp(float4(1, 0, 0, 1), color, IN.fogData);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
