/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 *
 */

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCProtocols.h"

#pragma mark -
#pragma mark CCSpriteFrame

/** A CCSpriteFrame has:
	- texture: A CCTexture2D that will be used by the CCSprite
	- rectangle: A rectangle of the texture


 You can modify the frame of a CCSprite by doing:
 
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect offset:offset];
	[sprite setDisplayFrame:frame];
 */
@interface CCSpriteFrame : NSObject <NSCopying>
{
	CGRect			rect_;
	CGPoint			offset_;
	CGSize			originalSize_;
	CCTexture2D		*texture_;
}
/** rect of the frame */
@property (nonatomic,readwrite) CGRect rect;

/** offset of the frame */
@property (nonatomic,readwrite) CGPoint offset;

/** original size of the trimmed image */
@property (nonatomic,readwrite) CGSize originalSize;

/** texture of the frame */
@property (nonatomic, retain, readwrite) CCTexture2D *texture;

/** Create a CCSpriteFrame with a texture, rect and offset.
 It is assumed that the frame was not trimmed.
 */
+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

/** Create a CCSpriteFrame with a texture, rect, offset and originalSize.
 The originalSize is the size in pixels of the frame before being trimmed.
 */
+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset originalSize:(CGSize)originalSize;

/** Initializes a CCSpriteFrame with a texture, rect and offset.
 It is assumed that the frame was not trimmed.
 */
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

/** Initializes a CCSpriteFrame with a texture, rect, offset and originalSize.
 The originalSize is the size in pixels of the frame before being trimmed.
 */
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset originalSize:(CGSize)originalSize;
@end

#pragma mark -
#pragma mark CCAnimation

/** an Animation object used within Sprites to perform animations */
@interface CCAnimation : NSObject
{
	NSString			*name_;
	float				delay_;
	NSMutableArray		*frames_;
}

/** name of the animation */
@property (nonatomic,readwrite,retain) NSString *name;
/** delay between frames in seconds. */
@property (nonatomic,readwrite,assign) float delay;
/** array of frames */
@property (nonatomic,readwrite,retain) NSMutableArray *frames;

/** Creates a CCAnimation with a name
 @since v0.99.3
 */
+(id) animationWithName:(NSString*)name;

/** Creates a CCAnimation with a name and frames
 @since v0.99.3
 */
+(id) animationWithName:(NSString*)name frames:(NSArray*)frames;

/** Creates a CCAnimation with a name and delay between frames. */
+(id) animationWithName:(NSString*)name delay:(float)delay;

/** Creates a CCAnimation with a name, delay and an array of CCSpriteFrames. */
+(id) animationWithName:(NSString*)name delay:(float)delay frames:(NSArray*)frames;

/** Initializes a CCAnimation with a name
 @since v0.99.3
 */
-(id) initWithName:(NSString*)name;

/** Initializes a CCAnimation with a name and frames
 @since v0.99.3
 */
-(id) initWithName:(NSString*)name frames:(NSArray*)frames;

/** Initializes a CCAnimation with a name and delay between frames. */
-(id) initWithName:(NSString*)name delay:(float)delay;

/** Initializes a CCAnimation with a name, delay and an array of CCSpriteFrames. */
-(id) initWithName:(NSString*)name delay:(float)delay frames:(NSArray*)frames;

/** Adds a frame to a CCAnimation. */
-(void) addFrame:(CCSpriteFrame*)frame;

/** Adds a frame with an image filename. Internally it will create a CCSpriteFrame and it will add it.
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addFrameWithFilename:(NSString*)filename;

/** Adds a frame with a texture and a rect. Internally it will create a CCSpriteFrame and it will add it.
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
@end
