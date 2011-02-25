// http://www.cocos2d-iphone.org

attribute vec4 aVertex;

uniform		mat4 uMVMatrix;
uniform		mat4 uPMatrix;

void main()
{
    gl_Position = uPMatrix * uMVMatrix * aVertex;
}