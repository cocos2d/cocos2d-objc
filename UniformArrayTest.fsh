uniform highp float uni1[3];
uniform highp vec2 uni2[3];
uniform highp vec3 uni3[3];
uniform highp vec4 uni4[3];

void main() {
    float c = uni1[0] * uni1[1] * uni1[2]
    * length(uni2[0]) * length(uni2[1]) * length(uni2[2])
    * length(uni3[0]) * length(uni3[1]) * length(uni3[2])
    * length(uni4[0]) * length(uni4[1]) * length(uni4[2]);
    
    if (c > 0.0)
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    else
        gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}