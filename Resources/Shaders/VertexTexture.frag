// http://www.cocos2d-iphone.org

varying lowp vec2 vTexCoord;
uniform sampler2D uTexture;

void main()
{
	gl_FragColor =  texture2D(uTexture, vTexCoord);
}
