/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
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
 *
 */


// opengl
#import "Platforms/CCGL.h"

// cocos2d
#import "ccConfig.h"
#import "CCParticleSystem.h"
#import "CCParticleBatchNode.h"
#import "CCTextureAtlas.h"
#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCSpriteFrame.h"
#import "CCDirector.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCGLProgram.h"
#import "CCConfiguration.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"
#import "Support/NSThread+performBlock.h"

// extern
#import "kazmath/GL/matrix.h"

#import "CCNode_Private.h"
#import "CCParticleSystemBase_Private.h"
#import "CCParticleSystem_Private.h"
#import "CCTexture_Private.h"

@interface CCParticleSystem ()
-(void) initVAO;
-(BOOL) allocMemory;
@end

@implementation CCParticleSystem

// overriding the init method
-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	// base initialization
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {

		// allocating data space
		if( ! [self allocMemory] ) {
			return nil;
		}

		// Don't initialize the texCoords yet since there are not textures
//		[self initTexCoordsWithRect:CGRectMake(0, 0, [_texture pixelsWide], [_texture pixelsHigh])];

		[self initIndices];
		[self initVAO];

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
	}

	return self;
}

-(BOOL) allocMemory
{
	NSAssert( ( !_quads && !_indices), @"Memory already alloced");
	NSAssert( !_batchNode, @"Memory should not be alloced when not using batchNode");

	_quads = calloc( sizeof(_quads[0]) * _totalParticles, 1 );
	_indices = calloc( sizeof(_indices[0]) * _totalParticles * 6, 1 );

	if( !_quads || !_indices) {
		CCLOG(@"cocos2d: Particle system: not enough memory");
		if( _quads )
			free( _quads );
		if(_indices)
			free(_indices);

		return NO;
	}

	return YES;
}

- (void) setTotalParticles:(NSUInteger)tp
{
    // If we are setting the total numer of particles to a number higher
    // than what is allocated, we need to allocate new arrays
    if( tp > _allocatedParticles )
    {
        // Allocate new memory
        size_t particlesSize = tp * sizeof(_CCParticle);
        size_t quadsSize = sizeof(_quads[0]) * tp * 1;
        size_t indicesSize = sizeof(_indices[0]) * tp * 6 * 1;
        
        _CCParticle* particlesNew = realloc(_particles, particlesSize);
        ccV3F_C4B_T2F_Quad *quadsNew = realloc(_quads, quadsSize);
        GLushort* indicesNew = realloc(_indices, indicesSize);
        
        if (particlesNew && quadsNew && indicesNew)
        {
            // Assign pointers
            _particles = particlesNew;
            _quads = quadsNew;
            _indices = indicesNew;
            
            // Clear the memory
			// XXX: Bug? If the quads are cleared, then drawing doesn't work... WHY??? XXX
//            memset(_quads, 0, quadsSize);
            memset(_particles, 0, particlesSize);
            memset(_indices, 0, indicesSize);
            
            _allocatedParticles = tp;
        }
        else
        {
            // Out of memory, failed to resize some array
            if (particlesNew) _particles = particlesNew;
            if (quadsNew) _quads = quadsNew;
            if (indicesNew) _indices = indicesNew;
            
            CCLOG(@"Particle system: out of memory");
            return;
        }
        
        _totalParticles = tp;
        
        // Init particles
        if (_batchNode)
		{
			for (int i = 0; i < _totalParticles; i++)
			{
				_particles[i].atlasIndex=i;
			}
		}
        
        [self initIndices];
		
		// clean VAO
		glDeleteBuffers(2, &_buffersVBO[0]);
		glDeleteVertexArrays(1, &_VAOname);

        [self initVAO];
    }
    else
    {
        _totalParticles = tp;
    }

	[self resetSystem];
}

-(void) initVAO
{
	// VAO requires GL_APPLE_vertex_array_object in order to be created on a different thread
	// https://devforums.apple.com/thread/145566?tstart=0
	
	void (^createVAO)(void) = ^ {
		glGenVertexArrays(1, &_VAOname);
		ccGLBindVAO(_VAOname);

	#define kQuadSize sizeof(_quads[0].bl)

		glGenBuffers(2, &_buffersVBO[0]);

		glBindBuffer(GL_ARRAY_BUFFER, _buffersVBO[0]);
		glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0]) * _totalParticles, _quads, GL_DYNAMIC_DRAW);

		// vertices
		glEnableVertexAttribArray(kCCVertexAttrib_Position);
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));

		// colors
		glEnableVertexAttribArray(kCCVertexAttrib_Color);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));

		// tex coords
		glEnableVertexAttribArray(kCCVertexAttrib_TexCoords);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _buffersVBO[1]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_indices[0]) * _totalParticles * 6, _indices, GL_STATIC_DRAW);

		// Must unbind the VAO before changing the element buffer.
		ccGLBindVAO(0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		CHECK_GL_ERROR_DEBUG();
	};
	
	NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
	if( cocos2dThread == [NSThread currentThread] || [[CCConfiguration sharedConfiguration] supportsShareableVAO] )
		createVAO();
	else 
		[cocos2dThread performBlock:createVAO waitUntilDone:YES];
}

-(void) dealloc
{
	if( ! _batchNode ) {
		free(_quads);
		free(_indices);

		glDeleteBuffers(2, &_buffersVBO[0]);
		glDeleteVertexArrays(1, &_VAOname);
	}

}

// pointRect is in Points coordinates.
-(void) initTexCoordsWithRect:(CGRect)pointRect
{
    // convert to Tex coords

	CGFloat scale = self.texture.contentScale;
	CGRect rect = CGRectMake(
							 pointRect.origin.x * scale,
							 pointRect.origin.y * scale,
							 pointRect.size.width * scale,
							 pointRect.size.height * scale );

	GLfloat wide = [_texture pixelWidth];
	GLfloat high = [_texture pixelHeight];

#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	GLfloat left = (rect.origin.x*2+1) / (wide*2);
	GLfloat bottom = (rect.origin.y*2+1) / (high*2);
	GLfloat right = left + (rect.size.width*2-2) / (wide*2);
	GLfloat top = bottom + (rect.size.height*2-2) / (high*2);
#else
	GLfloat left = rect.origin.x / wide;
	GLfloat bottom = rect.origin.y / high;
	GLfloat right = left + rect.size.width / wide;
	GLfloat top = bottom + rect.size.height / high;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL

	// Important. Texture in cocos2d are inverted, so the Y component should be inverted
	CC_SWAP( top, bottom);

	ccV3F_C4B_T2F_Quad *quads;
	NSUInteger start, end;
	if (_batchNode)
	{
		quads = [[_batchNode textureAtlas] quads];
		start = _atlasIndex;
		end = _atlasIndex + _totalParticles;
	}
	else
	{
		quads = _quads;
		start = 0;
		end = _totalParticles;
	}

	for(NSUInteger i=start; i<end; i++) {

		// bottom-left vertex:
		quads[i].bl.texCoords.u = left;
		quads[i].bl.texCoords.v = bottom;
		// bottom-right vertex:
		quads[i].br.texCoords.u = right;
		quads[i].br.texCoords.v = bottom;
		// top-left vertex:
		quads[i].tl.texCoords.u = left;
		quads[i].tl.texCoords.v = top;
		// top-right vertex:
		quads[i].tr.texCoords.u = right;
		quads[i].tr.texCoords.v = top;
	}
}

-(void) setTexture:(CCTexture *)texture withRect:(CGRect)rect
{
	// Only update the texture if is different from the current one
	if( [texture name] != [_texture name] )
		[super setTexture:texture];

	[self initTexCoordsWithRect:rect];
}

-(void) setTexture:(CCTexture *)texture
{
	CGSize s = [texture contentSize];
	[self setTexture:texture withRect:CGRectMake(0,0, s.width, s.height)];
}

-(void) setSpriteFrame:(CCSpriteFrame *)spriteFrame
{

	NSAssert( CGPointEqualToPoint( spriteFrame.offset , CGPointZero ), @"QuadParticle only supports SpriteFrames with no offsets");
    
	// update texture before updating texture rect
	if ( spriteFrame.texture.name != _texture.name )
		[self setTexture: spriteFrame.texture];
}

-(void) initIndices
{
	for( NSUInteger i = 0; i < _totalParticles; i++) {
		const NSUInteger i6 = i*6;
		const NSUInteger i4 = i*4;
		_indices[i6+0] = (GLushort) i4+0;
		_indices[i6+1] = (GLushort) i4+1;
		_indices[i6+2] = (GLushort) i4+2;

		_indices[i6+5] = (GLushort) i4+1;
		_indices[i6+4] = (GLushort) i4+2;
		_indices[i6+3] = (GLushort) i4+3;
	}
}

-(void) updateQuadWithParticle:(_CCParticle*)p newPosition:(CGPoint)newPos
{
	ccV3F_C4B_T2F_Quad *quad;

	if (_batchNode)
	{
		ccV3F_C4B_T2F_Quad *batchQuads = [[_batchNode textureAtlas] quads];
		quad = &(batchQuads[_atlasIndex+p->atlasIndex]);
	}
	else
		quad = &(_quads[_particleIdx]);

	ccColor4B color = (_opacityModifyRGB)
		? (ccColor4B){ p->color.r*p->color.a*255, p->color.g*p->color.a*255, p->color.b*p->color.a*255, p->color.a*255}
		: (ccColor4B){ p->color.r*255, p->color.g*255, p->color.b*255, p->color.a*255};

	quad->bl.colors = color;
	quad->br.colors = color;
	quad->tl.colors = color;
	quad->tr.colors = color;

	// vertices
	GLfloat size_2 = p->size/2;
	if( p->rotation ) {
		GLfloat x1 = -size_2;
		GLfloat y1 = -size_2;

		GLfloat x2 = size_2;
		GLfloat y2 = size_2;
		GLfloat x = newPos.x;
		GLfloat y = newPos.y;

		GLfloat r = (GLfloat)-CC_DEGREES_TO_RADIANS(p->rotation);
		GLfloat cr = cosf(r);
		GLfloat sr = sinf(r);
		GLfloat ax = x1 * cr - y1 * sr + x;
		GLfloat ay = x1 * sr + y1 * cr + y;
		GLfloat bx = x2 * cr - y1 * sr + x;
		GLfloat by = x2 * sr + y1 * cr + y;
		GLfloat cx = x2 * cr - y2 * sr + x;
		GLfloat cy = x2 * sr + y2 * cr + y;
		GLfloat dx = x1 * cr - y2 * sr + x;
		GLfloat dy = x1 * sr + y2 * cr + y;

		// bottom-left
		quad->bl.vertices.x = ax;
		quad->bl.vertices.y = ay;

		// bottom-right vertex:
		quad->br.vertices.x = bx;
		quad->br.vertices.y = by;

		// top-left vertex:
		quad->tl.vertices.x = dx;
		quad->tl.vertices.y = dy;

		// top-right vertex:
		quad->tr.vertices.x = cx;
		quad->tr.vertices.y = cy;
	} else {
		// bottom-left vertex:
		quad->bl.vertices.x = newPos.x - size_2;
		quad->bl.vertices.y = newPos.y - size_2;

		// bottom-right vertex:
		quad->br.vertices.x = newPos.x + size_2;
		quad->br.vertices.y = newPos.y - size_2;

		// top-left vertex:
		quad->tl.vertices.x = newPos.x - size_2;
		quad->tl.vertices.y = newPos.y + size_2;

		// top-right vertex:
		quad->tr.vertices.x = newPos.x + size_2;
		quad->tr.vertices.y = newPos.y + size_2;
	}
}

-(void) postStep
{
	glBindBuffer(GL_ARRAY_BUFFER, _buffersVBO[0] );

	// Option 1: Sub Data
#if __CC_PLATFORM_MAC
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(_quads[0])*_particleCount, _quads);

	// Option 2: Data
//	glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0]) * _particleCount, _quads, GL_STREAM_DRAW);

#elif __CC_PLATFORM_IOS
	// Option 3: Orphaning + glMapBuffer
	glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0])*_totalParticles, nil, GL_STREAM_DRAW);
	void *buf = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
	memcpy(buf, _quads, sizeof(_quads[0])*_particleCount);
	glUnmapBuffer(GL_ARRAY_BUFFER);
#endif

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	CHECK_GL_ERROR_DEBUG();
}

// overriding draw method
-(void) draw
{
	NSAssert(!_batchNode,@"draw should not be called when added to a particleBatchNode");

	CC_NODE_DRAW_SETUP();

	ccGLBindTexture2D( [_texture name] );
	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );

	NSAssert( _particleIdx == _particleCount, @"Abnormal error in particle quad");

	ccGLBindVAO( _VAOname );
	glDrawElements(GL_TRIANGLES, (GLsizei) _particleIdx*6, GL_UNSIGNED_SHORT, 0);
	
	CC_INCREMENT_GL_DRAWS(1);

	CHECK_GL_ERROR_DEBUG();
}

-(void) setBatchNode:(CCParticleBatchNode *)batchNode
{
	if( _batchNode != batchNode ) {

		CCParticleBatchNode *oldBatch = _batchNode;

		[super setBatchNode:batchNode];

		// NEW: is self render ?
		if( ! batchNode ) {
			[self allocMemory];
			[self initIndices];
			[self setTexture:[oldBatch texture]];
			[self initVAO];
		}

		// OLD: was it self render ? cleanup
		else if( ! oldBatch )
		{
			// copy current state to batch
			ccV3F_C4B_T2F_Quad *batchQuads = [[_batchNode textureAtlas] quads];
			ccV3F_C4B_T2F_Quad *quad = &(batchQuads[_atlasIndex] );
			memcpy( quad, _quads, _totalParticles * sizeof(_quads[0]) );

			if (_quads)
				free(_quads);
			_quads = NULL;

			if (_indices)
				free(_indices);
			_indices = NULL;

			glDeleteBuffers(2, &_buffersVBO[0]);
			glDeleteVertexArrays(1, &_VAOname);
		}
	}
}

@end
