//
//  CCNode+CCBRelativePositioning.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

enum
{
    kCCBPositionTypeRelativeBottomLeft,
    kCCBPositionTypeRelativeTopLeft,
    kCCBPositionTypeRelativeTopRight,
    kCCBPositionTypeRelativeBottomRight,
    kCCBPositionTypePercent,
    kCCBPositionTypeMultiplyResolution,
};

enum
{
    kCCBSizeTypeAbsolute,
    kCCBSizeTypePercent,
    kCCBSizeTypeRelativeContainer,
    kCCBSizeTypeHorizontalPercent,
    kCCBSizeTypeVerticalPercent,
    kCCBSizeTypeMultiplyResolution,
};

enum
{
    kCCBScaleTypeAbsolute,
    kCCBScaleTypeMultiplyResolution
};

extern float ccbResolutionScale;

@interface CCNode (CCBRelativePositioning)

- (float) resolutionScale;

#pragma mark Positions

- (CGPoint) absolutePositionFromRelative:(CGPoint)pt type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName;
- (void) setRelativePosition:(CGPoint)pt type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName;
- (void) setRelativePosition:(CGPoint)position type:(int)type parentSize:(CGSize)parentSize;
- (void) setRelativePosition:(CGPoint)position type:(int)type;

#pragma mark Content Size

- (void) setRelativeSize:(CGSize)size type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName;
- (void) setRelativeSize:(CGSize)size type:(int)type parentSize:(CGSize)parentSize;
- (void) setRelativeSize:(CGSize)size type:(int)type;

#pragma mark Scale

- (void) setRelativeScaleX:(float)x Y:(float)y type:(int)type propertyName:(NSString*)propertyName;
- (void) setRelativeScaleX:(float)x Y:(float)y type:(int)type;

#pragma mark Floats

- (void) setRelativeFloat:(float)f type:(int)type propertyName:(NSString*)propertyName;

@end
