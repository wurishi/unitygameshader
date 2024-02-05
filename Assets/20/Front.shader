Shader "Hidden/Front"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // Tags { "Queue" = "Transparent" }

        Pass
        {
            Color(1, 0, 0, 1)
        }
    }
}
