attribute vec4 aVertex;
attribute vec2 aTexCoord;
attribute vec4 aColor;

uniform		mat4 uMatrix;
uniform		vec2 uAnchor;

varying vec4 vFragmentColor;
varying vec2 vTexCoord;

mat4 projectionMatrix = mat4( 2.0/320.0, 0.0, 0.0, -1.0,
                              0.0, 2.0/480.0, 0.0, -1.0,
                              0.0, 0.0, -1.0, 0.0,
                              0.0, 0.0, 0.0, 1.0);     
void main()
{
    gl_Position = uMatrix * aVertex;
	gl_Position *= projectionMatrix;
	vFragmentColor = aColor;
	vTexCoord = aTexCoord;
}