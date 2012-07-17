//
//  CCNode+CCBRelativePositioning.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode+CCBRelativePositioning.h"

@implementation CCNode (CCBRelativePositioning)

#pragma mark Positions

- (CGPoint) absolutePositionFromRelative:(CGPoint)pt type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName
{
    CGPoint absPt = ccp(0,0);
    if (type == kCCBPositionTypeRelativeBottomLeft)
    {
        absPt = pt;
    }
    else if (type == kCCBPositionTypeRelativeTopLeft)
    {
        absPt.x = pt.x;
        absPt.y = containerSize.height - pt.y;
    }
    else if (type == kCCBPositionTypeRelativeTopRight)
    {
        absPt.x = containerSize.width - pt.x;
        absPt.y = containerSize.height - pt.y;
    }
    else if (type == kCCBPositionTypeRelativeBottomRight)
    {
        absPt.x = containerSize.width - pt.x;
        absPt.y = pt.y;
    }
    else if (type == kCCBPositionTypePercent)
    {
        absPt.x = (int)(containerSize.width * pt.x / 100.0f);
        absPt.y = (int)(containerSize.height * pt.y / 100.0f);
    }
    
    NSLog(@"pt: (%f,%f) absPt: (%f,%f)",pt.x,pt.y,absPt.x,absPt.y);
    
    return absPt;
}

- (void) setRelativePosition:(CGPoint)pt type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName
{
    CGPoint absPt = [self absolutePositionFromRelative:pt type:type parentSize:containerSize propertyName:propertyName];
    
#ifdef __CC_PLATFORM_IOS
    [self setValue:[NSValue valueWithCGPoint:absPt] forKey:propertyName];
#else
    [self setValue:[NSValue valueWithPoint:NSPointFromCGPoint(absPt)] forKey:propertyName];
#endif
}

- (void) setRelativePosition:(CGPoint)position type:(int)type parentSize:(CGSize)parentSize
{
    [self setRelativePosition:position type:type parentSize:parentSize propertyName:@"position"];
}

- (void) setRelativePosition:(CGPoint)position type:(int)type
{
    NSAssert(self.parent, @"Node must have a parent to use relative positioning");
    
    [self setRelativePosition:position type:type parentSize:self.parent.contentSize propertyName:@"position"];
}


#pragma mark Content Size

- (void) setRelativeSize:(CGSize)size type:(int)type parentSize:(CGSize)containerSize propertyName:(NSString*) propertyName
{
    CGSize absSize = CGSizeZero;
    if (type == kCCBSizeTypeAbsolute)
    {
        absSize = size;
    }
    else if (type == kCCBSizeTypeRelativeContainer)
    {
        absSize.width = containerSize.width - size.width;
        absSize.height = containerSize.height - size.height;
    }
    else if (type == kCCBSizeTypePercent)
    {
        absSize.width = (int)(containerSize.width * size.width / 100.0f);
        absSize.height = (int)(containerSize.height * size.height / 100.0f);
    }
    else if (type == kCCBSizeTypeHorizontalPercent)
    {
        absSize.width = (int)(containerSize.width * size.width / 100.0f);
        absSize.height = size.height;
    }
    else if (type == kCCBSzieTypeVerticalPercent)
    {
        absSize.width = size.width;
        absSize.height = (int)(containerSize.height * size.height / 100.0f);
    }
    
#ifdef __CC_PLATFORM_IOS
    [self setValue:[NSValue valueWithCGSize:absSize] forKey:propertyName];
#else
    [self setValue:[NSValue valueWithSize:NSSizeFromCGSize(absSize)] forKey:propertyName];
#endif
}

- (void) setRelativeSize:(CGSize)size type:(int)type parentSize:(CGSize)parentSize
{
    [self setRelativeSize:size type:type parentSize:parentSize propertyName:@"contentSize"];
}

- (void) setRelativeSize:(CGSize)size type:(int)type
{
    [self setRelativeSize:size type:type parentSize:self.parent.contentSize propertyName:@"contentSize"];
}


#pragma mark Scale

- (float) resolutionScale
{
#ifdef __CC_PLATFORM_IOS
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // iPad
        return 2;
    }
#endif
    return 1;
}

- (void) setRelativeScaleX:(float)x Y:(float)y type:(int)type propertyName:(NSString*)propertyName
{
    float resolutionScale = [self resolutionScale];
    
    if (type == kCCBScaleTypeMultiplyResolution)
    {
        x *= resolutionScale;
        y *= resolutionScale;
    }
    
    NSString* nameX = [NSString stringWithFormat:@"%@X",propertyName];
    NSString* nameY = [NSString stringWithFormat:@"%@Y",propertyName];
    [self setValue:[NSNumber numberWithFloat:x] forKey:nameX];
    [self setValue:[NSNumber numberWithFloat:y] forKey:nameY];
}

- (void) setRelativeScaleX:(float)x Y:(float)y type:(int)type
{
    [self setRelativeScaleX:x Y:y type:type propertyName:@"scale"];
}


#pragma mark Floats

- (void) setRelativeFloat:(float)f type:(int)type propertyName:(NSString*)propertyName
{
    if (type == kCCBScaleTypeMultiplyResolution)
    {
        f *= [self resolutionScale];
    }
    [self setValue:[NSNumber numberWithFloat:f] forKey:propertyName];
}

@end
