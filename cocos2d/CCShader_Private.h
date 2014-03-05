#import "CCShader.h"

@class CCRenderer;
typedef void (^CCUniformSetter)(__unsafe_unretained CCRenderer *renderer, __unsafe_unretained id value);

@interface CCShader() {
	@public
	GLuint _program;
	NSDictionary *_uniformSetters;
}

@end
