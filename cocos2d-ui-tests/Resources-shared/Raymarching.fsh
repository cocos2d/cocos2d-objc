precision highp float;

vec2 clip_coord()
{
	vec2 aspect = vec2(cc_ViewSize.x/cc_ViewSize.y, 1.0);
	return 2.0*aspect*gl_FragCoord.xy/cc_ViewSize.xy - aspect;
}

vec3 eye_ray(vec3 eye, vec3 look_at, vec3 eye_up, float fov){
	// Do as a matrix?
	vec3 forward = normalize(look_at - eye);
	vec3 right = cross(forward, normalize(eye_up));
	vec3 up = cross(right, forward);
	
	vec2 clip = clip_coord();
	return normalize(forward + (clip.x*fov)*right + clip.y*up);
}

float d_sphere(vec3 v, vec3 p, float r){
	return length(v - p) - r;
}

float d_cylinder(vec3 v, vec3 p, vec3 n, float r, float l){
	float dvn = dot(v - p, n);
	return max(
		length(v - n*dvn) - r,
		abs(dvn) - l*0.5
	);
}

float d_box(vec3 v, vec3 p, vec3 b){
	vec3 d = abs(v - p) - b*0.5;
	return max(max(d.x, d.y), d.z);
}

float d_union(float d1, float d2){ return min(d1, d2); }
float d_subtract(float d1, float d2){ return max(d1, -d2); }
float d_intersect(float d1, float d2){ return max(d1, d2); }

float dist(vec3 v){
	float s = 1.3;
	float r = mix(1.6, 1.8, 0.5*sin(2.0*cc_Time[0]) + 0.5);
	
	float d = 1e10;
	d = d_union(d, -d_box(v, vec3(0), vec3(10.0)));
	d = d_union(d, d_box(v, vec3(0), vec3(2.0*s)));
	d = d_subtract(d, d_sphere(v, vec3(0), r));
	d = d_union(d, d_sphere(v, vec3(0), r*0.75));
	d = d_union(d, d_cylinder(v, vec3(0), vec3(1,0,0), 0.2, 10.0));
	d = d_union(d, d_cylinder(v, vec3(0), vec3(0,1,0), 0.2, 10.0));
	d = d_union(d, d_cylinder(v, vec3(0), vec3(0,0,1), 0.2, 10.0));
	return d;
}

const float g_eps = 1e-3;

vec3 grad(vec3 p){
	return normalize(vec3(
		dist(p + vec3(g_eps,0,0)) - dist(p - vec3(g_eps,0,0)),
		dist(p + vec3(0,g_eps,0)) - dist(p - vec3(0,g_eps,0)),
		dist(p + vec3(0,0,g_eps)) - dist(p - vec3(0,0,g_eps))
	));
}

const int iterations = 32;
const float threshold = 1e-3;
const float min_step = 1e-4;
const float step_fraction = 0.75;

struct Hit {
	vec3 p, n;
	float d;
};

Hit raymarch(vec3 eye, vec3 ray){
	float dsum = 0.0;
	for(int i=0; i<iterations; i++){
		vec3 p = eye + dsum*ray;
		float dmin = dist(p);
		if(dmin < threshold){
			return Hit(p, grad(p), dsum);
		} else {
			dsum += max(min_step, dmin*step_fraction);
		}
	}
	
	vec3 p = eye + dsum*ray;
	return Hit(p, vec3(0), dsum);
}

const float ao_samples = 4.0;
const float ao_spacing = 0.3;
const float ao_strength = 4.0;

float ao(Hit hit){
	float sum = 0.0;
	for(float i=1.0; i<=ao_samples; i++){
		float d = i*ao_spacing;
		sum += (d - dist(hit.p + hit.n*d))/pow(2.0, i);
	}
	
	return 1.0 - ao_strength*sum;
}

const int shadow_iterations = 64;

float shadowmarch(vec3 point, vec3 light){
	vec3 delta = light - point;
	float dmax = length(delta);
	vec3 ray = delta/dmax;
	
	float shadow = 1.0;
	float dsum = 0.1;
	for(int i=0; i<shadow_iterations; i++){
		vec3 p = point + ray*dsum;
		float d = dist(p);
		if(d < 1e-6) return 0.0;
		
		dsum += max(min_step, d*step_fraction);
		shadow = min(shadow, 128.0*d/dsum);
		if(dsum > dmax) return shadow;
	}
	
	return shadow;
}

void main(void)
{
	float t = cc_Time[0]/3.0;
	vec3 eye = -4.0*normalize(vec3(-cos(t), cos(0.5*t), -sin(t)));
	vec3 look_at = vec3(0);
	vec3 up = vec3(0,sin(t),cos(t));
	
	vec3 ray = eye_ray(eye, look_at, up, 1.0);
	Hit hit = raymarch(eye, ray);
	vec3 albedo = abs(hit.n);
	float occlusion = ao(hit);
	vec3 color = albedo;
	
	vec3 light_pos = -eye.yzx;
	vec3 light_dir = normalize(light_pos - hit.p);
	float diff = clamp(dot(light_dir, hit.n), 0.0, 1.0);
	
	float spec = pow(clamp(dot(reflect(ray, hit.n), light_dir), 0.0, 1.0), 50.0);
	float light = 0.5*diff + 1.0*spec;
	float shadow = shadowmarch(hit.p, light_pos);
	color *= occlusion*(light*shadow + 0.1);
	
	vec3 fog_color = abs(ray);
	color = mix(color, fog_color, hit.d/12.0);
	
	// TODO add a curve to filter out the > 1.0 crustees
	color += 0.5*albedo*pow(1.0 + dot(hit.n, ray), 4.0);
	
	gl_FragColor = vec4(color, 0);
}