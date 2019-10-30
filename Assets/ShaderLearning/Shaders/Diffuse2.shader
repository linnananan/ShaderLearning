
Shader "Unlit/Diffuse"
{
    Properties
    {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1) 
    }
    SubShader
    {
        /*Pass
        {
            //多种光源,基于vertex渲染通道。但是光源颜色整体感觉与内置着色器不符，不建议使用
            Tags { "LightMode" = "Vertex" } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"

            float4 _Color;//材质自身颜色

            struct v2f
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;

            };
            //顶点着色器进行光照计算时，颜色不平滑
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 normalizeDir =  normalize(mul(v.normal.xyz,(float3x3)unity_WorldToObject));
                float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;
                float lightIntense = saturate(dot(normalizeDir,lightDir));//限制在0-1
                o.color = _LightColor0 * _Color * lightIntense;//用物体的颜色和光的颜色混合作为漫反射的颜色,乘上光照强度
                //unitycg.cginc中源码实现方式可以看出两参数都是基于模型空间都
                o.color.rgb = ShadeVertexLights(v.vertex, v.normal);
                //
                o.color += UNITY_LIGHTMODEL_AMBIENT;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                return i.color;
            }
            ENDCG
        }*/

        //让着色器既能被点光源照亮，也能被平行光照亮
        //多参照unity手册
        //UnityShaderVariables.cginc中的内置变量有_Time、_SinTime、_CosTime、unity_DeltaTime
        //等时间变量和unity_4LightPosX0、unity_4LightPosY0、unity_4LightPosZ0、unity_LightColor、unity_4LightAtten0衰减等灯光变量等内置变量信息
        Pass
        {
            Tags { "LightMode" = "ForwardBase" } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "lighting.cginc"

            float4 _Color;//材质自身颜色

            struct v2f
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;

            };
            //顶点着色器进行光照计算时，颜色不平滑
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 normalizeDir =  normalize(mul(v.normal.xyz,(float3x3)unity_WorldToObject));
                float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;
                float lightIntense = saturate(dot(normalizeDir,lightDir));//限制在0-1
                o.color = _LightColor0 * _Color * lightIntense;//用物体的颜色和光的颜色混合作为漫反射的颜色,乘上光照强度

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
                //只计算场景中点光源的照明信息，要同时显示平行光源，需要用加法
                //unitycg.cginc中源码实现方式可以看出参数都是基于世界空间
                o.color.rgb += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, 
                                                unity_LightColor[0].rgb, unity_LightColor[1].rgb, 
                                                unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                                                unity_4LightAtten0,
                                                worldPos,normalizeDir
                );
                //
                o.color += UNITY_LIGHTMODEL_AMBIENT;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                return i.color;
            }
            ENDCG
        }
    }
}
