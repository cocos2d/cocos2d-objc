/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/*
 * This file contains the delegates of the touches
 * There are 2 possible delegates:
 *   - CCStandardTouchHandler: propagates all the events at once
 *   - CCTargetedTouchHandler: propagates 1 event at the time
 */

#import "CCTouchHandler.h"
#import "../../ccMacros.h"

#pragma mark -
#pragma mark TouchHandler
@implementation CCTouchHandler

@synthesize delegate, priority;
@synthesize enabledSelectors=enabledSelectors_;

+ (id)handlerWithDelegate:(id) aDelegate priority:(int)aPriority
{
	return [[[self alloc] initWithDelegate:aDelegate priority:aPriority] autorelease];
}

- (id)initWithDelegate:(id) aDelegate priority:(int)aPriority
{
	NSAssert(aDelegate != nil, @"Touch delegate may not be nil");
	
	if ((self = [super init])) {
		self.delegate = aDelegate;
		priority = aPriority;
		enabledSelectors_ = 0;
	}
	
	return self;
}

- (void)dealloc {
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[delegate release];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark StandardTouchHandler
@implementation CCStandardTouchHandler
-(id) initWithDelegate:(id)del priority:(int)pri
{
	if( (self=[super initWithDelegate:del priority:pri]) ) {
		if( [del respondsToSelector:@selector(ccTouchesBegan:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorBeganBit;
		if( [del respondsToSelector:@selector(ccTouchesMoved:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorMovedBit;
		if( [del respondsToSelector:@selector(ccTouchesEnded:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorEndedBit;
		if( [del respondsToSelector:@selector(ccTouchesCancelled:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorCancelledBit;
	}
	return self;
}
@end

#pragma mark -
#pragma mark TargetedTouchHandler

@interface CCTargetedTouchHandler (private)
-(void) updateKnownTouches:(NSMutableSet *)touches withEvent:(UIEvent *)event selector:(SEL)selector unclaim:(BOOL)doUnclaim;
@end

@implementation CCTargetedTouchHandler

@synthesize swallowsTouches, claimedTouches;

+ (id)handlerWithDelegate:(id)aDelegate priority:(int)priority swallowsTouches:(BOOL)swallow
{
	return [[[self alloc] initWithDelegate:aDelegate priority:priority swallowsTouches:swallow] autorelease];
}

- (id)initWithDelegate:(id)aDelegate priority:(int)aPriority swallowsTouches:(BOOL)swallow
{
	if ((self = [super initWithDelegate:aDelegate priority:aPriority])) {	
		claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
		swallowsTouches = swallow;
		
		if( [aDelegate respondsToSelector:@selector(ccTouchBegan:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorBeganBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchMoved:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorMovedBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchEnded:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorEndedBit;
		if( [aDelegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)] )
			enabledSelectors_ |= kCCTouchSelectorCancelledBit;
	}
	
	return self;
}

- (void)dealloc {
	[claimedTouches release];
	[super dealloc];
}
@end


#endif // __IPHONE_OS_VERSION_MAX_ALLOWED