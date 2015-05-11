/*
	SurfaceShader
	支持透明通道阴影，需要场景中平行灯光照明支持，否则物体为黑的。

	已经针对移动端进行了优化：
	1.优化变量类型，用half2，fixed等低精度类型。
	2.减少参数个数，法线，高光贴图都共用漫反射贴图的UV，不分别给每个贴图一个UV。
	3.使用自定义简化版的兰伯特光照函数。
	4.修改#pragma声明，减少Shader处理的光源个数。Shader只工作在特定的渲染器上

	使用了更少的数据来得到相同的渲染效果。

  【Unity Shaders】Mobile Shader Adjustment —— 为手机定制Shader 
	http://blog.csdn.net/candycat1992/article/details/38585569
  【Unity Shaders】Mobile Shader Adjustment—— 什么是高效的Shader
	http://blog.csdn.net/candycat1992/article/details/38358773

	官网对类型的选择，给出了下面的建议：
    尽可能使用低精度变量。
    对于颜色值和单位长度的向量，使用fixed。
    对于其他类型，如果范围和精度合适的话，使用half；其他情况使用float。
	http://docs.unity3d.com/Manual/SL-ShaderPerformance.html
*/


Shader "双面材质/Transparent/Cutout/MobileBumpedSpecular" {
	Properties {
		_Color ("漫反射颜色", Color) = (1,1,1,1)
		_SpecColor ("高光颜色", Color) = (0.5, 0.5, 0.5, 0)
		_Shininess ("高光范围", Range (0.01, 1)) = 0.078125
		_MainTex ("漫反射贴图 (RGB) 透明通道(A)", 2D) = "white" {}
		_GlossMap ("光泽度贴图",2D) = "white" {}
		_BumpMap ("凹凸贴图", 2D) = "bump" {}
		_Cutoff ("透明通道裁切", Range(0,1)) = 0.5
	}

	SubShader {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 400
		Cull Off
	
		CGPROGRAM
		// noforwardadd 这主要是告诉Unity，使用这种Shader的对象，只接受一个单一的平行光光源作为逐像素光源，其他的光源都使用内置的球谐函数处理后作为逐顶点的光源。
		//第二个点光源并不会影响我们的法线贴图（只是照亮了模型，也就是它只是逐顶点处理），只有第一个平行光才会影响。

		//exclude_path:prepass 告诉Unity，这个Shader不会再接受来自延迟渲染中的其他任何自定义的光照。这意味着，我们仅可以在正向渲染（forward render）中有效地使用这个Shader。
		#pragma surface surf SimpleLambert exclude_path:prepass noforwardadd halfasview alphatest:_Cutoff

		sampler2D _MainTex;
		sampler2D _GlossMap;
		sampler2D _BumpMap;
		fixed4 _Color;
		half _Shininess;

		// 优化变量类型，float2类型的变量中，现在我们将它们改为half2。
		// 减少参数个数，法线，高光贴图都共用漫反射贴图的UV，不分别给每个贴图一个UV
		struct Input {
			half2 uv_MainTex;		
		};

		// 自定义的简化兰伯特光照函数
		inline fixed4 LightingSimpleLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {  
			// 使用fixed等低精度类型
			fixed diff = max (0, dot (s.Normal, lightDir));  
          
			fixed4 c;  
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);  
			c.a = s.Alpha;  
			return c;  
		}  

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb;
			fixed4 gls = tex2D(_GlossMap, IN.uv_MainTex);
			o.Gloss = gls.rgb;
			o.Alpha = tex.a * _Color.a;
			o.Specular = _Shininess;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		}
		ENDCG
	}

	FallBack "Transparent/Diffuse"
}
