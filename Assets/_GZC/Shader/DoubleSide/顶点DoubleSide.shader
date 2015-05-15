/*
	顶点片断Shader
	不支持透明通道阴影，只支持物体形状阴影。

  【Unity Shaders】Vertex & Fragment Shader入门
	http://blog.csdn.net/candycat1992/article/details/40212735
	解读Unity中的CG编写Shader系列6——不透明度与混合 
	http://blog.csdn.net/mobanchengshuang/article/details/38760545
*/


Shader "双面/VegitationVertexLit" {
    Properties {
        _Color ("漫反射颜色", Color) = (1,1,1,0)                            
        _SpecColor ("高光颜色", Color) = (1,1,1,1)   
		_Shininess ("高光范围", Range (0.01, 1)) = 0.7              
        _Emission ("自发光颜色", Color) = (0,0,0,0)                           
        _FrontTex ("正面贴图(RGB)", 2D) = "white" { }                             
        _BackTex ("背面贴图(RGB)", 2D) = "white" { }
    }

    SubShader {
        Material {
            Diffuse [_Color]                                             
            Ambient [_Color]                                             
            Shininess [_Shininess]                                     
            Specular [_SpecColor]                                 
            Emission [_Emission]                                     
        }
        Lighting On   
        // 分离高光                                          
        SeparateSpecular On       
        // 混合操作，1减源Alpha    
        Blend SrcAlpha OneMinusSrcAlpha   
        //Blend One One
		                      
        Pass {
			// LightMode是个非常重要的选项，因为它将决定该pass中光源的各变量的值。
			// 如果一个pass没有指定任何LightMode tag，那么我们就会得到上一个对象残留下来的光照值，这并不是我们想要的。
			// 其他各个LightMode的具体含义可以参见官网:
			// http://docs.unity3d.com/Manual/SL-PassTags.html
			// LightMode=Vertex：会设置4个光源，并按亮度从明到暗进行排序，它们的值会存储在unity_LightColor[n], unity_LightPosition[n], unity_LightAtten[n]这些数组中。因此，[0]总会得到最亮的光源。
			// LightMode=ForwardBase： _LightColor0将会是主要的directional light的颜色。
			// LightMode=ForwardAdd：和上面一样， _LightColor0将是该逐像素光源的颜色。
			Tags { "LightMode" = "Vertex" }  
			// 剔除正面
            Cull Front    
			// 设定混合操作的目标对象                         
            SetTexture [_BackTex] {  
                Combine Primary * Texture
            }
        }  
        Pass {
			Tags { "LightMode" = "Vertex" }  
			// 剔除背面
            Cull Back                                         
            SetTexture [_FrontTex] {                             
                Combine Primary * Texture
			}
		}
	}
	
	FallBack "Transparent/Cutout/VertexLit"
}