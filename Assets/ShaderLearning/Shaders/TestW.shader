Shader "Unlit/TestW"
{
    Properties
    {
       _dis("dis", float) = 0.1
       _r("r", float) = 0.8
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _dis;
            float _r;

            struct v2f
            {
                float4 pos : POSITION;
                fixed4 color : COLOR;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //透视除法，齐次除法
                float x = o.pos.x / o.pos.w;
                o.color = fixed4(x,x,x,1);
                //区别
                //float x2 = o.pos.x;
                //o.color = fixed4(x2,x2,x2,1);
                    
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
