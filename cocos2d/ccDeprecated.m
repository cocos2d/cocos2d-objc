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

#import "ccDeprecated.h"

#if CC_ENABLE_DEPRECATED

#import "CCSpriteBatchNode.h"

// Free functions
void ccGLUniformModelViewProjectionMatrix( CCGLProgram* program )
{
	[program setUniformForModelViewProjectionMatrix];
}

@implementation CCScheduler (Deprecated)
+(CCScheduler*) sharedScheduler
{
	return [[CCDirector sharedDirector] scheduler];
}
@end

@implementation CCActionManager (Deprecated)
+(CCActionManager*) sharedManager
{
	return [[CCDirector sharedDirector] actionManager];
}
@end

#if __CC_PLATFORM_IOS
@implementation CCTouchDispatcher (Deprecated)
+(CCTouchDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] touchDispatcher];
}
@end
#elif __CC_PLATFORM_MAC
@implementation CCEventDispatcher (Deprecated)
+(CCEventDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] eventDispatcher];
}
@end
#endif // __CC_PLATFORM_MAC

#pragma mark - CCDirector

@implementation CCDirector (Deprecated)
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

@implementation CCSprite (Deprecated)

+(id) spriteWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect
{
	id ret = [self spriteWithTexture:node.texture rect:rect];
	[ret setBatchNode:node];
	return ret;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect
{
	self = [self initWithTexture:node.texture rect:rect];
	[self setBatchNode:node];
	return self;
}

-(CCSpriteFrame*) displayedFrame
{
	return [self displayedFrame];
}
@end

@implementation CCMenuItemSprite (Deprecated)
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite];
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:target selector:selector];	
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector];
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite block:block];
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block];
}

-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector];
}
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block];
}
@end

@implementation CCMenuItemImage (Deprecated)
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2
{
	return [self itemWithNormalImage:value selectedImage:value2];
}
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s
{
	return [self itemWithNormalImage:value selectedImage:value2 target:r selector:s];	
}
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage:value3 target:r selector:s];	
}
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block
{
	return [self itemWithNormalImage:value selectedImage:value2 block:block];
}
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage:value3 block:block];
}
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s
{
	return [self initWithNormalImage:value selectedImage:value2 disabledImage:value3 target:r selector:s];
}
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
	return [self initWithNormalImage:value selectedImage:value2 disabledImage:value3 block:block];
}
@end


@implementation CCAnimation (Deprecated)
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames
{
	return [self animationWithSpriteFrames:arrayOfSpriteFrameNames];
}
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay
{
	return [self animationWithSpriteFrames:arrayOfSpriteFrameNames delay:delay];
}
-(id) initWithFrames:(NSArray*)arrayOfSpriteFrameNames
{
	return [self initWithSpriteFrames:arrayOfSpriteFrameNames];
}
-(id) initWithFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay
{
	return [self initWithSpriteFrames:arrayOfSpriteFrameNames delay:delay];
}
-(void) addFrame:(CCSpriteFrame*)frame
{
	[self addSpriteFrame:frame];
}
-(void) addFrameWithFilename:(NSString*)filename
{
	[self addSpriteFrameWithFilename:filename];
}
-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	[self addSpriteFrameWithTexture:texture rect:rect];
}
@end



#if __CC_PLATFORM_IOS
@implementation EAGLView
@end

#elif __CC_PLATFORM_MAC

@implementation MacView
@end

#endif // __CC_PLATFORM_MAC

#endif // CC_ENABLE_DEPRECATED
