// http://www.cocos2d-iphone.org

varying lowp vec2 v_texCoord;
uniform sampler2D u_texture;

void main()
{
	gl_FragColor =  texture2D(u_texture, v_texCoord);
}
