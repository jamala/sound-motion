varying vec3 vNormal;
void main() {
    gl_FragColor = vec4(vNormal.xyz, 1.0);
}