/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "CCSprite.h"

@interface CCSprite ()

// Whether or not the Sprite needs to be updated in the Atlas.
@property (nonatomic,readwrite) BOOL dirty;

// The quad (tex coords, vertex coords and color) information.
@property (nonatomic,readonly) ccV3F_C4B_T2F_Quad quad;

// The index used on the TextureAtlas. Don't modify this value unless you know what you are doing.
@property (nonatomic,readwrite) NSUInteger atlasIndex;

// Weak reference of the CCTextureAtlas used when the sprite is rendered using a CCSpriteBatchNode.
@property (nonatomic,readwrite,unsafe_unretained) CCTextureAtlas *textureAtlas;

// Weak reference to the CCSpriteBatchNode that renders the CCSprite.
@property (nonatomic,readwrite,unsafe_unretained) CCSpriteBatchNode *batchNode;

#pragma mark CCSprite - BatchNode

// Updates the quad according the the rotation, position, scale values.
-(void) updateTransform;

/* 
 Set the vertex rect. It will be called internally by setTextureRect.
 Useful if you want to create 2x images from SD images in Retina Display.  
 Do not call it manually. Use setTextureRect instead.
*/
-(void) setVertexRect:(CGRect)rect;

#pragma mark CCSprite - Animation

/* 
 Changes the display frame with animation name and index. 
 The animation name will be retried from the CCAnimationCache.
*/
-(void) setSpriteFrameWithAnimationName:(NSString*)animationName index:(int) frameIndex;

@end
