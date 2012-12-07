/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "CCParticleSystemQuad.h"
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

@interface CCParticleSystemQuad ()
-(void) initVAO;
-(BOOL) allocMemory;
@end

@implementation CCParticleSystemQuad

// overriding the init method
-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	// base initialization
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {

		// allocating data space
		if( ! [self allocMemory] ) {
			[self release];
			return nil;
		}

		// Don't initialize the texCoords yet since there are not textures
//		[self initTexCoordsWithRect:CGRectMake(0, 0, [texture_ pixelsWide], [texture_ pixelsHigh])];

		[self initIndices];
		[self initVAO];

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
	}

	return self;
}

-(BOOL) allocMemory
{
	NSAssert( ( !quads_ && !indices_), @"Memory already alloced");
	NSAssert( !batchNode_, @"Memory should not be alloced when not using batchNode");

	quads_ = calloc( sizeof(quads_[0]) * totalParticles, 1 );
	indices_ = calloc( sizeof(indices_[0]) * totalParticles * 6, 1 );

	if( !quads_ || !indices_) {
		CCLOG(@"cocos2d: Particle system: not enough memory");
		if( quads_ )
			free( quads_ );
		if(indices_)
			free(indices_);

		return NO;
	}

	return YES;
}

- (void) setTotalParticles:(NSUInteger)tp
{
    // If we are setting the total numer of particles to a number higher
    // than what is allocated, we need to allocate new arrays
    if( tp > allocatedParticles )
    {
        // Allocate new memory
        size_t particlesSize = tp * sizeof(tCCParticle);
        size_t quadsSize = sizeof(quads_[0]) * tp * 1;
        size_t indicesSize = sizeof(indices_[0]) * tp * 6 * 1;
        
        tCCParticle* particlesNew = realloc(particles, particlesSize);
        ccV3F_C4B_T2F_Quad *quadsNew = realloc(quads_, quadsSize);
        GLushort* indicesNew = realloc(indices_, indicesSize);
        
        if (particlesNew && quadsNew && indicesNew)
        {
            // Assign pointers
            particles = particlesNew;
            quads_ = quadsNew;
            indices_ = indicesNew;
            
            // Clear the memory
            memset(particles, 0, particlesSize);
            memset(quads_, 0, quadsSize);
            memset(indices_, 0, indicesSize);
            
            allocatedParticles = tp;
        }
        else
        {
            // Out of memory, failed to resize some array
            if (particlesNew) particles = particlesNew;
            if (quadsNew) quads_ = quadsNew;
            if (indicesNew) indices_ = indicesNew;
            
            CCLOG(@"Particle system: out of memory");
            return;
        }
        
        totalParticles = tp;
        
        // Init particles
        if (batchNode_)
		{
			for (int i = 0; i < totalParticles; i++)
			{
				particles[i].atlasIndex=i;
			}
		}
        
        [self initIndices];
        [self initVAO];
    }
    else
    {
        totalParticles = tp;
    }
}

-(void) initVAO
{
	// VAO requires GL_APPLE_vertex_array_object in order to be created on a different thread
	// https://devforums.apple.com/thread/145566?tstart=0
	
	void (^createVAO)(void) = ^ {
		glGenVertexArrays(1, &VAOname_);
		ccGLBindVAO(VAOname_);

	#define kQuadSize sizeof(quads_[0].bl)

		glGenBuffers(2, &buffersVBO_[0]);

		glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0]);
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * totalParticles, quads_, GL_DYNAMIC_DRAW);

		// vertices
		glEnableVertexAttribArray(kCCVertexAttrib_Position);
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));

		// colors
		glEnableVertexAttribArray(kCCVertexAttrib_Color);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));

		// tex coords
		glEnableVertexAttribArray(kCCVertexAttrib_TexCoords);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO_[1]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices_[0]) * totalParticles * 6, indices_, GL_STATIC_DRAW);

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
	if( ! batchNode_ ) {
		free(quads_);
		free(indices_);

		glDeleteBuffers(2, &buffersVBO_[0]);
		glDeleteVertexArrays(1, &VAOname_);
	}

	[super dealloc];
}

// pointRect is in Points coordinates.
-(void) initTexCoordsWithRect:(CGRect)pointRect
{
    // convert to Tex coords

	CGRect rect = CGRectMake(
							 pointRect.origin.x * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.origin.y * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.size.width * CC_CONTENT_SCALE_FACTOR(),
							 pointRect.size.height * CC_CONTENT_SCALE_FACTOR() );

	GLfloat wide = [texture_ pixelsWide];
	GLfloat high = [texture_ pixelsHigh];

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
	if (batchNode_)
	{
		quads = [[batchNode_ textureAtlas] quads];
		start = atlasIndex_;
		end = atlasIndex_ + totalParticles;
	}
	else
	{
		quads = quads_;
		start = 0;
		end = totalParticles;
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

-(void) setTexture:(CCTexture2D *)texture withRect:(CGRect)rect
{
	// Only update the texture if is different from the current one
	if( [texture name] != [texture_ name] )
		[super setTexture:texture];

	[self initTexCoordsWithRect:rect];
}

-(void) setTexture:(CCTexture2D *)texture
{
	CGSize s = [texture contentSize];
	[self setTexture:texture withRect:CGRectMake(0,0, s.width, s.height)];
}

-(void) setDisplayFrame:(CCSpriteFrame *)spriteFrame
{

	NSAssert( CGPointEqualToPoint( spriteFrame.offsetInPixels , CGPointZero ), @"QuadParticle only supports SpriteFrames with no offsets");
    
	// update texture before updating texture rect
	if ( spriteFrame.texture.name != texture_.name )
		[self setTexture: spriteFrame.texture];
}

-(void) initIndices
{
	for( NSUInteger i = 0; i < totalParticles; i++) {
		const NSUInteger i6 = i*6;
		const NSUInteger i4 = i*4;
		indices_[i6+0] = (GLushort) i4+0;
		indices_[i6+1] = (GLushort) i4+1;
		indices_[i6+2] = (GLushort) i4+2;

		indices_[i6+5] = (GLushort) i4+1;
		indices_[i6+4] = (GLushort) i4+2;
		indices_[i6+3] = (GLushort) i4+3;
	}
}

-(void) updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos
{
	ccV3F_C4B_T2F_Quad *quad;

	if (batchNode_)
	{
		ccV3F_C4B_T2F_Quad *batchQuads = [[batchNode_ textureAtlas] quads];
		quad = &(batchQuads[atlasIndex_+p->atlasIndex]);
	}
	else
		quad = &(quads_[particleIdx]);

	ccColor4B color = (opacityModifyRGB_)
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
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0] );
	
	// Option 1: Sub Data
//	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(quads_[0])*particleCount, quads_);
	
	// Option 2: Data
//	glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * particleCount, quads_, GL_DYNAMIC_DRAW);
	
	// Option 3: Orphaning + glMapBuffer
	glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0])*totalParticles, nil, GL_STREAM_DRAW);
	void *buf = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
	memcpy(buf, quads_, sizeof(quads_[0])*particleCount);
	glUnmapBuffer(GL_ARRAY_BUFFER);

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	CHECK_GL_ERROR_DEBUG();
}

// overriding draw method
-(void) draw
{
	NSAssert(!batchNode_,@"draw should not be called when added to a particleBatchNode");

	CC_NODE_DRAW_SETUP();

	ccGLBindTexture2D( [texture_ name] );
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );

	NSAssert( particleIdx == particleCount, @"Abnormal error in particle quad");

	ccGLBindVAO( VAOname_ );
	glDrawElements(GL_TRIANGLES, (GLsizei) particleIdx*6, GL_UNSIGNED_SHORT, 0);
	
	CC_INCREMENT_GL_DRAWS(1);

	CHECK_GL_ERROR_DEBUG();
}

-(void) setBatchNode:(CCParticleBatchNode *)batchNode
{
	if( batchNode_ != batchNode ) {

		CCParticleBatchNode *oldBatch = batchNode_;

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
			ccV3F_C4B_T2F_Quad *batchQuads = [[batchNode_ textureAtlas] quads];
			ccV3F_C4B_T2F_Quad *quad = &(batchQuads[atlasIndex_] );
			memcpy( quad, quads_, totalParticles * sizeof(quads_[0]) );

			if (quads_)
				free(quads_);
			quads_ = NULL;

			if (indices_)
				free(indices_);
			indices_ = NULL;

			glDeleteBuffers(2, &buffersVBO_[0]);
			glDeleteVertexArrays(1, &VAOname_);
		}
	}
}

@end
