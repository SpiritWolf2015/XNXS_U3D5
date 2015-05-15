//2012.03.12
//2012.04.05
//2013.06.26
//2013.07.05

/*
	2015年5月5日 10:21:49 郭志程

	使用Surface Shader，很多时候，我们只需要告诉shader，
	嘿，使用这些纹理去填充颜色，法线贴图去填充法线，
	使用Lambert光照模型，其他的不要来烦我！！！”
	我们不考虑！不考虑！不考虑！是使用forward还是deferred rendering，
	有多少光源类型、怎样处理这些类型，
	每个pass需要处理多少个光源！！！（人们总会rant写一个shader是多么的麻烦。。。）
	So！Unity说，不要急，放着我来~

	一个最基本的Surface Shader，至少需要有光照模式的声明、输入结构和表面着色函数的编写这三部分。
	分析Surface Shader到底是怎样解析我们编写的那些surf、LightingXXX等函数的，又是如何得到像素颜色的。

	讲解Surface Shader网址：
  【Unity Shaders】Shader学习资源和Surface Shader概述 
	http://blog.csdn.net/candycat1992/article/details/37882765
  【Unity Shaders】初探Surface Shader背后的机制
	http://blog.csdn.net/candycat1992/article/details/39994049
  【浅墨Unity3D Shader编程】之六 暗黑城堡篇: 表面着色器(Surface Shader)的写法(一)
	http://www.unitymanual.com/thread-35492-1-1.html
*/


Shader "虚拟现实/Base" {
	Properties {	
		_SpecColor0("高光颜色", Color) = (0,0,0,1)
		_Shininess("高光范围", Range(0,1) ) = 0.5
		
		_Color ("漫反射颜色", Color) = (0,0,0,1)
		_MainTex ("漫反射贴图", 2D) = "white" {}
		
		_globalInfluence("全局影响", Range(0,1) ) = 1
		_brightness("亮度", Range(1,5) ) = 1
		_contrast("对比度", Range(1,2.5) ) = 1

		_lightmap_color("光影贴图颜色", Color) = (0,0,0,1)
		_LightMap ("第二张贴图 (完整贴图 或 光影贴图)", 2D) = "white" {}
		// IOS不支持HDR
		_changeType ("<<<使用HDR *** 不使用HDR>>>", Range(0,1)) = 1
			
		_SelectColor ("描边颜色", Color) = (0.2,0.6,0.8,0)
		_SelectColorAlpha("Alpha透明",Range(0,1) ) = 0
	}
	SubShader {
		//-----------子着色器标签----------
		Tags { "RenderType"="Opaque"}
		LOD 200
		
		//-------------------开始CG着色器编程语言段-----------------
		CGPROGRAM

		//编译指令的一般格式如下：
		//#pragma surface surfaceFunction lightModel [optionalparams]
		// 比如这里，#pragma surface是固定格式，surf是surface函数，BlinnPhong_wjm是自定义的光照模型，
		// finalcolor:mycolor是加的一个可选参数。

		// 自定义光照模型
		//finalcolor:Color函数，对颜色输出作最后的更改，这里这个Color函数就是mycolor函数
		//surfaceFunction通常就是名为surf的函数（函数名可以任意），它的函数格式是固定的, void surf (Input IN, inout SurfaceOutput o) ，无返回值有2个形参。
		//其中Input是我们自己定义的结构。Input结构中应该包含所需的纹理坐标(texture coordinates)和和表面函数(surfaceFunction)所需要的额外的必需变量。

		#pragma surface surf BlinnPhong_wjm finalcolor:mycolor		
//		#pragma multi_compile_fwdadd_fullshadows		// U3D5报错		
		#pragma target 3.0
		#pragma profileoption MaxTexIndirections=64

		//变量声明
		float4x4 _RotateUVM;
		float _GLOBALBRIGHTNESS;
		float _GLOBALCONTRASR;
		
		float depth_bias;
		float border_clamp;
		float _changeType;
		
		float4 _SpecColor0;		
		float _Parallax;
		float _Shininess;
		float _brightness;
		float _contrast;
		float4 _Color;
		float4 _lightmap_color;
		float4 _lightmap_color2;
		
		sampler2D _MainTex;
		sampler2D _LightMap;

		float4 _SelectColor;		
		float _SelectColorAlpha;		
		float _globalInfluence;

		// 表面处理函数surf的输入
		//Input 这个输入结构通常拥有着色器需要的所有纹理坐标(texture coordinates)。
		//纹理坐标(Texturecoordinates)必须被命名为“uv”后接纹理(texture)名字。(或者uv2开始，使用第二纹理坐标集)。
		//可以在输入结构中根据自己的需要，可选附加这样的一些候选值。
		struct Input {
			float2 uv_MainTex;	//主UV
			float2 uv2_LightMap;	//光影贴图的UV
		};

		// 表面处理函数surf的输出
		struct SurfaceOutput_wjm 	{
			half3 Albedo;	// 漫反射颜色
			half3 Normal;
			half3 Emission;
			half3 Gloss;
			half Specular;
			half Alpha;
		};		
		
		inline half4 LightingBlinnPhong_wjm_PrePass (SurfaceOutput_wjm s, half4 light)	{
			half3 spec = light.a * s.Gloss;
			half4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
			c.a = s.Alpha;
			return c;
		}		
		
		inline half4 LightingBlinnPhong_wjm (SurfaceOutput_wjm s, half3 lightDir, half3 viewDir, half atten)	{
			half3 h = normalize (lightDir + viewDir);			
			half diff = max (0, dot ( lightDir, s.Normal ));				
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular * 128.0);				
			half4 lightPower;
			lightPower.rgb = _LightColor0.rgb * diff;
			lightPower.w = spec * Luminance (_LightColor0.rgb);
			lightPower *= atten * 2.0;
				
			half4 c;
			c.rgb = (s.Albedo * lightPower.rgb + lightPower.rgb * spec * s.Gloss);
			c.a = 1;
			return c;
		}
		
		// 自定义颜色函数
		void mycolor (Input IN, SurfaceOutput_wjm o, inout fixed4 color)	{
          color += _SelectColor * _SelectColorAlpha;
		}
		
		inline float3 DecodeLightmap2( float4 color )	{
		#if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
			return 2.0 * color.rgb;
		#else
			return pow((_GLOBALBRIGHTNESS * _globalInfluence + _brightness) * lerp(8.0 * color.a, 1, _changeType) * color.rgb, _contrast + _GLOBALCONTRASR * _globalInfluence);	
		#endif
		}
		
		// 面着色函数的编写
		void surf (Input IN, inout SurfaceOutput_wjm o) {			
			IN.uv_MainTex = mul(IN.uv_MainTex.xyxy, _RotateUVM).xy;			
			o.Normal = float3(0.0, 0.0, 1.0);
			float4 Tex2D0 = tex2D(_MainTex, IN.uv_MainTex);
			float4 Tex2D1 = 0;
			Tex2D1 += _lightmap_color * float4(DecodeLightmap2(tex2D(_LightMap, (IN.uv2_LightMap).xy)), 1);		
			float3 diffuseColor = Tex2D0;			
			
			o.Albedo = _Color.rgb * diffuseColor;			
			o.Emission = Tex2D1.rgb * diffuseColor;			
			o.Specular = _Shininess ;			
			o.Gloss = Tex2D0.a * _SpecColor0;			
			o.Alpha = Tex2D0.a * _Color.a;
			o.Normal = normalize(o.Normal);
		}	
		// 结束CG着色器编程语言段
		ENDCG		
	} 
	//“备胎”为普通漫反射
	FallBack "Diffuse"
}
