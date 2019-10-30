
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
            //Forward渲染路径
            Tags { "LightMode" = "ForwardAdd" } 

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
            //可参照UnityCG.cginc中appdata_base结构体成员变量
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                //法线方向
                float3 normalizeDir = normalize(mul(float4(v.normal,0.0),unity_WorldToObject)).xyz;
                //光线衰减量
                float attenuation;
                //光照方向
                float3 lightDir;
                
                //光方向必须是顶点指向光源
                float3 vertexToLightSource = (_WorldSpaceLightPos0 - mul(unity_ObjectToWorld, v.vertex)).xyz;
                //顶点到光源之间到距离
                float lightDis = length(vertexToLightSource);
                //用距离来计算光线衰减量,距离越大，衰减越大
                attenuation = 1.0 / lightDis;
                lightDir = normalize(vertexToLightSource).xyz;

                //简单的漫反射中，光照在物体上面，然后将物体表面的颜色一起反射到摄像机中
                //反射出来的光照强度则是由物体表面和光线的夹角确定的（其实是物体表面的法线和光线的夹角）
                //漫反射强度
                float lightIntense = saturate(dot(normalizeDir,lightDir));//限制在0-1
                o.color = _LightColor0 * _Color * lightIntense;//用物体的颜色和光的颜色混合作为漫反射的颜色,在乘上光照强度


                //一个典型的漫反射光照模拟自然世界的环境光照，包含环境光ambient和反射折射diffuse
                //手册BUilt-in shader variables中的Fog and Ambient中有光照模型中的环境光UNITY_LIGHTMODEL_AMBIENT
                //也可以直接在片段程序中加上UNITY_LIGHTMODEL_AMBIENT
                o.color += UNITY_LIGHTMODEL_AMBIENT;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                return i.color;
            }
            ENDCG
        }*/

        Pass
        {
            //Forward渲染路径
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
            //可参照《shader入门精要》，在片段着色器中进行光照计算
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //光照的属性肯定是从unity传进来的，shader自己肯定不知道灯光的信息
                //参照手册BUilt-in shader variables中的Lighting中
                //_LightColor0灯光颜色 float4
                //_WorldSpaceLightPos0世界坐标中灯光的位置 float4
                //如果是平行光，则值为（平行光在世界空间中的方向，0）
                //如果是其他光源，则值为 (光源在世界空间中的位置，1)
                //这些内置变量在lighting.cginc中
                //法线方向与光照方向数据必须在同一个坐标空间下，同时在模型坐标空间，或同时在世界坐标空间

                //模型空间下，在非等比缩放时，法向量错误，光照强度错误
                //float3 normalizeDir = normalize(v.normal);
                //float3 lightDir = normalize(mul(unity_WorldToObject,_WorldSpaceLightPos0)).xyz;

                //世界空间下，在非等比缩放时，法向量错误，光照强度错误
                //float3 normalizeDir =  normalize(mul(unity_ObjectToWorld, float4(v.normal,0))).xyz;
                //float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;

                //非等比缩放时，法向量的正确变换
                float3 normalizeDir =  normalize(mul(v.normal.xyz,(float3x3)unity_WorldToObject));
                float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;
                
                //简单的漫反射中，光照在物体上面，然后将物体表面的颜色一起反射到摄像机中
                //反射出来的光照强度则是由物体表面和光线的夹角确定的（其实是物体表面的法线和光线的夹角）
                //漫反射强度
                float lightIntense = saturate(dot(normalizeDir,lightDir));//限制在0-1
                o.color = _LightColor0 * _Color * lightIntense;//用物体的颜色和光的颜色混合作为漫反射的颜色,在乘上光照强度


                //一个典型的漫反射光照模拟自然世界的环境光照，包含环境光ambient和反射折射diffuse
                //手册BUilt-in shader variables中的Fog and Ambient中有光照模型中的环境光UNITY_LIGHTMODEL_AMBIENT
                //也可以直接在片段程序中加上UNITY_LIGHTMODEL_AMBIENT
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
