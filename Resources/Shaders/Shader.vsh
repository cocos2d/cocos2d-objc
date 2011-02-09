attribute vec4 aPosition;
attribute vec4 aColor;
varying vec4 vFragmentColor;

void main()
{
    gl_Position = aPosition;
	vFragmentColor = aColor;
}