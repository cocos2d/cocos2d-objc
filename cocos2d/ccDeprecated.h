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

#import "ccTypes.h"
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
#import "CCSpriteFrameCache.h"
#import "CCLabelTTF.h"
#import "CCTexture2D.h"
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

// CCLOGERROR is no longer supported.
#define CCLOGERROR CCLOGWARN

// ccTypes.h
enum {
#ifdef __CC_PLATFORM_IOS
	kCCResolutionStandard DEPRECATED_ATTRIBUTE	= kCCResolutioniPhone,
	kCCResolutionRetinaDisplay DEPRECATED_ATTRIBUTE = kCCResolutioniPhoneRetinaDisplay,
#endif // __CC_PLATFORM_IOS
	kCCMenuTouchPriority DEPRECATED_ATTRIBUTE	= kCCMenuHandlerPriority,
};

// CCRenderTexture.h
enum {
	kCCImageFormatJPG DEPRECATED_ATTRIBUTE = kCCImageFormatJPEG,
	kCCImageFormatRawData UNAVAILABLE_ATTRIBUTE,
};

enum {
	CCTextAlignmentLeft DEPRECATED_ATTRIBUTE = kCCTextAlignmentLeft,
	CCTextAlignmentCenter DEPRECATED_ATTRIBUTE = kCCTextAlignmentCenter,
	CCTextAlignmentRight DEPRECATED_ATTRIBUTE = kCCTextAlignmentRight,

	CCVerticalTextAlignmentTop DEPRECATED_ATTRIBUTE = kCCVerticalTextAlignmentTop,
	CCVerticalTextAlignmentMiddle DEPRECATED_ATTRIBUTE = kCCVerticalTextAlignmentCenter,
	CCVerticalTextAlignmentBottom DEPRECATED_ATTRIBUTE = kCCVerticalTextAlignmentBottom,

	CCLineBreakModeWordWrap DEPRECATED_ATTRIBUTE = kCCLineBreakModeWordWrap,
	CCLineBreakModeCharacterWrap DEPRECATED_ATTRIBUTE = kCCLineBreakModeCharacterWrap,
	CCLineBreakModeClip	DEPRECATED_ATTRIBUTE = kCCLineBreakModeClip,
	CCLineBreakModeHeadTruncation DEPRECATED_ATTRIBUTE = kCCLineBreakModeHeadTruncation,
	CCLineBreakModeTailTruncation DEPRECATED_ATTRIBUTE = kCCLineBreakModeTailTruncation,
	CCLineBreakModeMiddleTruncation DEPRECATED_ATTRIBUTE = kCCLineBreakModeMiddleTruncation,
};

//DEPRECATED_ATTRIBUTE typedef  ccTextAlignment CCTextAlignment;
//
//DEPRECATED_ATTRIBUTE typedef  ccVerticalTextAlignment CCVerticalTextAlignment;

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
// new: -(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval repeat: (uint) repeat delay: (ccTime) delay paused:(BOOL)paused;
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused repeat:(uint)repeat delay:(ccTime)delay DEPRECATED_ATTRIBUTE;
// new: unscheduleAllForTarget
-(void) unscheduleAllSelectorsForTarget:(id)target DEPRECATED_ATTRIBUTE;
// new: unscheduleAll
-(void) unscheduleAllSelectors DEPRECATED_ATTRIBUTE;
// new: unscheduleAllWithMinPriority:
-(void) unscheduleAllSelectorsWithMinPriority:(NSInteger)minPriority DEPRECATED_ATTRIBUTE;
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

@interface CCNode (Deprecated)
-(void) setIsRelativeAnchorPoint:(BOOL)value DEPRECATED_ATTRIBUTE;
-(BOOL) isRelativeAnchorPoint DEPRECATED_ATTRIBUTE;
@end

@interface CCLayer (Deprecated)
#if __CC_PLATFORM_IOS
// new: setTouchEnabled:
-(void) setIsTouchEnabled:(BOOL)enabled DEPRECATED_ATTRIBUTE;
// new: setAccelerometerEnabled:
-(void) setIsAccelerometerEnabled:(BOOL)enabled DEPRECATED_ATTRIBUTE;
#elif __CC_PLATFORM_MAC
-(void) setIsTouchEnabled:(BOOL)enabled DEPRECATED_ATTRIBUTE;
-(void) setIsKeyboardEnabled:(BOOL)enabled DEPRECATED_ATTRIBUTE;
-(void) setIsMouseEnabled:(BOOL)enabled DEPRECATED_ATTRIBUTE;
// new: setMouseEnabled:priority:
-(NSInteger) mouseDelegatePriority DEPRECATED_ATTRIBUTE;
// new: setKeyboardEnabled:priority:
-(NSInteger) keyboardDelegatePriority DEPRECATED_ATTRIBUTE;
// new: setTouchEnabled:priority:
-(NSInteger) touchDelegatePriority DEPRECATED_ATTRIBUTE;
#endif // __CC_PLATFORM_MAC
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

@interface CCSequence (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions DEPRECATED_ATTRIBUTE;
@end

@interface CCSpawn (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions DEPRECATED_ATTRIBUTE;
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

@interface CCFileUtils (Deprecated)

// new: -(NSString*) fullPathFromRelativePath:  (instance method, not class method)
+(NSString*) fullPathFromRelativePath:(NSString*) relPath DEPRECATED_ATTRIBUTE;
// new: -(NSString*) fullPathFromRelativePath:resolutionType  (instance method, not class method)
+(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType DEPRECATED_ATTRIBUTE;

#ifdef __CC_PLATFORM_IOS
// new: -(NSString*) removeSuffixFromFile:  (instance method, not class method)
+(NSString *)removeSuffixFromFile:(NSString*) path DEPRECATED_ATTRIBUTE;
// new: -(BOOL) iPhoneRetinaDisplayFileExistsAtPath: (instance method, not class method)
+(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)filename DEPRECATED_ATTRIBUTE;
// new: -(BOOL) iPadFileExistsAtPath: (instance method, not class method)
+(BOOL) iPadFileExistsAtPath:(NSString*)filename DEPRECATED_ATTRIBUTE;
// new: -(BOOL) iPadRetinaDisplayFileExistsAtPath: (instance method, not class method)
+(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)filename DEPRECATED_ATTRIBUTE;
// new: -(void) setiPhoneRetinaDisplaySuffix: (instance method, not class method)
+(void) setRetinaDisplaySuffix:(NSString*)suffix DEPRECATED_ATTRIBUTE;
#endif  //__CC_PLATFORM_IOS
@end


@interface CCSpriteFrameCache (Deprecated)
-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureFile:(NSString*)filename DEPRECATED_ATTRIBUTE;
-(void) addSpriteFramesWithFile:(NSString*)plist textureFile:(NSString*)filename DEPRECATED_ATTRIBUTE;
@end


@interface CCLabelTTF (Deprecated)
// new: + (id) labelWithString:(NSString*)string dimensions:hAlignment:fontName:fontSize:
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
// new: + (id) labelWithString:(NSString*)string dimensions:hAlignment:lineBreakMode:fontName:fontSize:
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vertAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vertAlignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;

// new: + (id) initWithString:(NSString*)string dimensions:hAlignment:fontName:fontSize:
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
// new: + (id) initWithString:(NSString*)string dimensions:hAlignment:lineBreakMode:fontName:fontSize:
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
@end

@interface CCTexture2D (Deprecated)
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
@end

#endif // CC_ENABLE_DEPRECATED

