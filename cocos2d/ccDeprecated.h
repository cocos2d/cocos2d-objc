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
#import "CCAnimation.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "CCActionInterval.h"
#import "CCRenderTexture.h"
#import "Support/CCFileUtils.h"
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"


/*
 *
 * IMPORTANT
 *
 * See the ccDrepecated.m file to see the name of the new methods
 *
 */

// ccTypes.h
enum {
	kCCResolutionStandard DEPRECATED_ATTRIBUTE	= kCCResolutioniPhone,
	kCCResolutionRetinaDisplay DEPRECATED_ATTRIBUTE = kCCResolutioniPhoneRetinaDisplay,
	kCCMenuTouchPriority DEPRECATED_ATTRIBUTE	= kCCMenuHandlerPriority,
};

// CCRenderTexture.h
enum {
	kCCImageFormatJPG DEPRECATED_ATTRIBUTE = kCCImageFormatJPEG,
	kCCImageFormatRawData UNAVAILABLE_ATTRIBUTE,
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
// new: [director scheduler]
+(CCScheduler*) sharedScheduler DEPRECATED_ATTRIBUTE;
@end

@interface CCActionManager (Deprecated)
// new: [director actionManager]
+(CCActionManager*) sharedManager DEPRECATED_ATTRIBUTE;
@end

#if __CC_PLATFORM_IOS
@interface CCTouchDispatcher (Deprecated)
// new: [director touchDispatcher]
+(CCTouchDispatcher*) sharedDispatcher DEPRECATED_ATTRIBUTE;
@end
#elif __CC_PLATFORM_MAC
@interface CCEventDispatcher (Deprecated)
// new: [director eventDispatcher]
+(CCEventDispatcher*) sharedDispatcher DEPRECATED_ATTRIBUTE;
@end
#endif // __CC_PLATFORM_MAC

@interface CCDirector (Deprecated)
// new: setView:
-(void) setOpenGLView:(CCGLView*)view DEPRECATED_ATTRIBUTE;
// new: view
-(CCGLView*) openGLView DEPRECATED_ATTRIBUTE;
// new: setDisplayStats:
-(void) setDisplayFPS:(BOOL)display DEPRECATED_ATTRIBUTE;
@end


@interface CCSprite (Deprecated)
// new: spriteWithTexture:rect:
+(id) spriteWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
// new: initWithTexture:rect:
-(id) initWithBatchNode:(CCSpriteBatchNode*)node rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
// displayFrame
-(CCSpriteFrame*) displayedFrame DEPRECATED_ATTRIBUTE;
@end

@interface CCMenuItemAtlasFont (Deprecated)
// new itemWithStirng:charmapFile:itemWidth:itemHeight:startCharMap
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap DEPRECATED_ATTRIBUTE;
// new itemWithStirng:charmapFile:itemWidth:itemHeight:startCharMap:target:selector
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb DEPRECATED_ATTRIBUTE;
// new itemWithStirng:charmapFile:itemWidth:itemHeight:startCharMap:block
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
// new initWithStirng:charmapFile:itemWidth:itemHeight:startCharMap:target:selector
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb DEPRECATED_ATTRIBUTE;
// new initWithStirng:charmapFile:itemWidth:itemHeight:startCharMap:block
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
@end


@interface CCMenuItemFont (Deprecated)
// new: itemWithString:
+(id) itemFromString: (NSString*) value DEPRECATED_ATTRIBUTE;
// new: itemWithString:target:selector
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
// new: itemWithString:block:
+(id) itemFromString: (NSString*) value block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
// new: initWithString:target:selector
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
// new: initWithString:block:
-(id) initFromString: (NSString*) value block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
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
// new: itemWithNormalImage:selectedImage:
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 DEPRECATED_ATTRIBUTE;
// new: itemWithNormalImage:selectedImage:target:selector
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
// new: itemWithNormalImage:selectedImage:disabledImage:target:selector
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
// new: itemWithNormalImage:selectedImage:block
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
// new: itemWithNormalImage:selectedImage:disabledImage:block
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
// new: initWithNormalImage:selectedImage:disabledImage:target:selector
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s DEPRECATED_ATTRIBUTE;
// new: initWithNormalImage:selectedImage:disabledImage:block
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block DEPRECATED_ATTRIBUTE;
@end

@interface CCAnimation (Deprecated)
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames DEPRECATED_ATTRIBUTE;
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay DEPRECATED_ATTRIBUTE;
-(id) initWithFrames:(NSArray*)arrayOfSpriteFrameNames DEPRECATED_ATTRIBUTE;
-(id) initWithFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay DEPRECATED_ATTRIBUTE;
-(void) addFrame:(CCSpriteFrame*)frame DEPRECATED_ATTRIBUTE;
-(void) addFrameWithFilename:(NSString*)filename DEPRECATED_ATTRIBUTE;
-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
@end

@interface CCAnimate (Deprecated)
// new: actionWithAnimation:
+(id) actionWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: actiontWithAnimation:
+(id) actionWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: initWithAnimation:
-(id) initWithAnimation:(CCAnimation*) a restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: initWithAnimation:
-(id) initWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
@end

@interface CCRenderTexture (Deprecated)
// new: saveToFile:
-(BOOL)saveBuffer:(NSString*)name DEPRECATED_ATTRIBUTE;
// new: saveToFile:format:
-(BOOL)saveBuffer:(NSString*)name format:(int)format DEPRECATED_ATTRIBUTE;
// new: -- not implemented on v2.0
-(NSData*)getUIImageAsDataFromBuffer:(int) format UNAVAILABLE_ATTRIBUTE;
#if __CC_PLATFORM_IOS
// new: getUIImage
-(UIImage *)getUIImageFromBuffer DEPRECATED_ATTRIBUTE;
#endif
@end

#if __CC_PLATFORM_IOS
@interface CCFileUtils (Deprecated)
// new: setiPhoneRetinaDisplaySuffix
+(void) setRetinaDisplaySuffix:(NSString*)suffix DEPRECATED_ATTRIBUTE;
@end
#endif


#endif // CC_ENABLE_DEPRECATED

