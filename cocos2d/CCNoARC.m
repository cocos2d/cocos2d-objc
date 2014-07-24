#import "CCNode_Private.h"
#import "CCSprite_Private.h"


@implementation CCNode(NoARC)

static inline GLKMatrix4
CCNodeTransform(CCNode *node, GLKMatrix4 parentTransform)
{
	CGAffineTransform t = [node nodeToParentTransform];
	float z = node->_vertexZ;
	
	// Convert to 4x4 column major GLK matrix.
	return GLKMatrix4Multiply(parentTransform, GLKMatrix4Make(
		 t.a,  t.b, 0.0f, 0.0f,
		 t.c,  t.d, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		t.tx, t.ty,    z, 1.0f
	));
}

-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform
{
	return CCNodeTransform(self, *parentTransform);
}

-(void) visit:(__unsafe_unretained CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// quick return if not visible. children won't be drawn.
	if (!_visible) return;
	
	[self sortAllChildren];
	
	GLKMatrix4 transform = CCNodeTransform(self, *parentTransform);
	BOOL drawn = NO;
	
	for(CCNode *child in _children){
		if(!drawn && child.zOrder >= 0){
			[self draw:renderer transform:&transform];
			drawn = YES;
		}
		
		[child visit:renderer parentTransform:&transform];
	}
	
	if(!drawn) [self draw:renderer transform:&transform];

	// reset for next frame
	_orderOfArrival = 0;
}

@end


@implementation CCSprite(NoARC)

static inline void
EnqueueTriangles(CCSprite *self, CCRenderer *renderer, const GLKMatrix4 *transform)
{
	CCRenderState *state = self->_renderState ?: self.renderState;
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:state globalSortOrder:0];
	
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(self->_verts.bl, transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(self->_verts.br, transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(self->_verts.tr, transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(self->_verts.tl, transform));

	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;
{
	if(!CCRenderCheckVisbility(transform, _vertexCenter, _vertexExtents)) return;
	
#if CC_ENABLE_EXPERIMENTAL_EFFECTS
	if (_effect)
	{
		_effectRenderer.contentSize = self.texture.contentSize;
		if ([self.effect prepareForRendering] == CCEffectPrepareSuccess)
		{
			// Preparing an effect for rendering can modify its uniforms
			// dictionary which means we need to reinitialize our copy of the
			// uniforms.
			[self updateShaderUniformsFromEffect];
		}
		[_effectRenderer drawSprite:self withEffect:self.effect uniforms:_shaderUniforms renderer:renderer transform:transform];
	}
	else
#endif
	{
		EnqueueTriangles(self, renderer, transform);
	}
    
#if CC_SPRITE_DEBUG_DRAW
	const GLKVector2 zero = {{0, 0}};
	const GLKVector4 white = {{1, 1, 1, 1}};
	
	CCRenderBuffer debug = [renderer enqueueLines:4 andVertexes:4 withState:[CCRenderState debugColor] globalSortOrder:0];
	CCRenderBufferSetVertex(debug, 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.bl.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.br.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tr.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tl.position), zero, zero, white});
	
	CCRenderBufferSetLine(debug, 0, 0, 1);
	CCRenderBufferSetLine(debug, 1, 1, 2);
	CCRenderBufferSetLine(debug, 2, 2, 3);
	CCRenderBufferSetLine(debug, 3, 3, 0);
#endif
}

-(void)enqueueTriangles:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	EnqueueTriangles(self, renderer, transform);
}

@end
