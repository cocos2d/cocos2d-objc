// http://www.cocos2d-iphone.org

attribute vec4 aVertex;
attribute vec4 aColor;

uniform		mat4 uMatrix;

varying vec4 vFragmentColor;

void main()
{
    gl_Position = uMatrix * aVertex;
	vFragmentColor = aColor;
}
