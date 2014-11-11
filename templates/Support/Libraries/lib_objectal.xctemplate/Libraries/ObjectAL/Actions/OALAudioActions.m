//
//  OALAudioActions.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-10-10.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import "OALAudioActions.h"
#import "OALAction+Private.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"


@implementation OALPropertyAction (Audio)

+ (OALPropertyAction*) pitchActionWithDuration:(float) duration
                                      endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"pitch"
                           endValue:endValue];
}

+ (OALPropertyAction*) pitchActionWithDuration:(float) duration
                                    startValue:(float) startValue
                                      endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"pitch"
                         startValue:startValue
                           endValue:endValue];
}

+ (OALPropertyAction*) panActionWithDuration:(float) duration
                                    endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"pan"
                           endValue:endValue];
}

+ (OALPropertyAction*) panActionWithDuration:(float) duration
                                  startValue:(float) startValue
                                    endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"pan"
                         startValue:startValue
                           endValue:endValue];
}

+ (OALPropertyAction*) gainActionWithDuration:(float) duration
                                     endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"gain"
                           endValue:endValue];
}

+ (OALPropertyAction*) gainActionWithDuration:(float) duration
                                   startValue:(float) startValue
                                     endValue:(float) endValue
{
    return [self actionWithDuration:duration
                        propertyKey:@"gain"
                         startValue:startValue
                           endValue:endValue];
}

@end


#pragma mark -
#pragma mark OAL_PositionProtocol

/** \cond */
/** (INTERNAL USE) Protocol to keep the compiler happy. */
@protocol OAL_PositionProtocol

/** The position in 3D space. */
@property(nonatomic,readwrite,assign) ALPoint position;

@end
/** \endcond */


#pragma mark -
#pragma mark OALPlaceAction

@implementation OALPlaceAction


#pragma mark Object Management

+ (id) actionWithPosition:(ALPoint) position
{
	return as_autorelease([(OALPlaceAction*)[self alloc] initWithPosition:position]);
}

- (id) initWithPosition:(ALPoint) positionIn
{
	if(nil != (self = [super init]))
	{
		position = positionIn;
	}
	return self;
}


#pragma mark Properties

@synthesize position;


#pragma mark Functions

- (void) prepareWithTarget:(id) targetIn
{	
	NSAssert([targetIn respondsToSelector:@selector(setPosition:)],
			 @"Target does not respond to selector [setPosition:]");
	
	[super prepareWithTarget:targetIn];
}

- (void) updateCompletion:(float) proportionComplete
{
	[super updateCompletion:proportionComplete];
	[(id<OAL_PositionProtocol>)self.target setPosition:position];
}

@end


#pragma mark -
#pragma mark OALMoveToAction

@implementation OALMoveToAction


#pragma mark Object Management

+ (id) actionWithDuration:(float) duration position:(ALPoint) position
{
	return as_autorelease([(OALMoveToAction*)[self alloc] initWithDuration:duration position:position]);
}

+ (id) actionWithUnitsPerSecond:(float) unitsPerSecond position:(ALPoint) position
{
	return as_autorelease([[self alloc] initWithUnitsPerSecond:unitsPerSecond position:position]);
}

- (id) initWithDuration:(float) durationIn position:(ALPoint) positionIn
{
	if(nil != (self = [super initWithDuration:durationIn]))
	{
		position = positionIn;
	}
	return self;
}

- (id) initWithUnitsPerSecond:(float) unitsPerSecondIn position:(ALPoint) positionIn
{
	if(nil != (self = [super init]))
	{
		position = positionIn;
		unitsPerSecond = unitsPerSecondIn;
	}
	return self;
}


#pragma mark Properties

@synthesize position;
@synthesize unitsPerSecond;


#pragma mark Functions

- (void) prepareWithTarget:(id) targetIn
{
	NSAssert([targetIn respondsToSelector:@selector(setPosition:)],
			 @"Target does not respond to selector [setPosition:]");
	
	[super prepareWithTarget:targetIn];

	startPoint = [(id<OAL_PositionProtocol>)targetIn position];
	delta = ALPointMake(position.x-startPoint.x, position.y-startPoint.y, position.z - startPoint.z);

	// If unitsPerSecond was set, we use that to calculate duration.  Otherwise just use the current
	// value in duration.
	if(unitsPerSecond > 0)
	{
		duration_ = sqrtf(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z) / unitsPerSecond;
	}
}

- (void) updateCompletion:(float) proportionComplete
{
	[(id<OAL_PositionProtocol>)self.target setPosition:
	 ALPointMake(startPoint.x + delta.x*proportionComplete,
				 startPoint.y + delta.y*proportionComplete,
				 startPoint.z + delta.z*proportionComplete)];
}

@end


#pragma mark -
#pragma mark OALMoveByAction

@implementation OALMoveByAction


#pragma mark Object Management

+ (id) actionWithDuration:(float) duration delta:(ALPoint) delta
{
	return as_autorelease([[self alloc] initWithDuration:duration delta:delta]);
}

+ (id) actionWithUnitsPerSecond:(float) unitsPerSecond delta:(ALPoint) delta
{
	return as_autorelease([[self alloc] initWithUnitsPerSecond:unitsPerSecond delta:delta]);
}

- (id) initWithDuration:(float) durationIn delta:(ALPoint) deltaIn
{
	if(nil != (self = [super initWithDuration:durationIn]))
	{
		delta = deltaIn;
	}
	return self;
}

- (id) initWithUnitsPerSecond:(float) unitsPerSecondIn delta:(ALPoint) deltaIn
{
	if(nil != (self = [super init]))
	{
		delta = deltaIn;
		unitsPerSecond = unitsPerSecondIn;
		if(unitsPerSecond > 0)
		{
			// If unitsPerSecond was set, we use that to calculate duration.  Otherwise just use the current
			// value in duration.
			duration_ = sqrtf(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z) / unitsPerSecond;
		}
	}
	return self;
}


#pragma mark Properties

@synthesize delta;
@synthesize unitsPerSecond;


#pragma mark Functions

- (void) prepareWithTarget:(id) targetIn
{
	NSAssert([targetIn respondsToSelector:@selector(setPosition:)],
			 @"Target does not respond to selector [setPosition:]");
	
	[super prepareWithTarget:targetIn];

	startPoint = [(id<OAL_PositionProtocol>)targetIn position];
	if(unitsPerSecond > 0)
	{
		// If unitsPerSecond was set, we use that to calculate duration.  Otherwise just use the current
		// value in duration.
		duration_ = sqrtf(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z) / unitsPerSecond;
	}
}

- (void) updateCompletion:(float) proportionComplete
{
	[(id<OAL_PositionProtocol>)self.target setPosition:
	 ALPointMake(startPoint.x + delta.x*proportionComplete,
				 startPoint.y + delta.y*proportionComplete,
				 startPoint.z + delta.z*proportionComplete)];
}

@end
