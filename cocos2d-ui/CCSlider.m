//
//  CCSlider.m
//  cocos2d-ios
//
//  Created by Viktor on 10/25/13.
//
//

#import "CCSlider.h"
#import "CCControlSubclass.h"
#include "UITouch+CC.h"

@interface CCSlider (Inputs)
- (void) inputEnteredWithWorlPos:(CGPoint)worldLocation;
- (void) inputUpInside;
- (void) inputUpOutside;
- (void) inputDraggedWithPos:(CGPoint)dragPos;
@end

@implementation CCSlider

- (id) init
{
    return [self initWithBackground:NULL andHandleImage:NULL];
}

- (id) initWithBackground:(CCSpriteFrame*)background andHandleImage:(CCSpriteFrame*)handle
{
    self = [super init];
    if (!self) return NULL;
    
    _backgroundSpriteFrames = [[NSMutableDictionary alloc] init];
    _handleSpriteFrames = [[NSMutableDictionary alloc] init];
    
    _endStop = 0.0;
    
    if (background)
    {
        _background = [CCSprite9Slice spriteWithSpriteFrame:background];
        [self setBackgroundSpriteFrame:background forState:CCControlStateNormal];
        self.preferredSize = background.originalSize;
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    if (handle)
    {
        _handle = [CCSprite spriteWithSpriteFrame:handle];
        [self setHandleSpriteFrame:handle forState:CCControlStateNormal];
    }
    else
    {
        _handle = [[CCSprite alloc] init];
    }
    
    [self addChild:_background];
    [self addChild:_handle];
    
    [self needsLayout];
    [self stateChanged];
    
    self.userInteractionEnabled = YES;
    
    return self;
}

- (void) updateSliderPositionFromValue
{
    CGSize size = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    _handle.position = ccp(_endStop + ((size.width - (2 * _endStop)) * _sliderValue), size.height * 0.5);
}

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID

#pragma mark Handle touches

- (void) touchEntered:(CCTouch*)touch withEvent:(CCTouchEvent*)event
{
    if (!self.enabled) return;
    
    CGPoint worldLocation = [touch locationInWorld];
    
    [self inputEnteredWithWorlPos:worldLocation];
}

- (void) touchUpInside:(CCTouch*)touch withEvent:(CCTouchEvent*)event
{
    [self inputUpInside];
}

- (void) touchUpOutside:(CCTouch*)touch withEvent:(CCTouchEvent*)event
{
    [self inputUpOutside];
}

- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint dragPos = [touch locationInNode:self];
    
    [self inputDraggedWithPos:dragPos];
    
    [super touchMoved:touch withEvent:event];
}


#elif __CC_PLATFORM_MAC

#pragma mark Handle mouse events

- (void) mouseDownEntered:(NSEvent*)event
{
    if (!self.enabled) return;
    
    CGPoint worldLocation = [event locationInWorld];
    
    [self inputEnteredWithWorlPos:worldLocation];
}

- (void) mouseUpInside:(NSEvent*)event
{
    [self inputUpInside];
}

- (void) mouseUpOutside:(NSEvent*)event
{
    [self inputUpOutside];
}

- (void) mouseDragged:(NSEvent*)event
{
    CGPoint dragPos = [event locationInNode:self];
    
    [self inputDraggedWithPos:dragPos];
    
    [super mouseDragged:event];
}

#endif

#pragma mark Inputs

- (void) inputEnteredWithWorlPos:(CGPoint)worldLocation
{
    if ([_handle hitTestWithWorldPos:worldLocation])
    {
        // Touch down in slider handle
        _draggingHandle = YES;
        self.highlighted = YES;
        _handleStartPos = _handle.position;
        _dragStartPos = [self convertToNodeSpace:worldLocation];
        _dragStartValue = _sliderValue;
    }
}

- (void) inputUpInside
{
    _draggingHandle = NO;
    self.highlighted = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        [self triggerAction];
    }
}

- (void) inputUpOutside
{
    _draggingHandle = NO;
    self.highlighted = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        if (self.enabled) [self triggerAction];
    }
}

- (void) inputDraggedWithPos:(CGPoint)dragPos
{
    if (_draggingHandle)
    {
        CGSize sizeInPoints = [self convertContentSizeToPoints:self.preferredSize type:self.preferredSizeType];
        
        CGPoint delta = ccpSub(dragPos, _dragStartPos);
        delta.y = 0;
        
        CGPoint newPos = ccpAdd(_handleStartPos, delta);
        if (newPos.x < _endStop) newPos.x = _endStop;
        if (newPos.x >= (sizeInPoints.width - _endStop)) newPos.x = sizeInPoints.width - _endStop;
        
        _sliderValue = (newPos.x - _endStop) / (sizeInPoints.width - (2 * _endStop));
        if (self.continuous && _sliderValue != _dragStartValue)
        {
            _dragStartValue = _sliderValue;
            if (self.enabled) [self triggerAction];
        }
        
        _handle.position = newPos;
    }
}

#pragma mark Laying out Component

- (void) layout
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    [_background setContentSize:sizeInPoints];
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    
    self.contentSize = [self convertContentSizeFromPoints: sizeInPoints type:self.contentSizeType];
    
    [self updateSliderPositionFromValue];
    
    self.hitAreaExpansion = _handle.contentSizeInPoints.width / 2.0f;
    
    [super layout];
}

- (void) updatePropertiesForState:(CCControlState)state
{
    // Update background
    CCSpriteFrame* spriteFrame = [self backgroundSpriteFrameForState:state];
    if (!spriteFrame) spriteFrame = [self backgroundSpriteFrameForState:CCControlStateNormal];
    _background.spriteFrame = spriteFrame;
    
    // Update handle
    spriteFrame = [self handleSpriteFrameForState:state];
    if (!spriteFrame) spriteFrame = [self handleSpriteFrameForState:CCControlStateNormal];
    _handle.spriteFrame = spriteFrame;
    
    [self needsLayout];
}

- (void) stateChanged
{
    if (self.enabled)
    {
        if (self.highlighted)
        {
            [self updatePropertiesForState:CCControlStateHighlighted];
        }
        else
        {
            [self updatePropertiesForState:CCControlStateNormal];
        }
    }
    else
    {
        [self updatePropertiesForState:CCControlStateDisabled];
    }
}

#pragma mark Properties

- (void) setSliderValue:(float)sliderValue
{
    NSAssert(sliderValue >= 0 && sliderValue <= 1, @"The slider value must be between 0 and 1");
    _sliderValue = sliderValue;
    
    [self updateSliderPositionFromValue];
}

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state
{
    if (spriteFrame)
    {
        [_backgroundSpriteFrames setObject:spriteFrame forKey:[NSNumber numberWithInt:state]];
    }
    else
    {
        [_backgroundSpriteFrames removeObjectForKey:[NSNumber numberWithInt:state]];
    }
    [self stateChanged];
}

- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state
{
    return [_backgroundSpriteFrames objectForKey:[NSNumber numberWithInt:state]];
}

- (void) setHandleSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state
{
    if (spriteFrame)
    {
        [_handleSpriteFrames setObject:spriteFrame forKey:[NSNumber numberWithInt:state]];
    }
    else
    {
        [_handleSpriteFrames removeObjectForKey:[NSNumber numberWithInt:state]];
    }
    [self stateChanged];
}

- (CCSpriteFrame*) handleSpriteFrameForState:(CCControlState)state
{
    return [_handleSpriteFrames objectForKey:[NSNumber numberWithInt:state]];
}

#pragma mark Setting properties by name

- (void) setValue:(id)value forKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        [self setBackgroundSpriteFrame:value forState:state];
    }
    else if ([key isEqualToString:@"handleSpriteFrame"])
    {
        [self setHandleSpriteFrame:value forState:state];
    }
}

- (id) valueForKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        return [self backgroundSpriteFrameForState:state];
    }
    else if ([key isEqualToString:@"handleSpriteFrame"])
    {
        return [self handleSpriteFrameForState:state];
    }
    
    return NULL;
}

@end
