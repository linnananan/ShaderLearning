Shader "Unlit/DiffuseShadow"
{
    Properties
    {
        _SpecularColor ("SpecularColor", Color) = (1, 1, 0, 1) 
        _Shininess ("Shininess", Range(1,32)) = 8
    }
    SubShader
    {
        //投射阴影
        //Pass{
            //只对平行光有影响
        //    Tags{ "LightMode" = "shadowcaster" }
        //}

        Pass
        {
            Tags { "LightMode"="ForwardBase" }//平行光与一些不重要的平行光
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"
            float4 _SpecularColor;
            float _Shininess;

            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase //依赖于多版本编译

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : TEXCOORD0;
                float4 vertex : COLOR;
                //阴影
                //unityShadowCoord3 _LightCoord : TEXCOORD0;
                //point light
                //unityShadowCoord3 _ShadowCoord : TEXCOORD1;
                //使用unity的宏
                LIGHTING_COORDS(0,1)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.vertex = v.vertex;
                //阴影
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = UNITY_LIGHTMODEL_AMBIENT;

                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 L = normalize(WorldSpaceLightDir(i.vertex));
                float diffuseScale = saturate(dot(N,L));
                col += _LightColor0 * diffuseScale;

                float3 R = 2 * dot(N,L) * N - L;
                float specularScale = saturate(dot(R,L));
                col += _SpecularColor * pow(specularScale, _Shininess);

                float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                col.rgb += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, 
                                                unity_LightColor[0].rgb, unity_LightColor[1].rgb, 
                                                unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                                                unity_4LightAtten0,
                                                worldPos,N
                );
                 
                //阴影
                //4.0版本
                float atten = LIGHT_ATTENUATION(i);
                //5.0版本
                //UNITY_LIGHT_ATTENUATION(atten, i, wpos);
                
                col.rgb *= atten;

                return col;
            }
            ENDCG
        }

        ////==================================================================
        Pass 
        {
            Tags { "LightMode"="ForwardAdd" }//只能计算像素光
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"
            float4 _SpecularColor;
            float _Shininess;

            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows //依赖于多版本编译

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : TEXCOORD0;
                float4 vertex : COLOR;
                //阴影
                //unityShadowCoord3 _LightCoord : TEXCOORD0;
                //point light
                //unityShadowCoord3 _ShadowCoord : TEXCOORD1;
                //使用unity的宏
                LIGHTING_COORDS(2,3)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.vertex = v.vertex;
                //阴影
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 col = UNITY_LIGHTMODEL_AMBIENT;
                fixed4 col;

                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 L = normalize(WorldSpaceLightDir(i.vertex));
                float diffuseScale = saturate(dot(N,L));
                col = _LightColor0 * diffuseScale;

                float3 R = 2 * dot(N,L) * N - L;
                float specularScale = saturate(dot(R,L));
                col += _SpecularColor * pow(specularScale, _Shininess);

                float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
                col.rgb += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, 
                                                unity_LightColor[0].rgb, unity_LightColor[1].rgb, 
                                                unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                                                unity_4LightAtten0,
                                                worldPos,N
                );
                 
                //阴影
                float atten = LIGHT_ATTENUATION(i);
                col.rgb *= atten;

                return col;
            }
            ENDCG
        }
    }
    fallback "Diffuse"
}
