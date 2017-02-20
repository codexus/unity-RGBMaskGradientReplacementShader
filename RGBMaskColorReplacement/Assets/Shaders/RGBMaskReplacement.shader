Shader "ColorReplacement/RGBMaskReplacement" {
	Properties {

		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RGBMask("RGB mask", 2D) = "white" {}
		_NormalMap("Normal map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range(0.1,5)) = 1

		_GradientTex1("Red gradient mask(don't change)", 2D) = "white" {}
		_GradientTex2("Green gradient mask(don't change)", 2D) = "white" {}
		_GradientTex3("Blue gradient mask(don't change)", 2D) = "white" {}
		
		
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM

		#pragma surface surf Lambert fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _RGBMask;
		sampler2D _NormalMap;
		half _NormalStrength;

		struct Input {
			float2 uv_MainTex;
		};

		sampler2D _GradientTex1;
		sampler2D _GradientTex2;
		sampler2D _GradientTex3;

		fixed3 ApplyMask(fixed4 c, fixed4 m) {
			
			fixed3 res = c.rgb; // end result color
			fixed grayVal = Luminance(c.rgb); // Converts color to luminance(grayscale). lerp 

			// apply lerped color from grayscale regarding mask
			if (m.r >= .1 || m.g >= .1 || m.b >= .1) {
	
				//tex2Dlod - 2D texture lookup with specified level of detail and optional texel offset.
				//float4 tex2Dlod(sampler2D samp, float4 s); samp - Sampler to lookup, s.xy - Coordinates to perform the lookup, s.w - Level of detail.

				half4 lerpedColor1 = tex2Dlod(_GradientTex1, half4 (grayVal, 1, 0, 0));  
				half4 lerpedColor2 = tex2Dlod(_GradientTex2, half4 (grayVal, 1, 0, 0));
				half4 lerpedColor3 = tex2Dlod(_GradientTex3, half4 (grayVal, 1, 0, 0));

				res = (lerpedColor1.rgb * m.r) + (lerpedColor2.rgb * m.g) + (lerpedColor3.rgb * m.b);
			}
			return res;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex); // main color
			fixed4 m = tex2D(_RGBMask, IN.uv_MainTex); // mask

			o.Albedo = ApplyMask(c, m);
 
			fixed3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			normal.z = normal.z / _NormalStrength; 
			o.Normal = normalize(normal);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
