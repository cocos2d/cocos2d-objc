// http://www.cocos2d-iphone.org

attribute vec4 a_position;

uniform		mat4 u_MVPMatrix;
uniform		vec4 u_color;

varying vec4 v_fragmentColor;

void main()
{
    gl_Position = u_MVPMatrix * a_position;
	v_fragmentColor = u_color;
}