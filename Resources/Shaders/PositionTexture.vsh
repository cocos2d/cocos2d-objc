// http://www.cocos2d-iphone.org

attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform		mat4 u_MVMatrix;
uniform		mat4 u_PMatrix;

varying vec2 v_texCoord;

void main()
{
    gl_Position = u_PMatrix * u_MVMatrix * a_position;
	v_texCoord = a_texCoord;
}