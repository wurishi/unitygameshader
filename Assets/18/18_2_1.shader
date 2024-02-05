Shader "Hidden/18_2_1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

        Pass
        {
            Color(1, 0, 0, 1)

            Offset 0, 1
        }
    }
}
