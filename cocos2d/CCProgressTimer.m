/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Lam Pham
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

#import "CCProgressTimer.h"

#import "ccMacros.h"
#import "CCTextureCache.h"
#import "CCGLProgram.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"
#import "CCDrawingPrimitives.h"

// extern
#import "kazmath/GL/matrix.h"

#define kProgressTextureCoordsCount 4
//  kProgressTextureCoords holds points {0,1} {0,0} {1,0} {1,1} we can represent it as bits
const char kCCProgressTextureCoords = 0x4b;

@interface CCProgressTimer ()

-(void)updateProgress;
-(void)updateBar;
-(void)updateRadial;
-(void)updateColor;
-(CGPoint)boundaryTexCoord:(char)index;
@end


@implementation CCProgressTimer
@synthesize percentage = percentage_;
@synthesize sprite = sprite_;
@synthesize type = type_;
@synthesize reverseDirection = reverseDirection_;
@synthesize midpoint = midpoint_;
@synthesize barChangeRate = barChangeRate_;
@synthesize vertexData = vertexData_;
@synthesize vertexDataCount = vertexDataCount_;

+(id)progressWithSprite:(CCSprite*) sprite
{
	return [[[self alloc]initWithSprite:sprite] autorelease];
}

-(id) init
{
	return [self initWithSprite:nil];
}

// designated initializer
-(id)initWithSprite:(CCSprite*) sprite
{
	if(( self = [super init] )){
		percentage_ = 0.f;
		vertexData_ = NULL;
		vertexDataCount_ = 0;
		self.anchorPoint = ccp(0.5f,0.5f);
		self.type = kCCProgressTimerTypeRadial;
		self.reverseDirection = NO;
		self.midpoint = ccp(.5f, .5f);
		self.barChangeRate = ccp(1,1);
		self.sprite = sprite;
    
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
	}
	return self;
}

-(void)dealloc
{
	if(vertexData_){
		free(vertexData_);
	}
	[sprite_ release];
	[super dealloc];
}

-(void)setPercentage:(float) percentage
{
	if(percentage_ != percentage) {
    percentage_ = clampf( percentage, 0, 100);
		[self updateProgress];
	}
}

-(void)setSprite:(CCSprite *)newSprite
{
	if(sprite_ != newSprite){
		[sprite_ release];
		sprite_ = [newSprite retain];
		self.contentSize = sprite_.contentSize;
    
		//	Everytime we set a new sprite, we free the current vertex data
		if(vertexData_){
			free(vertexData_);
			vertexData_ = NULL;
			vertexDataCount_ = 0;
		}
	}
}

-(void)setType:(CCProgressTimerType)newType
{
	if (newType != type_) {
    
		//	release all previous information
		if(vertexData_){
			free(vertexData_);
			vertexData_ = NULL;
			vertexDataCount_ = 0;
		}
		type_ = newType;
	}
}

-(void)setReverseProgress:(BOOL)reverse
{
	if( reverseDirection_ != reverse ) {
		reverseDirection_ = reverse;
    
		//	release all previous information
		if(vertexData_){
			free(vertexData_);
			vertexData_ = NULL;
			vertexDataCount_ = 0;
		}
	}
}

-(void)setColor:(ccColor3B)c
{
	sprite_.color = c;
	[self updateColor];
}

-(ccColor3B)color
{
	return sprite_.color;
}

-(void)setOpacity:(GLubyte)o
{
	sprite_.opacity = o;
	[self updateColor];
}

-(GLubyte)opacity
{
	return sprite_.opacity;
}

#pragma mark ProgressTimer Internal

///
//	@returns the vertex position from the texture coordinate
///
-(ccTex2F)textureCoordFromAlphaPoint:(CGPoint) alpha
{
	if (!sprite_) {
		return (ccTex2F){0,0};
	}
	ccV3F_C4B_T2F_Quad quad = sprite_.quad;
	CGPoint min = (CGPoint){quad.bl.texCoords.u,quad.bl.texCoords.v};
	CGPoint max = (CGPoint){quad.tr.texCoords.u,quad.tr.texCoords.v};
  //  Fix bug #1303 so that progress timer handles sprite frame texture rotation
  if (sprite_.textureRectRotated) {
    CC_SWAP(alpha.x, alpha.y);
  }
	return (ccTex2F){min.x * (1.f - alpha.x) + max.x * alpha.x, min.y * (1.f - alpha.y) + max.y * alpha.y};
}

-(ccVertex2F)vertexFromAlphaPoint:(CGPoint) alpha
{
	if (!sprite_) {
		return (ccVertex2F){0.f, 0.f};
	}
	ccV3F_C4B_T2F_Quad quad = sprite_.quad;
	CGPoint min = (CGPoint){quad.bl.vertices.x,quad.bl.vertices.y};
	CGPoint max = (CGPoint){quad.tr.vertices.x,quad.tr.vertices.y};
	return (ccVertex2F){min.x * (1.f - alpha.x) + max.x * alpha.x, min.y * (1.f - alpha.y) + max.y * alpha.y};
}

-(void)updateColor
{
	if (!sprite_) {
		return;
	}
	if(vertexData_){
		ccColor4B sc = sprite_.quad.tl.colors;
		for (int i=0; i < vertexDataCount_; ++i) {
			vertexData_[i].colors = sc;
		}
	}
}

-(void)updateProgress
{
	switch (type_) {
		case kCCProgressTimerTypeRadial:
			[self updateRadial];
			break;
		case kCCProgressTimerTypeBar:
			[self updateBar];
			break;
		default:
			break;
	}
}

-(void)setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
}

-(CGPoint) midpoint
{
	return midpoint_;
}

-(void)setMidpoint:(CGPoint)midPoint
{
	midpoint_ = ccpClamp(midPoint, CGPointZero, ccp(1,1));
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
	if (!sprite_) {
		return;
	}
  
	float alpha = percentage_ / 100.f;
  
	float angle = 2.f*((float)M_PI) * ( reverseDirection_ == YES ? alpha : 1.f - alpha);
  
	//	We find the vector to do a hit detection based on the percentage
	//	We know the first vector is the one @ 12 o'clock (top,mid) so we rotate
	//	from that by the progress angle around the midpoint_ pivot
	CGPoint topMid = ccp(midpoint_.x, 1.f);
	CGPoint percentagePt = ccpRotateByAngle(topMid, midpoint_, angle);
  
  
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
    
		for (int i = 0; i <= kProgressTextureCoordsCount; ++i) {
			int pIndex = (i + (kProgressTextureCoordsCount - 1))%kProgressTextureCoordsCount;
      
			CGPoint edgePtA = [self boundaryTexCoord:i % kProgressTextureCoordsCount];
			CGPoint edgePtB = [self boundaryTexCoord:pIndex];
      
			//	Remember that the top edge is split in half for the 12 o'clock position
			//	Let's deal with that here by finding the correct endpoints
			if(i == 0){
				edgePtB = ccpLerp(edgePtA, edgePtB, 1 - midpoint_.x);
			} else if(i == 4){
				edgePtA = ccpLerp(edgePtA, edgePtB, 1 - midpoint_.x);
			}
      
			//	s and t are returned by ccpLineIntersect
			float s = 0, t = 0;
			if(ccpLineIntersect(edgePtA, edgePtB, midpoint_, percentagePt, &s, &t))
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
				//	correct hitpoint from midpoint_ to percentagePt.
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
		hit = ccpAdd(midpoint_, ccpMult(ccpSub(percentagePt, midpoint_),min_t));
    
	}
  
  
	//	The size of the vertex data is the index from the hitpoint
	//	the 3 is for the midpoint_, 12 o'clock point and hitpoint position.
  
	BOOL sameIndexCount = YES;
	if(vertexDataCount_ != index + 3){
		sameIndexCount = NO;
		if(vertexData_){
			free(vertexData_);
			vertexData_ = NULL;
			vertexDataCount_ = 0;
		}
	}
  
  
	if(!vertexData_) {
		vertexDataCount_ = index + 3;
		vertexData_ = malloc(vertexDataCount_ * sizeof(ccV2F_C4B_T2F));
		NSAssert( vertexData_, @"CCProgressTimer. Not enough memory");
	}
	[self updateColor];
  
	if (!sameIndexCount) {
    
		//	First we populate the array with the midpoint_, then all
		//	vertices/texcoords/colors of the 12 'o clock start and edges and the hitpoint
		vertexData_[0].texCoords = [self textureCoordFromAlphaPoint:midpoint_];
		vertexData_[0].vertices = [self vertexFromAlphaPoint:midpoint_];
    
		vertexData_[1].texCoords = [self textureCoordFromAlphaPoint:topMid];
		vertexData_[1].vertices = [self vertexFromAlphaPoint:topMid];
    
		for(int i = 0; i < index; ++i){
			CGPoint alphaPoint = [self boundaryTexCoord:i];
			vertexData_[i+2].texCoords = [self textureCoordFromAlphaPoint:alphaPoint];
			vertexData_[i+2].vertices = [self vertexFromAlphaPoint:alphaPoint];
		}
	}
  
	//	hitpoint will go last
	vertexData_[vertexDataCount_ - 1].texCoords = [self textureCoordFromAlphaPoint:hit];
	vertexData_[vertexDataCount_ - 1].vertices = [self vertexFromAlphaPoint:hit];
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
	if (!sprite_) {
		return;
	}
	float alpha = percentage_ / 100.f;
	CGPoint alphaOffset = ccpMult(ccp(1.f * (1.f - barChangeRate_.x) + alpha * barChangeRate_.x, 1.f * (1.f - barChangeRate_.y) + alpha * barChangeRate_.y), .5f);
	CGPoint min = ccpSub(midpoint_, alphaOffset);
	CGPoint max = ccpAdd(midpoint_, alphaOffset);
  
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
  
  
	if (!reverseDirection_) {
		if(!vertexData_) {
			vertexDataCount_ = 4;
			vertexData_ = malloc(vertexDataCount_ * sizeof(ccV2F_C4B_T2F));
			NSAssert( vertexData_, @"CCProgressTimer. Not enough memory");
		}
		//	TOPLEFT
		vertexData_[0].texCoords = [self textureCoordFromAlphaPoint:ccp(min.x,max.y)];
		vertexData_[0].vertices = [self vertexFromAlphaPoint:ccp(min.x,max.y)];
    
		//	BOTLEFT
		vertexData_[1].texCoords = [self textureCoordFromAlphaPoint:ccp(min.x,min.y)];
		vertexData_[1].vertices = [self vertexFromAlphaPoint:ccp(min.x,min.y)];
    
		//	TOPRIGHT
		vertexData_[2].texCoords = [self textureCoordFromAlphaPoint:ccp(max.x,max.y)];
		vertexData_[2].vertices = [self vertexFromAlphaPoint:ccp(max.x,max.y)];
    
		//	BOTRIGHT
		vertexData_[3].texCoords = [self textureCoordFromAlphaPoint:ccp(max.x,min.y)];
		vertexData_[3].vertices = [self vertexFromAlphaPoint:ccp(max.x,min.y)];
	} else {
		if(!vertexData_) {
			vertexDataCount_ = 8;
			vertexData_ = malloc(vertexDataCount_ * sizeof(ccV2F_C4B_T2F));
			NSAssert( vertexData_, @"CCProgressTimer. Not enough memory");
			//	TOPLEFT 1
			vertexData_[0].texCoords = [self textureCoordFromAlphaPoint:ccp(0,1)];
			vertexData_[0].vertices = [self vertexFromAlphaPoint:ccp(0,1)];
      
			//	BOTLEFT 1
			vertexData_[1].texCoords = [self textureCoordFromAlphaPoint:ccp(0,0)];
			vertexData_[1].vertices = [self vertexFromAlphaPoint:ccp(0,0)];
      
			//	TOPRIGHT 2
			vertexData_[6].texCoords = [self textureCoordFromAlphaPoint:ccp(1,1)];
			vertexData_[6].vertices = [self vertexFromAlphaPoint:ccp(1,1)];
      
			//	BOTRIGHT 2
			vertexData_[7].texCoords = [self textureCoordFromAlphaPoint:ccp(1,0)];
			vertexData_[7].vertices = [self vertexFromAlphaPoint:ccp(1,0)];
		}
    
		//	TOPRIGHT 1
		vertexData_[2].texCoords = [self textureCoordFromAlphaPoint:ccp(min.x,max.y)];
		vertexData_[2].vertices = [self vertexFromAlphaPoint:ccp(min.x,max.y)];
    
		//	BOTRIGHT 1
		vertexData_[3].texCoords = [self textureCoordFromAlphaPoint:ccp(min.x,min.y)];
		vertexData_[3].vertices = [self vertexFromAlphaPoint:ccp(min.x,min.y)];
    
		//	TOPLEFT 2
		vertexData_[4].texCoords = [self textureCoordFromAlphaPoint:ccp(max.x,max.y)];
		vertexData_[4].vertices = [self vertexFromAlphaPoint:ccp(max.x,max.y)];
    
		//	BOTLEFT 2
		vertexData_[5].texCoords = [self textureCoordFromAlphaPoint:ccp(max.x,min.y)];
		vertexData_[5].vertices = [self vertexFromAlphaPoint:ccp(max.x,min.y)];
	}
	[self updateColor];
}

-(CGPoint)boundaryTexCoord:(char)index
{
	if (index < kProgressTextureCoordsCount) {
		if (reverseDirection_) {
			return ccp((kCCProgressTextureCoords>>(7-(index<<1)))&1,(kCCProgressTextureCoords>>(7-((index<<1)+1)))&1);
		} else {
			return ccp((kCCProgressTextureCoords>>((index<<1)+1))&1,(kCCProgressTextureCoords>>(index<<1))&1);
		}
	}
	return CGPointZero;
}

-(void) draw
{
	if( ! vertexData_ || ! sprite_)
		return;
  
	CC_NODE_DRAW_SETUP();
  
	ccGLBlendFunc( sprite_.blendFunc.src, sprite_.blendFunc.dst );
  
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
  
	ccGLBindTexture2D( sprite_.texture.name );
  
  glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(vertexData_[0]) , &vertexData_[0].vertices);
  glVertexAttribPointer( kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(vertexData_[0]), &vertexData_[0].texCoords);
  glVertexAttribPointer( kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(vertexData_[0]), &vertexData_[0].colors);
  
	if(type_ == kCCProgressTimerTypeRadial)
	{
		glDrawArrays(GL_TRIANGLE_FAN, 0, vertexDataCount_);
	} 
	else if (type_ == kCCProgressTimerTypeBar)
	{
		if (!reverseDirection_)
		{
			glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexDataCount_);
		}
		else
		{
			glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexDataCount_/2);
			glDrawArrays(GL_TRIANGLE_STRIP, 4, vertexDataCount_/2);
			
			// 2 draw calls
			CC_INCREMENT_GL_DRAWS(1);
		}
	}
	CC_INCREMENT_GL_DRAWS(1);
  
}

@end
