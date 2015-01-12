//
//  CCViewiOSGL.h
//  cocos2d
//
//  Created by Oleg Osin on 1/8/15.
//
//

#import "ccMacros.h"
#if __CC_PLATFORM_IOS

#import <UIKit/UIView.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "CCView.h"

@interface CCViewiOSGL : UIView <CCView>

/** creates an initializes an CCGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer. */
+ (id) viewWithFrame:(CGRect)frame;
/** creates an initializes an CCGLView with a frame, a color buffer format, and 0-bit depth buffer. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** creates an initializes an CCGLView with a frame, a color buffer format, and a depth buffer. */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth;
/** creates an initializes an CCGLView with a frame, a color buffer format, a depth buffer format, a sharegroup, and multisamping */
+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)multisampling numberOfSamples:(unsigned int)samples;

/** Initializes an CCGLView with a frame and 0-bit depth buffer, and a RGB565 color buffer */
- (id) initWithFrame:(CGRect)frame; //These also set the current context
/** Initializes an CCGLView with a frame, a color buffer format, and 0-bit depth buffer */
- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format;
/** Initializes an CCGLView with a frame, a color buffer format, a depth buffer format, a sharegroup and multisampling support */
- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)sampling numberOfSamples:(unsigned int)nSamples;

/** pixel format: it could be RGBA8 (32-bit) or RGB565 (16-bit) */
@property(nonatomic,readonly) NSString* pixelFormat;
/** depth format of the render buffer: 0, 16 or 24 bits*/
@property(nonatomic,readonly) GLuint depthFormat;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

/** OpenGL context */
@property(nonatomic,readonly) EAGLContext *context;

@property(nonatomic,readwrite) BOOL multiSampling;

@property(nonatomic, readonly) GLuint fbo;

@property(nonatomic, weak) CCDirector* director;

@end

#endif
