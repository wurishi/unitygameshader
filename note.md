# 2. 渲染流程

OpenGL 渲染流程：

- CPU: 
  - 模型文件 (fbx, obj 等)：包含了 uv, 顶点位置，法线，切线等渲染需要的信息。
  - MeshRender：导入模型文件后，Unity 会自动附加 MeshRender 组件，该组件负责将上述渲染需要的信息传递到 GPU。一般有二种：
    - SkinMeshRender：带蒙皮的骨骼。
    - MeshRender和MeshFilter：MeshRender 将顶点信息传递到 GPU, MeshFilter 通过 `mesh`属性将指定的形状顶点传递到 GPU。
- GPU:
  - 渲染管线
    - 顶点着色器：计算顶点颜色，将物体坐标系转换到相机坐标系。
    - 光栅化：将顶点转换为像素。
    - 片段着色器：纹理采样（从纹理像素赋给像素），像素与灯光进行计算。
      - 像素由 RGBA 四通道组成。
      - 顶点之间的像素颜色将根据顶点作插值获得。
    - Alpha 测试：挑选合格的像素显示。（根据 alpha 通道决定是否需要显示）
    - 模板测试：挑选合格的像素显示。（根据模板信息决定是否需要显示）
    - 深度测试：挑选合格的像素显示。（根据深度决定是否需要显示）
    - Blend：将当前需要渲染的像素与之前已经渲染出来的像素进行混合运算。
    - GBuffer：包含 RGBA，模板值，深度值等等信息的缓冲池。一般包含4组信息。（假设屏幕大小为800*600，GBuffer 的大小为 float(800 * 600 * 4)
    - FrontBuffer：前一次写入的 Buffer 信息。（假设屏幕大小为800*600 ，大小为 float(800 * 600)）
    - FrameBuffer：当前帧写入的 Buffer 信息。与 FrontBuffer 二者交替接受 GBuffer 中最新的 Buffer 数据。
    - 显示器

# 3. Shader 结构

## 3.1 Shader 语言

常见的有以下几种：

- OpenGL: SGI 的跨平台语言。GLSL（OpenGL Shader Language）
- DirectX: 微软平台独占的，性能更佳。HLSL（High Level Shader Language）
- CG: 微软与英传达合作开发的基于 C 语言的跨平台语言。

## 3.2 Unity 支持的 Shader 语言

OpenGL，DX，CG 都支持。

- CG 和 HLSL 包含在 `CGPROGRAM ... ENDCG`语法块内。
- GLSL 包含在 `GLSLPROGRAM ... ENDGLSL`语法块内。
- Unity 自带的 Shader Lab。

## 3.3 Unity Shader 分类

- Fixed Shader （Shader 1.0）：主要是提供了功能的开关。
- 顶点/片断着色器 (Shader 2.0) ：功能中的公式可以自定义。
- Surface Shader ：上述二种的封装

## 3.4 Shader 的结构

```glsl
// Shader的名字会出现在 Unity 的 Inspector 中选择 Shader 的菜单中。可以用 "/" 作为分隔形成菜单路径
Shader "Shader的名字" {
  [Properties] // 属性
  
  // 可能存在多个 subshader。Unity 会在所有 subshader 列表中选择当前环境符合运动条件的第一个 subshader 运行。
  Subshaders {
    Subshader {
      [Tags] // 标签
      [CommonState] // 提供给多个 Pass 块使用的设置
      Pass {
        [Pass Tags] // Pass 的标签
        [Render Setup] // 渲染设置，比如颜色混合
        [Texture Setup] // 纹理设置，只有在 fixed function shader 中才可以使用
      } // 可能有多个 Pass ，每个 Pass 触发一次渲染过程
    }
  }
  
  [Fallback] // 降级的着色器
  
  [CustomEditor] // 当有自定义 shader 的设置 UI 时使用
}
```

# 4. 属性定义

## 4.1 什么是材质球

比如说穿的衣服为什么显示为红色，是因为衣服的材质将太阳光中的其他颜色都吸收掉了，只反射红色。

## 4.2 什么是 Shader

决定了材质与灯光之间是怎样计算的。

## 4.3 Shader 属性定义的通用格式

将整个 Shader 看作一个类，`Properties`就等于这个类的成员变量。

`Properties { Property [Property ...]}`

```glsl
Properties {
  _name ("display name", Int) = number
  // _name 变量的名字，一般以下划线开始
  // display name 在 Inspector 面板显示的名称
  // Int 表示变量类型
  // = number 表示默认值
  _float ("testFloat", Float) = 1.0
  _range ("testRange", Range(min, max)) = 1.0
  // 通过设置 min 和 max 设置变量的范围
  // Range 和 Float 都是 single number
  _color ("testColor", Color) = (.34, .85, .92, 1)
  _vector ("textVector", Vector) = (1, 1, 1, 1)
  // Color 和 Vector 都是由四个数字组成的
  _2D ("test2D", 2D) = "white" {}
  // 平面材质
  _rect ("testRect", Rect) = "black" {}
  _cube ("testCube", Cube) = "gray" {}
  // CubeMap 定义六个面的纹理
  // 2D, Rect, Cube 的 "" 内表示默认材质颜色，可以为空或以下几个值：
  // "white" RGBA(1, 1, 1, 1)
  // "black" RGBA(0, 0, 0, 0)
  // "gray" RGBA(0.5, 0.5, 0.5, 0.5)
  // "bump" RGBA(0.5, 0.5, 1, 0.5)
  // "red" RGBA(1, 0, 0, 0)
  // {} 中可以定义 options 
  // TexGen: { TexGen EyeLinear }
  // 纹理坐标生成模式。可以是 ObjectLinear, EyeLinear, SphereMap, CubeNormal等，它们直接对应 OpenGL 的 texgen 模式。注意，如果使用自定义顶点程序，则 texgen 将被忽略。
  // LightmapMode: { LightmapMode } 纹理会受到每一个渲染器的 lightmap 参数的影响，即该纹理可以不在材质中，而是受渲染器设置参数影响。
  _3D ("test3D", 3D) = "" {}
  // 3D 纹理，只能由脚本创建纹理内容，且仅 OpenGL 3.0 及以上才支持。
}
```

# 5. 灯光设置（Shader1.0）

## 5.1 Shader1.0 顶点着色器

- 设置顶点颜色
    ```
    Pass
    {
        Color (1, 0, 0, 1) // 直接指定颜色值
    }
    ```
    ```
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Pass
        {
            Color[_Color] // 指定颜色属性值
        }
    }
    ```
- 顶点变换
- 灯光
    灯光计算公式：`Ambient * Lighting Windows Ambient Intensity Setting + (Light Color * Diffuse + Light Color * Specular) + Emission`
    ```
    Pass
    {
        Lighting On // 打开灯光
        Material
        {
            // Diffuse Color 漫反射
            // Ambient Color 环境光
            // Shininess number
            // Emission Color 自发光
            // Specular Color 高光/镜面反射
        }
        SeparateSpecular On // 是否打开镜面反射
    }
    ```

# 6. 纹理寻址原理

## 6.1 片段着色器

- 纹理采样
  - 纹理大小和显示区域不匹配
     1. 纹理像素和显示区域相等
     2. 纹理像素大于显示区域
        采用等比例映射
        Point：就近采样
        Bilinear：就近 + 周围4个像素的平均
        Trilinear：就近 + 周围8个像素的平均
     3. 纹理像素小于显示区域
        锯齿

# 7. 纹理设置（Shader1.0）

## 7.1 Shader1.0 纹理

```
Pass
{
    SetTexture [TextureName] 
    {
        combine [Previous/Primary/Texture/Constant]
    }
}
```

- Previous: 前一个SetTexture返回的像素
- Primary: 顶点颜色
- Texture: 当前 SetTexture 的纹理
- Constant: 一个固定的颜色

```
Pass
{
    SetTexture [TextureName]
    {
        combine Previous lerp(Texture) Texture
    }
}
// lerp 插值，根据lerp(Texture)的 alpha 
```

```
Pass
{
    SetTexture [TextureName]
    {
        constantColor(1, 0, 0, 1) // 指定颜色
        constantColor[PropName] // 指定属性

        combine Constant * Texture
    }
}
```

# 8. Shader2.0 结构及语义

- 不同点：Shader2.0 可以实现编程
- 相同点：渲染管线相同

```
#pragma vertex 函数名 // 定义一个顶点着色器的入口函数
#pragma fragment 函数名 // 定义一个片段着色器的入口函数

#include "UnityCG.cginc" // 引入 \CGIncludes 目录下的cginc

struct appdata
{
    float4 vertex : POSITION; // 模型顶点信息
    float2 uv : TEXCOORD0; // TEXCOORD(n) 高精度 可以从顶点着色器传递到片段着色器的数据 可以是float2/float3/float4
    // NORMAL 法线信息
    // COLOR 低精度 从顶点着色器传递到片段着色器的数据 float4
    // TANGENT 切线信息
};
```

POSITION/TEXCOORD0/NORMAL/COLOR 就是语义，用来告知 Unity appdata 这个结构体中变量从哪里取值，值的类型是什么。

SV_POSITION: 经过 mvp 矩阵计算已经转化为屏幕坐标

```
// 旧版
mul(UNITY_MATRIX_MVP, v.vertex)
// 新版
UnityObjectToClipPos(v.vertex)
```

SV_Target: 输出到哪个 render target （相机/材质）

# 9. Shader2.0 矩阵变换

## 9.1 Shader2.0 顶点着色器

- 计算顶点的位置变换（从物体坐标系转换到相机坐标系）

  1. 将物体坐标系变换到世界坐标系

     Unity3D 矩阵是左乘

     `P(世界) = M(物体到世界的变换矩阵) * P(物体)`

  2. 将世界坐标变换到相机坐标系

     `P(相机) = M(世界到相机) * P(世界)`

  3. 从 C# 来看

     ```c#
     // 物体->世界
     var posWorld = transform.parent.localToWorldMatrix.MultiplyPoint(transform.localPosition);
     // 世界->相机
     var targetPos = camera.transform.worldToLocalMatrix.MultiplyPoint(posWorld);
     ```
     
  4. MVP
  
     M：表示物体坐标系变换到世界坐标系
  
     V：表示世界坐标变换到相机坐标系
  
     P：将 3D 坐标系转换成 2维屏幕坐标（由相机的 Projection 决定 Perspective 透视投影 / Orthographic 正交投影）
  
- 计算顶点的颜色

- Unity Shader 常用常量：

  - Transformations:
    1. UNITY_MATRIX_MVP: current model * view * projection matrix
    2. UNITY_MATRIX_MV: current model * view matrix
    3. UNITY_MATRIX_V: current view matrix
    4. UNITY_MATRIX_P: current projection matrix
    5. UNITY_MATRIX_VP: current view * projection matrix
    6. UNITY_MATRIX_T_MV: Transpose of model * view matrix
    7. UNITY_MATRIX_IT_MV: Inverse transpose of model * view matrix
    8. _Object2World: current model matrix
    9. _World2Object: inverse of current world matrix

  - Camera and screen:
  
    | Name                           | Type     | Value                                                        |
    | ------------------------------ | -------- | ------------------------------------------------------------ |
    | _WorldSpaceCameraPos           | float3   | World space position of the camera                           |
    | _ProjectionParams              | float4   |                                                              |
    | _ScreenParams                  | float4   | x：相机渲染目标的宽像素；y：相机渲染目标的高像素；z：1.0 + 1.0 / width；w：1.0 + 1.0/height； |
    | _ZBufferParams                 | float4   |                                                              |
    | unity_OrthoParams              | float4   |                                                              |
    | unity_CameraProjection         | float4*4 |                                                              |
    | unity_CameraInvProjection      | float4*4 |                                                              |
    | unity_CameraWorldClipPlanes[6] | float4   |                                                              |
  
  - Time
  
    | Name            | Type   | Value                             |
    | --------------- | ------ | --------------------------------- |
    | _Time           | float4 | float4 分别为 (t/20, t, tx2, tx3) |
    | _SinTime        | float4 |                                   |
    | _CosTime        | float4 |                                   |
    | unity_DeltaTime | float4 |                                   |
  
    
  
  - Lighting
  
    | Name                                                    | Type     | Value                                          |
    | ------------------------------------------------------- | -------- | ---------------------------------------------- |
    | _LightColor0 (in Lighting.cginc)                        | fixed4   | 灯光颜色                                       |
    | _WorldSpaceLightPos0                                    | float4   | 方向光的世界坐标，有多个的话其他的会在 Pos1 中 |
    | _LightMatrix0 (in AutoLight.cginc)                      | float4*4 |                                                |
    | unity_4LightPosX0, unity_4LightPosY0, Unity_4LightPosZ0 | float4   | (仅 ForwordBase pass)                          |
    | unity_4LightAtten0                                      | float4   | (仅 ForwordBase pass)                          |
    | unity_LightColor                                        | half4[4] | (仅 ForwordBase pass)                          |
    | _LightColor (in UnityDeferredLibrary.cginc)             | float4   |                                                |
    | _LightMatrix0 (in UnityDeferredLibrary.cginc)           | float4*4 |                                                |
  
    | Name                | Type      | Value |
    | ------------------- | --------- | ----- |
    | unity_LightColor    | half4[8]  |       |
    | unity_LightPosition | float4[8] |       |
    | unity_LightAtten    | half4[8]  |       |
    | unity_SpotDirection | float4[8] |       |
  
  - Fog and Ambient
  
    | Name                     | Type   | Value    |
    | ------------------------ | ------ | -------- |
    | unity_AmbientSky         | fixed4 |          |
    | unity_AmbientEquator     | fixed4 |          |
    | unity_AmbientGround      | fixed4 |          |
    | UNITY_LIGHTMODEL_AMBIENT | fixed4 |          |
    | unity_FogColor           | fixed4 | 雾的颜色 |
    | unity_FogParams          | float4 |          |
  
  - Various
  
    | Name          | Type   | Value |
    | ------------- | ------ | ----- |
    | unity_LODFade | float4 |       |

# 10. Shader2.0 波动实例

顶点着色器中改变顶点位置实现波动效果。

```
y = 峰值【纵向拉伸压缩的倍数】 * sin(周期 * x + 波形与 x 轴的关系【左加右减】 )
```

Shader2.0 中 property 变量需要引用。

```glsl
float _A;
float _Frenquncy;
float _Speed;

v2f vert (appdata v)
{
    v2f o;

    float timer = _Time.y * _Speed;
    float wave = _A * sin(timer + v.vertex.x * _Frenquncy);
    v.vertex.y = v.vertex.y + wave;

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    return o;
}
```

# 11. 滚动效果

片段着色器中改变采样UV值实现滚动效果。

材质的 Wrap Mode:

- Clamp：UV 坐标超过 1 时，永远取 1。
- Repeat：重复，即 UV 超过 1 时，只取小数部分。

```glsl
fixed4 frag (v2f i) : SV_Target
{
    float2 tmpUV = i.uv;
    tmpUV.x += _Time.x;
    tmpUV.y += _Time.y;

    fixed4 col = tex2D(_MainTex, tmpUV);
    return col;
}
```

# 12. Loading 效果

UV 动画旋转（绕 z 轴旋转）
$$
R_z(\theta) = \left[
\begin{matrix}
cos\theta & -sin\theta & 0 \\
sin\theta & cos\theta & 0 \\
0 & 0 & 1
\end{matrix}
\right]
$$
绕另外两轴旋转，y 轴有些不一样：
$$
R_x(\theta) = \left[
\begin{matrix}
1 & 0 & 0 \\
0 & cos\theta & -sin\theta \\
0 & sin\theta & cos\theta
\end{matrix}
\right]

R_y(\theta) = \left[
\begin{matrix}
cos\theta & 0 & sin\theta \\
0 & 1 & 0 \\
-sin\theta & 0 & cos\theta
\end{matrix}
\right]
$$
UV 用矩阵方式旋转

1. 物体平移到原点
2. 实现旋转
3. 物体平移到原来位置

```glsl
Blend SrcAlpha OneMinusSrcAlpha // 如果需要打开图片透明度计算

// ...

float _Speed;

fixed4 frag (v2f i) : SV_Target
{
    float2 tmpUV = i.uv;
    tmpUV -= float2(0.5, 0.5); // 平移到中心点

    if(length(tmpUV) > 0.5) { // 不显示多余部分
        return 0;
    }
    
    float2 finalUV = 0;
    float angle = _Time.x * _Speed;

    finalUV.x = tmpUV.x * cos(angle) - tmpUV.y * sin(angle);
    finalUV.y = tmpUV.x * sin(angle) + tmpUV.y * cos(angle);

    finalUV += float2(0.5, 0.5); // 平移到原来位置

    fixed4 col = tex2D(_MainTex, finalUV);
    return col;
}
```

# 13. outline 效果

两种方法：

1. 渲染两个物体，一个大的返回纯色作为边缘轮廓，小的正常显示。（需要使用两个 Pass）
2. 渲染一个物体
   1. 找到边缘
   2. 给边缘着色
   3. 非边缘地带正常纹理采样

```glsl
Pass
{
    float _OutLineWidth;

    v2f vert (appdata v)
    {
        v2f o;
        v.vertex.xy *= _OutLineWidth;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
    }
}

Pass
{
	ZTest Always // 确保第二个PASS能够正常显示
}
```

# 14. blurning 效果

屏幕后期特效

MonoBehaviour.cs

```csharp
private void OnRenderImage(RenderTexture source, RenderTexture destination)
{
    Graphics.Blit(source, destination, this.graphicMat);
}
```

```glsl
float _Offset;

fixed4 frag (v2f i) : SV_Target
{
    float2 tmpUV = i.uv;

    float offset = _Offset;

    fixed4 col = tex2D(_MainTex, tmpUV);
    // just invert the colors
    // col.rgb = 1 - col.rgb;

    fixed4 col2 = tex2D(_MainTex, tmpUV + float2(-offset, 0));
    fixed4 col3 = tex2D(_MainTex, tmpUV + float2(0, -offset));
    fixed4 col4 = tex2D(_MainTex, tmpUV + float2(offset, 0));
    fixed4 col5 = tex2D(_MainTex, tmpUV + float2(0, +offset));

    col = (col + col2 + col3 + col4 + col5) / 5.0;

    return col;
}
```

# 15. Alpha 测试

## 15.1 Shader1.0

```js
AlphaTest Greater 0.5
```

- Always: 总是通过，和 Off
- Never: 总是不通过
- Greater
- GEqual
- Less
- LEqual
- NotEqual

## 15.2 Shader2.0

```glsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    // just invert the colors
    // col.rgb = 1 - col.rgb;
    if (col.a < 0.5)
    {
        return fixed4(0, 0, 0, 0);
    }
    return col;
}
```

# 16. 模板测试

```glsl
if ((referenceValue & readMask) comparisonFuncion (stencilBufferValue & readMask))
    // 通过测试
else
    // 抛弃像素
// 更新操作
// Pass
// Fail
// ZFail
```

- referenceValue: 通过 Ref 设定的参考值，取值范围 0 - 255 的整数
- readMask: 读遮罩，将和 referenceValue 和 stencilBufferValue 进行位与（&）操作，取值范围 0 - 255 的整数。默认值为 255，即二进制为 11111111。
- comparisonFunction: 比较方法，取值为：
  - Greater
  - GEqual
  - Less
  - LEqual
  - Equal
  - NotEqual
  - Always
  - Never
- 更新操作：
  - Keep：保持原来的值不变
  - Zero：0
  - Replace：设置的 ref value 替换模板缓存的值
  - IncrSat：自动增加，到255后不再增加
  - DecrSat：自减，到0后不再减少
  - Invert：取反
  - IncrWrap：自增，达到255后再增就回到0
  - DecrWrap：自减，达到0后再减就回到255

Front:

```glsl
ZWrite Off // 关闭深度测试，否则 Back 会显示不出来
Pass
{
    Stencil
    {
        Ref 2
        Comp always
        Pass replace
    }
}
```

Middle:

```glsl
Stencil{
    Ref 2
    Comp NotEqual
}
```

Back:

```glsl
Stencil{
    Ref 2
    Comp Equal
}
```

# 17. 深度缓存

## 17.1 什么是深度

## 17.2 什么是深度缓存

## 17.3 什么是深度测试 

- ZWrite：是否将要渲染物体的深度写入深度缓存区
  - On
  - Off
- ZTest
  - Less
  - Greater
  - LEqual
  - GEqual
  - Equal
  - NotEqual
  - Always

ZWrite 和 ZTest 的相互关系：

1. ZWrite 为 On 时，ZTest 通过，该像素的深度写入深度缓存，同时像素的颜色写入颜色缓存。
2. ZWrite 为 On 时，ZTest 不通过，该像素的深度不写入深度缓存，并且像素的颜色也不会写入颜色缓存。
3. ZWrite 为 Off 时，ZTest 通过，该像素的深度不写入深度缓存，但像素的颜色会写入颜色缓存。
4. ZWrite 为 Off 时，ZTest 不通过，该像素的深度不写入深度缓存，并且像素的颜色也不会写入颜色缓存。

# 18. 深度测试

微调两个物体在同一位置。

```glsl
Offset Factor,Units
```

- Factor：Z 缩放的最大斜率，值越小越靠前。`-1 到 1 之间`
- Units：可分辨的最小深度缓冲区的值。值越小越靠近相机。

# 19. Blend

新渲染的像素和已经在 GBuffer 中的像素如何处理

Blend = 要渲染的像素 * factorA 屏幕已经渲染的gbuffer中的像素 * factorB

factor 取值：

- One
- Zero
- SrcColor
- SrcAlpha
- DstColor
- DstAlpha
- OneMinusSrcColor
- OneMinusSrcAlpha
- OneMinusDstColor
- OneMinusDstAlpha

BlendOp

指定要渲染的像素和 BGuffer 中的像素的逻辑运算，该指令存在，Blend 指令将被忽略

- Add
- Sub
- RevSub
- Min
- Max
- LogicalClear
- LogicalSet
- LogicalCopy

# 20. Renderqueue

指定物体的渲染顺序。

```glsl
Tags { "Queue" = "" }
```

- Background：对应数值为 1000，用于需要被最先渲染的对象。它仅仅是  Renderqueue 中的一个，不要和 skybox 混淆。
- Geometry：对应数值为 2000用于不透明的物体。这个是默认选项。（从前往后渲染）
- AlphaTest：对应的数值为 2450，用于需要使用 AlphaTest 的对象以提高性能。AlphaTest 有类似裁剪（clip）功能。
- Transparent：对应的数值为 3000，用于需要使用 alpha blending 的对象，如粒子，玻璃等。（从后往前渲染）
- Overlay：对应的数值为 4000，用于最后被渲染的对象。

# 21. Renderpath

- Legacy Vertex Lit

  灯光只在顶点着色器有效

  物体只会渲染一次

- Forward

  渲染二次

  1. 找一个逐像素灯光和所有的逐顶点灯光渲染一次
  2. 其他逐像素灯光再渲染一次

  方向光和设置成 Important 的灯光都会认为是逐像素灯光

- Deferred

  Unity5.0 以后的渲染模式

  渲染二次

  1. 先计算物体的漫发射，高光，平滑度，法线，自发光和深度。
  2. 根据前一次渲染的 buffer，并添加自发光。

- Legacy Deferred (light prepass)

  Unity5.0 以前的渲染模式

  渲染三次

  1. 计算物体的深度法线高光。
  2. 用灯光计算一次存在生成的 buffer 中。
  3. 结合前二次渲染结果以及物体颜色和纹理与环境光自发光combine。

# 22. Surface

surface shader 里面没有 Pass

```glsl
#pragma surface surfaceFunction lightModel [optionalparams]
```

- surfaceFunction：入口函数名
- lightModel：灯光模式

```glsl
#pragma surface surf Standard fullforwardshadows
struct SurfaceOutputStandard
{
    fixed3 Albedo; // base (diffuse or sepcular) color 
    fixed3 Normal; // tangent space normal, if written
    half3 Emission;
    half Matallic; // 0=non-metal, 1=metal
    half Smoothness; // 0=rough, 1=smooth
    half Occlusion; // occlusion (default: 1)
    fixed Alpha; // alpha for transparencies
}

// 带高光
#pragma surface surf StandardSpecular fullforwardshadows
struct SurfaceOutputStandardSpecular
{
    
}
```

# 23. Surface 顶点变化

```glsl
#pragma surface surf Lambert finalcolor:mycolor vertex:myvert
```

pipeline: myvert(顶点着色器) -> surf -> Lambert -> finalColor

```glsl
#pragma surface surf Lambert vertex:myvert

float _P;    
void myvert(inout appdata_base v )
{
    v.vertex.xyz += v.normal * _P;
}

void surf (Input IN, inout SurfaceOutput o)
{
    o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
}
```

- float: 32
- half: 16
- fixed: 12

# 24. 片段着色器

```glsl
struct Input
{
    float2 uv_texturename; // uv2_ 第二张
    float3 viewDir;
    float4 COLOR;
    float4 screenPos;
    float3 worldPos;
    float3 worldRefl;
    float3 worldNormal;
}

struct SurfaceOutput
{
    fixed3 Albedo;
    flxed3 Normal;
    fixed3 Emission;
    half Specular;
    fixed Gloss;
    fixed Alpha;
}
```

# 25. 参数传递

```glsl
// 1. 首先在 Input 中增加要从顶点着色器传递到片断着色器的变量
struct Input
{
    float2 uv_MainTex;

    float3 myColor;
};

// 2. 顶点着色器增加 out Input 变量
void myvertex(inout appdata_base v, out Input o) {
    // 3. 使用 UNITY_INITIALIZE_OUTPUT() 初始化
    UNITY_INITIALIZE_OUTPUT(Input, o);

    // 4. 给要传递的变量赋值
    o.myColor = _Color * abs(v.normal);
}

// 5. o 的类型要从 SurfaceOutputStandard 改为 SurfaceOutput
void surf (Input IN, inout SurfaceOutput o)
{
    fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
    // 6. 使用
    o.Albedo = c.rgb * IN.myColor;
    o.Alpha = c.a;
}
```

# 26. 向量的运算

## 26.1 点乘

$$
A向量 . B向量 = |A| * |B| * cos(\theta)
$$

1. 假如 A 向量是单位向量，即 |A| === 1，等于是计算了 B向量的投影。
2. 假如两个向量都是单位向量，计算结果就是 cos()，再加上acos(cos(q))，就能得到两个点的叉角。

## 26.2 叉乘

C = A 叉乘 B

C 是垂直于 A 和 B 的向量。

A 叉乘 B === -(B 叉乘 A)

可以计算物体在另外一个物体的左侧还是右侧。

|A * B| = |A| * |B| * sin(q)

|B| * sin(q) = 高

|A| * |H| = 平行四边形面积

所以 | A 叉乘 B | = AB 组成的平行四边形的面积

# 27. 灯光原理

材质决定了物体与灯光的作用。

- 漫反射：

  与灯光的入射角有关系，跟观察角无关。即在同一时刻，无论站在哪个角度，观察到的漫反射应该都是相同的。

- 镜面反射：

  跟入射角有关，也跟观察角有关。

任何一个物体都不是只有漫反射或单一镜面反射的，都是由两者组合而成的。

L：灯光入射角；N：顶点法线；E：观察角；

漫反射：Dot(L, N) * 灯光的颜色

Dot(L, N) = | L | * | N | * cos(q)

镜面反射：

L：灯光入射角；N：顶点法线；E：观察角；R：灯光反射角；

Phone 式模型：R dot E

BilingPhone：(E-L) dot N === H dot N

(E - L) = H

镜面反射颜色 = 镜面反射 * 灯光的颜色 * 衰减值

物体颜色 = 镜面反射颜色 + 漫反射颜色 + 自发光 + 环境光

# 28. 自定义光照模型

Unity 5.4 以前

```glsl
half4 Lighting<Name> (SurfaceOutput s, half3 lightDir, half atten);

half4 Lighting<Name> (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten);

half4 Lighting<Name>_PrePass (SurfaceOutput s, half4 light);
```

Unity 5.5 开始

```glsl
// 1
half4 Lighting<Name> (SurfaceOutput s, UnityGI gi);

// 2
half4 Lighting<Name> (SurfaceOutput s, half3 viewDir, UnityGI gi);

// 3
half4 Lighting<Name>_Deferred (SurfaceOutput s, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal);

// 4
half4 Light<Name>_PrePass (SurfaceOutput s, half4 light);
```

# 29. 法线贴图原理

法线贴图的作用：

增加明暗对比度。cos(q) 角度越大，值越小。

由于法线的取值范围是 (-0.5 - 0.5)，然后图片的通道都是 0-1，所以还需要进行一次转换：

```glsl
UnpackNormal() // 从 0 - 1 的取值范围转换成 -0.5 - 0.5
```

