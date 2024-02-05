Shader "Hidden/5.1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color ("Color", Color) = (0, 1, 0, 1)
    }
    SubShader
    {
        Pass
        {
            // Color (1, 1, 0, 1) //设置顶点颜色

            // Color[_Color]

            Lighting On // 打开灯光
            Material
            {
                // Diffuse (1, 1, 1, 1)
                // Ambient (1, 1, 1, 1)
                Diffuse[_Color]
            }
        }
    }
}
