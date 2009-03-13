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

#import "CocosNodeExtras.h"

#define F_RADIANS_PER_DEGREE ((float) M_PI / 180.0f)

static inline cpVect vectFromPoint(CGPoint point)
{
	return cpv(point.x, point.y);
}

@implementation CocosNode (CocosExtrasTransforms)

- (CGAffineTransform)nodeToWorldTransform
{
	// NOTE: should add parallaxing following pattern in CocosNode#transform
	
	CGAffineTransform t = CGAffineTransformIdentity;
	
	if (parent != nil) {
		t = [parent nodeToWorldTransform];
	}
	
	if (!relativeTransformAnchor) {
		t = CGAffineTransformTranslate(t, transformAnchor.x, transformAnchor.y);
	}
	
	t = CGAffineTransformTranslate(t, position.x, position.y);
	t = CGAffineTransformRotate(t, rotation * -F_RADIANS_PER_DEGREE);
	t = CGAffineTransformScale(t, scaleX, scaleY);
	
	t = CGAffineTransformTranslate(t, -transformAnchor.x, -transformAnchor.y);
	
	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	return CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	nodePoint.x -= transformAnchor.x;
	nodePoint.y -= transformAnchor.y;
	return nodePoint;
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint.x += transformAnchor.x;
	nodePoint.y += transformAnchor.y;
	return [self convertToWorldSpace:nodePoint];
}

// convenience methods which return cpVect instead of CGPoint

- (cpVect)convertToNodeSpaceVect:(CGPoint)worldPoint
{
	return vectFromPoint( [self convertToNodeSpace:worldPoint] );
}

- (cpVect)convertToWorldSpaceVect:(CGPoint)nodePoint
{
	return vectFromPoint( [self convertToWorldSpace:nodePoint] );
}

- (cpVect)convertToNodeSpaceVectAR:(CGPoint)worldPoint
{
	return vectFromPoint( [self convertToNodeSpaceAR:worldPoint] );
}

- (cpVect)convertToWorldSpaceVectAR:(CGPoint)nodePoint
{
	return vectFromPoint( [self convertToWorldSpaceAR:nodePoint] );
}

// convenience methods which take a UITouch instead of CGPoint

- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpaceAR:point];
}

- (cpVect)convertTouchToNodeSpaceVect:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpaceVect:point];
}

- (cpVect)convertTouchToNodeSpaceVectAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpaceVectAR:point];
}

@end
