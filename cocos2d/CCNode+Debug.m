/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Zynga Inc.
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
 */

#import "CCNode+Debug.h"
#import "CCNode_Private.h"

#ifdef DEBUG

@implementation CCNode (Debug)

-(void) walkSceneGraph:(NSUInteger)level
{
	char buf[64];
	NSUInteger i=0;
	for( i=0; i<level+1; i++)
		buf[i] = '-';
	buf[i] = 0;
	

	if(_children) {
		
		[self sortAllChildren];
		
		i = 0;
		
		// draw children zOrder < 0
		for( ; i < _children.count; i++ ) {
			CCNode *child = [_children objectAtIndex:i];
			if ( [child zOrder] < 0 )
				[child walkSceneGraph:level+1];
			else
				break;
		}
		
		// self draw
		NSLog(@"walk tree: %s> %@ %p", buf, self, self);
		
		// draw children zOrder >= 0
		for( ; i < _children.count; i++ ) {
			CCNode *child = [_children objectAtIndex:i];
			[child walkSceneGraph:level+1];
		}
		
	} else
		NSLog(@"walk tree: %s> %@ %p", buf, self, self);
	
}
@end

#endif // DEBUG
