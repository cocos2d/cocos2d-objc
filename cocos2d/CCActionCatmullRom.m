/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008 Radu Gruian
 *
 * Copyright (c) 2011 Vit Valentin
 *
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
 *
 * Orignal code by Radu Gruian: http://www.codeproject.com/Articles/30838/Overhauser-Catmull-Rom-Splines-for-Camera-Animatio.So
 *
 * Adapted to cocos2d-x by Vit Valentin
 *
 * Adapted from cocos2d-x to cocos2d-iphone by Ricardo Quesada
 */


#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "CCActionCatmullRom.h"

#pragma mark - CCPointArray

@implementation CCPointArray

@synthesize controlPoints = controlPoints_;

+(id) arrayWithCapacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithCapacity:capacity] autorelease];
}

-(id) init
{
	return [self initWithCapacity:50];
}

// designated initializer
-(id) initWithCapacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		controlPoints_ = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	
	return self;
}

-(id) copyWithZone:(NSZone *)zone
{
	NSMutableArray *newArray = [controlPoints_ mutableCopy];
	CCPointArray *points = [[[self class] allocWithZone:zone] initWithCapacity:10];
	points.controlPoints = newArray;
	[newArray release];
	
	return points;
}

-(void) dealloc
{
	[controlPoints_ release];
	
	[super dealloc];
}

-(void) addControlPoint:(CGPoint)controlPoint
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:NSPointFromCGPoint(controlPoint)];
#elif defined(__CC_PLATFORM_IOS)
	NSValue *value = [NSValue valueWithCGPoint:controlPoint];
#endif
	
	[controlPoints_ addObject:value];
}

-(void) insertControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:NSPointFromCGPoint(controlPoint)];
#elif defined(__CC_PLATFORM_IOS)
	NSValue *value = [NSValue valueWithCGPoint:controlPoint];
#endif
	
	[controlPoints_ insertObject:value atIndex:index];
	
}

-(CGPoint) getControlPointAtIndex:(NSInteger)index
{
	index = MIN([controlPoints_ count]-1, MAX(index, 0));

	NSValue *value = [controlPoints_ objectAtIndex:index];

#ifdef __CC_PLATFORM_MAC
	CGPoint point = NSPointToCGPoint([value pointValue]);
#elif defined(__CC_PLATFORM_IOS)
	CGPoint point = [value CGPointValue];
#endif

	return point;
}

-(void) replaceControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:NSPointFromCGPoint(controlPoint)];
#elif defined(__CC_PLATFORM_IOS)
	NSValue *value = [NSValue valueWithCGPoint:controlPoint];
#endif

	[controlPoints_ replaceObjectAtIndex:index withObject:value];
}

-(void) removeControlPointAtIndex:(NSUInteger)index
{
	[controlPoints_ removeObjectAtIndex:index];
}

-(NSUInteger) count
{
	return [controlPoints_ count];
}

-(CCPointArray*) reverse
{
	NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[controlPoints_ count]];
	NSEnumerator *enumerator = [controlPoints_ reverseObjectEnumerator];
	for (id element in enumerator)
		[newArray addObject:element];

	CCPointArray *config = [[[self class] alloc] initWithCapacity:0];
	config.controlPoints = newArray;

	[newArray release];
	
	return [config autorelease];
}

-(void) reverseInline
{
	NSUInteger l = [controlPoints_ count];
	for( NSUInteger i=0; i<l/2;i++)
		[controlPoints_ exchangeObjectAtIndex:i withObjectAtIndex:l-i-1];
}
@end

// CatmullRom Spline formula:

inline CGPoint ccCardinalSplineAt( CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, CGFloat tension, ccTime t )
{
	CGFloat t2 = t * t;
	CGFloat t3 = t2 * t;

	/*
	 * Formula: s(-ttt + 2tt – t)P1 + s(-ttt + tt)P2 + (2ttt – 3tt + 1)P2 + s(ttt – 2tt + t)P3 + (-2ttt + 3tt)P3 + s(ttt – tt)P4
	 */
	CGFloat s = (1 - tension) / 2;
	
	CGFloat b1 = s * ((-t3 + (2 * t2)) - t);					// s(-t3 + 2 t2 – t)P1
	CGFloat b2 = s * (-t3 + t2) + (2 * t3 - 3 * t2 + 1);		// s(-t3 + t2)P2 + (2 t3 – 3 t2 + 1)P2
	CGFloat b3 = s * (t3 - 2 * t2 + t) + (-2 * t3 + 3 * t2);	// s(t3 – 2 t2 + t)P3 + (-2 t3 + 3 t2)P3
	CGFloat b4 = s * (t3 - t2);									// s(t3 – t2)P4

	CGFloat x = (p0.x*b1 + p1.x*b2 + p2.x*b3 + p3.x*b4); 
	CGFloat y = (p0.y*b1 + p1.y*b2 + p2.y*b3 + p3.y*b4); 
	
	return ccp(x,y);
}

#pragma mark - CCCatmullRomTo

@interface CCCardinalSplineTo ()
-(void) updatePosition:(CGPoint)newPosition;
@end

@implementation CCCardinalSplineTo

@synthesize points=points_;

+(id) actionWithDuration:(ccTime)duration points:(CCPointArray *)points tension:(CGFloat)tension
{
	return [[[self alloc] initWithDuration:duration points:points tension:tension ] autorelease];
}

-(id) initWithDuration:(ccTime)duration points:(CCPointArray *)points tension:(CGFloat)tension								
{
	NSAssert( [points count] > 0, @"Invalid configuration. It must at least have one control point");

	if( (self=[super initWithDuration:duration]) )
	{
		self.points = points;
		tension_ = tension;
	}

	return self;
}

- (void)dealloc
{
	[points_ release];
    [super dealloc];
}

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	
//	deltaT_ = (CGFloat) 1 / [points_ count];
	
	// Issue #1441
	deltaT_ = (CGFloat) 1 / ([points_ count]-1);
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] points:points_ tension:tension_];
    return copy;
}

-(void) update:(ccTime)dt
{
	NSUInteger p;
	CGFloat lt;

	// eg.
	// p..p..p..p..p..p..p
	// 1..2..3..4..5..6..7
	// want p to be 1, 2, 3, 4, 5, 6
	if (dt == 1) {
		p = [points_ count] - 1;
		lt = 1;
	} else {
		p = dt / deltaT_;
		lt = (dt - deltaT_ * (CGFloat)p) / deltaT_;
	}

	// Interpolate
	CGPoint pp0 = [points_ getControlPointAtIndex:p-1];
	CGPoint pp1 = [points_ getControlPointAtIndex:p+0];
	CGPoint pp2 = [points_ getControlPointAtIndex:p+1];
	CGPoint pp3 = [points_ getControlPointAtIndex:p+2];

	CGPoint newPos = ccCardinalSplineAt( pp0, pp1, pp2, pp3, tension_, lt );

	[self updatePosition:newPos];
}

-(void) updatePosition:(CGPoint)newPos
{
	[target_ setPosition:newPos];
}

-(CCActionInterval*) reverse
{
	CCPointArray *reverse = [points_ reverse];

	return [[self class] actionWithDuration:duration_ points:reverse tension:tension_];
}
@end

#pragma mark - CCCardinalSplineBy

@implementation CCCardinalSplineBy

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];

	startPosition_ = [(CCNode*)target position];
}

-(void) updatePosition:(CGPoint)newPos
{
	[target_ setPosition:ccpAdd(newPos, startPosition_)];
}

-(CCActionInterval*) reverse
{
	CCPointArray *copyConfig = [points_ copy];
	
	//
	// convert "absolutes" to "diffs"
	//
	CGPoint p = [copyConfig getControlPointAtIndex:0];
	for( NSUInteger i=1; i < [copyConfig count];i++ ) {
		
		CGPoint current = [copyConfig getControlPointAtIndex:i];
		CGPoint diff = ccpSub(current,p);
		[copyConfig replaceControlPoint:diff atIndex:i];
		
		p = current;
	}
	
	
	// convert to "diffs" to "reverse absolute"
	
	CCPointArray *reverse = [copyConfig reverse];
	[copyConfig release];
	
	// 1st element (which should be 0,0) should be here too
	p = [reverse getControlPointAtIndex: [reverse count]-1];
	[reverse removeControlPointAtIndex:[reverse count]-1];
	
	p = ccpNeg(p);
	[reverse insertControlPoint:p atIndex:0];
	
	for( NSUInteger i=1; i < [reverse count];i++ ) {
		
		CGPoint current = [reverse getControlPointAtIndex:i];
		current = ccpNeg(current);
		CGPoint abs = ccpAdd( current, p);
		[reverse replaceControlPoint:abs atIndex:i];
		
		p = abs;
	}
	
	return [[self class] actionWithDuration:duration_ points:reverse tension:tension_];
}
@end

@implementation CCCatmullRomTo
+(id) actionWithDuration:(ccTime)dt points:(CCPointArray *)points
{
	return [[[self alloc] initWithDuration:dt points:points] autorelease];
}

-(id) initWithDuration:(ccTime)dt points:(CCPointArray *)points
{
	if( (self=[super initWithDuration:dt points:points tension:0.5f]) ) {
		
	}
	
	return self;
}
@end

@implementation CCCatmullRomBy
+(id) actionWithDuration:(ccTime)dt points:(CCPointArray *)points
{
	return [[[self alloc] initWithDuration:dt points:points] autorelease];
}

-(id) initWithDuration:(ccTime)dt points:(CCPointArray *)points
{
	if( (self=[super initWithDuration:dt points:points tension:0.5f]) ) {
		
	}
	
	return self;
}
@end
