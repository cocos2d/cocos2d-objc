/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCButton.h"
#import "CCControlSubclass.h"

#import "cocos2d.h"
#import <objc/runtime.h>

#define kCCFatFingerExpansion 70

@implementation CCButton

- (id) init
{
    return [self initWithTitle:@"" spriteFrame:NULL];
}

+ (id) buttonWithTitle:(NSString*) title
{
    return [[self alloc] initWithTitle:title];
}

+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(float)size
{
    return [[self alloc] initWithTitle:title fontName:fontName fontSize:size];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    return [[self alloc] initWithTitle:title spriteFrame:spriteFrame];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    return [[self alloc] initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame: highlighted disabledSpriteFrame:disabled];
}

- (id) initWithTitle:(NSString *)title
{
    self = [self initWithTitle:title spriteFrame:NULL highlightedSpriteFrame:NULL disabledSpriteFrame:NULL];
    
    // Default properties for labels with only a title
    self.zoomWhenHighlighted = YES;
    
    return self;
}

- (id) initWithTitle:(NSString *)title fontName:(NSString*)fontName fontSize:(float)size
{
    self = [self initWithTitle:title];
    self.label.fontName = fontName;
    self.label.fontSize = size;
    
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    self = [self initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame:NULL disabledSpriteFrame:NULL];
    
    // Setup default colors for when only one frame is used
    [self setBackgroundColor:ccc3(190, 190, 190) forState:CCControlStateHighlighted];
    [self setLabelColor:ccc3(190, 190, 190) forState:CCControlStateHighlighted];
    
    [self setBackgroundOpacity:127 forState:CCControlStateDisabled];
    [self setLabelOpacity:127 forState:CCControlStateDisabled];
    
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    self = [super init];
    if (!self) return NULL;
    
    self.anchorPoint = ccp(0.5f, 0.5f);
    
    if (!title) title = @"";
    
    // Setup holders for properties
    _backgroundColors = [NSMutableDictionary dictionary];
    _backgroundOpacities = [NSMutableDictionary dictionary];
    _backgroundSpriteFrames = [NSMutableDictionary dictionary];
    
    _labelColors = [NSMutableDictionary dictionary];
    _labelOpacities = [NSMutableDictionary dictionary];
    
    // Setup background image
    if (spriteFrame)
    {
        _background = [CCSprite9Slice spriteWithSpriteFrame:spriteFrame];
        [self setBackgroundSpriteFrame:spriteFrame forState:CCControlStateNormal];
        self.preferredSize = spriteFrame.originalSize;
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background z:0];
    
    // Setup label
    _label = [CCLabelTTF labelWithString:title fontName:@"Helvetica" fontSize:14];
    _label.adjustsFontSizeToFit = YES;
    _label.horizontalAlignment = CCTextAlignmentCenter;
    _label.verticalAlignment = CCVerticalTextAlignmentCenter;
    
    [self addChild:_label z:1];
    
    // Setup original scale
    _originalScaleX = _originalScaleY = 1;
    
    [self needsLayout];
    [self stateChanged];
    
    return self;
}

- (void) layout
{
    _label.dimensions = CGSizeZero;
    CGSize originalLabelSize = _label.contentSize;
    CGSize paddedLabelSize = originalLabelSize;
    paddedLabelSize.width += _horizontalPadding * 2;
    paddedLabelSize.height += _verticalPadding * 2;
    
    CGSize size = paddedLabelSize;
    
    BOOL shrunkSize = NO;
    size = [self convertContentSizeToPoints: self.preferredSize type:self.contentSizeType];
    
    CGSize maxSize = [self convertContentSizeToPoints:self.maxSize type:self.contentSizeType];
    
    if (size.width < paddedLabelSize.width) size.width = paddedLabelSize.width;
    if (size.height < paddedLabelSize.height) size.height = paddedLabelSize.height;
    
    if (maxSize.width > 0 && maxSize.width < size.width)
    {
        size.width = maxSize.width;
        shrunkSize = YES;
    }
    if (maxSize.height > 0 && maxSize.height < size.height)
    {
        size.height = maxSize.height;
        shrunkSize = YES;
    }
    
    if (shrunkSize)
    {
        CGSize labelSize = CGSizeMake(clampf(size.width - _horizontalPadding * 2, 0, originalLabelSize.width),
                                      clampf(size.height - _verticalPadding * 2, 0, originalLabelSize.height));
        _label.dimensions = labelSize;
    }
    
    _background.contentSize = size;
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    
    _label.positionType = CCPositionTypeNormalized;
    _label.position = ccp(0.5f, 0.5f);
    
    self.contentSize = [self convertContentSizeFromPoints: size type:self.contentSizeType];
    
    [super layout];
}
#ifdef __CC_PLATFORM_IOS

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    
    if (self.claimsUserInteraction)
    {
        [super setHitAreaExpansion:_originalHitAreaExpansion + kCCFatFingerExpansion];
    }
    self.highlighted = YES;
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super setHitAreaExpansion:_originalHitAreaExpansion];
    
    if (self.enabled)
    {
        [self triggerAction];
    }
    
    self.highlighted = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super setHitAreaExpansion:_originalHitAreaExpansion];
    self.highlighted = NO;
}

#elif __CC_PLATFORM_MAC

- (void) mouseDownEntered:(NSEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    self.highlighted = YES;
}

- (void) mouseDownExited:(NSEvent *)event
{
    self.highlighted = NO;
}

- (void) mouseUpInside:(NSEvent *)event
{
    if (self.enabled)
    {
        [self triggerAction];
    }
    self.highlighted = NO;
}

- (void) mouseUpOutside:(NSEvent *)event
{
    self.highlighted = NO;
}

#endif

- (void) triggerAction
{
    // Handle toggle buttons
    if (self.togglesSelectedState)
    {
        self.selected = !self.selected;
    }
    
    [super triggerAction];
}

- (void) updatePropertiesForState:(CCControlState)state
{
    // Update background
    _background.color = [self backgroundColorForState:state];
    _background.opacity = [self backgroundOpacityForState:state];
    
    CCSpriteFrame* spriteFrame = [self backgroundSpriteFrameForState:state];
    if (!spriteFrame) spriteFrame = [self backgroundSpriteFrameForState:CCControlStateNormal];
    _background.spriteFrame = spriteFrame;
    
    // Update label
    _label.color = [self labelColorForState:state];
    _label.opacity = [self labelOpacityForState:state];
    
    [self needsLayout];
}

- (void) stateChanged
{
    if (self.enabled)
    {
        // Button is enabled
        if (self.highlighted)
        {
            [self updatePropertiesForState:CCControlStateHighlighted];
            
            if (_zoomWhenHighlighted)
            {
                [_label runAction:[CCActionScaleTo actionWithDuration:0.1 scaleX:_originalScaleX*1.2 scaleY:_originalScaleY*1.2]];
            }
        }
        else
        {
            if (self.selected)
            {
                [self updatePropertiesForState:CCControlStateSelected];
            }
            else
            {
                [self updatePropertiesForState:CCControlStateNormal];
            }
            
            [_label stopAllActions];
            if (_zoomWhenHighlighted)
            {
                _label.scaleX = _originalScaleX;
                _label.scaleY = _originalScaleY;
            }
        }
    }
    else
    {
        // Button is disabled
        [self updatePropertiesForState:CCControlStateDisabled];
    }
}

#pragma mark Properties

- (void) setHitAreaExpansion:(float)hitAreaExpansion
{
    _originalHitAreaExpansion = hitAreaExpansion;
    [super hitAreaExpansion];
}

- (float) hitAreaExpansion
{
    return _originalHitAreaExpansion;
}

- (void) setScale:(float)scale
{
    _originalScaleX = _originalScaleY = scale;
    [super setScale:scale];
}

- (void) setScaleX:(float)scaleX
{
    _originalScaleX = scaleX;
    [super setScaleX:scaleX];
}

- (void) setScaleY:(float)scaleY
{
    _originalScaleY = scaleY;
    [super setScaleY:scaleY];
}

- (void) setLabelColor:(ccColor3B)color forState:(CCControlState)state
{
    [_labelColors setObject:[NSValue value:&color withObjCType:@encode(ccColor3B)] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (ccColor3B) labelColorForState:(CCControlState)state
{
    NSValue* val = [_labelColors objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return ccc3(255, 255, 255);
    ccColor3B color;
    [val getValue:&color];
    return color;
}

- (void) setLabelOpacity:(GLubyte)opacity forState:(CCControlState)state
{
    [_labelOpacities setObject:[NSNumber numberWithInt:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (GLubyte) labelOpacityForState:(CCControlState)state
{
    NSNumber* val = [_labelOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 255;
    return [val intValue];
}

- (void) setBackgroundColor:(ccColor3B)color forState:(CCControlState)state
{
    [_backgroundColors setObject:[NSValue value:&color withObjCType:@encode(ccColor3B)] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (ccColor3B) backgroundColorForState:(CCControlState)state
{
    NSValue* val = [_backgroundColors objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return ccc3(255, 255, 255);
    ccColor3B color;
    [val getValue:&color];
    return color;
}

- (void) setBackgroundOpacity:(GLubyte)opacity forState:(CCControlState)state
{
    [_backgroundOpacities setObject:[NSNumber numberWithInt:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (GLubyte) backgroundOpacityForState:(CCControlState)state
{
    NSNumber* val = [_backgroundOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 255;
    return [val intValue];
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

- (void) setTitle:(NSString *)title
{
    _label.string = title;
    [self needsLayout];
}

- (NSString*) title
{
    return _label.string;
}

- (void) setHorizontalPadding:(float)horizontalPadding
{
    _horizontalPadding = horizontalPadding;
    [self needsLayout];
}

- (void) setVerticalPadding:(float)verticalPadding
{
    _verticalPadding = verticalPadding;
    [self needsLayout];
}

- (NSArray*) keysForwardedToLabel
{
    return [NSArray arrayWithObjects:
            @"fontName",
            @"fontSize",
            @"opacity",
            @"color",
            @"fontColor",
            @"outlineColor",
            @"outlineWidth",
            @"shadowColor",
            @"shadowBlurRadius",
            @"shadowOffset",
            @"shadowOffsetType",
            nil];
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        [_label setValue:value forKey:key];
        [self needsLayout];
        return;
    }
    [super setValue:value forKey:key];
}

- (id) valueForKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        return [_label valueForKey:key];
    }
    return [super valueForKey:key];
}

- (void) setValue:(id)value forKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        [self setLabelOpacity:[value intValue] forState:state];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        ccColor3B c;
        [value getValue:&c];
        [self setLabelColor:c forState:state];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        [self setBackgroundOpacity:[value intValue] forState:state];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        ccColor3B c;
        [value getValue:&c];
        [self setBackgroundColor:c forState:state];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        [self setBackgroundSpriteFrame:value forState:state];
    }
}

- (id) valueForKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        return [NSNumber numberWithUnsignedChar:[self labelOpacityForState:state]];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        ccColor3B c = [self labelColorForState:state];
        return [NSValue value:&c withObjCType:@encode(ccColor3B)];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        return [NSNumber numberWithUnsignedChar:[self backgroundOpacityForState:state]];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        ccColor3B c = [self backgroundColorForState:state];
        return [NSValue value:&c withObjCType:@encode(ccColor3B)];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        return [self backgroundSpriteFrameForState:state];
    }
    
    return NULL;
}

@end
