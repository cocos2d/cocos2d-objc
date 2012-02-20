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

#import "ccConfig.h"

#if CC_ENABLE_DEPRECATED

#import "ccMacros.h"
#import "CCMenu.h"
#import "CCDirector.h"
#import "CCSprite.h"
#import "CCGLProgram.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"

// Renamed constants
enum {
	kCCResolutionStandard DEPRECATED_ATTRIBUTE	= kCCResolutioniPhone,
	kCCMenuTouchPriority DEPRECATED_ATTRIBUTE	= kCCMenuHandlerPriority,
};

// Free functions
void ccGLUniformModelViewProjectionMatrix(CCGLProgram* program) DEPRECATED_ATTRIBUTE;

// Renamed classes
DEPRECATED_ATTRIBUTE @interface EAGLView : CCGLView
@end

DEPRECATED_ATTRIBUTE @interface MacView : CCGLView
@end

// hack to prevent "incopatible pointer type"
#define GLProgram CCGLProgram

// Extensions
@interface CCScheduler (Deprecated)
+(CCScheduler*) sharedScheduler DEPRECATED_ATTRIBUTE;
@end

@interface CCActionManager (Deprecated)
+(CCActionManager*) sharedManager DEPRECATED_ATTRIBUTE;
@end

#if __CC_PLATFORM_IOS
@interface CCTouchDispatcher (Deprecated)
+(CCTouchDispatcher*) sharedDispatcher DEPRECATED_ATTRIBUTE;
@end
#elif __CC_PLATFORM_MAC
@interface CCEventDispatcher (Deprecated)
+(CCEventDispatcher*) sharedDispatcher DEPRECATED_ATTRIBUTE;
@end
#endif // __CC_PLATFORM_MAC

@interface CCDirector (Deprecated)
-(void) setOpenGLView:(CCGLView*)view DEPRECATED_ATTRIBUTE;
-(CCGLView*) openGLView DEPRECATED_ATTRIBUTE;
-(void) setDisplayFPS:(BOOL)display DEPRECATED_ATTRIBUTE;
@end


@interface CCSprite (Deprecated)
+(id) spriteWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
@end

@interface CCMenuItemSprite (Deprecated)
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;

-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector DEPRECATED_ATTRIBUTE;
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
@end

@interface CCMenuItemImage (Deprecated)
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
@end


#endif // CC_ENABLE_DEPRECATED

