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

#pragma mark - CCCatmullRomConfig

@implementation CCCatmullRomConfig

@synthesize controlPoints = controlPoints_;

+(id) configWithCapacity:(NSUInteger)capacity
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
	CCCatmullRomConfig *config = [[[self class] allocWithZone:zone] initWithCapacity:10];
	config.controlPoints = newArray;
	[newArray release];
	
	return config;
}

-(void) dealloc
{
	[controlPoints_ release];
	
	[super dealloc];
}

-(void) addControlPoint:(CGPoint)controlPoint
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:controlPoint];
#elif defined(__CC_PLATFORM_IOS)
	NSValue *value = [NSValue valueWithCGPoint:controlPoint];
#endif
	
	[controlPoints_ addObject:value];
}

-(void) insertControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:controlPoint];
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
	CGPoint point = (CGPoint)[value pointValue];
#elif defined(__CC_PLATFORM_IOS)
	CGPoint point = [value CGPointValue];
#endif

	return point;
}

-(void) replaceControlPoint:(CGPoint)controlPoint atIndex:(NSUInteger)index
{
#ifdef __CC_PLATFORM_MAC
	NSValue *value = [NSValue valueWithPoint:controlPoint];
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

-(CCCatmullRomConfig*) reverse
{
	NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[controlPoints_ count]];
	NSEnumerator *enumerator = [controlPoints_ reverseObjectEnumerator];
	for (id element in enumerator)
		[newArray addObject:element];

	CCCatmullRomConfig *config = [[[self class] alloc] initWithCapacity:0];
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

inline CGPoint ccCatmullRomAt( CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, ccTime t )
{
	CGFloat t2 = t * t;
	CGFloat t3 = t2 * t;

//	CGFloat b1 = -0.5 * t3 + t2 - 0.5 * t;
//	CGFloat b2 =  1.5 * t3 - 2.5 * t2 + 1.0;
//	CGFloat b3 = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
//	CGFloat b4 =  0.5 * t3 - 0.5 * t2;

	CGFloat b1 = .5 * (  -t3 + 2*t2 - t);
	CGFloat b2 = .5 * ( 3*t3 - 5*t2 + 2);
	CGFloat b3 = .5 * (-3*t3 + 4*t2 + t);
	CGFloat b4 = .5 * (   t3 -   t2    );

	CGFloat x = (p0.x*b1 + p1.x*b2 + p2.x*b3 + p3.x*b4); 
	CGFloat y = (p0.y*b1 + p1.y*b2 + p2.y*b3 + p3.y*b4); 
	
	return ccp(x,y);
}

#pragma mark - CCCatmullRomTo

@interface CCCatmullRomTo ()
-(void) updatePosition:(CGPoint)newPosition;
@end

@implementation CCCatmullRomTo

@synthesize configuration=configuration_;

+(id) actionWithDuration:(ccTime)duration configuration:(CCCatmullRomConfig *)config
{
	return [[[self alloc] initWithDuration:duration configuration:config] autorelease];
}

-(id) initWithDuration:(ccTime)duration configuration:(CCCatmullRomConfig *)config									
{
	NSAssert( [config count] > 0, @"Invalid configuration. It must at least have one control point");

	if( (self=[super initWithDuration:duration]) )
	{
		self.configuration = config;
	}

	return self;
}

- (void)dealloc
{
	[configuration_ release];
    [super dealloc];
}

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	
	deltaT_ = (CGFloat) 1 / [configuration_ count];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] configuration:configuration_];
    return copy;
}

-(void) update:(ccTime) dt
{	
	NSUInteger p;
	CGFloat lt;
	
	// border
	if( dt == 1 ) {
		p = [configuration_ count] - 1;
		lt = 1;
	} else {
		p = dt / deltaT_;
		lt = (dt - deltaT_ * (CGFloat)p) / deltaT_;
	}

	// Interpolate
	CGPoint pp0 = [configuration_ getControlPointAtIndex:p-1];
	CGPoint pp1 = [configuration_ getControlPointAtIndex:p+0];
	CGPoint pp2 = [configuration_ getControlPointAtIndex:p+1];
	CGPoint pp3 = [configuration_ getControlPointAtIndex:p+2];
	
	CGPoint newPos = ccCatmullRomAt( pp0, pp1, pp2, pp3,lt);
	
	[self updatePosition:newPos];
}

-(void) updatePosition:(CGPoint)newPos
{
	[target_ setPosition:newPos];
}

-(CCActionInterval*) reverse
{
	CCCatmullRomConfig *reverse = [configuration_ reverse];

	return [CCCatmullRomTo actionWithDuration:duration_ configuration:reverse];
}
@end

#pragma mark - CCCatmullRomBy

@implementation CCCatmullRomBy

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
	CCCatmullRomConfig *copyConfig = [configuration_ copy];
	
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
	
	CCCatmullRomConfig *reverse = [copyConfig reverse];
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
	
	return [CCCatmullRomBy actionWithDuration:duration_ configuration:reverse];	
}
@end
