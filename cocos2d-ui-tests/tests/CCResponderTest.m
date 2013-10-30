//
//  CCResponderTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/18/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "CCResponderTest.h"

@interface SimpleMultiTouchLayer : CCNode
{
    NSMutableDictionary* _currentTouches;
    CCLabelTTF* _lblNumTouches;
}
@end

@implementation SimpleMultiTouchLayer

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    _currentTouches = [[NSMutableDictionary alloc] init];
    
    // Enable touches and multi touch
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    
    // Make the node fill the entire area
    self.contentSizeType = kCCContentSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Setup a label that displays the number of current touches
    _lblNumTouches = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-Light" fontSize:14];
    _lblNumTouches.positionType = CCPositionTypeMake(kCCPositionUnitNormalized, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
    _lblNumTouches.position = ccp(0.5, 64);
    _lblNumTouches.horizontalAlignment = CCTextAlignmentCenter;
    
    [self addChild:_lblNumTouches];
    
    return self;
}

- (void) update:(ccTime)delta
{
    _lblNumTouches.string = [NSString stringWithFormat:@"Num touches: %d", _currentTouches.count];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray* touchesArray = [touches allObjects];
    for (UITouch* touch in touchesArray)
    {
        CGPoint touchLoc = [touch locationInNode:self];
        
        CCSprite* sprite = [CCSprite spriteWithImageNamed:@"Sprites/circle.png"];
        sprite.position = touchLoc;
        
        [self addChild:sprite];
        
        [_currentTouches setObject:sprite forKey:[NSValue valueWithPointer:(void*)touch]];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray* touchesArray = [touches allObjects];
    for (UITouch* touch in touchesArray)
    {
        CGPoint touchLoc = [touch locationInNode:self];
        
        CCSprite* sprite = [_currentTouches objectForKey:[NSValue valueWithPointer:(void*)touch]];
        sprite.position = touchLoc;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray* touchesArray = [touches allObjects];
    for (UITouch* touch in touchesArray)
    {
        CCSprite* sprite = [_currentTouches objectForKey:[NSValue valueWithPointer:(void*)touch]];
        [self removeChild:sprite];
        [_currentTouches removeObjectForKey:[NSValue valueWithPointer:(void*)touch]];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end

@implementation CCResponderTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupSimpleMultiTouchTest",
            nil];
}

- (void) setupSimpleMultiTouchTest
{
    self.subTitle = @"All your touches should be tracked with sprites.";
    
    SimpleMultiTouchLayer* touchLayer = [[SimpleMultiTouchLayer alloc] init];
    [self.contentNode addChild:touchLayer];
}

@end
