
Shader "Unlit/MultiLightFrag"
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
                //Specular col 反射向量与视向量
                float3 R = 2 * dot(N,L) * N - L;
                float specularScale = saturate(dot(R,V));
                col += _SpecularColor * pow(specularScale,_Shininess);
                //compute 4 points lighting
                float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                col.rgb += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, 
                                                unity_LightColor[0].rgb, unity_LightColor[1].rgb, 
                                                unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                                                unity_4LightAtten0,
                                                worldPos,N
                );

                return col;
            }
            ENDCG
        }
    }
}
