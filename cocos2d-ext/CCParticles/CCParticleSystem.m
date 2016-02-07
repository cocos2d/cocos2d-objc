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
#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCSpriteFrame.h"
#import "CCDirector.h"
#import "CCShader.h"
#import "CCConfiguration.h"

// support
#import "Support/CGPointExtension.h"
#import "Support/NSThread+performBlock.h"

#import "CCNode_Private.h"
#import "CCParticleSystemBase_Private.h"
#import "CCParticleSystem_Private.h"
#import "CCTexture_Private.h"

@implementation CCParticleSystem {
	GLKVector2 _texCoord1[4];
}

// overriding the init method
-(id) initWithTotalParticles:(NSUInteger) numberOfParticles
{
	// base initialization
	if( (self=[super initWithTotalParticles:numberOfParticles]) ) {

		// Don't initialize the texCoords yet since there are not textures
//		[self initTexCoordsWithRect:CGRectMake(0, 0, [_texture pixelsWide], [_texture pixelsHigh])];

		self.shader = [CCShader positionTextureColorShader];
	}

	return self;
}

- (void) setTotalParticles:(NSUInteger)tp
{
	// If we are setting the total numer of particles to a number higher
	// than what is allocated, we need to allocate new arrays
	if( tp > _allocatedParticles ){
		// Allocate new memory
		size_t particlesSize = tp * sizeof(_CCParticle);

		_particles = realloc(_particles, particlesSize);
		bzero(_particles, particlesSize);

		_allocatedParticles = tp;
	}
	
	_totalParticles = tp;
	[self resetSystem];
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

	GLfloat wide = [self.texture pixelWidth];
	GLfloat high = [self.texture pixelHeight];

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

	_texCoord1[0] = GLKVector2Make(left, bottom);
	_texCoord1[1] = GLKVector2Make(right, bottom);
	_texCoord1[2] = GLKVector2Make(right, top);
	_texCoord1[3] = GLKVector2Make(left, top);
}

-(void) setTexture:(CCTexture *)texture withRect:(CGRect)rect
{
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
	if(spriteFrame.texture != self.texture){
		[self setTexture: spriteFrame.texture];
	}
}

static inline void OutputParticle(CCRenderBuffer buffer, int i, _CCParticle *p, GLKVector2 pos, const GLKMatrix4 *transform, GLKVector2 *texCoord1)
{
	const GLKVector2 zero = {{0, 0}};
	GLKVector4 color = GLKVector4Make(p->color.r*p->color.a, p->color.g*p->color.a, p->color.b*p->color.a, p->color.a);

//#warning TODO Can do some extra optimization to the vertex transform math.
//#warning TODO Can pass the particle life and maybe another param using TexCoord2?

	float hs = 0.5f*p->size;
	
	if( p->rotation ) {
		float r = -CC_DEGREES_TO_RADIANS(p->rotation);
		float cr = cosf(r);
		float sr = sinf(r);
		float ax = -hs * cr - -hs * sr + pos.x;
		float ay = -hs * sr + -hs * cr + pos.y;
		float bx =  hs * cr - -hs * sr + pos.x;
		float by =  hs * sr + -hs * cr + pos.y;
		float cx =  hs * cr -  hs * sr + pos.x;
		float cy =  hs * sr +  hs * cr + pos.y;
		float dx = -hs * cr -  hs * sr + pos.x;
		float dy = -hs * sr +  hs * cr + pos.y;
		
		CCRenderBufferSetVertex(buffer, 4*i + 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(ax, ay, 0.0f, 1.0f)), texCoord1[0], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(bx, by, 0.0f, 1.0f)), texCoord1[1], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(cx, cy, 0.0f, 1.0f)), texCoord1[2], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(dx, dy, 0.0f, 1.0f)), texCoord1[3], zero, color});
	} else {
		CCRenderBufferSetVertex(buffer, 4*i + 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x - hs, pos.y - hs, 0.0f, 1.0f)), texCoord1[0], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x + hs, pos.y - hs, 0.0f, 1.0f)), texCoord1[1], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x + hs, pos.y + hs, 0.0f, 1.0f)), texCoord1[2], zero, color});
		CCRenderBufferSetVertex(buffer, 4*i + 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(pos.x - hs, pos.y + hs, 0.0f, 1.0f)), texCoord1[3], zero, color});
	}
	
	CCRenderBufferSetTriangle(buffer, 2*i + 0, 4*i + 0, 4*i + 1, 4*i + 2);
	CCRenderBufferSetTriangle(buffer, 2*i + 1, 4*i + 0, 4*i + 2, 4*i + 3);
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if(_particleCount == 0) return;
	
	GLKVector2 currentPosition = GLKVector2Make(0.0f, 0.0f);
	if( _particlePositionType == CCParticleSystemPositionTypeFree ){
		CGPoint p = [self convertToWorldSpace:CGPointZero];
		currentPosition = GLKVector2Make(p.x, p.y);
	} else if( _particlePositionType == CCParticleSystemPositionTypeRelative ){
		CGPoint p = self.position;
		currentPosition = GLKVector2Make(p.x, p.y);
	}
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:_particleCount*2 andVertexes:_particleCount*4 withState:self.renderState globalSortOrder:0];
	
	for(int i=0; i<_particleCount; i++){
		_CCParticle *p = _particles + i;
		GLKVector2 pos = p->pos;
		
		if( _particlePositionType == CCParticleSystemPositionTypeFree || _particlePositionType == CCParticleSystemPositionTypeRelative ){
			GLKVector2 diff = GLKVector2Subtract(currentPosition, p->startPos);
			pos = GLKVector2Subtract(pos, diff);
		}
		
		OutputParticle(buffer, i, p, pos, transform, _texCoord1);
	}
}

@end
