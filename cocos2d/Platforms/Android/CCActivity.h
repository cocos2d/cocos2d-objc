//
//  CCActivity.h
//  Cocos2d
//
//  Created by Philippe Hausler on 6/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCMacros.h"
#if __CC_PLATFORM_ANDROID

#import <GLActivityKit/GLActivity.h>
#import "../../Platforms/CCGL.h"
#import "CCDirector.h"
#import "CCProtocols.h"
#import "CCGLView.h"

@class CCScene;
@class AndroidAbsoluteLayout;
@class AndroidDisplayMetrics;


@interface CCActivity : GLActivity <AndroidSurfaceHolderCallback, CCDirectorDelegate>
@property (readonly, nonatomic) AndroidAbsoluteLayout *layout;
@property (nonatomic, strong) NSDictionary *cocos2dSetupConfig;
@property (nonatomic, strong) CCGLView<CCView> *glView;
@property (nonatomic, strong) NSString *startScene;
+ (instancetype)currentActivity;


- (void)run;

- (void)scheduleInRunLoop;

- (void)applyRequestedOrientation:(NSDictionary *)config;

- (void)constructViewWithConfig:(NSDictionary *)config andDensity:(float)density;

- (AndroidDisplayMetrics *)getDisplayMetrics;

- (void)runOnGameThread:(dispatch_block_t)block;
- (void)runOnGameThread:(dispatch_block_t)block waitUntilDone:(BOOL)waitUntilDone;

- (EGLContext)pushApplicationContext;
- (void)popApplicationContext:(EGLContext)ctx;

@end

#endif

