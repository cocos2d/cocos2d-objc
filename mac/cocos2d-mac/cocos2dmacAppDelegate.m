//
//  cocos2dmacAppDelegate.m
//  cocos2d-mac
//
//  Created by Ricardo Quesada on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2dmacAppDelegate.h"

#import "cocos2d.h"

@implementation cocos2dmacAppDelegate

@synthesize window, glView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	CCDirector *director = [CCDirector sharedDirector];
	

	[director setOpenGLView:glView];
	
	CCScene *scene = [CCScene node];
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
	[sprite setPosition:ccp(200,200)];
	CCLayer *layer = [CCLayer node];
	[layer addChild:sprite];
	[scene addChild:layer];
	
	[director runWithScene:scene];
}

@end
