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
	CGPoint	point_;
	CGPoint offset_;
}
@property (readwrite) CGPoint point;
@property (readwrite) CGPoint offset;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize point = point_;
@synthesize offset = offset_;

+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset
{
	return [[[self alloc] initWithCGPoint:point offset:offset] autorelease];
}
-(id) initWithCGPoint:(CGPoint)aPoint offset:(CGPoint)offset
{
	if( (self=[super init])) {
		point_ = aPoint;
		offset_ = offset;
	}
	return self;
}
@end


@implementation ParallaxNode

-(id) init
{
	if( (self=[super init]) ) {
		parallaxDictionary = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
	}
	return self;
}

- (void) dealloc
{
	[parallaxDictionary release];
	[super dealloc];
}

-(NSString*) addressForObject:(CocosNode*)child
{
	return [NSString stringWithFormat:@"<%08X>", child];
}
-(id) addChild: (CocosNode*) child z:(int)z parallaxRatio:(CGPoint)c positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[parallaxDictionary setObject:[CGPointObject pointWithCGPoint:c offset:offset] forKey:[self addressForObject:child]];
	
	CGPoint pos = self.position;
	float x = pos.x * c.x + offset.x;
	float y = pos.y * c.y + offset.y;
	child.position = ccp(x,y);
	
	return [super addChild: child z:z tag:child.tag];
}

-(void) removeChild:(CocosNode*)node cleanup:(BOOL)cleanup
{
	[parallaxDictionary removeObjectForKey:[self addressForObject:node]];
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	[parallaxDictionary removeAllObjects];
	[super removeAllChildrenWithCleanup:cleanup];
}

-(void) setPosition:(CGPoint)pos
{
	for( CocosNode *node in children) {
		CGPointObject *point = [parallaxDictionary objectForKey:[self addressForObject:node]];
		float x = -pos.x + pos.x * point.point.x + point.offset.x;
		float y = -pos.y + pos.y * point.point.y + point.offset.y;

		node.position = ccp(x,y);
	}

	[super setPosition:pos];
}
@end
