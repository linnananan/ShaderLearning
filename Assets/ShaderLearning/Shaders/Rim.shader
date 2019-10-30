Shader "Unlit/Rim"
{
    Properties{
        _Scale("Scale", Range(1,9)) = 2
    }
    SubShader{
        Tags{"queue" = "transparent"}
        pass{
            Blend SrcAlpha OneMinusSrcAlpha
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
