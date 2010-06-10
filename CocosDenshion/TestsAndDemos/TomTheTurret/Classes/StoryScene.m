//
//  StoryScene.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "StoryScene.h"
#import "GameState.h"
#import "Level.h"
#import "TomTheTurretAppDelegate.h"

@implementation StoryScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [[[StoryLayer alloc] init] autorelease];
        [self addChild:_layer];
    }
    return self;
    
}

@end

@implementation StoryLayer
@synthesize spriteSheet = _spriteSheet;
@synthesize main_bkgrnd = _main_bkgrnd;
@synthesize label = _label;
@synthesize curStoryIndex = _curStoryIndex;
@synthesize tapToCont = _tapToCont;
@synthesize newGame = _newGame;

- (id) init {
    
    if ((self = [super init])) {
        
        self.isTouchEnabled = YES;
        
        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.spriteSheet = [CCSpriteSheet spriteSheetWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:_spriteSheet];
        
        // Add main background to scene
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Turret_main_bkgrnd.png"];
        _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_spriteSheet addChild:_main_bkgrnd];
        
        // Add a label to the scene
        static int LABEL_MARGIN = 20;
        static int LABEL_MARGIN_BOTTOM = 50;
        self.label = [CCLabel labelWithString:@"" dimensions:CGSizeMake(winSize.width - LABEL_MARGIN*2, winSize.height - LABEL_MARGIN-LABEL_MARGIN_BOTTOM) alignment:UITextAlignmentCenter fontName:@"Verdana" fontSize:24];
        _label.position = ccp(winSize.width/2, winSize.height/2);
        _label.color = ccc3(0, 0, 0);
        [self addChild:_label];
        
        // Add "tap to continue" sprite...
        static int TAPTOCONT_BOTTOM_MARGIN = 30;
        self.tapToCont = [CCSprite spriteWithSpriteFrameName:@"Turret_main_taptocont.png"];
        _tapToCont.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + TAPTOCONT_BOTTOM_MARGIN);
        _tapToCont.visible = NO;
        [_spriteSheet addChild:_tapToCont];
        
        // Add "new game" sprite...
        static int NEWGAME_BOTTOM_MARGIN = 30;
        self.newGame = [CCSprite spriteWithSpriteFrameName:@"Turret_newgame.png"];
        _newGame.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + NEWGAME_BOTTOM_MARGIN);
        _newGame.visible = NO;
        [_spriteSheet addChild:_newGame];
                        
    }
    
    return self;
    
}

- (void)displayCurStoryString {
 
    StoryLevel *curLevel = (StoryLevel *) [GameState sharedState].curLevel;
    NSString *curStoryString = [curLevel.storyStrings objectAtIndex:_curStoryIndex];
    [_label setString:curStoryString];
    
    if (curLevel.isGameOver && _curStoryIndex == curLevel.storyStrings.count - 1) {
        _newGame.visible = YES;
        _tapToCont.visible = NO;
    } else {
        _newGame.visible = NO;
        _tapToCont.visible = YES;
    }
    
}

- (void)onEnter {
 
    [super onEnter];
	
	
    
    // Display the current string
    _curStoryIndex = 0;
    [self displayCurStoryString];
    
    // Animate the "tap to continue" so user notices...
    [_tapToCont runAction:[CCRepeatForever actionWithAction:
                           [CCSequence actions:
                            [CCFadeOut actionWithDuration:1.0f],
                            [CCFadeIn actionWithDuration:1.0f],
                            nil]]];
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _curStoryIndex++;
    StoryLevel *curLevel = (StoryLevel *) [GameState sharedState].curLevel;
    if (_curStoryIndex < curLevel.storyStrings.count) {
        [self displayCurStoryString];
    } else {
        TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate *) [UIApplication sharedApplication].delegate;
        if (curLevel.isGameOver) {
            [delegate launchMainMenu];
        } else {   
            [delegate launchNextLevel];
        }
    }
    
}

@end