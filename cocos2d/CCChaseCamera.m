/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 */


#import "CCChaseCamera.h"
#import "CGPointExtension.h"

@implementation CCChaseCamera

@synthesize target = target_;

+ (id)cameraWithTarget:(CCNode *)target {
	return [[[self alloc] initWithTarget:target] autorelease];
}

- (id)init {
	if ((self = [super init])) {
		target_ = nil;
	}
	
	return self;
}

- (id)initWithTarget:(CCNode *)target {
	if ((self = [super init])) {
		target_ = target;
	}
	
	return self;
}

- (void)setTarget:(CCNode *)target {
	if (target != nil) {
		NSAssert( target.parent != nil, @"chase camera's target must be a child node (i.e. target must have a parent)");
	}
	
	target_ = target;
}

- (void)locate {
	if (target_ != nil) {
		CGPoint pos = target_.position;
		
		if (!CGPointEqualToPoint(pos, lastPosition)) {
			CGPoint a = target_.parent.anchorPointInPixels;
			CGPoint c = ccp(pos.x - a.x,
							pos.y - a.y);
			
			gluLookAt(c.x, c.y, eyeZ_,
					  c.x, c.y, centerZ_,
					  upX_, upY_, upZ_);
			
			lastPosition = pos;
		}
	} else {
		[super locate];
	}
}

@end
