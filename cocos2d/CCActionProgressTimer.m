/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
 * Copyright (c) 2013-2014 Cocos2D Authors
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


#import "CCActionProgressTimer.h"

@implementation CCActionProgressTo
+(id) actionWithDuration: (CCTime) t percent: (float) v
{
	return [[ self alloc] initWithDuration: t percent: v];
}

-(id) initWithDuration: (CCTime) t percent: (float) v
{
	if( (self=[super initWithDuration: t] ) )
		_to = v;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:_duration percent:_to];
	return copy;
}

-(void) startWithTarget:(id) aTarget;
{
	[super startWithTarget:aTarget];
	_from = [(CCProgressNode*)_target percentage];

	// XXX: Is this correct ?
	// Adding it to support CCRepeat
	if( _from == 100)
		_from = 0;
}

-(void) update: (CCTime) t
{
	[(CCProgressNode*)_target setPercentage: _from + ( _to - _from ) * t];
}
@end

@implementation CCActionProgressFromTo
+(id) actionWithDuration: (CCTime) t from:(float)fromPercentage to:(float) toPercentage
{
	return [[self alloc] initWithDuration: t from: fromPercentage to: toPercentage];
}

-(id) initWithDuration: (CCTime) t from:(float)fromPercentage to:(float) toPercentage
{
	if( (self=[super initWithDuration: t] ) ){
		_to = toPercentage;
		_from = fromPercentage;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:_duration from:_from to:_to];
	return copy;
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithDuration:_duration from:_to to:_from];
}

-(void) startWithTarget:(id) aTarget;
{
	[super startWithTarget:aTarget];
}

-(void) update: (CCTime) t
{
	[(CCProgressNode*)_target setPercentage: _from + ( _to - _from ) * t];
}
@end
