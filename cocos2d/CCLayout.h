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

#import "CCNode.h"

/**
 The layout node is an abstract class. It will take control of its childrens' positions. 
 
 Do not create instances of CCLayout, instead use one of its subclasses:
 
 - CCLayoutBox
 
 **Note:** If you are using a layout node you should not set the positions of the layout node's children manually or via move actions.
 
 ### Subclassing Note
 
 CCLayout is an abstract class for nodes that provide layouts. You should subclass CCLayout to create your own layout node.
 Implement the layout method to create your own layout.
 */
@interface CCLayout : CCNode {
    BOOL _needsLayout;
}

/** @name Methods Implemented by Subclasses */

/**
 *  Called whenever the node needs to layout its children again. Normally, there is no need to call this method directly.
 */
- (void) needsLayout;

/**
 The layout method layouts the children according to the rules implemented in a CCLayout subclass.
 @note Your subclass must call `[super layout]` to reset the _needsLayout flag. Not calling super could cause the layout
 to unnecessarily run the layout method every frame.
 */
- (void) layout __attribute__((objc_requires_super));

@end
