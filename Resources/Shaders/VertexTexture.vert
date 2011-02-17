// http://www.cocos2d-iphone.org

attribute vec4 aVertex;
attribute vec2 aTexCoord;

uniform		mat4 uMVPMatrix;

varying vec2 vTexCoord;

void main()
{
    gl_Position = uMVPMatrix * aVertex;
	vTexCoord = aTexCoord;
}