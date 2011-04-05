//
//  Bug-1159.m
//  Z-Fighting in iPad 2
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=1159
//
//  Created by Greg Woods on 4/5/11.
//  Copyright 2011 Westlake Design. All rights reserved.
//

#import "Bug-1159.h"

@implementation Bug1159

+(id)scene
{
    CCScene *scene = [CCScene node];
    Bug1159 *layer = [self node];
	[scene addChild:layer];
	
//	scene.scale = 1.5f;
    return scene;
}

-(id)init
{
    if ((self = [super init]))
	{
		CCSprite *background = [CCSprite spriteWithFile:@"bugs/1159-background.png"];
		background.position = ccp(512.0, 384.0);
		[self addChild:background];
		
		CCSprite *sprite_a = [CCSprite spriteWithFile:@"bugs/1159-sprite_a.png"];
		sprite_a.position = ccp(0.0, 384.0);
		[self addChild:sprite_a];
		
		[sprite_a runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
															   [CCMoveTo actionWithDuration:1.0 position:ccp(1024.0, 384.0)],
															   [CCMoveTo actionWithDuration:1.0 position:ccp(0.0, 384.0)],
															   nil]]];
		
		CCSprite *sprite_b = [CCSprite spriteWithFile:@"bugs/1159-sprite_b.png"];
		sprite_b.position = ccp(512.0, 384.0);
		[self addChild:sprite_b];
		
		CCMenuItemLabel *label = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Flip Me"
																				   fontName:@"Helvetica"
																				   fontSize:24]
														  block:^(id sender){
															  [self doPageFlip];
														  }
								  ];
		CCMenu *menu = [CCMenu menuWithItems:label, nil];
		menu.position = ccp(950.0, 50.0);
		[self addChild:menu];
	}
	return self;
}

-(void)doPageFlip
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0 scene:[Bug1159 scene]]];
}

@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
	// Set to 2D Projection
	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[director setAnimationInterval:1.0/60];
	
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
    EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:GL_DEPTH_COMPONENT24_OES];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// make the OpenGLView a child of the main window
	[window addSubview:glView];
	
	// make main window visible
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	[director runWithScene:[Bug1159 scene] ];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

@end
