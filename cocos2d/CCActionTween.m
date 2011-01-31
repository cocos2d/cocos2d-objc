/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
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

#import "CCActionTween.h"


@implementation CCActionTween

+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(float)aFrom to:(float)aTo {

	return [[[[self class] alloc] initWithDuration:aDuration key:aKey from:aFrom to:aTo] autorelease];
}

- (id)initWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to {
    
	if ((self = [super initWithDuration:aDuration])) {
    
		key_	= [key copy];
		to_		= to;
		from_	= from;

	}
    
	return self;
}

- (void) dealloc
{
	[key_ release];
	[super dealloc];
}

- (void)startWithTarget:aTarget
{
	[super startWithTarget:aTarget];
	delta_ = to_ - from_;
}

- (void) update:(ccTime) dt
{    
	[target_ setValue:[NSNumber numberWithFloat:to_  - delta_ * (1 - dt)] forKey:key_];
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithDuration:duration_ key:key_ from:to_ to:from_];
}


@end
