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

// -----------------------------------------------------------------------

@implementation Credits
{
    NSMutableArray *_shaderStack;
    NSUInteger _shaderStackPointer;
    __weak CCScene *_scene;
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
}

// -----------------------------------------------------------------------

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{

}

// -----------------------------------------------------------------------

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self removeFromParentAndCleanup:YES];
    
    _shaderStackPointer = 0;
    [self restoreShader:_scene];

}

// -----------------------------------------------------------------------

@end













