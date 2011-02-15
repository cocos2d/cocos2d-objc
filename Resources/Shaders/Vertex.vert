// http://www.cocos2d-iphone.org

attribute vec4 aVertex;
uniform		mat4 uMVPMatrix;

void main()
{
    gl_Position = uMVPMatrix * aVertex;
}
