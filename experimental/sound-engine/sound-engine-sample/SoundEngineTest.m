/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 by Florin Dumitrescu.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 ***********************************************************************
 *
 * The sounds in this example have been downloaded from freesound.org
 * and are available under a Creative Commons Sampling Plus 1.0 license
 * (http://creativecommons.org/licenses/sampling+/1.0/)
 * For full attribution info please see ATTRIBUTION in the "sfx/" directory
 *
 */

#import "SoundEngineTest.h"
#import "PASoundMgr.h"
#import "PASoundSource.h"

@implementation SoundEngineTest

- (id)init {
    if ((self = [super init])) {
        isTouchEnabled = YES;
        
        // init sound manager/OpenAL support
        [PASoundMgr sharedSoundManager];
        // preload interface-like sounds
        [[PASoundMgr sharedSoundManager] addSound:@"clank" withPosition:cpv(160,240) looped:NO];
        [[PASoundMgr sharedSoundManager] addSound:@"chicken" withPosition:cpv(160,240) looped:NO];

        Label *info = [Label labelWithString:@"Tap and move your finger to update\nthe listener's position." dimensions:CGSizeMake(320, 40) alignment:UITextAlignmentCenter fontName:@"TrebuchetMS-Bold" fontSize:14];
        [self addChild:info z:1];
        info.position = cpv(160, 450);
        
        // set bottom menu (its actions play some sample interface-like sound, right from the manager)
        MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(selectedBackForwardMenuItem:)];
        MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(selectedCenterMenuItem:)];
        MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(selectedBackForwardMenuItem:)];
        Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
        menu.position = cpvzero;
        item1.position = cpv(320/2-100,30);
        item2.position = cpv(320/2, 30);
        item3.position = cpv(320/2+100,30);
        [self addChild: menu z:1];
        
        // set listener's position and sprite
        [[[PASoundMgr sharedSoundManager] listener] setPosition:cpv(160,240)];
        listenerSprite = [Sprite spriteWithFile:@"listener-marker.png"];
        [self addChild:listenerSprite z:1];
        listenerSprite.position = cpv(160,240);
        
        // set first sound source (static waterfall)
        source1 = [[PASoundSource alloc] initWithFile:@"waterfall" extension:@"caf" looped:YES];
        source1Sprite = [Sprite spriteWithFile:@"source-marker.png"];
        [self addChild:source1Sprite z:0];
        source1Sprite.position = cpv(50,100);
        [source1 setGain:.5f];
        [source1 playAtPosition:source1Sprite.position];
        
        // set the 2nd sound source (moving chicken)
        source2 = [[PASoundSource alloc] initWithFile:@"chicken" looped:YES];
        source2Sprite = [Sprite spriteWithFile:@"source-marker.png"];
        [self addChild:source2Sprite z:0];
        source2Sprite.position = cpv(270,400);
        [source2 setGain:.5f];
        [source2 playAtPosition:source2.position];
        
        id move = [MoveBy actionWithDuration:2 position:cpv(-220,0)];
        id sequence = [Sequence actions:move,[move reverse],nil];
        [source2Sprite runAction:[RepeatForever actionWithAction:sequence]];
        
        // schedule selector for updating openal listener and sources position with the sprites' position
        [self schedule:@selector(loop:)];
    }
    return self;
}

- (void)selectedBackForwardMenuItem:(id)sender {
    // play the common interface "clank" sound
    [[PASoundMgr sharedSoundManager] play:@"clank"];
}
- (void)selectedCenterMenuItem:(id)sender {
    [[PASoundMgr sharedSoundManager] play:@"chicken"];    
}

- (void)loop:(ccTime)t {
    // update at every frame the OpenAL listener's position per the updated Listener icon
    [[[PASoundMgr sharedSoundManager] listener] setPosition:listenerSprite.position];
    
    // update the chicken's sound source position with the moving sprite's position
    [source2 playAtPosition:source2Sprite.position];
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
    point = [[Director sharedDirector] convertCoordinate: point];
    listenerSprite.position = cpv(point.x, point.y);
    return kEventHandled;
}    

- (void)dealloc {
    // it's safer to stop before release
    [source1 stop];
    [source2 stop];
    
    [source1 release];
    [source2 release];
    
    [super dealloc];
}

@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	[[Director sharedDirector] setLandscape: NO];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
    
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	Scene *scene = [Scene node];
	[scene addChild: [SoundEngineTest node]];
    
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
