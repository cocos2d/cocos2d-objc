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
#import "CCDirector.h"
#import "CCSprite.h"
#import "CCParticleSystemQuad.h"
#import "CCGLProgram.h"
#import "CCAnimation.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "CCActionInterval.h"
#import "CCRenderTexture.h"
#import "CCSpriteFrameCache.h"
#import "CCLabelTTF.h"
#import "CCTexture.h"
#import "Support/CCFileUtils.h"
#import "Platforms/Mac/CCDirectorMac.h"
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

#define ccGridSize CGSize
#define ccg CGSizeMake

// ccTypes.h
#ifdef __CC_PLATFORM_IOS
enum {
	kCCResolutionStandard DEPRECATED_ATTRIBUTE	= CCResolutionTypeiPhone,
	kCCResolutionRetinaDisplay DEPRECATED_ATTRIBUTE = CCResolutionTypeiPhoneRetinaDisplay,
};
#endif // __CC_PLATFORM_IOS

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
@end

@interface CCActionManager (Deprecated)
// new: [director actionManager]
+(CCActionManager*) sharedManager DEPRECATED_ATTRIBUTE;
@end

#if __CC_PLATFORM_IOS

#elif __CC_PLATFORM_MAC

#endif // __CC_PLATFORM_MAC

@interface CCDirector (Deprecated)
// new: [director isPaused]
-(BOOL) getIsPaused DEPRECATED_ATTRIBUTE;
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
- (void) setIgnoreAnchorPointForPosition:(BOOL)value DEPRECATED_ATTRIBUTE;
- (BOOL) ignoreAnchorPointForPosition:(BOOL)value DEPRECATED_ATTRIBUTE;
@end

@interface CCSprite (Deprecated)
// new: spriteFrame
-(CCSpriteFrame*) displayedFrame DEPRECATED_ATTRIBUTE;
// new: spriteFrame
- (CCSpriteFrame*) displayFrame DEPRECATED_ATTRIBUTE;
// new: spriteFrame
- (void) setDisplayFrame:(CCSpriteFrame *)newFrame DEPRECATED_ATTRIBUTE;
// don't use
-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame DEPRECATED_ATTRIBUTE;
@end

@interface CCParticleSystemQuad (Deprecated)
@end

@interface CCAnimation (Deprecated)
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames DEPRECATED_ATTRIBUTE;
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay DEPRECATED_ATTRIBUTE;
-(id) initWithFrames:(NSArray*)arrayOfSpriteFrameNames DEPRECATED_ATTRIBUTE;
-(id) initWithFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay DEPRECATED_ATTRIBUTE;
-(void) addFrame:(CCSpriteFrame*)frame DEPRECATED_ATTRIBUTE;
-(void) addFrameWithFilename:(NSString*)filename DEPRECATED_ATTRIBUTE;
-(void) addFrameWithTexture:(CCTexture*)texture rect:(CGRect)rect DEPRECATED_ATTRIBUTE;
@end

@interface CCActionAnimate (Deprecated)
// new: actionWithAnimation:
+(id) actionWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: actiontWithAnimation:
+(id) actionWithDuration:(CCTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: initWithAnimation:
-(id) initWithAnimation:(CCAnimation*) a restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
// new: initWithAnimation:
-(id) initWithDuration:(CCTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame DEPRECATED_ATTRIBUTE;
@end

@interface CCActionSequence (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions DEPRECATED_ATTRIBUTE;
@end

@interface CCActionSpawn (Deprecated)
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
+(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(CCResolutionType*)resolutionType DEPRECATED_ATTRIBUTE;

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
/*
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
 */
@end

@interface CCTexture (Deprecated)
/*
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size DEPRECATED_ATTRIBUTE;
 */
@end

#endif // CC_ENABLE_DEPRECATED
