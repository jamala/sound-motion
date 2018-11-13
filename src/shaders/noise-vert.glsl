varying vec3 vNormal;
uniform float time;

const float M_PI = 3.14159265359;

float noise(float x, float y, float z) {
    return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453) * fract(sin(z));
}

float noise2(float x, float y, float z) {
    return fract(cos(x) * 1397531.0);
}

float linear_interpolation(float a, float b, float t) {
    return a * (1.0 - t) + b * t;     // same as a + (b - a)*t
}

float cosine_interpolation(float a, float b, float t) {
    float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
    return linear_interpolation(a, b, cos_t);
}

float interpolate2d(float v1, float v2, float v3, float v4, float tx,  float ty) {
    float n1 = cosine_interpolation(v1, v2, tx);
    float n2 = cosine_interpolation(v3, v4, tx);

    return cosine_interpolation(n1, n2, ty);
} 

float interpolate3d(float v1, float v2, float v3, float v4,
                    float v5, float v6, float v7, float v8,
                    float tx, float ty, float tz) {
    float n1 = cosine_interpolation(v1, v2, tx);
    float n2 = cosine_interpolation(v3, v4, tx);
    float n3 = cosine_interpolation(v5, v6, tx);
    float n4 = cosine_interpolation(v7, v8, tx);

    return interpolate2d(n1, n2, n3, n4, ty, tz);
}

float smooth3(float x, float y, float z) {
    float total = noise(x, y, z);

    //6 faces
    total += noise(x + 1.0, y, z);
    total += noise(x - 1.0, y, z);
    total += noise(x, y + 1.0, z);
    total += noise(x, y - 1.0, z);
    total += noise(x, y, z + 1.0);
    total += noise(x, y, z - 1.0);
    
    //12 edges
    total += noise(x + 1.0, y + 1.0, z);
    total += noise(x - 1.0, y + 1.0, z);
    total += noise(x - 1.0, y - 1.0, z);
    total += noise(x + 1.0, y - 1.0, z);
    total += noise(x + 1.0, y, z + 1.0);
    total += noise(x - 1.0, y, z + 1.0);
    total += noise(x - 1.0, y, z - 1.0);
    total += noise(x + 1.0, y, z - 1.0);
    total += noise(x, y + 1.0, z + 1.0);
    total += noise(x, y - 1.0, z + 1.0);
    total += noise(x, y - 1.0, z - 1.0);
    total += noise(x, y + 1.0, z - 1.0);

    //8 corners
    total += noise(x + 1.0, y + 1.0, z + 1.0);
    total += noise(x + 1.0, y + 1.0, z - 1.0);
    total += noise(x - 1.0, y + 1.0, z - 1.0);
    total += noise(x - 1.0, y + 1.0, z + 1.0);
    total += noise(x + 1.0, y - 1.0, z + 1.0);
    total += noise(x + 1.0, y - 1.0, z - 1.0);
    total += noise(x - 1.0, y - 1.0, z - 1.0);
    total += noise(x - 1.0, y - 1.0, z + 1.0);

    return total = 27.0;

}

float interp_noise(float x, float y, float z) { 
	float x0 = floor(x),
		y0 = floor(y),
		z0 = floor(z),
	 	x1 = ceil(x),
	 	y1 = ceil(y),
	 	z1 = ceil(z);

	float p1 = noise(x0, y0, z0),
		p2 = noise(x1, y0, z0),
		p3 = noise(x0, y1, z0),
		p4 = noise(x0, y0, z1),
		p5 = noise(x0, y1, z1),
		p6 = noise(x1, y1, z0),
		p7 = noise(x1, y0, z1),
		p8 = noise(x1, y1, z1);

	float dx = (x - x0) / (x1 - x0),
		dy = (y - y0) / (y1 - y0),
		dz = (z - z0) / (z1 - z0);

	// Interpolate along x
	float a1 = cosine_interpolation(p1, p2, dx),
		a2 = cosine_interpolation(p4, p7, dx), 
		a3 = cosine_interpolation(p3, p6, dx),
		a4 = cosine_interpolation(p5, p8, dx);

	// Interpolate along y
	float b1 = cosine_interpolation(a1, a3, dy),
		b2 = cosine_interpolation(a2, a4, dy);

	// Interpolate along z
	float c = cosine_interpolation(b1, b2, dz);

	return c; 
}


float interpolate_noise(vec3 p) {
    vec3 t = fract(p);
    vec3 n = floor(p);

    float v1 = noise(n.x, n.y, n.z);
    float v2 = noise(n.x + 1.0, n.y, n.z);
    float v3 = noise(n.x + 1.0, n.y, n.z + 1.0);
    float v4 = noise(n.x, n.y, n.z + 1.0);
    float v5 = noise(n.x, n.y + 1.0, n.z);
    float v6 = noise(n.x + 1.0, n.y + 1.0, n.z);
    float v7 = noise(n.x + 1.0, n.y + 1.0, n.z + 1.0);
    float v8 = noise(n.x, n.y + 1.0, n.z + 1.0);
    return interpolate3d(v1, v2, v3, v4, v5, v6, v7, v8, t.x, t.y, t.z);


}
void main() {
    vNormal = normal;
    vec4 noise_pos = vec4(position.xyz + normal * interp_noise(position.x + time, position.y + time, position.z + time), 1.0);
    if (noise_pos == vec4(0,0,0,1)) {
        noise_pos = vec4(position, 1.0);
    }
    gl_Position = projectionMatrix * modelViewMatrix * noise_pos; 
}