//
//  Compatibility_v2.m
//  ZooClient
//
//  Created by Ricardo Quesada on 2/2/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//


#import "cocos2d_compatibility_v2.h"

@implementation CCScheduler (Compatibility)
+(CCScheduler*) sharedScheduler
{
	return [[CCDirector sharedDirector] scheduler];
}
@end

@implementation CCActionManager (Compatibility)
+(CCActionManager*) sharedManager
{
	return [[CCDirector sharedDirector] actionManager];
}
@end

@implementation CCTouchDispatcher (Compatibility)
+(CCTouchDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] touchDispatcher];
}
@end

@implementation CCDirector (Compatibility)
-(void) setOpenGLView:(CCGLView*)view
{
	[self setView:view];
}

-(UIView*) openGLView
{
	return self.view;
}
@end

@implementation CCSprite (Compatibility)

-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect
{
	[self initWithTexture:node.texture rect:rect];
	[self setBatchNode:node];
	return self;
}

@end


