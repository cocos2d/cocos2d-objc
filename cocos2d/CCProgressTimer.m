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
#import "Support/CGPointExtension.h"



#define kProgressTextureCoordsCount 4
//  kProgressTextureCoords holds points {0,0} {0,1} {1,1} {1,0} we can represent it as bits
const char kProgressTextureCoords = 0x1e;

@interface CCProgressTimer (Internal)

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

+(id)progressWithFile:(NSString*) filename
{
	return [[[self alloc]initWithFile:filename] autorelease];
}
-(id)initWithFile:(NSString*) filename
{
	return [self initWithTexture:[[CCTextureCache sharedTextureCache] addImage: filename]];
}

+(id)progressWithTexture:(CCTexture2D*) texture
{
	return [[[self alloc]initWithTexture:texture] autorelease];
}
-(id)initWithTexture:(CCTexture2D*) texture
{
	if(( self = [super init] )){
		self.sprite = [CCSprite spriteWithTexture:texture];
		percentage_ = 0.f;
		vertexData_ = NULL;
		vertexDataCount_ = 0;
		self.anchorPoint = ccp(.5f,.5f);
		self.contentSize = sprite_.contentSize;
		self.type = kCCProgressTimerTypeRadialCCW;
	}
	return self;
}
-(void)dealloc
{
	if(vertexData_)
		free(vertexData_);

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

#pragma mark CCRGBAProtocol implementation

-(void)setColor:(ccColor3B)color
{
	[sprite_ setColor:color];
	[self updateColor];
}

-(ccColor3B)color
{
	return sprite_.color;
}

-(GLubyte)opacity
{
	return sprite_.opacity;
}

-(void)setOpacity:(GLubyte)opacity
{
	[sprite_ setOpacity:opacity];
	[self updateColor];
}
@end

@implementation CCProgressTimer(Internal)

///
//	@returns the vertex position from the texture coordinate
///
-(ccVertex2F)vertexFromTexCoord:(CGPoint) texCoord
{
	CGPoint tmp;
	ccVertex2F ret;
	if (sprite_.texture) {
		CCTexture2D *texture = [sprite_ texture];
		CGSize texSize = [texture contentSizeInPixels];
		tmp = ccp(texSize.width * texCoord.x/texture.maxS,
				   texSize.height * (1 - (texCoord.y/texture.maxT)));
	} else
		tmp = CGPointZero;

	ret.x = tmp.x;
	ret.y = tmp.y;
	return ret;
}

-(void)updateColor
{
	GLubyte op = sprite_.opacity;
	ccColor3B c3b = sprite_.color;

	ccColor4B color = { c3b.r, c3b.g, c3b.b, op };
	if([sprite_.texture hasPremultipliedAlpha]){
		color.r *= op/255.f;
		color.g *= op/255.f;
		color.b *= op/255.f;
	}

	if(vertexData_){
		for (int i=0; i < vertexDataCount_; ++i) {
			vertexData_[i].colors = color;
		}
	}
}

-(void)updateProgress
{
	switch (type_) {
		case kCCProgressTimerTypeRadialCW:
		case kCCProgressTimerTypeRadialCCW:
			[self updateRadial];
			break;
		case kCCProgressTimerTypeHorizontalBarLR:
		case kCCProgressTimerTypeHorizontalBarRL:
		case kCCProgressTimerTypeVerticalBarBT:
		case kCCProgressTimerTypeVerticalBarTB:
			[self updateBar];
			break;
		default:
			break;
	}
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
	//	Texture Max is the actual max coordinates to deal with non-power of 2 textures
	CGPoint tMax = ccp(sprite_.texture.maxS,sprite_.texture.maxT);

	//	Grab the midpoint
	CGPoint midpoint = ccpCompMult(self.anchorPoint, tMax);

	float alpha = percentage_ / 100.f;

	//	Otherwise we can get the angle from the alpha
	float angle = 2.f*((float)M_PI) * ( type_ == kCCProgressTimerTypeRadialCW? alpha : 1.f - alpha);

	//	We find the vector to do a hit detection based on the percentage
	//	We know the first vector is the one @ 12 o'clock (top,mid) so we rotate
	//	from that by the progress angle around the midpoint pivot
	CGPoint topMid = ccp(midpoint.x, 0.f);
	CGPoint percentagePt = ccpRotateByAngle(topMid, midpoint, angle);


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

			CGPoint edgePtA = ccpCompMult([self boundaryTexCoord:i % kProgressTextureCoordsCount],tMax);
			CGPoint edgePtB = ccpCompMult([self boundaryTexCoord:pIndex],tMax);

			//	Remember that the top edge is split in half for the 12 o'clock position
			//	Let's deal with that here by finding the correct endpoints
			if(i == 0){
				edgePtB = ccpLerp(edgePtA,edgePtB,.5f);
			} else if(i == 4){
				edgePtA = ccpLerp(edgePtA,edgePtB,.5f);
			}

			//	s and t are returned by ccpLineIntersect
			float s = 0, t = 0;
			if(ccpLineIntersect(edgePtA, edgePtB, midpoint, percentagePt, &s, &t))
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
				//	correct hitpoint from midpoint to percentagePt.
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
		hit = ccpAdd(midpoint, ccpMult(ccpSub(percentagePt, midpoint),min_t));

	}


	//	The size of the vertex data is the index from the hitpoint
	//	the 3 is for the midpoint, 12 o'clock point and hitpoint position.

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

		[self updateColor];
	}

	if (!sameIndexCount) {

		//	First we populate the array with the midpoint, then all
		//	vertices/texcoords/colors of the 12 'o clock start and edges and the hitpoint
		vertexData_[0].texCoords = (ccTex2F){midpoint.x, midpoint.y};
		vertexData_[0].vertices = [self vertexFromTexCoord:midpoint];

		vertexData_[1].texCoords = (ccTex2F){midpoint.x, 0.f};
		vertexData_[1].vertices = [self vertexFromTexCoord:ccp(midpoint.x, 0.f)];

		for(int i = 0; i < index; ++i){
			CGPoint texCoords = ccpCompMult([self boundaryTexCoord:i], tMax);

			vertexData_[i+2].texCoords = (ccTex2F){texCoords.x, texCoords.y};
			vertexData_[i+2].vertices = [self vertexFromTexCoord:texCoords];
		}

		//	Flip the texture coordinates if set
		if (sprite_.flipY || sprite_.flipX) {
			for(int i = 0; i < vertexDataCount_ - 1; ++i){
				if (sprite_.flipX) {
					vertexData_[i].texCoords.u = tMax.x - vertexData_[i].texCoords.u;
				}
				if(sprite_.flipY){
					vertexData_[i].texCoords.v = tMax.y - vertexData_[i].texCoords.v;
				}
			}
		}
	}

	//	hitpoint will go last
	vertexData_[vertexDataCount_ - 1].texCoords = (ccTex2F){hit.x, hit.y};
	vertexData_[vertexDataCount_ - 1].vertices = [self vertexFromTexCoord:hit];

	if (sprite_.flipY || sprite_.flipX) {
		if (sprite_.flipX) {
			vertexData_[vertexDataCount_ - 1].texCoords.u = tMax.x - vertexData_[vertexDataCount_ - 1].texCoords.u;
		}
		if(sprite_.flipY){
			vertexData_[vertexDataCount_ - 1].texCoords.v = tMax.y - vertexData_[vertexDataCount_ - 1].texCoords.v;
		}
	}
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

	float alpha = percentage_ / 100.f;

	CGPoint tMax = ccp(sprite_.texture.maxS,sprite_.texture.maxT);

	unsigned char vIndexes[2] = {0,0};
	unsigned char index = 0;

	//	We know vertex data is always equal to the 4 corners
	//	If we don't have vertex data then we create it here and populate
	//	the side of the bar vertices that won't ever change.
	if (!vertexData_) {
		vertexDataCount_ = kProgressTextureCoordsCount;
		vertexData_ = malloc(vertexDataCount_ * sizeof(ccV2F_C4B_T2F));
		NSAssert( vertexData_, @"CCProgressTimer. Not enough memory");

		if(type_ == kCCProgressTimerTypeHorizontalBarLR){
			vertexData_[vIndexes[0] = 0].texCoords = (ccTex2F){0,0};
			vertexData_[vIndexes[1] = 1].texCoords = (ccTex2F){0, tMax.y};
		}else if (type_ == kCCProgressTimerTypeHorizontalBarRL) {
			vertexData_[vIndexes[0] = 2].texCoords = (ccTex2F){tMax.x, tMax.y};
			vertexData_[vIndexes[1] = 3].texCoords = (ccTex2F){tMax.x, 0.f};
		}else if (type_ == kCCProgressTimerTypeVerticalBarBT) {
			vertexData_[vIndexes[0] = 1].texCoords = (ccTex2F){0, tMax.y};
			vertexData_[vIndexes[1] = 3].texCoords = (ccTex2F){tMax.x, tMax.y};
		}else if (type_ == kCCProgressTimerTypeVerticalBarTB) {
			vertexData_[vIndexes[0] = 0].texCoords = (ccTex2F){0, 0};
			vertexData_[vIndexes[1] = 2].texCoords = (ccTex2F){tMax.x, 0};
		}

		index = vIndexes[0];
		vertexData_[index].vertices = [self vertexFromTexCoord:ccp(vertexData_[index].texCoords.u, vertexData_[index].texCoords.v)];

		index = vIndexes[1];
		vertexData_[index].vertices = [self vertexFromTexCoord:ccp(vertexData_[index].texCoords.u, vertexData_[index].texCoords.v)];

		if (sprite_.flipY || sprite_.flipX) {
			if (sprite_.flipX) {
				index = vIndexes[0];
				vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
				index = vIndexes[1];
				vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
			}
			if(sprite_.flipY){
				index = vIndexes[0];
				vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
				index = vIndexes[1];
				vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
			}
		}

		[self updateColor];
	}

	if(type_ == kCCProgressTimerTypeHorizontalBarLR){
		vertexData_[vIndexes[0] = 3].texCoords = (ccTex2F){tMax.x*alpha, tMax.y};
		vertexData_[vIndexes[1] = 2].texCoords = (ccTex2F){tMax.x*alpha, 0};
	}else if (type_ == kCCProgressTimerTypeHorizontalBarRL) {
		vertexData_[vIndexes[0] = 1].texCoords = (ccTex2F){tMax.x*(1.f - alpha), 0};
		vertexData_[vIndexes[1] = 0].texCoords = (ccTex2F){tMax.x*(1.f - alpha), tMax.y};
	}else if (type_ == kCCProgressTimerTypeVerticalBarBT) {
		vertexData_[vIndexes[0] = 0].texCoords = (ccTex2F){0, tMax.y*(1.f - alpha)};
		vertexData_[vIndexes[1] = 2].texCoords = (ccTex2F){tMax.x, tMax.y*(1.f - alpha)};
	}else if (type_ == kCCProgressTimerTypeVerticalBarTB) {
		vertexData_[vIndexes[0] = 1].texCoords = (ccTex2F){0, tMax.y*alpha};
		vertexData_[vIndexes[1] = 3].texCoords = (ccTex2F){tMax.x, tMax.y*alpha};
	}

	index = vIndexes[0];
	vertexData_[index].vertices = [self vertexFromTexCoord:ccp(vertexData_[index].texCoords.u, vertexData_[index].texCoords.v)];
	index = vIndexes[1];
	vertexData_[index].vertices = [self vertexFromTexCoord:ccp(vertexData_[index].texCoords.u, vertexData_[index].texCoords.v)];

	if (sprite_.flipY || sprite_.flipX) {
		if (sprite_.flipX) {
			index = vIndexes[0];
			vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
			index = vIndexes[1];
			vertexData_[index].texCoords.u = tMax.x - vertexData_[index].texCoords.u;
		}
		if(sprite_.flipY){
			index = vIndexes[0];
			vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
			index = vIndexes[1];
			vertexData_[index].texCoords.v = tMax.y - vertexData_[index].texCoords.v;
		}
	}

}

-(CGPoint)boundaryTexCoord:(char)index
{
	if (index < kProgressTextureCoordsCount) {
		switch (type_) {
			case kCCProgressTimerTypeRadialCW:
				return ccp((kProgressTextureCoords>>((index<<1)+1))&1,(kProgressTextureCoords>>(index<<1))&1);
			case kCCProgressTimerTypeRadialCCW:
				return ccp((kProgressTextureCoords>>(7-(index<<1)))&1,(kProgressTextureCoords>>(7-((index<<1)+1)))&1);
			default:
				break;
		}
	}
	return CGPointZero;
}

-(void)draw
{
	[super draw];

	if(!vertexData_)return;
	if(!sprite_)return;
	ccBlendFunc blendFunc = sprite_.blendFunc;
	BOOL newBlend = blendFunc.src != CC_BLEND_SRC || blendFunc.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc.src, blendFunc.dst );

	///	========================================================================
	//	Replaced [texture_ drawAtPoint:CGPointZero] with my own vertexData
	//	Everything above me and below me is copied from CCTextureNode's draw
	glBindTexture(GL_TEXTURE_2D, sprite_.texture.name);
	glVertexPointer(2, GL_FLOAT, sizeof(ccV2F_C4B_T2F), &vertexData_[0].vertices);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccV2F_C4B_T2F), &vertexData_[0].texCoords);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(ccV2F_C4B_T2F), &vertexData_[0].colors);
	if(type_ == kCCProgressTimerTypeRadialCCW || type_ == kCCProgressTimerTypeRadialCW){
		glDrawArrays(GL_TRIANGLE_FAN, 0, vertexDataCount_);
	} else if (type_ == kCCProgressTimerTypeHorizontalBarLR ||
			   type_ == kCCProgressTimerTypeHorizontalBarRL ||
			   type_ == kCCProgressTimerTypeVerticalBarBT ||
			   type_ == kCCProgressTimerTypeVerticalBarTB) {
		glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexDataCount_);
	}
	//glDrawElements(GL_TRIANGLES, indicesCount_, GL_UNSIGNED_BYTE, indices_);
	///	========================================================================

	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}
@end
