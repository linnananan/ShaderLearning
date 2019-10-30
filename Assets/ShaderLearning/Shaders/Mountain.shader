// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Mountain"
{
    Properties
    {

       _R("R", Range(0,5)) = 1
       _OX("OX", Range(-5,5)) = 0
       _OY("OY", Range(-5,5)) = 0

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
            float _R;
            float _OX;
            float _OY;

            struct v2f
            {
                float4 pos : POSITION;
                fixed4 color : COLOR;
            };

            v2f vert (appdata_base v)
            {
                float4  wPos = mul(unity_ObjectToWorld, v.vertex);

                float2 xy = wPos.xz;
                float d = _R - length(xy - float2(_OX, _OY));
                d = d<0 ? 0:d;
                float height = 1;
                float4 uppos = float4(v.vertex.x, height * d, v.vertex.z, v.vertex.w);


                v2f o;
                o.pos = UnityObjectToClipPos(uppos);
               
                o.color = fixed4(uppos.y,uppos.y,uppos.y,1);
                
                    
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
