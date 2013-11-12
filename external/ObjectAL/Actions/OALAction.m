//
//  OALAction.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-09-18.
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

#import "OALAction.h"
#import "OALAction+Private.h"
#import "OALActionManager.h"
#import "ObjectALMacros.h"
#import "ARCSafe_MemMgmt.h"
#import <objc/message.h>


#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS


#pragma mark OALAction (ObjectAL version)


@implementation OALAction


#pragma mark Object Management

- (id) init
{
	return [self initWithDuration:0];
}

- (id) initWithDuration:(float) duration
{
	if(nil != (self = [super init]))
	{
		self.duration = duration;
	}
	return self;
}


#pragma mark Properties

@synthesize target = _target;
@synthesize duration = duration_;
@synthesize elapsed = elapsed_;
@synthesize running = running_;
@synthesize runningInManager = runningInManager_;


#pragma mark Functions

- (void) runWithTarget:(id) target
{
	[self prepareWithTarget:target];
	[self startAction];
	[self updateCompletion:0];

	// Only add this action to the manager if it has a duration.
	if(self.duration > 0)
	{
		[[OALActionManager sharedInstance] notifyActionStarted:self];
		self.runningInManager = YES;
	}
	else
	{
		// If there's no duration, the action has completed.
		[self stopAction];
	}
}

- (void) prepareWithTarget:(id) target
{
	NSAssert(!self.running, @"Error: Action is already running");

	self.target = target;
}

- (void) startAction
{
	self.running = YES;
	self.elapsed = 0;
}

- (void) updateCompletion:(float) proportionComplete
{
    #pragma unused(proportionComplete)
	// Subclasses will override this.
}

- (void) stopAction
{
	self.running = NO;
	if(self.runningInManager)
	{
		[[OALActionManager sharedInstance] notifyActionStopped:self];
		self.runningInManager = NO;
	}
}

@end


#else /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */

@implementation OALAction

- (id) init
{
	return [self initWithDuration:0];
}

-(void) startWithTarget:(id) target
{
	[super startWithTarget:target];
	[self prepareWithTarget:target];
	started_ = YES;
	[self runWithTarget:target];
}

- (void) update:(float) proportionComplete
{
	// The only difference from COCOS2D_SUBCLASS() is that
	// I don't call [super update:] here.
	[self updateCompletion:proportionComplete];
}

- (bool) running
{
	return !self.isDone;
}

- (void) runWithTarget:(id) target
{
	if(!started_)
	{
		[[CCActionManager sharedManager] addAction:self target:target paused:NO];
	}
}

- (void) stopAction
{
	[[CCActionManager sharedManager] removeAction:self];
}

- (void) prepareWithTarget:(id) target
{
    #pragma unused(target)
}

- (void) updateCompletion:(float) proportionComplete
{
    #pragma unused(proportionComplete)
}

- (void) setTarget:(id)target
{
    target_ = target;
}

- (id) target
{
    return target_;
}

- (void) setDuration:(float)duration
{
    duration_ = duration;
}

- (float) duration
{
    return duration_;
}

@synthesize running = running_;

@end

#endif /* !OBJECTAL_CFG_USE_COCOS2D_ACTIONS */


#pragma mark -
#pragma mark OALPropertyAction

@interface OALPropertyAction ()

@property(nonatomic,readwrite,assign) float delta;

@property(nonatomic,readwrite,retain) NSString* propertyKey;

@end

@implementation OALPropertyAction

#pragma mark Properties

@synthesize startValue = _startValue;

@synthesize endValue = _endValue;

@synthesize delta = _delta;

@synthesize propertyKey = _propertyKey;


#pragma mark Object Management

+ (id) actionWithDuration:(float) duration
              propertyKey:(NSString*) propertyKey
				 endValue:(float) endValue
{
	return as_autorelease([[self alloc] initWithDuration:duration
                                             propertyKey:propertyKey
                                                endValue:endValue]);
}

+ (id) actionWithDuration:(float) duration
              propertyKey:(NSString*) propertyKey
			   startValue:(float) startValue
				 endValue:(float) endValue
{
	return as_autorelease([[self alloc] initWithDuration:duration
                                             propertyKey:propertyKey
                                              startValue:startValue
                                                endValue:endValue]);
}

- (id) initWithDuration:(float) duration
            propertyKey:(NSString*) propertyKey
               endValue:(float) endValue
{
	return [self initWithDuration:duration
                      propertyKey:propertyKey
					   startValue:NAN
						 endValue:endValue];
}

- (id) initWithDuration:(float) duration
            propertyKey:(NSString*) propertyKey
			 startValue:(float) startValue
			   endValue:(float) endValue
{
	if(nil != (self = [super initWithDuration:duration]))
	{
        self.propertyKey = propertyKey;
		self.startValue = startValue;
		self.endValue = endValue;
	}
	return self;
}


#pragma mark Functions

- (void) prepareWithTarget:(id) target
{
	[super prepareWithTarget:target];

    if(isnan(self.startValue))
    {
        self.startValue = [[target valueForKey:self.propertyKey] floatValue];
    }

	self.delta = self.endValue - self.startValue;
}

- (void) updateCompletion:(float) proportionComplete
{
    float value = self.startValue + self.delta * proportionComplete;
    [self.target setValue:[NSNumber numberWithFloat:value] forKey:self.propertyKey];
}

@end


#pragma mark -
#pragma mark OALEaseAction

static float easeFunction_sineIn(float x)
{
    return 1.0f - cosf(x * (float)M_PI_2);
}

static float easeFunction_sineOut(float x)
{
    return sinf(x * (float)M_PI_2);
}

static float easeFunction_sineInOut(float x)
{
    return -0.5f * (cosf(x * (float)M_PI) - 1);
}

static float easeFunction_exponentIn(float x)
{
    if(x == 0)
    {
        return 0;
    }
    return powf(2, 10 * (x - 1));
}

static float easeFunction_exponentOut(float x)
{
    if(x == 1)
    {
        return 1;
    }
    return powf(-2, -10 * x) + 1;
}

static float easeFunction_exponentInOut(float x)
{
    if(x < 0.5)
    {
        if(x == 0)
        {
            return 0;
        }
        return powf(2, (12 * (x - 0.86f))) * 10;
    }
    if(x == 1)
    {
        return 1;
    }
    return powf(-2, (-12 * (x - 0.4165f))) + 1;
}


static EaseFunctionPtr g_easeFunctions[2][3] =
{
    {
        easeFunction_sineIn,
        easeFunction_sineOut,
        easeFunction_sineInOut,
    },
    {
        easeFunction_exponentIn,
        easeFunction_exponentOut,
        easeFunction_exponentInOut,
    },
};

@interface OALEaseAction ()

@property(nonatomic, readwrite, retain) OALAction* action;
@property(nonatomic, readwrite, assign) EaseFunctionPtr easeFunction;

@end

@implementation OALEaseAction

@synthesize action = action_;
@synthesize easeFunction = easeFunction_;

+ (EaseFunctionPtr) easeFunctionForShape:(OALEaseShape) shape
                                   phase:(OALEasePhase) phase
{
    return g_easeFunctions[shape][phase];
}

+ (OALEaseAction*) actionWithShape:(OALEaseShape) shape
                             phase:(OALEasePhase) phase
                            action:(OALAction*) action
{
    return as_autorelease([[self alloc] initWithShape:shape
                                                phase:phase
                                               action:action]);
}

- (id) initWithShape:(OALEaseShape) shape
               phase:(OALEasePhase) phase
              action:(OALAction*) action
{
    if((self = [super initWithDuration:action.duration]))
    {
        self.easeFunction = [[self class] easeFunctionForShape:shape phase:phase];
        self.action = action;
    }
    return self;
}

- (void) dealloc
{
    as_release(action_);
    as_superdealloc();
}

- (void) prepareWithTarget:(id) target
{
    [self.action prepareWithTarget:target];
    self.duration = self.action.duration;
}

#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS
- (void) startAction
{
    [self.action startAction];
    [super startAction];
}
#else
- (void) startWithTarget:(id)target
{
    [self.action startWithTarget:target];
    [super startWithTarget:target];
}
#endif

- (void) stopAction
{
    [self.action stopAction];
    [super stopAction];
}

- (void) updateCompletion:(float) proportionComplete
{
    [self.action updateCompletion:self.easeFunction(proportionComplete)];
}

@end
