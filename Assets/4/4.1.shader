Shader "Hidden/4.1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        name1("display name1", Range(0, 10)) = 5
        name2("display name2", Float) = 0.1
        name3("display name3", Int) = 1

        c ("display name", Color) = (1.0, 1.0, 0, 0)
        v ("display name", Vector) = (20, 20, 20, 20)

        t1 ("display name", 2D) = "defaulttexture" {}
        t2 ("display name", Cube) = "white" {}
        t3 ("display name", 3D) = "red" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            fixed4 c;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                col.rgb = c.rgb;
                return col;
            }
            ENDCG
        }
    }
}
