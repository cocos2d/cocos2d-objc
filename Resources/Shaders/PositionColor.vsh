// http://www.cocos2d-iphone.org

attribute vec4 a_position;
attribute vec4 a_color;

uniform		mat4 u_MVMatrix;
uniform		mat4 u_PMatrix;

varying vec4 v_fragmentColor;

void main()
{
    gl_Position = u_PMatrix * u_MVMatrix * a_position;
	v_fragmentColor = a_color;
}