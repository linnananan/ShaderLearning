﻿Shader "Unlit/BlinnPhong"
{
    Properties{
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(1,64)) = 8 //衰减
    }
    SubShader
    {
        Pass{
            tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"
            float4  _SpecularColor;
            float _Shininess;

            struct v2f{
                float4 pos : POSITION;
                fixed4 color : COLOR;
            };
            //Phong
            /*v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 N = normalize(v.normal);
                float3 L = normalize(_WorldSpaceLightPos0);

                N = normalize(mul(N, (float3x3)unity_WorldToObject)).xyz;

                //也可以用unitycg.cginc中的函数将法向量转化到世界空间中
                //float3 N = UnityObjectToWorldNormal(v.normal);
                //ambient color
                o.color = UNITY_LIGHTMODEL_AMBIENT
                //diffuse color
                float lightStrength = saturate(dot(N,L));
                o.color += _LightColor0 * lightStrength;
    
                //specular color
                //入射光向量I
                //float3 wpos = mul(unity_ObjectToWorld, v.vertex);
                //float3 I = wpos - _WorldSpaceLightPos0.xyz;
                //以上两个计算在unitycg.cginc已经封装在以下函数中
                float3 I = -WorldSpaceLightDir(v.vertex);
                float3 R = reflect(I, N);//反射光
                //顶点指向摄像机方向向量
                float3 V = WorldSpaceViewDir(v.vertex);
                //规范化，方便dot计算cos值
                R = normalize(R);
                V = normalize(V);
                float specularScale =pow( saturate(dot(R, V)), _Shininess);//排除负值
                o.color += _SpecularColor * specularScale;
                return o;
            }*/

            //用计算反射的方式实现高光
            /*v2f vert(appdata_base v)
            {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            float3 L = normalize(WorldSpaceLightDir(v.vertex));
            float3 N = UnityObjectToWorldNormal(v.normal);
            //ambient color
            o.color = UNITY_LIGHTMODEL_AMBIENT;
            //diffuse color
            float lightStrength = saturate(dot(N,L));
            o.color += _LightColor0 * lightStrength;
            //specular color
            float3 R = 2 * dot(N,L) * N - L;
            float3 V = WorldSpaceViewDir(v.vertex);
            R = normalize(R);
            L = normalize(L);
            float specularScale = pow(saturate(dot(R,V)),_Shininess);
            o.color.rgb += _SpecularColor * specularScale;
            return o;
            }*/

            //BlinnPhong
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 L = normalize(WorldSpaceLightDir(v.vertex));
                float3 N = UnityObjectToWorldNormal(v.normal);
                //ambient color
                o.color = UNITY_LIGHTMODEL_AMBIENT;
                //diffuse color
                float lightStrength = saturate(dot(N,L));
                o.color += _LightColor0 * lightStrength;
                //specular color
                float3 V = normalize(WorldSpaceViewDir(v.vertex));
                float3 H = L + V;
                H = normalize(H);
                float specularScale = pow(saturate(dot(H,N)),_Shininess);
                o.color.rgb += _SpecularColor * specularScale;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}