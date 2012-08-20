//
//  Created by krzysztof.zablocki on 8/19/12.
//
//
//

#import "CCRenderTargetNode.h"
#import "CCRenderTexture.h"
#import "CCGrid.h"
#import "kazmath/mat4.h"
#import "kazmath/GL/matrix.h"

@implementation CCRenderTargetNode {
  CCRenderTexture *renderTexture_;
  GLbitfield clearFlags_;
  ccColor4F clearColor_;
  GLfloat clearDepth_;
  GLint clearStencil_;
}
@synthesize clearFlags = clearFlags_;
@synthesize clearColor = clearColor_;
@synthesize clearDepth = clearDepth_;
@synthesize clearStencil = clearStencil_;


- (id)initWithRenderTexture:(CCRenderTexture *)renderTexture
{
  self = [super init];
  if (self) {
    renderTexture_ = renderTexture;
  }
  return self;
}

- (void)visit
{
// override visit.
// Don't call visit on its children

  if (!visible_) {
    return;
  }

  kmGLPushMatrix();

  if (grid_ && grid_.active) {
    [grid_ beforeDraw];
    [self transformAncestors];
  }

  [self sortAllChildren];
  [self transform];
  [self draw];

  if (grid_ && grid_.active) {
    [grid_ afterDraw:self];
  }

  kmGLPopMatrix();

  orderOfArrival_ = 0;

}

- (void)draw
{
  NSAssert(renderTexture_ != nil, @"RenderTexture is needed by CCRenderTargetNode");

  BOOL requireClearing = self.clearFlags != 0;

  [renderTexture_ begin];

  if (requireClearing) {
    // save previous clear color
    GLfloat clearColor[4];
    GLfloat depthClearValue;
    int stencilClearValue;
    glGetFloatv(GL_COLOR_CLEAR_VALUE, clearColor);
    glGetFloatv(GL_DEPTH_CLEAR_VALUE, &depthClearValue);
    glGetIntegerv(GL_STENCIL_CLEAR_VALUE, &stencilClearValue);

    glClearColor(self.clearColor.r, self.clearColor.g, self.clearColor.b, self.clearColor.a);
    glClearDepth(self.clearDepth);
    glClearStencil(self.clearStencil);
    glClear(self.clearFlags);

    // restore clear colors
    glClearColor(clearColor[0], clearColor[1], clearColor[2], clearColor[3]);
    glClearDepth(depthClearValue);
    glClearStencil(stencilClearValue);
  }

  //! make sure all children are drawn
  CCNode *child;
  CCARRAY_FOREACH(children_, child) {
  [child visit];
}

  [renderTexture_ end];
}
@end
