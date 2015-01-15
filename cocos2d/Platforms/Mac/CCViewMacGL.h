//
//  CCViewMacGL.h
//  cocos2d
//
//  Created by Oleg Osin on 1/12/15.
//
//

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "ccMacros.h"
#if __CC_PLATFORM_MAC

#import <Cocoa/Cocoa.h>
#import "CCView.h"

//#import "../../ccConfig.h"

/** CCViewMacGL
 
 Only available for Mac OS X
 */
@interface CCViewMacGL : NSOpenGLView <CCView>

@property(nonatomic, weak, readonly) CCDirector* director;

/** initializes the CCGLView with a frame rect and an OpenGL context */
-(id)initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context;

/** returns the depth format of the view in BPP */
-(NSUInteger)depthFormat;

/** uses and locks the OpenGL context */
-(void)lockOpenGLContext;

/** unlocks the openGL context */
-(void)unlockOpenGLContext;

-(GLuint)fbo;

@end

#endif // __CC_PLATFORM_MAC
