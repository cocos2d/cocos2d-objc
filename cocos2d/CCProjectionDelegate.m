/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
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

#import "CCProjectionDelegate.h"

#import <objc/message.h>

#import "CCNode.h"

@implementation CCAbstractProjection {
    @protected
    __weak CCNode *_target;
    
    float _nearZ;
    float _farZ;
}

-(instancetype)initWithTarget:(CCNode *)target
{
    if((self = [super init])){
        _target = target;
    }
    
    return self;
}

@end


@implementation CCOrthoProjection

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    
    // TODO magic numbers
    return GLKMatrix4MakeOrtho(0, w, 0, h, -1024, 1024);
}

@end


@implementation CCCenteredOrthoProjection

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    
    // TODO magic numbers
    return GLKMatrix4MakeOrtho(-w/2, w/2, -h/2, h/2, -1024, 1024);
}

@end


@implementation CCCenteredPerspectiveProjection

-(instancetype)initWithTarget:(CCNode *)target
{
    if((self = [super initWithTarget:target])){
        self.eyeZ = 1.0;
        self.nearZ = 1.0;
        self.farZ = 2.0;
    }
    
    return self;
}

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    float scale = 2.0*_eyeZ/_nearZ;
    
    return GLKMatrix4Multiply(
        GLKMatrix4MakeFrustum(-w/scale, w/scale, -h/scale, h/scale, _nearZ, _farZ),
        GLKMatrix4MakeTranslation(0, 0, -_eyeZ)
    );
}

@end
