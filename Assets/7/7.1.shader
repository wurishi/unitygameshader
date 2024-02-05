Shader "Hidden/7.1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _STex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Pass
        {
           Color (1, 0, 0, 1)

           // SetTexture [_MainTex]
           // {
           //     combine Primary * Texture
           // }

           // SetTexture [_STex]
           // {
           //     combine Previous lerp(Texture) Texture
           // }

            SetTexture [_MainTex]
            {
                // constantColor(1, 1, 0, 1)
                constantColor[_Color]

                combine Constant * Texture
            }
        }
    }
}
