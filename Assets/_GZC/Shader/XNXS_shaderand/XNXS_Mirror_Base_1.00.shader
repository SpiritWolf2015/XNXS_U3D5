//2012.03.09
//2015年5月4日 15:14:16 郭志程


Shader "虚拟现实/镜子" {

	Properties {		
		_SpecColor0("高光颜色", Color) = (0,0,0,1)
		_Shininess("高光范围", Range(0,1) ) = 0.5
		
		_Color ("漫反射颜色", Color) = (0,0,0,1)
		_MainTex ("漫反射贴图", 2D) = "white" {}
		
		_brightness("亮度", Range(1,5) ) = 1
		_contrast("对比度", Range(1,2.5) ) = 1

		_lightmap_color("光影贴图颜色", Color) = (0,0,0,1)
		_LightMap ("第二张贴图 (完整贴图 或 光影贴图)", 2D) = "white" {}
		// IOS不支持HDR
		_changeType ("<<<使用HDR *** 不使用HDR>>>", Range(0,1)) = 1
		
		_BumpMap ("法线贴图", 2D) = "bump" {}

		_MirrorDistortion  ("镜面扭曲", range (0,1)) = 0
		_reflect_blender("反射混合", range (0,1)) = 0.5
		_fresnel_ctrl("菲涅尔反射", range (-5,0)) = -1
		_FresnelBias ("菲涅尔偏移", Range(0.015, 1)) = 0.1
		_ReflectionTex("反射贴图", 2D) = "white" {}

		_SelectColor ("描边颜色", Color) = (0.2,0.6,0.8,0)
		_SelectColorAlpha("Alpha透明",Range(0,1) ) = 0	
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf BlinnPhong_wjm  finalcolor:mycolor
		#pragma target 3.0
		#pragma debug

		float _GLOBALBRIGHTNESS;
		float _GLOBALCONTRASR;

		float4 _SpecColor0;
		
		float _Parallax;
		float _Shininess;
		float _brightness;
		float _contrast;
		float _MirrorDistortion;
		
		float _changeType;		
		float4 _Color;
		float4 _lightmap_color;		
		
		float4 screenPos;
		float _reflect_blender;
		float _fresnel_ctrl;
		float _FresnelBias;
		float _SelectColorAlpha;
		float4 _SelectColor;

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _LightMap;
		sampler2D _ReflectionTex;
		
		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
			float2 uv2_LightMap;
			float3 viewDir;

			INTERNAL_DATA
		};

		struct SurfaceOutput_wjm {
			half3 Albedo;
			float3 Normal;
			half3 Emission;
			half3 Gloss;
			half Specular;
			half Alpha;
		};
		
		void mycolor (Input IN, SurfaceOutput_wjm o, inout fixed4 color) {
			color += _SelectColor * _SelectColorAlpha;
		}
		
		inline half4 LightingBlinnPhong_wjm_PrePass (SurfaceOutput_wjm s, half4 light) {
			half3 spec = light.a * s.Gloss;
			half4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
			c.a = s.Alpha;
			return c;
		}		

		inline float3 DecodeLightmap2( float4 color ) {
		#if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
			return 2.0 * color.rgb;
		#else
			return pow((_GLOBALBRIGHTNESS + _brightness) * lerp(8.0 * color.a, 1, _changeType) * color.rgb, _contrast + _GLOBALCONTRASR);	
		#endif
		}
															
		inline half4 LightingBlinnPhong_wjm (SurfaceOutput_wjm s, half3 lightDir, half3 viewDir, half atten) {
			half3 h = normalize (lightDir + viewDir);			
			half diff = max (0, dot( lightDir, s.Normal));
				
			float nh = max(0, dot(s.Normal, h));
			float spec = pow(nh, s.Specular * 128.0);
				
			half4 lightPower;
			lightPower.rgb = _LightColor0.rgb * diff;
			lightPower.w = spec * Luminance (_LightColor0.rgb);
			lightPower *= atten * 2.0;
				
			half4 c;
			c.rgb = (s.Albedo * lightPower.rgb + lightPower.rgb * spec * s.Gloss);
			c.a = s.Alpha;
			return c;
		}

		void surf (Input IN, inout SurfaceOutput_wjm o) {	
			o = (SurfaceOutput_wjm)0;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex)).xyz;

			float2 mirrordistortionuv = 0.1 * o.Normal.xy * _MirrorDistortion;
			mirrordistortionuv = ((IN.screenPos.xy / IN.screenPos.w).xyxy).xy + mirrordistortionuv;			
			
			float4 Tex2D0 = tex2D(_MainTex, IN.uv_MainTex);
			float4	Tex2D1 = _lightmap_color * float4(DecodeLightmap2(tex2D(_LightMap, (IN.uv2_LightMap).xy)), 1);
			float4 mirrorcolor = tex2D(_ReflectionTex, mirrordistortionuv);

			float fresnel_intensity = 1 - clamp(pow((max(0, dot(normalize(IN.viewDir), o.Normal))),  -_fresnel_ctrl).xxxx, 0, 1);
  			fresnel_intensity = min(fresnel_intensity + _FresnelBias, 1.0f);
			
			float3 diffuseColor = Tex2D0.rgb * Tex2D1.rgb;			
			float3 diffuseFinalcolor = lerp(diffuseColor, mirrorcolor.rgb, _reflect_blender * fresnel_intensity);
			
			o.Albedo = _Color.rgb * diffuseFinalcolor;			
			o.Emission = _lightmap_color.rrr * diffuseFinalcolor;
			o.Specular = _Shininess ;			
			o.Gloss = Tex2D0.a*_SpecColor0.rgb;			
			o.Alpha = Tex2D0.a * _Color.a;
			o.Normal = normalize(o.Normal);
		}	
		ENDCG		
	} 
	FallBack "Diffuse"
}
