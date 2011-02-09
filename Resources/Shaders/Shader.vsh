attribute vec4 aVertex;
attribute vec2 aTexCoord;
attribute vec4 aColor;

uniform		mat4 uMatrix;
uniform		mat4 uProjMatrix;

varying vec4 vFragmentColor;
varying vec2 vTexCoord;

void main()
{
    gl_Position = uMatrix * aVertex * uProjMatrix;
	vFragmentColor = aColor;
	vTexCoord = aTexCoord;
}