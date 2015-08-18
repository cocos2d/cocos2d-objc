//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import "Credits.h"
#import "CCNode_Private.h"
#import "cocos2d-ui.h"
#import "GameTypes.h"

// -----------------------------------------------------------------------
// The Credits is a small helper class, creating a nice credits scroll
//
// It demonstrates a couple of techniques
// 1) Reading data from a plist (Yay, data-driven design)
// 2) Replacing shaders of a node with a blurry greyscale shader (in this case the entire scene)
// 3) Some basic touch setup and handling
// 4) Buttons with callbacks
// 5) The power of CCActions
// 6) How a node can kill itself by removing itself from parent
// -----------------------------------------------------------------------

@implementation Credits
{
    // ivars are great. You can never have too many (ahh, okay, maybe you can)
    
    // some internal stuff we are responsible for
    NSMutableArray *_shaderStack;
    CCNode *_scrollNode;
    CCButton *_back;
    NSMutableArray *_endGameList;
    
    // some external stuff we are not responsible for (always makes those weak)
    __weak CCScene *_scene;
    
    // and just some plain ivars which makes life easier
    NSUInteger _shaderStackPointer;
    float _spacing;
    BOOL _useGreyScale;
    float _yPos;
    float _scrollSpeed;
    CGPoint _lastPosition;
    BOOL _isScrolling;
    BOOL _endGame;
    float _volume;
}

// -----------------------------------------------------------------------

+ (instancetype)creditsWithScene:(CCScene *)scene andDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithScene:scene andDictionary:dict];
}

- (instancetype)initWithScene:(CCScene *)scene andDictionary:(NSDictionary *)dict
{
    self = [super init];
    self.contentSize = [CCDirector sharedDirector].viewSize;
    
    self.anchorPoint = CGPointZero;
    self.userInteractionEnabled = YES;
    
    // load stuff
    _shaderStack = [NSMutableArray array];
    _scene = scene;
    _yPos = 0.5;
    _isScrolling = YES;
    _endGame = NO;
    _spacing = [[dict objectForKey:@"spacing"] floatValue];
    _useGreyScale = [[dict objectForKey:@"use.greyscale"] boolValue];
    _scrollSpeed = [[dict objectForKey:@"scroll.speed"] floatValue];
    
    // create a scroll node occupying the entire screen
    _scrollNode = [CCNode new];
    _scrollNode.contentSize = [CCDirector sharedDirector].viewSize;
    // allow us to fade the scrollnode and all its children without fading the back button
    _scrollNode.cascadeOpacityEnabled = YES;
    [self addChild:_scrollNode];
    
    // create the sprite
    CCSprite *sprite = [CCSprite spriteWithImageNamed:[dict objectForKey:@"image"]];
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = (CGPoint){0.5, _yPos};
    [_scrollNode addChild:sprite];

    // adjust yPos for first section
    _yPos -= (sprite.contentSize.height * 0.5) / [CCDirector sharedDirector].viewSize.height;
    _yPos -= _spacing;
    
    // load the sections
    for (int sectionIndex = 1; sectionIndex < 999; sectionIndex ++)
    {
        NSDictionary *section = [dict objectForKey:[NSString stringWithFormat:@"section - %d", sectionIndex]];
        if (section != nil)
            [self loadSectionWithDictionary:section];
        else
            break;
    }
    
    // load endgame
    _endGameList = [NSMutableArray array];
    NSDictionary *endGameDict = [dict objectForKey:@"endgame"];
    for (int creditIndex = 1; creditIndex < 999; creditIndex ++)
    {
        NSString *entry = [endGameDict objectForKey:[NSString stringWithFormat:@"credit - %d", creditIndex]];
        if (entry != nil)
            [_endGameList addObject:entry];
        else
            break;
    }
    
    // back button
    _back = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back.png"]];
    _back.positionType = CCPositionTypeNormalized;
    _back.position = (CGPoint){0.08, 0.90};
    [_back setTarget:self selector:@selector(backPressed:)];
    [self addChild:_back];
    
    // traverse all nodes, and swap their shaders
    if (_useGreyScale) [self replaceShaderWithGreyScaleShader:_scene];

    // play credits music
    // set music volume
    NSUserDefaults *setup = [NSUserDefaults standardUserDefaults];
    _volume = [setup floatForKey:kGameKeyMusicVolume];
    if ([dict objectForKey:@"music"])
    {
        [[OALSimpleAudio sharedInstance] setBgVolume:_volume];
        [[OALSimpleAudio sharedInstance] playBg:[dict objectForKey:@"music"]];
    }
    
    return self;
}

// -----------------------------------------------------------------------

- (void)onEnter
{
    [super onEnter];
    // quick fade in
    [_scrollNode runAction:[CCActionFadeIn actionWithDuration:0.25]];
}

- (void)onExit
{
    [[OALSimpleAudio sharedInstance] stopEverything];
    [super onExit];
}

// -----------------------------------------------------------------------

- (void)loadSectionWithDictionary:(NSDictionary *)dict
{
    CCLabelTTF *label;
    
    label = [CCLabelTTF labelWithString:[dict objectForKey:@"header"] fontName:@"ArialMT" fontSize:40];
    label.positionType = CCPositionTypeNormalized;
    label.position = (CGPoint){0.5, _yPos};
    _yPos -= _spacing;
    [_scrollNode addChild:label];
    
    NSString *key = @"credit - ";
    for (int index = 1; index < 999; index ++)
    {
        NSString *entry = [dict objectForKey:[NSString stringWithFormat:@"%@%d", key, index]];
        if (entry != nil)
        {
            CCLabelTTF *label = [CCLabelTTF labelWithString:entry fontName:@"ArialMT" fontSize:24];
            label.positionType = CCPositionTypeNormalized;
            label.position = (CGPoint){0.5, _yPos};
            _yPos -= _spacing;
            [_scrollNode addChild:label];
        }
        else
        {
            break;
        }
    }
    // Take back one kadam to honor the Hebrew God
    _yPos -= _spacing;
}

// -----------------------------------------------------------------------

- (void)replaceShaderWithGreyScaleShader:(CCNode *)node
{
    if ([node isKindOfClass:[CCSprite class]])
    {
        // CCLOG(@"Replacing shader for %@", [node class]);
        // save shader and replace with greyscale
        CCShader *shader = node.shader;
        [_shaderStack addObject:shader];
        
        node.shader = [CCShader shaderNamed:@"shader.greyscale"];
        node.opacity *= 0.25;
    }
    // call recursively
    for (CCNode *child in node.children) [self replaceShaderWithGreyScaleShader:child];
}

- (void)restoreShader:(CCNode *)node
{
    if ([node isKindOfClass:[CCSprite class]])
    {
        // CCLOG(@"Restoring shader for %@", [node class]);
        // restore shader for node
        node.shader = (CCShader *)[_shaderStack objectAtIndex:_shaderStackPointer];
        node.opacity /= 0.25;
        _shaderStackPointer ++;
    }
    // call recursively
    for (CCNode *child in node.children) [self restoreShader:child];
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    _shaderStackPointer = 0;
    if (_useGreyScale) [self restoreShader:_scene];
}

// -----------------------------------------------------------------------

- (void)backPressed:(id)sender
{
    [_scrollNode runAction:[CCActionSequence actions:
                            [CCActionFadeOut actionWithDuration:1.0],
                            [CCActionCallBlock actionWithBlock:^(void)
                             {
                                 [self removeFromParentAndCleanup:YES];
                             }],
                            nil]];
}

// -----------------------------------------------------------------------

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    _lastPosition = touch.locationInWorld;
}

// -----------------------------------------------------------------------

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (!_isScrolling) return;
    
    _scrollNode.position = (CGPoint){_scrollNode.position.x, _scrollNode.position.y - (_lastPosition.y - touch.locationInWorld.y)};
    _lastPosition = touch.locationInWorld;
}

// -----------------------------------------------------------------------

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    if (!_isScrolling) return;
    
    float scrollAmountPrSecond = [CCDirector sharedDirector].viewSize.height * _scrollSpeed;
    _scrollNode.position = (CGPoint){_scrollNode.position.x, _scrollNode.position.y + (scrollAmountPrSecond * delta)};
    // if all text scrolled out, start again
    
    if (_endGame) return;
    
    // start fading a little before last line hits centre of screen
    if (_scrollNode.position.y > ((fabs(_yPos) + 0.2) * [CCDirector sharedDirector].viewSize.height))
    {
        // endgame is on
        _endGame = YES;
        
        // hide the back button
        _back.visible = NO;

        // run endgame sequence
        [_scrollNode runAction:[CCActionSequence actions:
                                [CCActionFadeOut actionWithDuration:1.0],
                                [CCActionCallBlock actionWithBlock:^(void)
                                 {
                                     // clear scrollNode (not visible anyways)
                                     [_scrollNode removeAllChildrenWithCleanup:YES];
                                     _scrollNode.position = CGPointZero;
                                     _isScrolling = NO;
                                     
                                     // show endgame
                                     _yPos = 0.5 + ((_endGameList.count - 1) * _spacing * 0.5);
                                     for (NSString *labelText in _endGameList)
                                     {
                                         CCLabelTTF *label = [CCLabelTTF labelWithString:labelText fontName:@"ArialMT" fontSize:36];
                                         label.positionType = CCPositionTypeNormalized;
                                         label.position = (CGPoint){0.5, _yPos};
                                         [_scrollNode addChild:label];
                                         _yPos -= _spacing;
                                     }
                                 }],
                                [CCActionFadeIn actionWithDuration:0.5],
                                [CCActionDelay actionWithDuration:2.0],
                                [CCActionFadeOut actionWithDuration:1.0],
                                [CCActionCallBlock actionWithBlock:^(void)
                                 {
                                     [self removeFromParentAndCleanup:YES];
                                 }],
                                nil]];
    }
}

// -----------------------------------------------------------------------

- (void)startEndGame
{







}

// -----------------------------------------------------------------------

@end













