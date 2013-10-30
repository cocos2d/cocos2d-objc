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
#import "CCDirector_Private.h"

// Free functions
void ccGLUniformModelViewProjectionMatrix( CCGLProgram* program )
{
	[program setUniformsForBuiltins];
}

#pragma mark - Scheduler

@implementation CCScheduler (Deprecated)
@end

#pragma mark - ActionManager

@implementation CCActionManager (Deprecated)
+(CCActionManager*) sharedManager
{
	return [[CCDirector sharedDirector] actionManager];
}
@end

#if __CC_PLATFORM_IOS

#elif __CC_PLATFORM_MAC

#endif // __CC_PLATFORM_MAC

#pragma mark - Director

@implementation CCDirector (Deprecated)
-(BOOL) getIsPaused
{
	return [self isPaused];
}

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
	return (CCGLView*)__view;
}
@end

#pragma mark - Node
@implementation CCNode (Deprecated)
-(void) setIsRelativeAnchorPoint:(BOOL)value
{
	NSAssert(NO, @"Set anchorPoint to 0, 0 instead of changing this property");
}
-(BOOL) isRelativeAnchorPoint
{
	NSAssert(NO, @"Set anchorPoint to 0, 0 instead of changing this property");
	return YES;
}
- (void) setIgnoreAnchorPointForPosition:(BOOL)value
{
    NSAssert(NO, @"Set anchorPoint to 0, 0 instead of changing this property");
}
- (BOOL) ignoreAnchorPointForPosition:(BOOL)value
{
    NSAssert(NO, @"Set anchorPoint to 0, 0 instead of changing this property");
    return NO;
}
@end

#pragma mark - Sprite

@implementation CCSprite (Deprecated)

-(CCSpriteFrame*) displayedFrame
{
	return [self displayFrame];
}

- (CCSpriteFrame*) displayFrame
{
    return [self spriteFrame];
}

- (void) setDisplayFrame:(CCSpriteFrame *)newFrame
{
    self.spriteFrame = newFrame;
}

-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame
{
    return NO;
}

@end

#pragma mark - Particle syste

@implementation CCParticleSystemQuad (Deprecated)

@end

#pragma mark - Animation

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
-(void) addFrameWithTexture:(CCTexture*)texture rect:(CGRect)rect
{
	[self addSpriteFrameWithTexture:texture rect:rect];
}
@end

#pragma mark - Animate

@implementation CCActionAnimate (Deprecated)
+(id) actionWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [animation copy];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	
	return [[self alloc] initWithAnimation:anim];
}
+(id) actionWithDuration:(CCTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [animation copy];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	anim.delayPerUnit =  duration / animation.frames.count;
	
	return [[self alloc] initWithAnimation:anim];	
}
-(id) initWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [animation copy];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	
	return [self initWithAnimation:anim];	
}
-(id) initWithDuration:(CCTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [animation copy];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	anim.delayPerUnit =  duration / animation.frames.count;
	
	return [self initWithAnimation:anim];
}
@end

#pragma mark - Sequence

@implementation CCActionSequence (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions
{
	return [self actionWithArray:actions];
}
@end

#pragma mark - Spawn

@implementation CCActionSpawn (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions
{
	return [self actionWithArray:actions];
}
@end

#pragma mark - RenderTexture

@implementation CCRenderTexture (Deprecated)
-(BOOL)saveBuffer:(NSString*)name
{
	return [self saveToFile:name];
}
-(BOOL)saveBuffer:(NSString*)name format:(int)format
{
	return [self saveToFile:name format:format];
}

-(NSData*)getUIImageAsDataFromBuffer:(int) format
{
	NSAssert(NO, @"NOT IMPLEMENTED IN V2.0");
	
	return nil;
}
#if __CC_PLATFORM_IOS
-(UIImage *)getUIImageFromBuffer
{
	return [self getUIImage];
}
#endif
@end

#pragma mark - FileUtils

@implementation CCFileUtils (Deprecated)
+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	return [[self sharedFileUtils] fullPathFromRelativePath:relPath];
}

+(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(CCResolutionType*)resolutionType
{
	return [[self sharedFileUtils] fullPathFromRelativePath:relPath resolutionType:resolutionType];
}

#if __CC_PLATFORM_IOS
+(void) setRetinaDisplaySuffix:(NSString*)suffix
{
	return [[self sharedFileUtils] setiPhoneRetinaDisplaySuffix:suffix];
}
+(NSString *)removeSuffixFromFile:(NSString*) path
{
	return [[self sharedFileUtils] removeSuffixFromFile:path];
}
+(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)filename
{
	return [[self sharedFileUtils] iPhoneRetinaDisplayFileExistsAtPath:filename];
}
+(BOOL) iPadFileExistsAtPath:(NSString*)filename
{
	return [[self sharedFileUtils] iPadFileExistsAtPath:filename];
}
+(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)filename
{
	return [[self sharedFileUtils] iPadRetinaDisplayFileExistsAtPath:filename];
}
#endif
@end

#pragma mark - SpriteFrameCache

@implementation CCSpriteFrameCache (Deprecated)
-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureFile:(NSString*)filename
{
	NSAssert(NO, @"unimplemented. Use addSpriteFramesWithFile:textureFile: instead");
//	[self addSpriteFramesWithDictionary:dictionary textureFilename:filename];
}

-(void) addSpriteFramesWithFile:(NSString*)plist textureFile:(NSString*)filename
{
	[self addSpriteFramesWithFile:plist textureFilename:filename];
}
@end

#pragma mark - LabelTTF

@implementation CCLabelTTF (Deprecated)

@end

#pragma mark - Texture2D

@implementation CCTexture (Deprecated)

@end

#pragma mark - Effects

#if __CC_PLATFORM_IOS
@implementation EAGLView
@end

#elif __CC_PLATFORM_MAC

@implementation MacView
@end

#endif // __CC_PLATFORM_MAC

#endif // CC_ENABLE_DEPRECATED
