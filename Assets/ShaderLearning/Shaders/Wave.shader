
Shader "Unlit/Wave"
{
   
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : POSITION;
                fixed4 color : COLOR;
            };

            v2f vert (appdata_base v)
            {
                float up = sin(v.vertex.x) + _Time.y;
                //波浪，在y方向上的运动
                //正弦波，简谐运动
                //A*sin(w*x+t)
                //v.vertex.y += 1*sin(_Time.y * 1 + _Time.y);//所有顶点同步简谐运动 
                //考虑x、z,引入w角速度
                //旗帜
                //v.vertex.y += 0.5 * sin(v.vertex.x / 2 + _Time.y);
                //v.vertex.y += 0.5 * sin(v.vertex.z / 2 + _Time.y);

                //点波浪
                //v.vertex.y += 0.2 * sin(-length(v.vertex.xz) * 1.5 + _Time.y);

                //错落有致水波
                v.vertex.y += 0.2 * sin( (v.vertex.x + v.vertex.z) / 2 + _Time.y);
                v.vertex.y += 0.3 * sin( (v.vertex.x - v.vertex.z) / 2 + _Time.w);

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = fixed4(v.vertex.y,v.vertex.y,v.vertex.y,1);
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
