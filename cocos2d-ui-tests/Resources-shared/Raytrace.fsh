#extension GL_OES_standard_derivatives : enable
precision highp float;

const vec4 sky = vec4(0.5, 0.5, 1.0, 1.0);

// Filter far away values to get rid of the flicker.
vec4 checker_aa(vec3 coord){
	coord *= 0.25;
	coord += vec3(0.3);
	vec3 tri = abs(mod(2.0*coord, 4.0) - vec3(2.0)) - vec3(1.0);
	float value = tri.x*tri.z;
	float fw = fwidth(value)*0.5;
	return vec4(smoothstep(-fw, fw, value));
}

vec4 raytrace_plane(vec3 origin, vec3 dir){
	float t = origin.y/dir.y;
	vec3 point = origin - dir*t + vec3(0.0);
	return mix(checker_aa(point), sky, step(0.0, t));
}

const vec3 center = vec3(0, 2, 0);
float radius = 0.75;

vec4 raytrace_sphere(vec3 origin, vec3 dir){
	
	vec3 a = origin - center;
	vec3 b = a + dir;
	float daa = dot(a, a);
	float dab = dot(a, b);
	
	float qa = daa - 2.0*dab + dot(b, b);
	float qb = -daa + dab;
	float qc = daa - radius*radius;
	
	float det = qb*qb - qa*qc;
	if(det >= 0.0){
		float t = (-qb - sqrt(det))/(qa);
		if(t >= 0.0){
			vec3 n = normalize(mix(a, b, t));
			vec3 point = origin + dir*t;
			
			vec3 diffuse = max(-n, 0.0);
			vec3 ref = raytrace_plane(point, reflect(dir, n)).rgb;
			
			
			return vec4(mix(diffuse, ref, 0.5), 1.0);
		}
	}
	
	return vec4(0.0);
}

vec4 raytrace()
{
	const float rate = 1.0;
	float t = cc_Time[0];
	vec2 sc = vec2(cos(t*rate), sin(t*rate));
	
	float dist = (0.5*sin(0.3*t) + 0.5) + radius + 0.05;
	float height = 2.0*sin(0.6*t);
	
	// Do as a matrix?
	vec3 forward = normalize(vec3(sc.y, -height, sc.x));
	vec3 origin = center - dist*forward;
	vec3 right = cross(forward, vec3(0,1,0));
	vec3 up = cross(right, forward);
	
	float aspect = cc_ViewSizeInPixels.x/cc_ViewSizeInPixels.y;
	vec2 clip = vec2(2)*gl_FragCoord.xy/cc_ViewSizeInPixels.xy - vec2(1);
	vec3 dir = normalize(forward + (clip.x*aspect)*right + clip.y*up);
	
	vec4 sphere = raytrace_sphere(origin, dir);
	vec4 plane = raytrace_plane(origin, dir);
	return mix(plane, sphere, sphere.a);
}

void main(void)
{
	gl_FragColor = raytrace();
}