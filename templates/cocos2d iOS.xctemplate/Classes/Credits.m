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

// -----------------------------------------------------------------------

@implementation Credits
{
    NSMutableArray *_shaderStack;
    NSUInteger _shaderStackPointer;
    __weak CCScene *_scene;
    CCNode *_scrollNode;
    float _yPos;
    CGPoint _lastPosition;
    BOOL _isScrolling;
    BOOL _endGame;
    CCButton *_back;
}

// -----------------------------------------------------------------------

+ (instancetype)creditsWithScene:(CCScene *)scene
{
    return [[self alloc] initWithScene:scene];
}

- (instancetype)initWithScene:(CCScene *)scene;
{
    CGSize size = [CCDirector sharedDirector].viewSize;
    self = [super initWithColor:[CCColor whiteColor] width:size.width height:size.height];
    self.opacity = 0.0;
    
    self.anchorPoint = CGPointZero;
    self.userInteractionEnabled = YES;
    
    _shaderStack = [NSMutableArray array];
    _scene = scene;
    _yPos = 0.5;
    _isScrolling = YES;
    _endGame = NO;
    
    // create list of credits
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"team.plist" ofType:nil];
    NSDictionary *team = [NSDictionary dictionaryWithContentsOfFile:filename];
    
    _scrollNode = [CCNode new];
    _scrollNode.contentSize = [CCDirector sharedDirector].viewSize;
    // allow us to fade the scrollnode and all its children
    _scrollNode.cascadeOpacityEnabled = YES;
    [self addChild:_scrollNode];
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"angry.png"];
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = (CGPoint){0.5, _yPos};
    _yPos -= 0.25;
    [_scrollNode addChild:sprite];
    
    CCLabelTTF *label;
    
    label = [CCLabelTTF labelWithString:@"Cocos2D was made by" fontName:@"ArialMT" fontSize:32];
    label.positionType = CCPositionTypeNormalized;
    label.position = (CGPoint){0.5, _yPos};
    _yPos -= 0.1;
    [_scrollNode addChild:label];
    
    NSString *key = @"New item - ";
    for (int index = 1; index < 999; index ++)
    {
        NSString *entry = [team objectForKey:[NSString stringWithFormat:@"%@%d", key, index]];
        if (entry != nil)
        {
            CCLabelTTF *label = [CCLabelTTF labelWithString:entry fontName:@"ArialMT" fontSize:24];
            label.positionType = CCPositionTypeNormalized;
            label.position = (CGPoint){0.5, _yPos};
            _yPos -= 0.1;
            [_scrollNode addChild:label];
        }
        else
        {
            break;
        }
    }

    // back button
    _back = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back.png"]];
    _back.positionType = CCPositionTypeNormalized;
    _back.position = (CGPoint){0.92, 0.10};
    [_back setTarget:self selector:@selector(backPressed:)];
    [self addChild:_back];
    
    // traverse all nodes, and swap their shaders
    [self replaceShaderWithGreyScaleShader:_scene];
    
    return self;
}

// -----------------------------------------------------------------------

- (void)replaceShaderWithGreyScaleShader:(CCNode *)node
{
    if ([node isKindOfClass:[CCSprite class]])
    {
        CCLOG(@"Replacing shader for %@", [node class]);
        // save shader and replace with greyscale
        CCShader *shader = node.shader;
        [_shaderStack addObject:shader];
        
        node.shader = [CCShader shaderNamed:@"shader.greyscale"];
        node.opacity *= 0.5;
    }
    // call recursively
    for (CCNode *child in node.children) [self replaceShaderWithGreyScaleShader:child];
}

- (void)restoreShader:(CCNode *)node
{
    if ([node isKindOfClass:[CCSprite class]])
    {
        CCLOG(@"Restoring shader for %@", [node class]);
        // restore shader for node
        node.shader = (CCShader *)[_shaderStack objectAtIndex:_shaderStackPointer];
        node.opacity /= 0.5;
        _shaderStackPointer ++;
    }
    // call recursively
    for (CCNode *child in node.children) [self restoreShader:child];
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    _shaderStackPointer = 0;
    [self restoreShader:_scene];
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
    
    float scrollAmountPrSecond = [CCDirector sharedDirector].viewSize.height * 0.125;
    _scrollNode.position = (CGPoint){_scrollNode.position.x, _scrollNode.position.y + (scrollAmountPrSecond * delta)};
    // if all text scrolled out, start again
    
    if (_endGame) return;
    
    // 0.25 is a hardcoded cut'n'try (dont do this at home guys)
    if (_scrollNode.position.y > ((fabs(_yPos) + 0.25) * [CCDirector sharedDirector].viewSize.height))
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
                                     
                                     // show final text
                                     CCLabelTTF *label;
                                     
                                     label = [CCLabelTTF labelWithString:@"Cocos2D-ObjC" fontName:@"ArialMT" fontSize:36];
                                     label.positionType = CCPositionTypeNormalized;
                                     label.position = (CGPoint){0.5, 0.55};
                                     [_scrollNode addChild:label];
                                     
                                     label = [CCLabelTTF labelWithString:@"2015" fontName:@"ArialMT" fontSize:36];
                                     label.positionType = CCPositionTypeNormalized;
                                     label.position = (CGPoint){0.5, 0.45};
                                     [_scrollNode addChild:label];
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

@end













