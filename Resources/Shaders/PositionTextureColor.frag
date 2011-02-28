// http://www.cocos2d-iphone.org

varying lowp vec4 v_fragmentColor;
varying lowp vec2 v_texCoord;
uniform sampler2D u_texture;

void main()
{
	gl_FragColor = v_fragmentColor * texture2D(u_texture, v_texCoord);
}
