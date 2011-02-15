// http://www.cocos2d-iphone.org

precision mediump float;
varying vec4 vFragmentColor;
varying vec2 vTexCoord;
uniform sampler2D sTexture;

void main()
{
	gl_FragColor = vFragmentColor * texture2D(sTexture, vTexCoord);

//   float odd = floor(mod(gl_FragCoord.y, 2.0));	
//	gl_FragColor *= odd;
}
