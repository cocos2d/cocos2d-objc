/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import "CCWindow.h"


@implementation CCWindow

- (id) initWithFrame:(NSRect)frame fullscreen:(BOOL)fullscreen
{
	int styleMask = fullscreen ? NSBackingStoreBuffered : ( NSTitledWindowMask | NSClosableWindowMask );
	self = [self initWithContentRect:frame
						   styleMask:styleMask
							 backing:NSBackingStoreBuffered
							   defer:YES];

	if (self != nil)
	{
		if(fullscreen)
		{
			[self setLevel:NSMainMenuWindowLevel+1];
			[self setHidesOnDeactivate:YES];
			[self setHasShadow:NO];
		}

		[self setAcceptsMouseMovedEvents:NO];
		[self setOpaque:YES];
	}
	return self;
}

- (BOOL) canBecomeKeyWindow
{
	return YES;
}

- (BOOL) canBecomeMainWindow
{
	return YES;
}
@end

#endif // __CC_PLATFORM_MAC
