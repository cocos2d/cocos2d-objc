// http://www.cocos2d-iphone.org

attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform		mat4 u_MVPMatrix;

varying vec2 v_texCoord;

void main()
{
    gl_Position = u_MVPMatrix * a_position;
	v_texCoord = a_texCoord;
}