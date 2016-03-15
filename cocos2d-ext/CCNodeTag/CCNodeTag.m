/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 */

#import "CCNodeTag.h"
#import <objc/runtime.h>

//----------------------------------------------------------------------

static void *nodeTagKey = &nodeTagKey;

//----------------------------------------------------------------------

@implementation CCNode (CCNodeTag)

//----------------------------------------------------------------------

- (void)addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag
{
    node.tag = tag;
    [self addChild:node z:z];
}

//----------------------------------------------------------------------

- (void)removeChildByTag:(NSInteger)tag
{
    CCNode *node = [self getChildByTag:tag];
    if (!node)
        ;
    else
        [self removeChild:node];
}

//----------------------------------------------------------------------

- (void)removeChildByTag:(NSInteger)tag cleanup:(BOOL)cleanup
{
    CCNode *node = [self getChildByTag:tag];
    if (!node)
        ;
    else
        [self removeChild:node cleanup:cleanup];
}

//----------------------------------------------------------------------

- (CCNode *)getChildByTag:(NSInteger)tag
{
    /*
    for (CCNode *node in self.children)
    {
        if (node.tag == tag) return(node);
    }
    return(nil);
     */
    return [self getChildByTag:tag recursively:NO];
}

// Recursively get a child by tag, but don't return the root of the search.
-(CCNode*) getChildByTagRecursive:(NSInteger)tag root:(CCNode *)root
{
    if(self != root && self.tag == tag) return self;
    
    for (CCNode* node in _children) {
        CCNode *n = [node getChildByTagRecursive:tag root:root];
        if(n) return n;
    }
    // not found
    return nil;
}

- (CCNode *)getChildByTag:(NSInteger)tag recursively:(bool)isRecursive {
    NSAssert(tag, @"tag is nil.");
    
    if(isRecursive){
        return [self getChildByTagRecursive:tag root:self];
    } else {
        for (CCNode* node in _children) {
            if(node.tag == tag){
                return node;
            }
        }
    }
    // not found
    return nil;
}


//----------------------------------------------------------------------
// tag property implementation

// OBS!
// As long as tag hasn't been set, the associated object will be nil, and intergetValue will return 0 (zero), which is well defined behaviour

- (NSInteger)tag
{
    NSNumber *number = objc_getAssociatedObject(self, nodeTagKey);
    return([number integerValue]);
}

- (void)setTag:(NSInteger)tag
{
    objc_setAssociatedObject(self, nodeTagKey, [NSNumber numberWithInteger:tag], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//----------------------------------------------------------------------

@end
