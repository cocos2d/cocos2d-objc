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
#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCSpriteFrame.h"
#import "CCParticleBatchNode.h"
#import "CCTextureAtlas.h"

// support
#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

@interface CCParticleSystemQuad (private)
-(id) initializeParticleSystemWithBatchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect;
@end

@implementation CCParticleSystemQuad

@synthesize quads=quads_;
+(id) particleWithFile:(NSString*) plistFile batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect
{
	return [[[self alloc] initWithFile:plistFile batchNode:batchNode rect:rect] autorelease];
}

-(id) initWithFile:(NSString *)plistFile  batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect
{
	batchNode_ = batchNode; 	
	textureRect_ = rect; 
	return [super initWithFile:plistFile];
}

// overriding the init method, this is the base initializer
-(id) initWithTotalParticles:(NSUInteger)numberOfParticles batchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect
{
	batchNode_ = batchNode; 
	textureRect_ = rect;
	
	//first super then self 
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {
		if ([self initializeParticleSystemWithBatchNode:batchNode rect:rect]==nil) return nil; 
	}
	
	return self;
}

-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	CCParticleBatchNode* batchNode = nil;
	CGRect rect = CGRectMake(0.0f,0.0f,0.0f,0.0f); 
	if (batchNode_) 
	{
		batchNode = batchNode_; 
		rect = textureRect_; 
	}	
	return [self initWithTotalParticles:numberOfParticles batchNode:batchNode rect:rect];
}

-(id) initializeParticleSystemWithBatchNode:(CCParticleBatchNode*) batchNode rect:(CGRect) rect
{
	if (rect.size.width == 0.f && rect.size.height == 0.f && batchNode != nil) 
	{	
		rect.size = CGSizeMake([batchNode.textureAtlas.texture pixelsWide], [batchNode.textureAtlas.texture pixelsHigh]);
	}	
	
	// allocating data space
	if (batchNode == nil) 
	{	
		
		quads_ = calloc( sizeof(quads_[0]) * totalParticles, 1 );
		indices_ = calloc( sizeof(indices_[0]) * totalParticles * 6, 1 );
		
		if( !quads_ || !indices_) {
			NSLog(@"cocos2d: Particle system: not enough memory");
			if( quads_ )
				free( quads_ );
			if(indices_)
				free(indices_);
			
			[self release];
			return nil;
		}
		
		// initialize only once the texCoords and the indices
		[self initTexCoordsWithRect:rect];
		[self initIndices];
		
	#if CC_USES_VBO
		// create the VBO buffer
		glGenBuffers(1, &quadsID_);
		
		// initial binding
		glBindBuffer(GL_ARRAY_BUFFER, quadsID_);
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0])*totalParticles, quads_,GL_DYNAMIC_DRAW);	
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	#endif
		
		useBatchNode_ = NO;
	}
	else {
		quads_ = NULL;
		indices_ = NULL;
		
		batchNode_ = batchNode;
		
		//can't use setTexture here since system isn't added to batchnode yet
		texture_ = [batchNode.textureAtlas.texture retain];
		textureRect_ = rect; 

		useBatchNode_ = YES;
	}

	return [NSNumber numberWithInt:1];
}

-(void) dealloc
{
	if (quads_) free(quads_);
	if (indices_) free(indices_);
#if CC_USES_VBO
	if (!useBatchNode_) glDeleteBuffers(1, &quadsID_);
#endif
	
	[super dealloc];
}

// pointRect is in Points coordinates.
-(void) initTexCoordsWithRect:(CGRect)pointRect
{
	textureRect_ = pointRect;
	
	if (texture_)
	{
		// convert to pixels coords
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
		
		ccV3F_C4B_T2F_Quad *quadCollection; 
		NSUInteger start, end; 
		if (useBatchNode_)
		{
			quadCollection = [[batchNode_ textureAtlas] quads]; 
			start = atlasIndex_; 
			end = atlasIndex_ + totalParticles; 
		}
		else 
		{
			quadCollection = quads_; 
			start = 0; 
			end = totalParticles; 
		}

		for(NSInteger i=start; i<end; i++) {
			// bottom-left vertex:
			quadCollection[i].bl.texCoords.u = left;
			quadCollection[i].bl.texCoords.v = bottom;
			// bottom-right vertex:
			quadCollection[i].br.texCoords.u = right;
			quadCollection[i].br.texCoords.v = bottom;
			// top-left vertex:
			quadCollection[i].tl.texCoords.u = left;
			quadCollection[i].tl.texCoords.v = top;
			// top-right vertex:
			quadCollection[i].tr.texCoords.u = right;
			quadCollection[i].tr.texCoords.v = top;
		}
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
		[self setTexture: spriteFrame.texture withRect:spriteFrame.rect];	
}

-(void) initIndices
{
	for( NSUInteger i=0;i< totalParticles;i++) {
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
	// colors
	ccV3F_C4B_T2F_Quad *quad; 

	if (useBatchNode_) 
	{	
		ccV3F_C4B_T2F_Quad *batchQuads = [[batchNode_ textureAtlas] quads]; 
		quad = &(batchQuads[atlasIndex_+p->atlasIndex]); 
	}
	else quad = &(quads_[particleIdx]);
	
	ccColor4B color = { p->color.r*255, p->color.g*255, p->color.b*255, p->color.a*255};
	quad->bl.colors = color;
	quad->br.colors = color;
	quad->tl.colors = color;
	quad->tr.colors = color;
	
	// vertices
	GLfloat size_2 = p->size/2;
	//don't transform particles if type is free
	if (useBatchNode_ && transformSystemDirty_ && positionType_!=kCCPositionTypeFree)
	{
		GLfloat x1 = -size_2*scaleX_;
		GLfloat y1 = -size_2*scaleY_;
		
		GLfloat x2 = size_2*scaleX_;
		GLfloat y2 = size_2*scaleY_;
		GLfloat x = newPos.x;
		GLfloat y = newPos.y;
		
		GLfloat r = (GLfloat)-CC_DEGREES_TO_RADIANS(p->rotation+rotation_);
		GLfloat cr = cosf(r) * scaleX_;
		GLfloat sr = sinf(r) * scaleX_;
		GLfloat cr2 = cosf(r) * scaleY_;
		GLfloat sr2 = sinf(r) * scaleY_;
		GLfloat ax = x1 * cr - y1 * sr2 + x;
		GLfloat ay = x1 * sr + y1 * cr2 + y;
		GLfloat bx = x2 * cr - y1 * sr2 + x;
		GLfloat by = x2 * sr + y1 * cr2 + y;
		GLfloat cx = x2 * cr - y2 * sr2 + x;
		GLfloat cy = x2 * sr + y2 * cr2 + y;
		GLfloat dx = x1 * cr - y2 * sr2 + x;
		GLfloat dy = x1 * sr + y2 * cr2 + y;
		
		// bottom-left
		quad->bl.vertices.x = ax;
		quad->bl.vertices.y = ay;
		quad->bl.vertices.z = p->z;
		
		// bottom-right vertex:
		quad->br.vertices.x = bx;
		quad->br.vertices.y = by;
		quad->br.vertices.z = p->z;
		
		// top-left vertex:
		quad->tl.vertices.x = dx;
		quad->tl.vertices.y = dy;
		quad->tl.vertices.z = p->z;
		// top-right vertex:
		quad->tr.vertices.x = cx;
		quad->tr.vertices.y = cy;
		quad->tr.vertices.z = p->z;	
	}
	else if( p->rotation ) {
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
#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, quadsID_);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(quads_[0])*particleCount, quads_);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif
}

// overriding draw method
-(void) draw
{	
	[super draw];

	NSAssert(!useBatchNode_,@"draw should not be called when added to a particleBatchNode"); 
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -

	glBindTexture(GL_TEXTURE_2D, [texture_ name]);

#define kQuadSize sizeof(quads_[0].bl)

#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, quadsID_);

	glVertexPointer(3,GL_FLOAT, kQuadSize, 0);

	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (GLvoid*) offsetof(ccV3F_C4B_T2F,colors) );
	
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (GLvoid*) offsetof(ccV3F_C4B_T2F,texCoords) );
#else // vertex array list

	NSUInteger offset = (NSUInteger) quads_;

	// vertex
	NSUInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexPointer(2,GL_FLOAT, kQuadSize, (GLvoid*) (offset+diff) );
	
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (GLvoid*)(offset + diff));
	
	// tex coords
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (GLvoid*)(offset + diff));		

#endif // ! CC_USES_VBO
	
	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	NSAssert( particleIdx == particleCount, @"Abnormal error in particle quad");
	glDrawElements(GL_TRIANGLES, (GLsizei) particleIdx*6, GL_UNSIGNED_SHORT, indices_);
	
	// restore blend state
	if( newBlend )
		glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );

#if CC_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
#endif

	// restore GL default state
	// -
}

-(void) useSelfRender
{
	if (useBatchNode_)
	{
		[self initializeParticleSystemWithBatchNode:nil rect:textureRect_];
		useBatchNode_ = NO;
	}
}

-(void) batchNodeInitialization
{
	[self initTexCoordsWithRect:textureRect_]; 	
}

-(void) useBatchNode:(CCParticleBatchNode*) batchNode
{
	if (!useBatchNode_)
	{	
		[super useBatchNode:batchNode]; 
		
		if (quads_) free(quads_);
		quads_ = NULL;
		
		if (indices_) free(indices_);
		indices_ = NULL;

#if CC_USES_VBO
		glDeleteBuffers(1, &quadsID_);
#endif
	}
}

@end