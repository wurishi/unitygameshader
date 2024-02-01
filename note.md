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
- Surface Shader 。

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

