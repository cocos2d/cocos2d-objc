#extension GL_OES_standard_derivatives : enable
precision highp float;

const float rmin = 0.414213562373095; // sqrt(2) - 1
const float rmax = 1.0;

const float pi = 3.14159265358979;

float circles_mask(vec2 uv, float phase){
	float r = mix(rmin, rmax, phase);
	float l = length(mod(uv, 1.0)*2.0 - 1.0) - r;
	float fw = fwidth(l)*0.5;
	
	return smoothstep(fw, -fw, l) + min(l/r*0.5, 0.0);
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy/128.0;
	float t0 = cc_Time[0];
	float t = t0 +
	length(3.0*sin(t0*vec2(-0.5,  0.9) + 0.5*uv)) +
	length(3.0*sin(t0*vec2( 0.3, -0.7) + 0.5*uv));
	
	float phase1 = sin(t)*0.5 + 0.5;
	float mask1 = circles_mask(uv, phase1);
	
	float phase2 = sin(t + pi)*0.5 + 0.5;
	float mask2 = circles_mask(uv + 0.5, phase2);
	
	vec4 color = vec4(1.0);
	color = mix(color, vec4(1.0, 0.0, 0.0, 1.0), mask1);
	color = mix(color, vec4(0.0, 0.5, 1.0, 0.5), mask2);
	gl_FragColor = color;
}