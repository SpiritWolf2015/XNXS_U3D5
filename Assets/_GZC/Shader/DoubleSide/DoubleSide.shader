/*
	顶点片断Shader
	不支持透明通道阴影，只支持物体形状阴影。

  【Unity Shaders】Vertex & Fragment Shader入门
	http://blog.csdn.net/candycat1992/article/details/40212735
*/


Shader "双面材质/VegitationVertexLit" {
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
        SeparateSpecular On                                       
        Blend SrcAlpha OneMinusSrcAlpha   
		                      
        Pass {
			// 剔除正面
            Cull Front    
			                                 
            SetTexture [_BackTex] {                             
                Combine Primary * Texture
            }
        }  
        Pass {
			// 剔除背面
            Cull Back                                         
            SetTexture [_FrontTex] {                             
                Combine Primary * Texture
			}
		}
	}
	
	FallBack "Transparent/Cutout/VertexLit"
}