/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Lam Pham
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

#import "CCProgressNode.h"

#import "ccMacros.h"
#import "CCTextureCache.h"
#import "CCShader.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "CCSprite_Private.h"

#import "CCNode_Private.h"
#import "CCProgressNode_Private.h"

#import "CCTexture_Private.h"

@implementation CCProgressNode {
	CCProgressNodeType _type;
	float _percentage;
	CCSprite *_sprite;

	int _vertexCount;
	CCVertex *_verts;
	CGPoint _midpoint;
	CGPoint _barChangeRate;
	BOOL _reverseDirection;
	
	BOOL _dirtyVertexData;
	BOOL _needsUpdateProgress;
}

@synthesize percentage = _percentage;
@synthesize sprite = _sprite;
@synthesize type = _type;
@synthesize reverseDirection = _reverseDirection;
@synthesize midpoint = _midpoint;
@synthesize barChangeRate = _barChangeRate;

+(instancetype)progressWithSprite:(CCSprite*) sprite
{
	return [[self alloc]initWithSprite:sprite];
}

-(id) init
{
	return [self initWithSprite:nil];
}

// designated initializer
-(id)initWithSprite:(CCSprite*) sprite
{
	if(( self = [super init] )){
		_type = CCProgressNodeTypeRadial;
		_reverseDirection = NO;
		_percentage = 0.f;
		_verts = NULL;
		_vertexCount = 0;
		
		self.anchorPoint = ccp(0.5f,0.5f);
		self.midpoint = ccp(0.5f, 0.5f);
		self.barChangeRate = ccp(1, 1);
		self.sprite = sprite;
		
		_dirtyVertexData = NO;
		_needsUpdateProgress = YES;
	}
	
	return self;
}

-(void)freeVertexData
{
	free(_verts);
	_verts = NULL;
	_vertexCount = 0;
}

-(void)dealloc
{
	[self freeVertexData];
}

-(void)setPercentage:(float)percentage
{
	if(_percentage != percentage) {
		_percentage = clampf(percentage, 0, 100);
		
		// only flag update progress here, let the progress type handle
		// whether it needs to rebuild the vertex data
		_needsUpdateProgress = YES;
	}
}

-(void)setSprite:(CCSprite *)newSprite
{
	if(_sprite != newSprite){
		_sprite = newSprite;
		self.contentSize = _sprite.contentSize;
    
		_dirtyVertexData = YES;
		_needsUpdateProgress = YES;
	}
}

-(void)setType:(CCProgressNodeType)newType
{
	if (newType != _type) {
		_type = newType;
		
		_dirtyVertexData = YES;
		_needsUpdateProgress = YES;
	}
}

-(void)setReverseDirection:(BOOL)reverse
{
	if( _reverseDirection != reverse ) {
		_reverseDirection = reverse;
    
		_dirtyVertexData = YES;
		_needsUpdateProgress = YES;
	}
}

-(void)setColor:(CCColor*)c
{
	_sprite.color = c;
	[self updateColor];
}

-(CCColor*)color
{
	return _sprite.color;
}

-(void)setOpacity:(CGFloat)o
{
	_sprite.opacity = o;
	[self updateColor];
}

-(CGFloat)opacity
{
	return _sprite.opacity;
}

#pragma mark ProgressTimer Internal

///
//	@returns the vertex position from the texture coordinate
///
-(GLKVector2)textureCoordFromAlphaPoint:(CGPoint) alpha
{
	if (!_sprite) {
		return GLKVector2Make(0.0f, 0.0f);
	}
	
	const CCSpriteVertexes *verts = _sprite.vertexes;
	GLKVector2 min = verts->bl.texCoord1;
	GLKVector2 max = verts->tr.texCoord1;
  //  Fix bug #1303 so that progress timer handles sprite frame texture rotation
  if (_sprite.textureRectRotated) {
    CC_SWAP(alpha.x, alpha.y);
  }
	
	// As of 3.1, the x alpha needs to be flipped. Not really sure why.
	alpha.x = 1.0 - alpha.x;
	return GLKVector2Make(min.x * (1.f - alpha.x) + max.x * alpha.x, min.y * (1.f - alpha.y) + max.y * alpha.y);
}

-(GLKVector4)vertexFromAlphaPoint:(CGPoint) alpha
{
	if (!_sprite) {
		return GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
	}
	
	const CCSpriteVertexes *verts = _sprite.vertexes;
	GLKVector4 min = verts->br.position;
	GLKVector4 max = verts->tl.position;
	
	// As of 3.1, the x alpha needs to be flipped. Not really sure why.
	alpha.x = 1.0 - alpha.x;
	return GLKVector4Make(min.x * (1.f - alpha.x) + max.x * alpha.x, min.y * (1.f - alpha.y) + max.y * alpha.y, 0.0f, 1.0f);
}

-(void)updateColor
{
	if (!_sprite) {
		return;
	}
	if(_verts){
		GLKVector4 sc = _sprite.vertexes->br.color;
		for (int i=0; i < _vertexCount; ++i) {
			_verts[i].color = sc;
		}
	}
}

-(void)updateProgress
{
	if (_dirtyVertexData){
		// remove the vertex data if the type, direction, or sprite have changed 
		if (_verts) {
			[self freeVertexData];
		}
		
		_dirtyVertexData = NO;
	}
        
	switch (_type) {
		case CCProgressNodeTypeRadial:
			[self updateRadial];
			return;
		case CCProgressNodeTypeBar:
			[self updateBar];
			return;
		default:
			return;
	}
}

-(void)setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
}

-(CGPoint) midpoint
{
	return _midpoint;
}

-(void)setMidpoint:(CGPoint)midPoint
{
	_midpoint = ccpClamp(midPoint, CGPointZero, ccp(1,1));
}

static inline CGPoint
BoundryTexCoord(int index)
{
	static const CGPoint points[] = {{1,1}, {1,0}, {0,0}, {0,1}};
	return points[index];
}

///
//	Update does the work of mapping the texture onto the triangles
//	It now doesn't occur the cost of free/alloc data every update cycle.
//	It also only changes the percentage point but no other points if they have not
//	been modified.
//
//	It now deals with flipped texture. If you run into this problem, just use the
//	sprite property and enable the methods flipX, flipY.
///
-(void)updateRadial
{
	if (!_sprite) {
		return;
	}
  
	float alpha = _percentage / 100.f;
  
	float angle = 2.f*((float)M_PI) * ( _reverseDirection == YES ? alpha : 1.f - alpha);
  
	//	We find the vector to do a hit detection based on the percentage
	//	We know the first vector is the one @ 12 o'clock (top,mid) so we rotate
	//	from that by the progress angle around the _midpoint pivot
	CGPoint topMid = ccp(_midpoint.x, 1.f);
	CGPoint percentagePt = ccpRotateByAngle(topMid, _midpoint, angle);
  
  
	int index = 0;
	CGPoint hit = CGPointZero;
  
	if (alpha == 0.f) {
		//	More efficient since we don't always need to check intersection
		//	If the alpha is zero then the hit point is top mid and the index is 0.
		hit = topMid;
		index = 0;
	} else if (alpha == 1.f) {
		//	More efficient since we don't always need to check intersection
		//	If the alpha is one then the hit point is top mid and the index is 4.
		hit = topMid;
		index = 4;
	} else {
		//	We run a for loop checking the edges of the texture to find the
		//	intersection point
		//	We loop through five points since the top is split in half
    
		float min_t = FLT_MAX;
    
		for (int i = 0; i <= 4; ++i) {
			int pIndex = (i + 3)%4;
      
			CGPoint edgePtA = BoundryTexCoord(i % 4);
			CGPoint edgePtB = BoundryTexCoord(pIndex);
      
			//	Remember that the top edge is split in half for the 12 o'clock position
			//	Let's deal with that here by finding the correct endpoints
			if(i == 0){
				edgePtB = ccpLerp(edgePtA, edgePtB, 1 - _midpoint.x);
			} else if(i == 4){
				edgePtA = ccpLerp(edgePtA, edgePtB, 1 - _midpoint.x);
			}
      
			//	s and t are returned by ccpLineIntersect
			float s = 0, t = 0;
			if(ccpLineIntersect(edgePtA, edgePtB, _midpoint, percentagePt, &s, &t))
			{
        
				//	Since our hit test is on rays we have to deal with the top edge
				//	being in split in half so we have to test as a segment
				if ((i == 0 || i == 4)) {
					//	s represents the point between edgePtA--edgePtB
					if (!(0.f <= s && s <= 1.f)) {
						continue;
					}
				}
				//	As long as our t isn't negative we are at least finding a
				//	correct hitpoint from _midpoint to percentagePt.
				if (t >= 0.f) {
					//	Because the percentage line and all the texture edges are
					//	rays we should only account for the shortest intersection
					if (t < min_t) {
						min_t = t;
						index = i;
					}
				}
			}
		}
    
		//	Now that we have the minimum magnitude we can use that to find our intersection
		hit = ccpAdd(_midpoint, ccpMult(ccpSub(percentagePt, _midpoint),min_t));
    
	}
  
  
	//	The size of the vertex data is the index from the hitpoint
	//	the 3 is for the _midpoint, 12 o'clock point and hitpoint position.
  
	BOOL sameIndexCount = YES;
	if(_vertexCount != index + 3){
		sameIndexCount = NO;
		[self freeVertexData];
	}
  
  
	if(!_verts) {
		_vertexCount = index + 3;
		_verts = calloc(_vertexCount, sizeof(*_verts));
		NSAssert( _verts, @"CCProgressTimer. Not enough memory");
	}
	[self updateColor];
  
	if (!sameIndexCount) {
    
		//	First we populate the array with the _midpoint, then all
		//	vertices/texcoords/colors of the 12 'o clock start and edges and the hitpoint
		_verts[0].texCoord1 = [self textureCoordFromAlphaPoint:_midpoint];
		_verts[0].position = [self vertexFromAlphaPoint:_midpoint];
    
		_verts[1].texCoord1 = [self textureCoordFromAlphaPoint:topMid];
		_verts[1].position = [self vertexFromAlphaPoint:topMid];
    
		for(int i = 0; i < index; ++i){
			CGPoint alphaPoint = BoundryTexCoord(i);
			_verts[i+2].texCoord1 = [self textureCoordFromAlphaPoint:alphaPoint];
			_verts[i+2].position = [self vertexFromAlphaPoint:alphaPoint];
		}
	}
  
	//	hitpoint will go last
	_verts[_vertexCount - 1].texCoord1 = [self textureCoordFromAlphaPoint:hit];
	_verts[_vertexCount - 1].position = [self vertexFromAlphaPoint:hit];
}

///
//	Update does the work of mapping the texture onto the triangles for the bar
//	It now doesn't occur the cost of free/alloc data every update cycle.
//	It also only changes the percentage point but no other points if they have not
//	been modified.
//
//	It now deals with flipped texture. If you run into this problem, just use the
//	sprite property and enable the methods flipX, flipY.
///
-(void)updateBar
{
	if (!_sprite) {
		return;
	}
	float alpha = _percentage / 100.f;
	CGPoint alphaOffset = ccpMult(ccp(1.f * (1.f - _barChangeRate.x) + alpha * _barChangeRate.x, 1.f * (1.f - _barChangeRate.y) + alpha * _barChangeRate.y), .5f);
	CGPoint min = ccpSub(_midpoint, alphaOffset);
	CGPoint max = ccpAdd(_midpoint, alphaOffset);
  
	if (min.x < 0.f) {
		max.x += -min.x;
		min.x = 0.f;
	}
  
	if (max.x > 1.f) {
		min.x -= max.x - 1.f;
		max.x = 1.f;
	}
  
	if (min.y < 0.f) {
		max.y += -min.y;
		min.y = 0.f;
	}
  
	if (max.y > 1.f) {
		min.y -= max.y - 1.f;
		max.y = 1.f;
	}
  
  
	if (!_reverseDirection) {
		if(!_verts) {
			_vertexCount = 4;
			_verts = calloc(_vertexCount, sizeof(*_verts));
			NSAssert( _verts, @"CCProgressTimer. Not enough memory");
		}
		//	TOPLEFT
		_verts[0].texCoord1 = [self textureCoordFromAlphaPoint:ccp(min.x,max.y)];
		_verts[0].position = [self vertexFromAlphaPoint:ccp(min.x,max.y)];
    
		//	BOTLEFT
		_verts[1].texCoord1 = [self textureCoordFromAlphaPoint:ccp(min.x,min.y)];
		_verts[1].position = [self vertexFromAlphaPoint:ccp(min.x,min.y)];
    
		//	TOPRIGHT
		_verts[2].texCoord1 = [self textureCoordFromAlphaPoint:ccp(max.x,max.y)];
		_verts[2].position = [self vertexFromAlphaPoint:ccp(max.x,max.y)];
    
		//	BOTRIGHT
		_verts[3].texCoord1 = [self textureCoordFromAlphaPoint:ccp(max.x,min.y)];
		_verts[3].position = [self vertexFromAlphaPoint:ccp(max.x,min.y)];
	} else {
		if(!_verts) {
			_vertexCount = 8;
			_verts = calloc(_vertexCount, sizeof(*_verts));
			NSAssert( _verts, @"CCProgressTimer. Not enough memory");
			//	TOPLEFT 1
			_verts[0].texCoord1 = [self textureCoordFromAlphaPoint:ccp(0,1)];
			_verts[0].position = [self vertexFromAlphaPoint:ccp(0,1)];
      
			//	BOTLEFT 1
			_verts[1].texCoord1 = [self textureCoordFromAlphaPoint:ccp(0,0)];
			_verts[1].position = [self vertexFromAlphaPoint:ccp(0,0)];
      
			//	TOPRIGHT 2
			_verts[6].texCoord1 = [self textureCoordFromAlphaPoint:ccp(1,1)];
			_verts[6].position = [self vertexFromAlphaPoint:ccp(1,1)];
      
			//	BOTRIGHT 2
			_verts[7].texCoord1 = [self textureCoordFromAlphaPoint:ccp(1,0)];
			_verts[7].position = [self vertexFromAlphaPoint:ccp(1,0)];
		}
    
		//	TOPRIGHT 1
		_verts[2].texCoord1 = [self textureCoordFromAlphaPoint:ccp(min.x,max.y)];
		_verts[2].position = [self vertexFromAlphaPoint:ccp(min.x,max.y)];
    
		//	BOTRIGHT 1
		_verts[3].texCoord1 = [self textureCoordFromAlphaPoint:ccp(min.x,min.y)];
		_verts[3].position = [self vertexFromAlphaPoint:ccp(min.x,min.y)];
    
		//	TOPLEFT 2
		_verts[4].texCoord1 = [self textureCoordFromAlphaPoint:ccp(max.x,max.y)];
		_verts[4].position = [self vertexFromAlphaPoint:ccp(max.x,max.y)];
    
		//	BOTLEFT 2
		_verts[5].texCoord1 = [self textureCoordFromAlphaPoint:ccp(max.x,min.y)];
		_verts[5].position = [self vertexFromAlphaPoint:ccp(max.x,min.y)];
	}
	[self updateColor];
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	[super visit:renderer parentTransform:parentTransform];
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if (_needsUpdateProgress) {
		[self updateProgress];
		_needsUpdateProgress = NO;
	}
	
	if(!_verts || !_sprite)return;
  
	if(_type == CCProgressNodeTypeRadial){
		int triangles = _vertexCount - 2;
		CCRenderBuffer buffer = [renderer enqueueTriangles:triangles andVertexes:_vertexCount withState:_sprite.renderState globalSortOrder:0];
		
		for(int i=0; i<_vertexCount; i++){
			CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(_verts[i], transform));
		}
		
		for(int i=0; i<triangles; i++){
			CCRenderBufferSetTriangle(buffer, i, 0, i + 1, i + 2);
		}
	} else if (_type == CCProgressNodeTypeBar){
		int triangles = _vertexCount/2;
		CCRenderBuffer buffer = [renderer enqueueTriangles:triangles andVertexes:_vertexCount withState:_sprite.renderState globalSortOrder:0];
		
		for(int i=0; i<_vertexCount; i++){
			CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(_verts[i], transform));
		}
		
		if (!_reverseDirection){
			CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
			CCRenderBufferSetTriangle(buffer, 1, 1, 2, 3);
		} else {
			CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
			CCRenderBufferSetTriangle(buffer, 1, 1, 2, 3);
			CCRenderBufferSetTriangle(buffer, 2, 4, 5, 6);
			CCRenderBufferSetTriangle(buffer, 3, 5, 6, 7);
		}
	}
}

@end
