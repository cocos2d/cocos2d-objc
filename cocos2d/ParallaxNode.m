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

#import "ParallaxNode.h"
#import "Support/CGPointExtension.h"


@interface CGPointObject : NSObject
{
	CGPoint	ratio_;
	CGPoint offset_;
}
@property (readwrite) CGPoint ratio;
@property (readwrite) CGPoint offset;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize ratio = ratio_;
@synthesize offset = offset_;

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


@implementation ParallaxNode

@synthesize parallaxDictionary = parallaxDictionary_;

-(id) init
{
	if( (self=[super init]) ) {
		self.parallaxDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
		
		[self schedule:@selector(updateCoords:)];
		lastPosition = CGPointMake(-100,-100);
	}
	return self;
}

- (void) dealloc
{
	[parallaxDictionary_ release];
	[super dealloc];
}

-(NSString*) addressForObject:(CocosNode*)child
{
	return [NSString stringWithFormat:@"<%08X>", child];
}
-(id) addChild: (CocosNode*) child z:(int)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[parallaxDictionary_ setObject:[CGPointObject pointWithCGPoint:ratio offset:offset] forKey:[self addressForObject:child]];
	
	CGPoint pos = self.position;
	float x = pos.x * ratio.x + offset.x;
	float y = pos.y * ratio.y + offset.y;
	child.position = ccp(x,y);
	
	return [super addChild: child z:z tag:child.tag];
}

-(void) removeChild:(CocosNode*)node cleanup:(BOOL)cleanup
{
	[parallaxDictionary_ removeObjectForKey:[self addressForObject:node]];
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	[parallaxDictionary_ removeAllObjects];
	[super removeAllChildrenWithCleanup:cleanup];
}

-(void) updateCoords: (ccTime) dt
{
	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	
	if( ! CGPointEqualToPoint(pos, lastPosition) ) {

		for( CocosNode *child in children) {
			CGPointObject *point = [parallaxDictionary_ objectForKey:[self addressForObject:child]];
			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;
			
			child.position = ccp(x,y);
		}
		
		lastPosition = pos;
	}
}
@end
