// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

Shader "ColorReplacement/RGBMaskGradientUnlit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RGBMask("RGB mask", 2D) = "white" {}
		
		_GradientTex1("Gradient texture red channel", 2D) = "white" {}
		_GradientTex2("Gradient texture green channel", 2D) = "white" {}
		_GradientTex3("Gradient texture blue channel", 2D) = "white" {}
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
			#include "AutoLight.cginc"

			// Variables

			// https://forum.unity3d.com/threads/what-is-_maintex_st.24962/
			// Unity provides value for float4 with "_ST" suffix. The x,y contains texture scale, and z,w contains translation (offset). 
			// S = sccale, T = translation ( offset ), NOTE: Can't use TRANSFORM_TEX without _[name]_ST
			float4 _MainTex_ST;

			// Simple samplers
			sampler2D _MainTex;
			sampler2D _RGBMask;

			sampler2D _GradientTex1;
			sampler2D _GradientTex2;
			sampler2D _GradientTex3;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				half4 normal : NORMAL;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex); 
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				/*
				A note regarding UnityObjectToClipPos
				
				UnityObjectToClipPos(v.vertex) is always preferred where mul(UNITY_MATRIX_MVP, v.vertex) would otherwise be used.
				
				While you can continue to use UNITY_MATRIX_MVP as normal in instanced Shaders,
				UnityObjectToClipPos is the most efficient way of transforming vertex positions from object space into clip space.
				
				In instanced Shaders, UNITY_MATRIX_MVP(among other built - in matrices) is transparently modified to include an extra matrix multiply.
				
				Specifically, it is expanded to mul(UNITY_MATRIX_VP, unity_ObjectToWorld).unity_ObjectToWorld is expanded to unity_ObjectToWorldArray[unity_InstanceID]).
				UnityObjectToClipPos is optimized to perform two matrix - vector multiplications simultaneously, 
				and is therefore more efficient than performing the multiplication manually, because the Shader compiler does not automatically perform this optimization.
				*/

				o.uv = TRANSFORM_TEX(v.uv, _MainTex); // TRANSFORM_TEX macro from UnityCG.cginc to make sure texture scale and offset is applied correctly
				return o;
			}

			fixed3 ApplyMask(fixed4 c, fixed4 m) {
				
				fixed3 res = c.rgb; // end result color
				fixed grayVal = Luminance(c.rgb);

				if (m.r >= .1 || m.g >= .1 || m.b >= .1) {

					//tex2Dlod - 2D texture lookup with specified level of detail and optional texel offset.
					//float4 tex2Dlod(sampler2D samp, float4 s); samp - Sampler to lookup, s.xy - Coordinates to perform the lookup, s.w - Level of detail.

					float4 lerpedColor1 = tex2Dlod(_GradientTex1, float4 (grayVal, 1, 1, 0));
					float4 lerpedColor2 = tex2Dlod(_GradientTex2, float4 (grayVal, 1, 1, 0));
					float4 lerpedColor3 = tex2Dlod(_GradientTex3, float4 (grayVal, 1, 1, 0));
					res = (lerpedColor1.rgb * m.r) + (lerpedColor2.rgb * m.g) + (lerpedColor3.rgb * m.b);
				}
				return res;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv); // main tex
				fixed4 m = tex2D(_RGBMask, i.uv); // mask

				fixed4 col = fixed4(ApplyMask(c, m), c.a);
				// sample the texture
				return col;
			}
			ENDCG
		}		
	}
}
