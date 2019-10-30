
Shader "Unlit/DiffuseFrag"
{
    Properties
    {
        
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

            fixed4 frag (v2f i) : SV_Target
            {
                //ambient color
                fixed4  col = UNITY_LIGHTMODEL_AMBIENT;
                //diffuse col
                float3 N = UnityObjectToWorldNormal(i.normal);
                float3 L = normalize(WorldSpaceLightDir(i.vertex));
                float diffuseScale = saturate(dot(N, L));//限定在0-1
                col += _LightColor0 * diffuseScale;
                return col;
            }
            ENDCG
        }
    }
}
