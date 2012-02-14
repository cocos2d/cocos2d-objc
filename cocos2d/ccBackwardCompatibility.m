/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Ricardo Quesada
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

#import "ccBackwardCompatibility.h"

#if CC_BACKWARD_COMPATIBILITY

#import "CCSpriteBatchNode.h"

@implementation CCScheduler (Compatibility)
+(CCScheduler*) sharedScheduler
{
	return [[CCDirector sharedDirector] scheduler];
}
@end

@implementation CCActionManager (Compatibility)
+(CCActionManager*) sharedManager
{
	return [[CCDirector sharedDirector] actionManager];
}
@end

#if __CC_PLATFORM_IOS
@implementation CCTouchDispatcher (Compatibility)
+(CCTouchDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] touchDispatcher];
}
@end
#elif __CC_PLATFORM_MAC
@implementation CCEventDispatcher (Compatibility)
+(CCEventDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] eventDispatcher];
}
@end
#endif // __CC_PLATFORM_MAC

@implementation CCDirector (Compatibility)
-(void) setDisplayFPS:(BOOL)display
{
	[self setDisplayStats:display];
}

-(void) setOpenGLView:(CCGLView*)view
{
	[self setView:view];
}

-(CCGLView*) openGLView
{
	return (CCGLView*)self.view;
}
@end

@implementation CCSprite (Compatibility)

-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect
{
	[self initWithTexture:node.texture rect:rect];
	[self setBatchNode:node];
	return self;
}

@end

#endif // CC_BACKWARD_COMPATIBILITY
