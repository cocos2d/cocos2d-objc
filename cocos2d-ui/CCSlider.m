//
//  CCSlider.m
//  cocos2d-ios
//
//  Created by Viktor on 10/25/13.
//
//

#import "CCSlider.h"
#import "CCControlSubclass.h"

@implementation CCSlider

- (id) init
{
    return [self initWithBackground:NULL andHandleImage:NULL];
}

- (id) initWithBackground:(CCSpriteFrame*)background andHandleImage:(CCSpriteFrame*) handle
{
    self = [super init];
    if (!self) return NULL;
    
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

#ifdef __CC_PLATFORM_IOS

#pragma mark Handle touches

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint worldLocation = [touch locationInWorld];
    
    if ([_handle hitTestWithWorldPos:worldLocation])
    {
        // Touch down in slider handle
        _draggingHandle = YES;
        _handleStartPos = _handle.position;
        _dragStartPos = [self convertToNodeSpace:worldLocation];
        _dragStartValue = _sliderValue;
    }
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    _draggingHandle = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        [self triggerAction];
    }
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    _draggingHandle = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        [self triggerAction];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    UITouch* touch = [touches anyObject];
    
    if (_draggingHandle)
    {
        CGPoint dragPos = [touch locationInNode:self];
        
        CGPoint delta = ccpSub(dragPos, _dragStartPos);
        delta.y = 0;
        
        CGPoint newPos = ccpAdd(_handleStartPos, delta);
        if (newPos.x < 0) newPos.x = 0;
        if (newPos.x >= sizeInPoints.width) newPos.x = sizeInPoints.width;
        
        _sliderValue = newPos.x / sizeInPoints.width;
        if (self.continuous && _sliderValue != _dragStartValue)
        {
            _dragStartValue = _sliderValue;
            [self triggerAction];
        }
        
        _handle.position = newPos;
    }
    
    [super touchesMoved:touches withEvent:event];
}

#elif defined(__CC_PLATFORM_MAC)

- (void) mouseDownEntered:(NSEvent *)event
{
    CGPoint worldLocation = [event locationInWorld];
    
    if ([_handle hitTestWithWorldPos:worldLocation])
    {
        // Touch down in slider handle
        _draggingHandle = YES;
        _handleStartPos = _handle.position;
        _dragStartPos = [self convertToNodeSpace:worldLocation];
        _dragStartValue = _sliderValue;
    }
}

- (void) mouseUpInside:(NSEvent *)event
{
    _draggingHandle = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        [self triggerAction];
    }
}

- (void) mouseUpOutside:(NSEvent *)event
{
    _draggingHandle = NO;
    
    if (_dragStartValue != _sliderValue)
    {
        [self triggerAction];
    }
}

- (void) mouseDragged:(NSEvent *)event
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    if (_draggingHandle)
    {
        CGPoint dragPos = [event locationInNode:self];
        
        CGPoint delta = ccpSub(dragPos, _dragStartPos);
        delta.y = 0;
        
        CGPoint newPos = ccpAdd(_handleStartPos, delta);
        if (newPos.x < 0) newPos.x = 0;
        if (newPos.x >= sizeInPoints.width) newPos.x = sizeInPoints.width;
        
        _sliderValue = newPos.x / sizeInPoints.width;
        if (self.continuous && _sliderValue != _dragStartValue)
        {
            _dragStartValue = _sliderValue;
            [self triggerAction];
        }
        
        _handle.position = newPos;
    }
    
    [super mouseDragged:event];
}

#pragma mark Handle mouse events

#endif

- (void) updateSliderPositionFromValue
{
    CGSize size = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    _handle.position = ccp(size.width * _sliderValue, size.height/2.0f);
}

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

- (void) setSliderValue:(float)sliderValue
{
    NSAssert(sliderValue >= 0 && sliderValue <= 1, @"The slider value must be between 0 and 1");
    _sliderValue = sliderValue;
    
    [self updateSliderPositionFromValue];
}

@end
