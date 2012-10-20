/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Pierre-David Bélanger
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

#import "CCClippingNode.h"

#import "CCGL.h"

#import "CCGLProgram.h"
#import "CCShaderCache.h"

#import "kazmath/GL/matrix.h"

static GLint _stencilBits = -1;

@implementation CCClippingNode

@synthesize stencil = stencil_;
@synthesize alphaThreshold = alphaThreshold_;
@synthesize inverted = inverted_;

- (void)dealloc
{
    [stencil_ release];
    [super dealloc];
}

+ (id)clippingNode
{
    return [self node];
}

+ (id)clippingNodeWithStencil:(CCNode *)stencil
{
    return [[[self alloc] initWithStencil:stencil] autorelease];
}

- (id)init
{
    return [self initWithStencil:nil];
}

- (id)initWithStencil:(CCNode *)stencil
{
    if (self = [super init]) {
        self.stencil = stencil;
        self.alphaThreshold = 0.05;
        self.inverted = NO;
        // get (only once) the number of bits of the stencil buffer
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            glGetIntegerv(GL_STENCIL_BITS, &_stencilBits);
            // warn if the stencil buffer is not enabled
            if (_stencilBits <= 0) {
#if defined(__CC_PLATFORM_IOS)
                CCLOGWARN(@"Stencil buffer is not enabled; enable it by passing GL_DEPTH24_STENCIL8_OES into the depthFormat parrameter when initializing CCGLView. Until then, everything will be drawn without stencil.");
#elif defined(__CC_PLATFORM_MAC)
                CCLOGWARN(@"Stencil buffer is not enabled; enable it by setting the Stencil attribue to 8 bit in the Attributes inspector of the CCGLView view object in MainMenu.xib, or programmatically by adding NSOpenGLPFAStencilSize and 8 in the NSOpenGLPixelFormatAttribute array of the NSOpenGLPixelFormat used when initializing CCGLView. Until then, everything will be drawn without stencil.");
#endif
            }
        });
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    [stencil_ onEnter];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [stencil_ onEnterTransitionDidFinish];
}

- (void)onExitTransitionDidStart
{
    [stencil_ onExitTransitionDidStart];
    [super onExitTransitionDidStart];
}

- (void)onExit
{
    [stencil_ onExit];
    [super onExit];
}

- (void)visit
{
    // if stencil buffer disabled
    if (_stencilBits < 1) {
        // draw everything, as if there where no stencil
        [super visit];
        return;
    }
    
    // return fast (draw nothing, or draw everything if in inverted mode) if:
    // - nil stencil node
    // - or stencil node invisible:
    if (!stencil_ || !stencil_.visible) {
        if (inverted_) {
            // draw everything
            [super visit];
        }
        return;
    }

    // store the current stencil layer (position in the stencil buffer),
    // this will allow nesting up to n CCClippingNode,
    // where n is the number of bits of the stencil buffer.
    static GLint layer = -1;
    
    // all the _stencilBits are in use?
    if (layer + 1 == _stencilBits) {
        // warn once
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            CCLOGWARN(@"Nesting more than %d stencils is not supported. Everything will be drawn without stencil for this node and its childs.", _stencilBits);
        });
        // draw everything, as if there where no stencil
        [super visit];
        return;
    }
    
    ///////////////////////////////////
    // INIT

    // all 0 mask
    static GLuint mask_zeros = 0;
    // all 1 mask
    static GLuint mask_ones = ~0;
    
    // increment the current layer
    layer++;
    
    // mask of the current layer (ie: for layer 3: 00000100)
    GLint mask_layer = 0x1 << layer;
    // mask of all layers less than the current (ie: for layer 3: 00000011)
    GLint mask_layer_l = mask_layer - 1;
    // mask of all layers less than or equal to the current (ie: for layer 3: 00000111)
    GLint mask_layer_le = mask_layer | mask_layer_l;
    
#if defined(__CC_PLATFORM_IOS)
    // manually save the stencil state
    GLboolean currentStencilEnabled = GL_FALSE;
    GLuint currentStencilWriteMask = mask_ones;
    GLenum currentStencilFunc = GL_ALWAYS;
    GLint currentStencilRef = 0;
    GLuint currentStencilValueMask = mask_ones;
    GLenum currentStencilFail = GL_KEEP;
    GLenum currentStencilPassDepthFail = GL_KEEP;
    GLenum currentStencilPassDepthPass = GL_KEEP;
    currentStencilEnabled = glIsEnabled(GL_STENCIL_TEST);
    glGetIntegerv(GL_STENCIL_WRITEMASK, (GLint *)&currentStencilWriteMask);
    glGetIntegerv(GL_STENCIL_FUNC, (GLint *)&currentStencilFunc);
    glGetIntegerv(GL_STENCIL_REF, &currentStencilRef);
    glGetIntegerv(GL_STENCIL_VALUE_MASK, (GLint *)&currentStencilValueMask);
    glGetIntegerv(GL_STENCIL_FAIL, (GLint *)&currentStencilFail);
    glGetIntegerv(GL_STENCIL_PASS_DEPTH_FAIL, (GLint *)&currentStencilPassDepthFail);
    glGetIntegerv(GL_STENCIL_PASS_DEPTH_PASS, (GLint *)&currentStencilPassDepthPass);
#elif defined(__CC_PLATFORM_MAC)
    // save the enable state
    glPushAttrib(GL_ENABLE_BIT);
    // save the stencil state
    glPushAttrib(GL_STENCIL_BUFFER_BIT);
#endif
    
    // enable stencil use
    glEnable(GL_STENCIL_TEST);
    
    // all bits on the stencil buffer are readonly, except the current layer bit,
    // this means that operation like glClear or glStencilOp will be masked with this value
    glStencilMask(mask_layer);
    
    // value to use when clearing the stencil buffer
    // all 0, or all 1 if in inverted mode
    glClearStencil(!inverted_ ? mask_zeros : mask_ones);
    
    // clear the stencil buffer
    glClear(GL_STENCIL_BUFFER_BIT);
    
    ///////////////////////////////////
    // DRAW CLIPPING STENCIL

    // setup the stencil test func like this:
    // for each pixel in the stencil node
    //     if all layer values less than the current are set to 1 in the stencil buffer
    //         if not in inverted mode: set the current layer value to 1 in the stencil buffer
    //         if in inverted mode: set the current layer value to 0 in the stencil buffer
    //     else
    //         keep the current layer value in the stencil buffer
    glStencilFunc(GL_EQUAL, mask_layer_le, mask_layer_l);
    glStencilOp(GL_KEEP, GL_KEEP, !inverted_ ? GL_REPLACE : GL_ZERO);
    
    // setup the alpha test if needed
#if defined(__CC_PLATFORM_IOS)
    CCGLProgram *currentProgram = nil;
#endif
    
    // enable alpha test only if the alpha threshold < 1,
    // indeed if alpha threshold == 1, every pixel will be drawn anyways
    if (alphaThreshold_ < 1) {
#if defined(__CC_PLATFORM_IOS)
        // since glAlphaTest do not exists in OES, use a shader that writes
        // pixel only if greater than an alpha threshold
        // save the stencil node current shader
        currentProgram = stencil_.shaderProgram;
        // assign the alpha test shader to the stencil
        stencil_.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
        GLint alphaValueLocation = glGetUniformLocation(stencil_.shaderProgram->program_, kCCUniformAlphaTestValue);
        // set our alphaThreshold
        [stencil_.shaderProgram setUniformLocation:alphaValueLocation withF1:alphaThreshold_];
#elif defined(__CC_PLATFORM_MAC)
        // save the color buffer state
        glPushAttrib(GL_COLOR_BUFFER_BIT);
        // enable alpha testing
        glEnable(GL_ALPHA_TEST);
        // pixel will be drawn only if greater than an alpha threshold
        glAlphaFunc(GL_GREATER, alphaThreshold_);
#endif
    }

    // disable drawing colors, only draw the alpha part of the stencil node,
    // we are only interested in the stencil buffer being populated,
    // not the stencil node being visible
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    
    // draw the stencil node as if it was one of our child
    // (according to the stencil test func/op and alpha (or alpha shader) test)
	kmGLPushMatrix();
	[self transform];
    [stencil_ visit];
    kmGLPopMatrix();
    
    // restore drawing colors
    // XXX: may be this was not the right state before we disabled them,
    // on OSX there is no problem since we will do a glPopAttrib() for the GL_COLOR_BUFFER_BIT,
    // but on iOS it can be problematic, we probably should manually saving/restoring those values
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    // restore alpha test state
    if (alphaThreshold_ < 1) {
#if defined(__CC_PLATFORM_IOS)
        // restore the stencil node current shader if any
        stencil_.shaderProgram = currentProgram;
#elif defined(__CC_PLATFORM_MAC)
        // restore the color buffer state
        glPopAttrib();
#endif
    }
    
    ///////////////////////////////////
    // DRAW CONTENT
    
    // setup the stencil test func like this:
    // for each pixel of this node and its childs
    //     if all layers less than or equals to the current are set to 1 in the stencil buffer
    //         draw the pixel and keep the current layer in the stencil buffer
    //     else
    //         do not draw the pixel but keep the current layer in the stencil buffer
    glStencilFunc(GL_EQUAL, mask_layer_le, mask_layer_le);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    // draw (according to the stencil test func) this node and its childs
    [super visit];
    
    ///////////////////////////////////
    // CLEANUP
    
#if defined(__CC_PLATFORM_IOS)
    // manually restore the stencil state
    glStencilFunc(currentStencilFunc, currentStencilRef, currentStencilValueMask);
    glStencilOp(currentStencilFail, currentStencilPassDepthFail, currentStencilPassDepthPass);
    glStencilMask(currentStencilWriteMask);
    if (!currentStencilEnabled) {
        glDisable(GL_STENCIL_TEST);
    }
#elif defined(__CC_PLATFORM_MAC)
    // restore the stencil state
    glPopAttrib();
    // restore the enable state
    glPopAttrib();
#endif
    
    // we are done using this layer, decrement
    layer--;
}

@end
