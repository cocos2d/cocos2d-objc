//
//  Compatibility_v2.h
//  ZooClient
//
//  Created by Ricardo Quesada on 2/2/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Renamed constants
#define EAGLView				CCGLView
#define kCCResolutionStandard	kCCResolutioniPhone
#define GLProgram				CCGLProgram

// Extensions
@interface CCScheduler (Compatibility)
+(CCScheduler*) sharedScheduler;
@end

@interface CCActionManager (Compatibility)
+(CCActionManager*) sharedManager;
@end

@interface CCTouchDispatcher (Compatibility)
+(CCTouchDispatcher*) sharedDispatcher;
@end

@interface CCDirector (Compatibility)
-(void) setOpenGLView:(CCGLView*)view;
-(CCGLView*) openGLView;
@end


@implementation CCSprite (Compatibility)
-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect;
@end
