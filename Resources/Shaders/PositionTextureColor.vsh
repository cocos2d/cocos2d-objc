// http://www.cocos2d-iphone.org

attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform		mat4 u_MVMatrix;
uniform		mat4 u_PMatrix;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    gl_Position = u_PMatrix * u_MVMatrix * a_position;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
}