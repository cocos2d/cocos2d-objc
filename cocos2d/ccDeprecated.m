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
	[program setUniformsForBuiltins];
}

#pragma mark - Scheduler

@implementation CCScheduler (Deprecated)
+(CCScheduler*) sharedScheduler
{
	return [[CCDirector sharedDirector] scheduler];
}
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused repeat:(uint)repeat delay:(ccTime)delay
{
	[self scheduleSelector:selector forTarget:target interval:interval repeat:repeat delay:delay paused:paused];
}
-(void) unscheduleAllSelectorsForTarget:(id)target
{
	[self unscheduleAllForTarget:target];
}
-(void) unscheduleAllSelectorsWithMinPriority:(NSInteger)minPriority
{
	[self unscheduleAllWithMinPriority:minPriority];
}
-(void) unscheduleAllSelectors
{
	[self unscheduleAll];
}
@end

#pragma mark - ActionManager

@implementation CCActionManager (Deprecated)
+(CCActionManager*) sharedManager
{
	return [[CCDirector sharedDirector] actionManager];
}
@end

#if __CC_PLATFORM_IOS

#pragma mark - TouchDispatcher

@implementation CCTouchDispatcher (Deprecated)
+(CCTouchDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] touchDispatcher];
}
@end
#elif __CC_PLATFORM_MAC

#pragma mark - EventDispatcher

@implementation CCEventDispatcher (Deprecated)
+(CCEventDispatcher*) sharedDispatcher
{
	return [[CCDirector sharedDirector] eventDispatcher];
}
@end
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
	[self setIgnoreAnchorPointForPosition:!value];
}
-(BOOL) isRelativeAnchorPoint
{
	return ! self.ignoreAnchorPointForPosition;
}
@end

#pragma mark - Layer

@implementation CCLayer (Deprecated)
#if __CC_PLATFORM_IOS
-(void) setIsTouchEnabled:(BOOL)enabled
{
	[self setTouchEnabled:enabled];
}
-(void) setIsAccelerometerEnabled:(BOOL)enabled
{
	[self setAccelerometerEnabled:enabled];
}
#elif __CC_PLATFORM_MAC
-(void) setIsTouchEnabled:(BOOL)enabled
{
	[self setTouchEnabled:enabled];
}
-(void) setIsKeyboardEnabled:(BOOL)enabled
{
	[self setKeyboardEnabled:enabled];	
}
-(void) setIsMouseEnabled:(BOOL)enabled
{
	[self setMouseEnabled:enabled];
}
-(NSInteger) mouseDelegatePriority
{
	// new: setKeyboardEnabled:priority:
	NSAssert(NO, @"deprecated method");
	return 0;
}
-(NSInteger) keyboardDelegatePriority
{
	// new: setTouchEnabled:priority:
	NSAssert(NO, @"deprecated method");
	return 0;
}
-(NSInteger) touchDelegatePriority
{
	// new: setTouchEnabled:priority:
	NSAssert(NO, @"deprecated method");
	return 0;
}

#endif // __CC_PLATFORM_IOS
@end


#pragma mark - Sprite

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
	return [self displayFrame];
}
@end

@implementation CCMenuItem (Deprecated)
// new: -(CGRect) activeArea;
-(CGRect) rect
{
	NSAssert(NO, @"Use CCMenuItem # activeArea instead");
	return CGRectZero;
}

-(void) setRect:(CGRect)rect
{
	NSAssert(NO, @"Use CCMenuItem # setActiveArea instead");
}

@end

#pragma mark - MenuItemAtlasFont

@implementation CCMenuItemAtlasFont (Deprecated)
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return [self itemWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap];
}
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	return [self itemWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:rec selector:cb];
}
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block
{
	return  [self itemWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:block];
}
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	return [self initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:rec selector:cb];
}
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block
{
	return [self initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:block];
}
@end

#pragma mark - MenuItemFont

@implementation CCMenuItemFont (Deprecated)
+(id) itemFromString: (NSString*) value
{
	return [self itemWithString:value];
}
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s
{
	return [self itemWithString:value target:r selector:s];
}
+(id) itemFromString: (NSString*) value block:(void(^)(id sender))block
{
	return [self itemWithString:value block:block];
}
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s
{
	return [self initWithString:value target:r selector:s];
}
-(id) initFromString: (NSString*) value block:(void(^)(id sender))block
{
	return [self initWithString:value block:block];
}
@end

#pragma mark - MenuItemSprite

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

#pragma mark - MenuItemImage

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
-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	[self addSpriteFrameWithTexture:texture rect:rect];
}
@end

#pragma mark - Animate

@implementation CCAnimate (Deprecated)
+(id) actionWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [[animation copy] autorelease];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	
	return [[[self alloc] initWithAnimation:anim] autorelease];
}
+(id) actionWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [[animation copy] autorelease];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	anim.delayPerUnit =  duration / animation.frames.count;
	
	return [[[self alloc] initWithAnimation:anim] autorelease];	
}
-(id) initWithAnimation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [[animation copy] autorelease];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	
	return [self initWithAnimation:anim];	
}
-(id) initWithDuration:(ccTime)duration animation:(CCAnimation*)animation restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation *anim = [[animation copy] autorelease];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	anim.delayPerUnit =  duration / animation.frames.count;
	
	return [self initWithAnimation:anim];
}
@end

#pragma mark - Sequence

@implementation CCSequence (Deprecated)
// new: actionWithArray
+(id) actionsWithArray: (NSArray*) actions
{
	return [self actionWithArray:actions];
}
@end

#pragma mark - Spawn

@implementation CCSpawn (Deprecated)
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

+(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType
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
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment];
}
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment lineBreakMode:lineBreakMode];
}
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment];
}
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment lineBreakMode:lineBreakMode];	
}
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vertAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment lineBreakMode:lineBreakMode];
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vertAlignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self labelWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment];
}
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment lineBreakMode:lineBreakMode];
}
@end

#pragma mark - Texture2D

@implementation CCTexture2D (Deprecated)
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return  [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:lineBreakMode ];
}
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop ];
}
@end

#pragma mark - Effects

@implementation CCGridAction (Deprecated)
+(id) actionWithSize:(CGSize)size duration:(ccTime)d
{
	return [self actionWithDuration:d size:size];
}
-(id) initWithSize:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize];
}
@end

@implementation CCWaves3D (Deprecated)
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize waves:wav amplitude:amp];
}
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize waves:wav amplitude:amp];
}
@end

@implementation CCLens3D (Deprecated)
+(id)actionWithPosition:(CGPoint)pos radius:(float)r grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize position:pos radius:r];
}
-(id)initWithPosition:(CGPoint)pos radius:(float)r grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize position:pos radius:r];
}
@end

@implementation CCRipple3D (Deprecated)
+(id)actionWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize position:pos radius:r waves:wav amplitude:amp];
}
-(id)initWithPosition:(CGPoint)pos radius:(float)r waves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize position:pos radius:r waves:wav amplitude:amp];
}
@end

@implementation CCShaky3D (Deprecated)
+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize range:range shakeZ:shakeZ];
}
-(id)initWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize range:range shakeZ:shakeZ];
}
@end

@implementation CCLiquid (Deprecated)
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize waves:wav amplitude:amp];
}
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize waves:wav amplitude:amp];
}
@end

@implementation CCWaves (Deprecated)
+(id)actionWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize waves:wav amplitude:amp horizontal:h vertical:v];
}
-(id)initWithWaves:(int)wav amplitude:(float)amp horizontal:(BOOL)h vertical:(BOOL)v grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize waves:wav amplitude:amp horizontal:h vertical:v];
}
@end

@implementation CCTwirl (Deprecated)
+(id)actionWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize position:pos twirls:t amplitude:amp];
}
-(id)initWithPosition:(CGPoint)pos twirls:(int)t amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize position:pos twirls:t amplitude:amp];
}
@end

@implementation CCShakyTiles3D (Deprecated)
+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize range:range shakeZ:shakeZ];
}
-(id)initWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize range:range shakeZ:shakeZ];
}
@end

@implementation CCShatteredTiles3D  (Deprecated)
+(id)actionWithRange:(int)range shatterZ:(BOOL)shatterZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize	range:range shatterZ:shatterZ];
}
-(id)initWithRange:(int)range shatterZ:(BOOL)shatterZ grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize range:range shatterZ:shatterZ];
}
@end

@implementation CCShuffleTiles (Deprecated)
+(id)actionWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize seed:s];
}
-(id)initWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize seed:s];
}
@end

@implementation CCTurnOffTiles (Deprecated)
+(id)actionWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize seed:s];
}
-(id)initWithSeed:(int)s grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize seed:s];
}
@end

@implementation CCWavesTiles3D  (Deprecated)
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize waves:wav amplitude:amp];
}
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize waves:wav amplitude:amp];
}
@end

@implementation CCJumpTiles3D (Deprecated)
+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self actionWithDuration:d size:gridSize jumps:j amplitude:amp];
}
-(id)initWithJumps:(int)j amplitude:(float)amp grid:(CGSize)gridSize duration:(ccTime)d
{
	return [self initWithDuration:d size:gridSize jumps:j amplitude:amp];
}
@end

@implementation CCSplitRows (Deprecated)
+(id)actionWithRows:(int)rows duration:(ccTime)duration
{
	return [self actionWithDuration:duration rows:rows];
}
-(id)initWithRows:(int)rows duration:(ccTime)duration
{
	return [self initWithDuration:duration rows:rows];
}
@end

@implementation CCSplitCols  (Deprecated)
+(id)actionWithCols:(int)cols duration:(ccTime)duration
{
	return [self actionWithDuration:duration cols:cols];
}
-(id)initWithCols:(int)cols duration:(ccTime)duration
{
	return [self initWithDuration:duration cols:cols];
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
