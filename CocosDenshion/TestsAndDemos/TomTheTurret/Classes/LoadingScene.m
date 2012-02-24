//
//  LoadingScene.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "LoadingScene.h"
#import "GameState.h"
#import "TomTheTurretAppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation LoadingScene

- (id)init {

    if ((self = [super init])) {
        LoadingLayer *layer = [[LoadingLayer alloc] init];
        [self addChild:layer];
        [layer release];
    }
    return self;

}

@end

@implementation LoadingLayer

@synthesize defaultImage = _defaultImage;
@synthesize batchNode = _batchNode;
@synthesize main_bkgrnd = _main_bkgrnd;
@synthesize main_title = _main_title;
@synthesize tom = _tom;
@synthesize tapToCont = _tapToCont;
@synthesize loading = _loading;
@synthesize isLoading = _isLoading;
@synthesize imagesLoaded = _imagesLoaded;
@synthesize scenesLoaded = _scenesLoaded;

- (id) init {

    if ((self = [super init])) {

        // Initialize variables
        self.isLoading = YES;
        self.imagesLoaded = NO;
        self.scenesLoaded = NO;

        // Set touch enabled
        self.isTouchEnabled = YES;

        // Continue to show Default.png until we're fully loaded...
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.defaultImage = [CCSprite spriteWithFile:@"DefaultLandscape.png"];
        _defaultImage.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_defaultImage];

        // Load our sprites in the background
        [[CCTextureCache sharedTextureCache] addImageAsync:@"sprites.png" target:self selector:@selector(spritesLoaded:)];

        // Load up our sound effects in the background
		/*
        if ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
            //The audio manager is not initialised yet so kick off the sound loading as an NSOperation that will wait for
            //the audio manager
            NSInvocationOperation* bufferLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSoundBuffers:) object:nil] autorelease];
            NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease];
            [opQ addOperation:bufferLoadOp];
        } else {
            [self loadSoundBuffers:nil];
        }
        */

        // Schedule a periodic method to check status
        [self schedule: @selector(tick:)];

    }

    return self;

}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (!_isLoading) {
        TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate *) [UIApplication sharedApplication].delegate;
        [delegate launchMainMenu];
    }

}

-(void) tick: (ccTime) dt {

    if (_imagesLoaded && _scenesLoaded && _isLoading) {

        // Set flag that we're no longer loading
        self.isLoading = NO;

        // Remove loading sprite
        [_batchNode removeChild:_loading cleanup:YES];
        self.loading = nil;

        // Add "tap to continue" sprite...
        CGSize winSize = [CCDirector sharedDirector].winSize;
        static int TAPTOCONT_BOTTOM_MARGIN = 30;
        self.tapToCont = [CCSprite spriteWithSpriteFrameName:@"Turret_main_taptocont.png"];
        _tapToCont.position = ccp(((winSize.width - _tom.contentSize.width) / 2) + _tom.contentSize.width, _tapToCont.contentSize.height/2 + TAPTOCONT_BOTTOM_MARGIN);
        [_batchNode addChild:_tapToCont];

        // Animate the "tap to continue" much the same way we did the "loading" so user notices...
        [_tapToCont runAction:[CCRepeatForever actionWithAction:
                             [CCSequence actions:
                              [CCFadeOut actionWithDuration:1.0f],
                              [CCFadeIn actionWithDuration:1.0f],
                              nil]]];

    }

}

-(void) loadScenes:(NSObject*) data {

    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

    TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate *) [UIApplication sharedApplication].delegate;
    [delegate loadScenes];
    self.scenesLoaded = YES;

    [autoreleasepool release];

}

-(void) spritesLoaded: (CCTexture2D*) tex {

    // Remove existing image
    [self removeChild:_defaultImage cleanup:YES];
    self.defaultImage = nil;

    // Store sprite texture in cache and initialize sprite frames
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];

    // Add a sprite sheet based on the loaded texture and add it to the scene
    self.batchNode = [CCSpriteBatchNode batchNodeWithTexture:tex];
    [self addChild:_batchNode];

    // Add main background to scene
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Turret_main_bkgrnd.png"];
    _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
    [_batchNode addChild:_main_bkgrnd];

    // Add title to scene
    static int MAIN_TITLE_TOP_MARGIN = 20;
    self.main_title = [CCSprite spriteWithSpriteFrameName:@"Turret_main_title.png"];
    _main_title.position = ccp(winSize.width/2, winSize.height - _main_title.contentSize.height/2 - MAIN_TITLE_TOP_MARGIN);
    [_batchNode addChild:_main_title];

    // Add Tom to scene
    static int TOM_BOTTOM_MARGIN = 30;
    static int TOM_LEFT_MARGIN = 20;
    self.tom = [CCSprite spriteWithSpriteFrameName:@"Tom.png"];
    _tom.position = ccp(_tom.contentSize.width/2 + TOM_LEFT_MARGIN, _tom.contentSize.height/2 + TOM_BOTTOM_MARGIN);
    [_batchNode addChild:_tom];

    // Make tom blink, for fun
    NSMutableArray *blinkAnimFrames = [NSMutableArray array];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tom.png"]];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tom_blink.png"]];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Tom.png"]];
    CCAnimation *blinkAnimation = [CCAnimation animationWithSpriteFrames:blinkAnimFrames delay:0.1f];
    [_tom runAction:[CCRepeatForever actionWithAction:
                     [CCSequence actions:
                      [CCAnimate actionWithAnimation:blinkAnimation],
                      [CCDelayTime actionWithDuration:2.5f],
                      nil]]];

    // Add "Loading..." to scene
    static int LOADING_BOTTOM_MARGIN = 30;
    self.loading = [CCSprite spriteWithSpriteFrameName:@"Turret_loading.png"];
    _loading.position = ccp(((winSize.width - _tom.contentSize.width) / 2) + _tom.contentSize.width, _loading.contentSize.height/2 + LOADING_BOTTOM_MARGIN);
    [_batchNode addChild:_loading];

    // Perform a little animation on the "loading" text to users know something is going on...
    [_loading runAction:[CCRepeatForever actionWithAction:
                         [CCSequence actions:
                         [CCFadeOut actionWithDuration:1.0f],
                         [CCFadeIn actionWithDuration:1.0f],
                          nil]]];

    self.imagesLoaded = YES;

    // Kick off an operation to load the scenes now that our textures are loaded
    NSInvocationOperation* sceneLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadScenes:) object:nil] autorelease];
    NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease];
    [opQ addOperation:sceneLoadOp];

}

- (void) dealloc {
    [super dealloc];
}

@end
