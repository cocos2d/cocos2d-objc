/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <CoreGraphics/CoreGraphics.h>
#endif // IPHONE

@class CCSpriteFrame;
@class CCTexture2D;

/** A CCAnimation object is used to perform animations on the CCSprite objects.
 
 The CCAnimation object contains CCSpriteFrame objects, and a possible delay between the frames.
 You can animate a CCAnimation object by using the CCAnimate action. Example:
 
  [sprite runAction:[CCAnimate actionWithAnimation:animation]];
 
 */
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

/** Creates an animation
 @since v0.99.5
 */
+(id) animation;

/** Creates an animation with frames.
 @since v0.99.5
 */
+(id) animationWithFrames:(NSArray*)frames;

/* Creates an animation with frames and a delay between frames.
 @since v0.99.5
 */
+(id) animationWithFrames:(NSArray*)frames delay:(float)delay;

/** Initializes a CCAnimation with frames.
 @since v0.99.5
*/
-(id) initWithFrames:(NSArray*)frames;

/** Initializes a CCAnimation with frames and a delay between frames
 @since v0.99.5
 */
-(id) initWithFrames:(NSArray *)frames delay:(float)delay;

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
