//
//  CCResponderTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/18/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"

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
    self.contentSizeType = CCSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Setup a label that displays the number of current touches
    _lblNumTouches = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-Light" fontSize:14];
    _lblNumTouches.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
    _lblNumTouches.position = ccp(0.5, 64);
    _lblNumTouches.horizontalAlignment = CCTextAlignmentCenter;
    
    [self addChild:_lblNumTouches];
    
    return self;
}

- (void) update:(CCTime)delta
{
    _lblNumTouches.string = [NSString stringWithFormat:@"Num touches: %d", (unsigned int)_currentTouches.count];
}

- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:self];
    
    CCSprite* sprite = [CCSprite spriteWithImageNamed:@"Sprites/circle.png"];
    sprite.position = touchLoc;
    
    [self addChild:sprite];
    
    [_currentTouches setObject:sprite forKey:[NSValue valueWithPointer:(void*)touch]];
}

- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:self];
    
    CCSprite* sprite = [_currentTouches objectForKey:[NSValue valueWithPointer:(void*)touch]];
    sprite.position = touchLoc;
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CCSprite* sprite = [_currentTouches objectForKey:[NSValue valueWithPointer:(void*)touch]];
    [self removeChild:sprite];
    [_currentTouches removeObjectForKey:[NSValue valueWithPointer:(void*)touch]];
}

- (void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self touchEnded:touch withEvent:event];
}

@end

// -----------------------------------------------------------------

@interface CCResponderTest : TestBase @end
@implementation CCResponderTest {
    CCLabelTTF* _message;
}

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
- (void) setupSimpleMultiTouchTest
{
    self.subTitle = @"All your touches should be tracked with sprites.";
    
    SimpleMultiTouchLayer* touchLayer = [[SimpleMultiTouchLayer alloc] init];
    [self.contentNode addChild:touchLayer];
}

// -----------------------------------------------------------------

- (void)setupExclusiveTouchTest
{
    self.subTitle = @"The two rightmost buttons are exclusive, and will cancel all other touches.";

    SimpleMultiTouchLayer* touchLayer = [[SimpleMultiTouchLayer alloc] init];
    [self.contentNode addChild:touchLayer];

    CCButton *button0 = [CCButton buttonWithTitle:@"Excl" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Sprites/circle.png"]];
    button0.positionType = CCPositionTypeNormalized;
    button0.position = ccp(0.9f, 0.65f);
    button0.claimsUserInteraction = YES;
    button0.exclusiveTouch = YES;
    [self.contentNode addChild:button0];

    CCButton *button1 = [CCButton buttonWithTitle:@"Excl" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Sprites/circle.png"]];
    button1.positionType = CCPositionTypeNormalized;
    button1.position = ccp(0.9f, 0.35f);
    button1.claimsUserInteraction = NO;
    button1.exclusiveTouch = YES;
    [self.contentNode addChild:button1];

    CCButton *button2 = [CCButton buttonWithTitle:@"Non Excl" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Sprites/circle.png"]];
    button2.positionType = CCPositionTypeNormalized;
    button2.position = ccp(0.1f, 0.65f);
    button2.claimsUserInteraction = YES;
    button2.exclusiveTouch = NO;
    [self.contentNode addChild:button2];
    
    CCButton *button3 = [CCButton buttonWithTitle:@"Non Excl" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Sprites/circle.png"]];
    button3.positionType = CCPositionTypeNormalized;
    button3.position = ccp(0.1f, 0.35f);
    button3.claimsUserInteraction = NO;
    button3.exclusiveTouch = NO;
    [self.contentNode addChild:button3];

}
#endif

#if __CC_PLATFORM_MAC
- (void) setupBasicLoopTest
{
    self.subTitle = @"On desktop platforms, pressing a key should change the message on screen.";

    _message = [CCLabelTTF labelWithString:@"Last Key:" fontName:@"HelveticaNeue-Light" fontSize:32];
    _message.positionType = CCPositionTypeNormalized;
    _message.position = ccp(0.5, 0.5);
    _message.horizontalAlignment = CCTextAlignmentCenter;

    self.userInteractionEnabled = YES;

    CCNode *keycatcher = [CCNode node];
    keycatcher.userInteractionEnabled = YES;
    keycatcher.name = @"key catcher";

    [self addChild:keycatcher];
    [self addChild:_message];
}

-(void)keyDown:(NSEvent *)theEvent
{
    _message.string = [NSString stringWithFormat:@"Key Down:\n\tcode=%d\n\tchars=%@", theEvent.keyCode, theEvent.characters];
}

-(void)keyUp:(NSEvent *)theEvent
{
    _message.string = [NSString stringWithFormat:@"Key Up:\n\tcode=%d\n\tchars=%@", theEvent.keyCode, theEvent.characters];
}

-(void)mouseDown:(NSEvent *)theEvent button:(CCMouseButton)button
{
    NSPoint location = theEvent.locationInWorld;
    _message.string = [NSString stringWithFormat:@"MouseDown:\n\tloc=(% 3.1f, % 3.1f)\n\tbutton=%d", location.x, location.y, (int)theEvent.buttonNumber];
}

-(void)mouseUp:(NSEvent *)theEvent button:(CCMouseButton)button
{
    NSPoint location = theEvent.locationInWorld;
    _message.string = [NSString stringWithFormat:@"MouseUp:\n\tloc=(% 3.1f, % 3.1f)\n\tbutton=%d", location.x, location.y, (int)theEvent.buttonNumber];
}

-(void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint location = theEvent.locationInWorld;
    _message.string = [NSString stringWithFormat:@"MouseMoved:\n\tloc=(% 3.1f, % 3.1f)", location.x, location.y];
}

-(void)mouseDragged:(NSEvent *)theEvent button:(CCMouseButton)button
{
    NSPoint location = theEvent.locationInWorld;
    _message.string = [NSString stringWithFormat:@"MouseDragged:\n\tloc=(% 3.1f, % 3.1f)\n\tbutton=%d", location.x, location.y, (int)theEvent.buttonNumber];
}
#endif

@end
