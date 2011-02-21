// http://www.cocos2d-iphone.org

varying lowp vec4 vFragmentColor;
varying lowp vec2 vTexCoord;
uniform sampler2D uTexture;

void main()
{
	gl_FragColor = vFragmentColor * texture2D(uTexture, vTexCoord);
}
