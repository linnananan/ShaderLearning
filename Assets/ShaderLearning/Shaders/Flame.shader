Shader "Custom/Flame"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HDR]_BurnFirstColor("Burn First Color", Color) = (1,0,0,1)//HDR让颜色在支持hdr渲染流程中有发光效果
        [HDR]_BurnSecondColor("Burn Second Color", Color) = (1,0,0,1)
        _LineWidth("Burn Size", Range(0.0, 0.2)) = 0.1

        _BurnTex("Burn Texture(RGB)", 2D) = "white" {}//燃烧纹理
        _BurnAmount("Burn Amount", Range(0.0, 1.0)) = 0.5//燃烧值

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BurnTex;
        float _BurnAmount;
        fixed4 _BurnFirstColor;
        fixed4 _BurnSecondColor;
        float _LineWidth;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BurnTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            //为了达到物体溶解的效果，采用一张噪声纹理作为燃烧的纹理，同时用clip去掉已燃烧掉部分的像素
            fixed3 burn = tex2D(_BurnTex, IN.uv_BurnTex);
            clip(burn.r - _BurnAmount);//根据纹理clip掉燃烧的像素，这张纹理是灰度图rgb都一样
            //燃烧的宽度对火焰颜色进行插值作为当前像素的火焰颜色
            fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
            //火焰的初始颜色和结束颜色插值作为边缘火焰效果
            fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
            burnColor = pow(burnColor, 10);
            //叠加贴图主纹理
            fixed3 finalColor = lerp(o.Albedo, burnColor, t * step(0.0001, _BurnAmount));

            o.Albedo = finalColor;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
