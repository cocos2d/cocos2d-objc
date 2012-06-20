"																		\n\
#ifdef GL_ES															\n\
precision lowp float;													\n\
#endif																	\n\
																		\n\
varying vec2 v_texCoord;												\n\
uniform sampler2D CC_Texture0;											\n\
																		\n\
void main()																\n\
{																		\n\
	gl_FragColor =  texture2D(CC_Texture0, v_texCoord);					\n\
}																		\n\
";
