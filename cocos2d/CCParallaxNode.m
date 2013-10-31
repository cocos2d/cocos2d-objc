/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 *
 */

#import "CCParallaxNode.h"
#import "Support/CGPointExtension.h"

@interface CGPointObject : NSObject
{
	CGPoint	_ratio;
	CGPoint _offset;
	CCNode *__unsafe_unretained _child;	// weak ref
}
@property (nonatomic,readwrite) CGPoint ratio;
@property (nonatomic,readwrite) CGPoint offset;
@property (nonatomic,readwrite,unsafe_unretained) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize ratio = _ratio;
@synthesize offset = _offset;
@synthesize child = _child;

+(id) pointWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	return [[self alloc] initWithCGPoint:ratio offset:offset];
}
-(id) initWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	if( (self=[super init])) {
		_ratio = ratio;
		_offset = offset;
	}
	return self;
}
@end

@implementation CCParallaxNode

@synthesize parallaxArray = _parallaxArray;

-(id) init
{
	if( (self=[super init]) ) {
		_parallaxArray = [[NSMutableArray alloc] init];
		_lastPosition = CGPointMake(-100,-100);
	}
	return self;
}


-(void) addChild:(CCNode*)child z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert(NO,@"ParallaxNode: use addChild:z:parallaxRatio:positionOffset instead");
}

-(void) addChild: (CCNode*) child z:(NSInteger)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObject *obj = [CGPointObject pointWithCGPoint:ratio offset:offset];
	obj.child = child;
    [_parallaxArray addObject:obj];

	CGPoint pos = self.position;
	pos.x = pos.x * ratio.x + offset.x;
	pos.y = pos.y * ratio.y + offset.y;
	child.position = pos;

	[super addChild: child z:z name:child.name];
}

-(void) removeChild:(CCNode*)node cleanup:(BOOL)cleanup
{
	[_parallaxArray removeObject:node];
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
    [_parallaxArray removeAllObjects];
	[super removeAllChildrenWithCleanup:cleanup];
}

-(CGPoint) absolutePosition_
{
	CGPoint ret = _position;

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
   - overriding "draw" will only be precise if the children have a z > 0
*/
-(void) visit
{
//	CGPoint pos = _position;
//	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	CGPoint pos = [self absolutePosition_];
	if( ! CGPointEqualToPoint(pos, _lastPosition) ) {
        for (CGPointObject *point in _parallaxArray) {
			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;
			point.child.position = ccp(x,y);
		}

		_lastPosition = pos;
	}

	[super visit];
}
@end
