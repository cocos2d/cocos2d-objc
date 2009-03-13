/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CocosNode.h"
#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>

/** CocosNode Extension */
@interface CocosNode (CocosExtrasTransforms)

// actual affine transforms used
- (CGAffineTransform)nodeToWorldTransform;
- (CGAffineTransform)worldToNodeTransform;

// conversions
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;
/// converts local coordinate to world space
- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;

// treat returned/received node point as anchor relative
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;


// convenience methods which take a UITouch instead of CGPoint
- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch;
- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch;

@end
