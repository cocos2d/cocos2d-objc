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


#import "CCSpriteBatchNode.h"
#import "CCTexture.h"
#import "CCTextureCache.h"
#import "CCNode_Private.h"

@implementation CCSpriteBatchNode {
}

+(id)batchNodeWithTexture:(CCTexture *)tex
{
	return [[self alloc] initWithTexture:tex capacity:0];
}

+(id)batchNodeWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity
{
	return [[self alloc] initWithTexture:tex capacity:capacity];
}

+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[self alloc] initWithFile:fileImage capacity:capacity];
}

+(id)batchNodeWithFile:(NSString*) imageFile
{
	return [[self alloc] initWithFile:imageFile capacity:0];
}

-(id)init
{
    return [self initWithTexture:[[CCTexture alloc] init] capacity:0];
}

-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	CCTexture *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity];
}

// Designated initializer
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		self.texture = tex;
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %@>", [self class], self, _name ];
}

@end
