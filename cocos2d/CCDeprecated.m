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
 */


#import "CCDeprecated.h"


@implementation CCColor(Deprecated)

+ (CCColor*) colorWithCcColor3b:(ccColor3B)c
{
    return [[CCColor alloc] initWithCcColor3b:c];
}

+ (CCColor*) colorWithCcColor4b:(ccColor4B)c
{
    return [[CCColor alloc] initWithCcColor4b:c];
}

+ (CCColor*) colorWithCcColor4f:(ccColor4F)c
{
    return [[CCColor alloc] initWithCcColor4f:c];
}

- (CCColor*) initWithCcColor3b: (ccColor3B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

- (CCColor*) initWithCcColor4b: (ccColor4B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:c.a/255.0];
}

- (CCColor*) initWithCcColor4f: (ccColor4F) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (ccColor3B) ccColor3b
{
    GLKVector4 vec4 = self.glkVector4;
    return (ccColor3B){(uint8_t)(vec4.r*255), (uint8_t)(vec4.g*255), (uint8_t)(vec4.b*255)};
}

- (ccColor4B) ccColor4b
{
    GLKVector4 vec4 = self.glkVector4;
    return (ccColor4B){(uint8_t)(vec4.r*255), (uint8_t)(vec4.g*255), (uint8_t)(vec4.b*255), (uint8_t)(vec4.a*255)};
}

- (ccColor4F) ccColor4f
{
    GLKVector4 vec4 = self.glkVector4;
    return ccc4f(vec4.r, vec4.g, vec4.b, vec4.a);
}

@end


@implementation CCNode(Deprecated)

static CGAffineTransform
CGAffineTransformFromGLKMatrix4(GLKMatrix4 m)
{
    return CGAffineTransformMake(m.m[0], m.m[1], m.m[4], m.m[5], m.m[12], m.m[13]);
}

- (CGAffineTransform)nodeToParentTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.nodeToParentMatrix);
}

- (CGAffineTransform)parentToNodeTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.parentToNodeMatrix);
}

- (CGAffineTransform)nodeToWorldTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.nodeToWorldMatrix);
}

- (CGAffineTransform)worldToNodeTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.worldToNodeMatrix);
}

-(BOOL)isRunningInActiveScene
{
    return self.active;
}

@end
