// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Outline ("OutlineWidth", float) = 0.2
        _OutlineColor ("OutlineColor", Color) = (1,1,0,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        //剔除物体背面，走默认的渲染管线
        Pass
        {       
            Name "BASE"
            Cull Back
            //Cull Back剔除背面，Cull Front剔除正面， Cull Off关闭背面剔除
            Blend OneMinusSrcColor One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG

        }
        //在VS中把顶点在投影空间沿着边缘的方向微微扩张，然后再次剔除物体正面
        Pass
        {
            Name "OUTLINE"
            Tags{"LightMode" = "Always"}
            Cull Front//使用cull front把外表面裁掉
            Blend One Zero
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f{
                float4 pos : POSITION;
            };
           
            float _Outline;
            float4 _OutlineColor;
            v2f vert(appdata v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //float3 norm = mul((float3x3)UNITY_MATRIX_MV, v.normal);
                float3 norm = UnityObjectToViewPos(v.normal);
                //得到投影空间所需扩张的方向
                float2 offset = TransformViewToProjection(norm.xy);
                o.pos.xy += offset * _Outline;
                return o;

            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _OutlineColor;
                return col;
            }
            
            ENDCG
        }
    }
}
