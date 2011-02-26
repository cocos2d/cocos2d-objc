// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision highp float;
#endif

varying vec4 vFragmentColor;
varying vec2 vTexCoord;

uniform sampler2D uTexture;

uniform vec2 blurSize;
uniform vec4 subtract;

void main() {
	vec4 sum = vec4(0.0);
	sum += texture2D(uTexture, vTexCoord - 4.0 * blurSize) * 0.05;
	sum += texture2D(uTexture, vTexCoord - 3.0 * blurSize) * 0.09;
	sum += texture2D(uTexture, vTexCoord - 2.0 * blurSize) * 0.12;
	sum += texture2D(uTexture, vTexCoord - 1.0 * blurSize) * 0.15;
	sum += texture2D(uTexture, vTexCoord                 ) * 0.16;
	sum += texture2D(uTexture, vTexCoord + 1.0 * blurSize) * 0.15;
	sum += texture2D(uTexture, vTexCoord + 2.0 * blurSize) * 0.12;
	sum += texture2D(uTexture, vTexCoord + 3.0 * blurSize) * 0.09;
	sum += texture2D(uTexture, vTexCoord + 4.0 * blurSize) * 0.05;

	gl_FragColor = (sum - subtract) * vFragmentColor;
}

