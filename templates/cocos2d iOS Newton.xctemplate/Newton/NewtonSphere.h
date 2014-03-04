/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Lars Birkemose
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NewtonConstants.h"

// -----------------------------------------------------------------------
// Types of effects applied to the spheres
typedef NS_ENUM(NSInteger, NewtonSphereEffect)
{
    // The sphere reacts to a light source
    NewtonSphereEffectLight,
    // The spheres are on fire
    NewtonSphereEffectFire,
};

// -----------------------------------------------------------------------
// NewtonSphere wraps newton sphere in a single class

@interface NewtonSphere : CCNode

// -----------------------------------------------------------------------

@property (nonatomic, readonly) CCSprite *sphere;
@property (nonatomic, assign) CGPoint lightPos;
@property (nonatomic, assign) NewtonSphereEffect effect;

// -----------------------------------------------------------------------

+ (instancetype)newtonSphereWithLetter:(NSString *)letter;
- (instancetype)initWithLetter:(NSString *)letter;

// -----------------------------------------------------------------------

@end
