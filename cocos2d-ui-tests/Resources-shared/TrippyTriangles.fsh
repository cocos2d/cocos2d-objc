#ifdef GL_ES
precision highp float;
#extension GL_OES_standard_derivatives : enable
#endif

const float sqrt3 = 1.73205080756888;

vec2 rotate(vec2 v, float t)
{
	mat2 m1 = mat2(1,0,0,1);
	mat2 m2 = mat2(-0.5, sqrt3*0.5, -sqrt3*0.5, -0.5);
	mat2 m = m1*(1.0 - t) + m2*t;
	float det = m[0][0]*m[1][1] - m[1][0]*m[0][1];
	return m*v/det;
}

float tri_dist(vec2 uv)
{
	return max(uv.y, abs(uv.x)*sqrt3*0.5 - uv.y*0.5);
}

const mat3 rect2tri = mat3(
	2.0*sqrt3, 0.0, 0.0,
	-sqrt3, -3.0, 0.0,
	-sqrt3, 1.0, 1.0
);

const mat3 tri2rect = mat3(
	sqrt3/6.0, 0.0, 0.0,
	-1.0/6.0, -1.0/3.0, 0.0,
	2.0/3.0, 1.0/3.0, 1.0
);

void main(void)
{
	float scale = 32.0;
	vec2 uv = (gl_FragCoord.xy - cc_ViewSize.xy/2.0)/scale;
	
	// Some fun pointless distortion.
	float t1 = cc_Time[0]/10.0;
	uv = vec2(uv.x + 5.0*sin(t1 + uv.y/10.0), uv.y + 5.0*sin(1.3*t1 + uv.x/10.0));
	
	// Some fun pointless rotation.
	vec2 rot = vec2(cos(t1), sin(t1));
	uv = mat2(rot.x, rot.y, -rot.y, rot.x)*uv;
	
	// Convert to rectangular UVs and reflect over y=x
	vec2 rect = (tri2rect*vec3(uv, 1.0)).xy;
	vec2 wrap = rect - floor(rect);
	vec2 flip = vec2(max(wrap.x, wrap.y), min(wrap.x, wrap.y));
	
	// Convert back to screen space
	vec2 uv2 = (rect2tri*vec3(flip, 1.0)).xy;
	
	vec2 t2 = cc_Time[0]*vec2(1.0, 1.3);
	float phase = dot(sin(uv/5.0 + t2), vec2(1.0))/4.0;
	
	// Rotate the UVs of the triangles.
	float t3 = mod(cc_Time[0]/16.0 + phase, 1.0);
	float d = tri_dist(rotate(uv2, t3));
	
	// Trace the d = 1.0 contour! \o/
	float fw = fwidth(d)*0.5;
	float mask = smoothstep(1.0 - fw, 1.0 + fw, d);
//	float mask = step(d, 1.0);
	
	float t4 = 0.0;//pow(abs(2.0*mod(t3 + 0.95, 1.0) - 1.0), 3.0);
	vec3 color1 = vec3(t4, t4, 0.0);
	vec3 color2 = vec3(1.0, 1.0 - t3, 0.0);
	vec3 color = mix(color1, color2, mask);
	gl_FragColor = vec4(color, 1.0); return;
}
