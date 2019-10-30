
Shader "Unlit/Warp"
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
                
                //扭曲
                //旋转角度
                float angle = length(v.vertex) * _SinTime.w * 0.5;//_SinTime的w分量没有运行时时间因子为0，需要运行才有效果
                //构建了一个在模型坐标中绕着y轴旋转的矩阵，旋转角度取为顶点到模型坐标中心到距离
                /*float4x4 m = {
                    float4(cos(angle),0,sin(angle),0),
                    float4(0,1,0,0),
                    float4(-sin(angle),0,cos(angle),0),
                    float4(0,0,0,1)
                };
                v.vertex = mul(m, v.vertex);*/
                //优化运算次数，以上矩阵相乘等同于
                /*float x = cos(angle) *  v.vertex.x + sin(angle) * v.vertex.z;
                float z = -sin(angle) * v.vertex.x + cos(angle) * v.vertex.z;
                v.vertex.x = x;
                v.vertex.z = z;*/ 

                //x缩放
                float x = sin(v.vertex.z + _Time.y)/5 + 0.5 * v.vertex.x;
                v.vertex.x = x;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = fixed4(0,1,1,1);
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
