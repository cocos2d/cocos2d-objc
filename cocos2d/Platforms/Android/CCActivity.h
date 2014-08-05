//
//  CCActivity.h
//  Cocos2d
//
//  Created by Philippe Hausler on 6/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCMacros.h"
#if __CC_PLATFORM_ANDROID

#import <BridgeKitV3/BridgeKit.h>
#import "../../Platforms/CCGL.h"
#import "CCProtocols.h"

@class CCScene;
@class AndroidRelativeLayout;
BRIDGE_CLASS("org.cocos2d.CCActivity")
@interface CCActivity : AndroidActivity <AndroidSurfaceHolderCallback, CCDirectorDelegate>
@property (readonly, nonatomic) AndroidRelativeLayout *layout;
+ (instancetype)currentActivity;

- (void)run;

- (void)onDestroy;

- (void)onPause;
- (void)onResume;

- (void)onLowMemory;

- (void)surfaceChanged:(JavaObject<AndroidSurfaceHolder> *)holder format:(int)format width:(int)width height:(int)height;
- (void)surfaceCreated:(JavaObject<AndroidSurfaceHolder> *)holder;
- (void)surfaceDestroyed:(JavaObject<AndroidSurfaceHolder> *)holder;

- (BOOL)onKeyDown:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event;
- (BOOL)onKeyUp:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event;

- (void)runOnGameThread:(dispatch_block_t)block;
- (void)runOnGameThread:(dispatch_block_t)block waitUntilDone:(BOOL)waitUntilDone;

- (void)setupPaths;
- (CCScene *)startScene;

- (EGLContext)pushApplicationContext;
- (void)popApplicationContext:(EGLContext)ctx;

@end

#endif

