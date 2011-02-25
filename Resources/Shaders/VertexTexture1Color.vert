// http://www.cocos2d-iphone.org

attribute vec4 aVertex;
attribute vec2 aTexCoord;

uniform		mat4 uMVMatrix;
uniform		mat4 uPMatrix;
uniform		vec4 uOneColor;

varying vec4 vFragmentColor;
varying vec2 vTexCoord;

void main()
{
    gl_Position = uPMatrix * uMVMatrix * aVertex;
	vFragmentColor = uOneColor;
	vTexCoord = aTexCoord;
}