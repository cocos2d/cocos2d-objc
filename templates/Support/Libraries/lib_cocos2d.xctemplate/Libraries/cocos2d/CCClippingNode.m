/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Pierre-David Bélanger
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

#import "CCClippingNode.h"

#import "CCGL.h"
#import "CCShader.h"

#import "CCDirector.h"
#import "CGPointExtension.h"

#import "CCNode_Private.h"
//#import "CCDrawingPrimitives.h"

static GLint _stencilBits = -1;

static void
SetProgram(CCNode *n, CCShader *p, NSNumber *alpha) {
	n.shader = p;
	n.shaderUniforms[CCShaderUniformAlphaTestValue] = alpha;
	
	if(!n.children) return;
	for(CCNode* c in n.children) SetProgram(c,p, alpha);
}

@implementation CCClippingNode

@synthesize stencil = _stencil;
@synthesize inverted = _inverted;


+ (id)clippingNode
{
    return [self node];
}

+ (id)clippingNodeWithStencil:(CCNode *)stencil
{
    return [[self alloc] initWithStencil:stencil];
}

- (id)init
{
    return [self initWithStencil:nil];
}

- (id)initWithStencil:(CCNode *)stencil
{
    if (self = [super init]) {
        self.stencil = stencil;
        self.alphaThreshold = 1;
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
    [_stencil onEnter];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [_stencil onEnterTransitionDidFinish];
}

- (void)onExitTransitionDidStart
{
    [_stencil onExitTransitionDidStart];
    [super onExitTransitionDidStart];
}

- (void)onExit
{
    [_stencil onExit];
    [super onExit];
}

- (void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    // if stencil buffer disabled
    if (_stencilBits < 1) {
        // draw everything, as if there where no stencil
        [super visit:renderer parentTransform:parentTransform];
        return;
    }
    
    // return fast (draw nothing, or draw everything if in inverted mode) if:
    // - nil stencil node
    // - or stencil node invisible:
    if (!_stencil || !_stencil.visible) {
        if (_inverted) {
            // draw everything
            [super visit:renderer parentTransform:parentTransform];
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
        [super visit:renderer parentTransform:parentTransform];
        return;
    }
    
    ///////////////////////////////////
    // INIT

    // increment the current layer
    layer++;
    
    // mask of the current layer (ie: for layer 3: 00000100)
    GLint mask_layer = 0x1 << layer;
    // mask of all layers less than the current (ie: for layer 3: 00000011)
    GLint mask_layer_l = mask_layer - 1;
    // mask of all layers less than or equal to the current (ie: for layer 3: 00000111)
    GLint mask_layer_le = mask_layer | mask_layer_l;
    
    // manually save the stencil state
    __block GLboolean currentStencilEnabled = GL_FALSE;
    __block GLuint currentStencilWriteMask = ~0;
    __block GLenum currentStencilFunc = GL_ALWAYS;
    __block GLint currentStencilRef = 0;
    __block GLuint currentStencilValueMask = ~0;
    __block GLenum currentStencilFail = GL_KEEP;
    __block GLenum currentStencilPassDepthFail = GL_KEEP;
    __block GLenum currentStencilPassDepthPass = GL_KEEP;
		__block GLboolean currentDepthWriteMask = GL_TRUE;
		
		[renderer pushGroup];
		
		[renderer enqueueBlock:^{
			currentStencilEnabled = glIsEnabled(GL_STENCIL_TEST);
			glGetIntegerv(GL_STENCIL_WRITEMASK, (GLint *)&currentStencilWriteMask);
			glGetIntegerv(GL_STENCIL_FUNC, (GLint *)&currentStencilFunc);
			glGetIntegerv(GL_STENCIL_REF, &currentStencilRef);
			glGetIntegerv(GL_STENCIL_VALUE_MASK, (GLint *)&currentStencilValueMask);
			glGetIntegerv(GL_STENCIL_FAIL, (GLint *)&currentStencilFail);
			glGetIntegerv(GL_STENCIL_PASS_DEPTH_FAIL, (GLint *)&currentStencilPassDepthFail);
			glGetIntegerv(GL_STENCIL_PASS_DEPTH_PASS, (GLint *)&currentStencilPassDepthPass);
			
			// enable stencil use
			glEnable(GL_STENCIL_TEST);
			// check for OpenGL error while enabling stencil test
			CC_CHECK_GL_ERROR_DEBUG();
			
			// all bits on the stencil buffer are readonly, except the current layer bit,
			// this means that operation like glClear or glStencilOp will be masked with this value
			glStencilMask(mask_layer);
			
			// manually save the depth test state
			//GLboolean currentDepthTestEnabled = GL_TRUE;
			//currentDepthTestEnabled = glIsEnabled(GL_DEPTH_TEST);
			glGetBooleanv(GL_DEPTH_WRITEMASK, &currentDepthWriteMask);
			
			// disable depth test while drawing the stencil
			//glDisable(GL_DEPTH_TEST);
			// disable update to the depth buffer while drawing the stencil,
			// as the stencil is not meant to be rendered in the real scene,
			// it should never prevent something else to be drawn,
			// only disabling depth buffer update should do
			glDepthMask(GL_FALSE);
			
			///////////////////////////////////
			// CLEAR STENCIL BUFFER
			
			// setup the stencil test func like this:
			// for each pixel in the stencil buffer
			//     never draw it into the frame buffer
			//     if not in inverted mode: set the current layer value to 0 in the stencil buffer
			//     if in inverted mode: set the current layer value to 1 in the stencil buffer
			glClearStencil(_inverted ? ~0 : 0);
			glClear(GL_STENCIL_BUFFER_BIT);
			
			///////////////////////////////////
			// DRAW CLIPPING STENCIL

			// setup the stencil test func like this:
			// for each pixel in the stencil node
			//     never draw it into the frame buffer
			//     if not in inverted mode: set the current layer value to 1 in the stencil buffer
			//     if in inverted mode: set the current layer value to 0 in the stencil buffer
			glStencilFunc(GL_NEVER, mask_layer, mask_layer);
			glStencilOp(_inverted ? GL_ZERO : GL_REPLACE, GL_KEEP, GL_KEEP);
			
//			NSLog(@"Stencil setup.");
		} globalSortOrder:NSIntegerMin debugLabel:@"CCClippingNode: Setup Stencil" threadSafe:NO];
		
		// since glAlphaTest do not exists in OES, use a shader that writes
		// pixel only if greater than an alpha threshold
		CCShader *program = [CCShader positionTextureColorAlphaTestShader];
		// we need to recursively apply this shader to all the nodes in the stencil node
		// XXX: we should have a way to apply shader to all nodes without having to do this
		SetProgram(_stencil, program, _alphaThreshold);
		
    // draw the stencil node as if it was one of our child
    // (according to the stencil test func/op and alpha (or alpha shader) test)
    GLKMatrix4 transform = [self transform:parentTransform];
		
		[renderer pushGroup];
    [_stencil visit:renderer parentTransform:&transform];
		[renderer popGroupWithDebugLabel:@"CCClippingNode: Stencil" globalSortOrder:NSIntegerMin];
		
		[renderer enqueueBlock:^{
//			NSLog(@"Stencil rendered.");
			// restore the depth test state
			glDepthMask(currentDepthWriteMask);
			
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
		} globalSortOrder:NSIntegerMin debugLabel:@"CCClippingNode: Setup Children" threadSafe:NO];
  
    // draw (according to the stencil test func) this node and its childs
    [super visit:renderer parentTransform:parentTransform];
  
		[renderer enqueueBlock:^{
			///////////////////////////////////
			// CLEANUP
			
			// manually restore the stencil state
			glStencilFunc(currentStencilFunc, currentStencilRef, currentStencilValueMask);
			glStencilOp(currentStencilFail, currentStencilPassDepthFail, currentStencilPassDepthPass);
			glStencilMask(currentStencilWriteMask);
			if (!currentStencilEnabled) {
					glDisable(GL_STENCIL_TEST);
			}
		} globalSortOrder:NSIntegerMax debugLabel:@"CCClippingNode: Restore" threadSafe:NO];
		
		[renderer popGroupWithDebugLabel:@"CCClippingNode: Visit" globalSortOrder:0];
  
    // we are done using this layer, decrement
    layer--;
}

-(GLfloat)alphaThreshold
{
	return _alphaThreshold.floatValue;
}

-(void)setAlphaThreshold:(GLfloat)alphaThreshold
{
	_alphaThreshold = @(alphaThreshold);
}

@end
