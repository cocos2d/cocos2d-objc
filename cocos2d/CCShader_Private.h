#import "CCShader.h"


#if __CC_METAL_SUPPORTED_AND_ENABLED
#import <Metal/Metal.h>
#import "CCMetalSupport_Private.h"
#endif


@class CCRenderer;


typedef void (^CCUniformSetter)(
	__unsafe_unretained CCRenderer *renderer,
	__unsafe_unretained NSDictionary *shaderUniforms,
	__unsafe_unretained NSDictionary *globalShaderUniforms
);


@interface CCShader() {
	@public
	GLuint _program;
	NSDictionary *_uniformSetters;
	
	// TODO This should really be split into a separate subclass somehow.
#if __CC_METAL_SUPPORTED_AND_ENABLED
	id<MTLFunction> _vertexFunction, _fragmentFunction;
#endif
}

@end
