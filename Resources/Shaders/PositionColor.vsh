// http://www.cocos2d-iphone.org

attribute vec4 a_position;
attribute vec4 a_color;

uniform		mat4 u_MVPMatrix;

varying vec4 v_fragmentColor;

void main()
{
    gl_Position = u_MVPMatrix * a_position;
	v_fragmentColor = a_color;
}