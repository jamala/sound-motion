varying vec3 vNormal;
uniform float time;

void main() {
    gl_FragColor = vec4(vNormal.xyz, 1.0);
}