/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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
 */

#import "CCLayout.h"
#import "CCNode_Private.h"

@implementation CCLayout

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    [self needsLayout];
    
    return self;
}

- (void) needsLayout
{
    _needsLayout = YES;
}

- (void) layout
{
    _needsLayout = NO;
}

- (CGSize)contentSize
{
    if (_needsLayout) [self layout];
    return super.contentSize;
}

- (void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    if (_needsLayout)
    {
        [self layout];
    }
    
    [super visit:renderer parentTransform:parentTransform];
}

- (void) addChild:(CCNode *)node z:(NSInteger)z name:(NSString*)name
{
    [super addChild:node z:z name:name];
    [self sortAllChildren];
    [self layout];
}

@end
