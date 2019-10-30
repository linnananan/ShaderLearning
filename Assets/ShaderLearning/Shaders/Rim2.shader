Shader "Unlit/Rim2"
{
    Properties{
        _LightColor("LightColor", Color) = (1,1,1,1)
        _Scale("Scale", Range(1,9)) = 2
        _Outer("Outer", Range(0, 1)) = 0.2
    }
    SubShader{
        Tags{"queue" = "transparent"}

        //外发光，顶点扩展
        pass{
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"
            float _Scale;
            float _Outer;
            float4 _LightColor;

            struct v2f{
                float4 pos: POSITION;
                float3 normal: NORMAL;
                float4 vertex: TEXCOORD0;
            };

            v2f vert(appdata_base i){
                i.vertex.xyz += i.normal * _Outer;
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = i.normal;
                o.vertex = i.vertex;
                return o;
            }
            fixed4 frag(v2f i): COLOR{
                //世界空间
                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 V = normalize(WorldSpaceViewDir(i.vertex)).xyz;
                float strength = saturate(dot(N, V));
                strength = pow(strength, _Scale);
                _LightColor.a *= strength;
                return _LightColor;
            }

            ENDCG
        }

        //=======================================================
        pass{
            BlendOp RevSub 
            Blend DstAlpha One
            ZWrite Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"
            float4 _LightColor;
            struct v2f{
                float4 pos: POSITION;
            };

            v2f vert(appdata_base i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                return o;
            }
            fixed4 frag(v2f i): COLOR{
                
                return _LightColor;
            }

            ENDCG
        }
        
        //=======================================================
        //内发光
        pass{
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend Zero One
            ZWrite Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"
            float _Scale;

            struct v2f{
                float4 pos: POSITION;
                float3 normal: NORMAL;
                float4 vertex: TEXCOORD0;
            };

            v2f vert(appdata_base i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = i.normal;
                o.vertex = i.vertex;
                return o;
            }
            fixed4 frag(v2f i): COLOR{
                //世界空间
                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 V = normalize(WorldSpaceViewDir(i.vertex)).xyz;
                float strength = 1 - saturate(dot(N, V));
                fixed4 col = fixed4(1,1,1,1);
                strength = pow(strength, _Scale);
                col *= strength;
                return col;
            }

            ENDCG
        }
    }
}
