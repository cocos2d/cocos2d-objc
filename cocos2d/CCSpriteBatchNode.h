/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#import "CCNode.h"

@class CCTexture;
@class CCSprite;

/**
 A CCSpriteBatchNode offers improved rendering performance for multiple sprite rendering by utilising a single OpenGL call to render 
 all of its child sprites from one texture. This is called batch drawing.
 
 ### Requirements
 
 - Only CCSprite or CCSprite subclass instances can be added to the CCSpriteBatchNode
 - All sprites added must use the same CCTexture object
 
 Failing to meet these requirements will result in a runtime error.
 
 */
__attribute__((deprecated))
@interface CCSpriteBatchNode : CCNode<CCTextureProtocol, CCBlendProtocol>


/// -----------------------------------------------------------------------
/// @name Creating a Sprite Batch Node
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a batch node with the specified texture value.
 *
 *  @param tex Texture to use.
 *
 *  @return The CCSpriteBatchNode Object.
 *  @see CCTexture
 */
+(instancetype)batchNodeWithTexture:(CCTexture *)tex;

/**
 *  Creates and returns a batch node with the specified image file value.
 *
 *  @param fileImage Image file name.
 *
 *  @return The CCSpriteBatchNode Object.
 */
+(instancetype)batchNodeWithFile:(NSString*) fileImage;

/**
 *  Creates and returns a batch node with the specified texture and capacity values.
 *
 *  @param tex      Texture to use.
 *  @param capacity Initial capacity.
 *
 *  @return An initialized CCSpriteBatchNode Object.
 *  @see CCTexture
 */
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity;

/**
 *  Creates and returns a batch node with the specified texture and capacity values.
 *
 *  @param fileImage    Image file name.
 *  @param capacity Initial capacity.
 *
 *  @return An initialized CCSpriteBatchNode Object.
 */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

@end
