//
//  CCActivity.h
//  Cocos2d
//
//  Created by Philippe Hausler on 6/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ccMacros.h"
#if __CC_PLATFORM_ANDROID

#import <GLActivityKit/GLActivity.h>
#import "../../Platforms/CCGL.h"
#import "CCProtocols.h"

@class CCScene;
@class AndroidAbsoluteLayout;

@interface CCActivity : GLActivity <AndroidSurfaceHolderCallback, CCDirectorDelegate>
@property (readonly, nonatomic) AndroidAbsoluteLayout *layout;
+ (instancetype)currentActivity;


- (void)runOnGameThread:(dispatch_block_t)block;
- (void)runOnGameThread:(dispatch_block_t)block waitUntilDone:(BOOL)waitUntilDone;

- (void)setupPaths;
- (CCScene *)startScene;

- (EGLContext)pushApplicationContext;
- (void)popApplicationContext:(EGLContext)ctx;

@end

#endif

