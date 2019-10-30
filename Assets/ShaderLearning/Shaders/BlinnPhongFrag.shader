﻿
Shader "Unlit/BlinnPhongFrag"
{
    Properties
    {
        _SpecularColor ("SpecularColor", Color) = (1, 1, 0, 1) 
        _Shininess ("Shininess", Range(1,32)) = 8
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"
            float4 _SpecularColor;
            float _Shininess;

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : TEXCOORD0;
                float4 vertex : COLOR;

            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.vertex = v.vertex;
                return o;
            }
            //Phong光照模型
            fixed4 frag (v2f i) : SV_Target
            {
                //ambient color
                fixed4  col = UNITY_LIGHTMODEL_AMBIENT;
                //diffuse col
                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 L = normalize(WorldSpaceLightDir(i.vertex));
                float diffuseScale = saturate(dot(N, L));//限定在0-1
                col += _LightColor0 * diffuseScale;
                //Specular col 
                float3 V = normalize(WorldSpaceViewDir(i.vertex));
                float3 H = L + V;
                H = normalize(H);
                float specularScale = saturate(dot(H,N));
                col += _SpecularColor * pow(specularScale,_Shininess);

                return col;
            }
            ENDCG
        }
    }
}
