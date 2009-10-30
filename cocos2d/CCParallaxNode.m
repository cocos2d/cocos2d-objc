/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCParallaxNode.h"
#import "Support/CGPointExtension.h"
#import "Support/ccArray.h"

@interface CGPointObject : NSObject
{
	CGPoint	ratio_;
	CGPoint offset_;
	CCNode *child_;	// weak ref
}
@property (readwrite) CGPoint ratio;
@property (readwrite) CGPoint offset;
@property (readwrite,assign) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize ratio = ratio_;
@synthesize offset = offset_;
@synthesize child=child_;

+(id) pointWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	return [[[self alloc] initWithCGPoint:ratio offset:offset] autorelease];
}
-(id) initWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	if( (self=[super init])) {
		ratio_ = ratio;
		offset_ = offset;
	}
	return self;
}
@end

@implementation CCParallaxNode

@synthesize parallaxArray=parallaxArray_;

-(id) init
{
	if( (self=[super init]) ) {
		parallaxArray_ = ccArrayNew(5);		
		lastPosition = CGPointMake(-100,-100);
	}
	return self;
}

- (void) dealloc
{
	if( parallaxArray_ ) {
		ccArrayFree(parallaxArray_);
		parallaxArray_ = nil;
	}
	[super dealloc];
}

-(id) addChild:(CCNode*)child z:(int)z tag:(int)tag
{
	NSAssert(NO,@"ParallaxNode: use addChild:z:parallaxRatio:positionOffset instead");
	return nil;
}

-(id) addChild: (CCNode*) child z:(int)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObject *obj = [CGPointObject pointWithCGPoint:ratio offset:offset];
	obj.child = child;
	ccArrayAppendObjectWithResize(parallaxArray_, obj);
	
	CGPoint pos = self.position;
	float x = pos.x * ratio.x + offset.x;
	float y = pos.y * ratio.y + offset.y;
	child.position = ccp(x,y);
	
	return [super addChild: child z:z tag:child.tag];
}

-(void) removeChild:(CCNode*)node cleanup:(BOOL)cleanup
{
	for( unsigned int i=0;i < parallaxArray_->num;i++) {
		CGPointObject *point = parallaxArray_->arr[i];
		if( [point.child isEqual:node] ) {
			ccArrayRemoveObjectAtIndex(parallaxArray_, i);
			break;
		}
	}
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	ccArrayRemoveAllObjects(parallaxArray_);
	[super removeAllChildrenWithCleanup:cleanup];
}

-(CGPoint) absolutePosition_
{
	CGPoint ret = position_;
	
	CCNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}
	
	return ret;
}

/*
 The positions are updated at visit because:
   - using a timer is not guaranteed that it will called after all the positions were updated
   - overriding "draw" will only precise if the children have a z > 0
*/
-(void) visit
{
//	CGPoint pos = position_;
//	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	CGPoint pos = [self absolutePosition_];
	if( ! CGPointEqualToPoint(pos, lastPosition) ) {
		
		for(unsigned int i=0; i < parallaxArray_->num; i++ ) {

			CGPointObject *point = parallaxArray_->arr[i];
			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;			
			point.child.position = ccp(x,y);
		}
		
		lastPosition = pos;
	}
	
	[super visit];
}
@end
