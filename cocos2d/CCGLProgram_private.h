#import "CCGLProgram.h"

@class CCRenderer;
typedef void (^CCUniformSetter)(__unsafe_unretained CCRenderer *renderer, __unsafe_unretained id value);

@interface CCGLProgram() {
	@public
	GLint _program;
	NSMutableDictionary *_uniformSetters;
}

@end
