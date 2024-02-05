Shader "Hidden/15_1.0"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

        AlphaTest Greater 0.5

        Pass
        {
            SetTexture[_MainTex]
            {
                combine texture
            }
        }
    }
}
