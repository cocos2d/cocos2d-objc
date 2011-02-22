// http://www.cocos2d-iphone.org

attribute vec4 aVertex;
attribute vec2 aTexCoord;

uniform		mat4 uMVMatrix;
uniform		mat4 uPMatrix;

varying vec2 vTexCoord;

void main()
{
    gl_Position = uPMatrix * uMVMatrix * aVertex;
	vTexCoord = aTexCoord;
}