//
//  CCView.h
//  cocos2d
//
//  Created by Oleg Osin on 1/7/15.
//
//

#import "ccTypes.h"

@class CCDirector;

@protocol CCView <NSObject>

// Prepare the view to render a new frame.
-(void)beginFrame;

// Present the current frame to the display.
-(void)presentFrame;

// Schedule a block to be invoked when the frame completes.
// The block may not be invoked from the main thread.
// @param handler The completion block. The block takes no arguments and has no return value.
-(void)addFrameCompletionHandler:(dispatch_block_t)handler;

@property(nonatomic, strong, readonly) CCDirector *director;
@property(nonatomic, readonly) GLuint fbo;

@end
