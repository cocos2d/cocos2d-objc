/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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

#import "CCSprite9Slice.h"

// ---------------------------------------------------------------------

const float CCSprite9SliceMarginDefault         = 1.0f/3.0f;

// ---------------------------------------------------------------------

@implementation CCSprite9Slice
{
    CGSize _originalContentSize;
}

// ---------------------------------------------------------------------
#pragma mark - create and destroy
// ---------------------------------------------------------------------

- (id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    NSAssert(self != nil, @"Unable to create class");
		
    _originalContentSize = self.contentSizeInPoints;
    
    // initialize new parts in 9slice
		self.margin = CCSprite9SliceMarginDefault;
    
    // done
    return(self);
}

// ---------------------------------------------------------------------
#pragma mark - overridden properties
// ---------------------------------------------------------------------

- (void)setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
    CGSize oldContentSize = self.contentSize;
    CCSizeType oldContentSizeType = self.contentSizeType;
    
    [super setTextureRect:rect rotated:rotated untrimmedSize:untrimmedSize];
    
    // save the original sizes for texture calculations
    _originalContentSize = self.contentSizeInPoints;
    
    if (!CGSizeEqualToSize(oldContentSize, CGSizeZero))
    {
        self.contentSizeType = oldContentSizeType;
        self.contentSize = oldContentSize;
    }
}

// ---------------------------------------------------------------------
#pragma mark - draw

static GLKMatrix4
PositionInterpolationMatrix(const CCSpriteVertexes *verts, const GLKMatrix4 *transform)
{
	GLKVector4 origin = verts->bl.position;
	GLKVector4 basisX = GLKVector4Subtract(verts->br.position, origin);
	GLKVector4 basisY = GLKVector4Subtract(verts->tl.position, origin);
	
	return GLKMatrix4Multiply(*transform, GLKMatrix4Make(
		basisX.x, basisX.y, basisX.z, 0.0f,
		basisY.x, basisY.y, basisY.z, 0.0f,
				0.0f,     0.0f,     1.0f, 0.0f,
		origin.x, origin.y, origin.z, 1.0f
	));
}

static GLKMatrix3
TexCoordInterpolationMatrix(const CCSpriteVertexes *verts)
{
	GLKVector2 origin = verts->bl.texCoord1;
	GLKVector2 basisX = GLKVector2Subtract(verts->br.texCoord1, origin);
	GLKVector2 basisY = GLKVector2Subtract(verts->tl.texCoord1, origin);
	
	return GLKMatrix3Make(
		basisX.x, basisX.y, 0.0f,
		basisY.x, basisY.y, 0.0f,
		origin.x, origin.y, 1.0f
	);
}

// TODO This is sort of brute force. Could probably use some optimization after profiling.
// Could it be done in a vertex shader using the texCoord2 attribute?
-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	// Don't draw rects that were originally sizeless. CCButtons in tableviews are like this.
	// Not really sure it's intended behavior or not.
	if(_originalContentSize.width == 0 && _originalContentSize.height == 0) return;
	
	CGSize size = self.contentSizeInPoints;
	CGSize rectSize = self.textureRect.size;
	
	CGSize physicalSize = CGSizeMake(
		size.width + rectSize.width - _originalContentSize.width,
		size.height + rectSize.height - _originalContentSize.height
	);
	
	// Lookup tables for alpha coefficients.
	float scaleX = physicalSize.width/rectSize.width;
	float scaleY = physicalSize.height/rectSize.height;
	
	float alphaX2[4];
	alphaX2[0] = 0;
	alphaX2[1] = _marginLeft / (physicalSize.width / rectSize.width);
	alphaX2[2] = 1 - _marginRight / (physicalSize.width / rectSize.width);
	alphaX2[3] = 1;
	const float alphaX[4] = {0.0f, _marginLeft, scaleX - _marginRight, scaleX};
	const float alphaY[4] = {0.0f, _marginBottom, scaleY - _marginTop, scaleY};
	
	const float alphaTexX[4] = {0.0f, _marginLeft, 1.0f - _marginRight, 1.0f};
	const float alphaTexY[4] = {0.0f, _marginBottom, 1.0f - _marginTop, 1.0f};
	
	// Interpolation matrices for the vertexes and texture coordinates
	const CCSpriteVertexes *_verts = self.vertexes;
	GLKMatrix4 interpolatePosition = PositionInterpolationMatrix(_verts, transform);
	GLKMatrix3 interpolateTexCoord = TexCoordInterpolationMatrix(_verts);
	GLKVector4 color = _verts->bl.color;
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:18 andVertexes:16 withState:self.renderState globalSortOrder:0];
	
	// Interpolate the vertexes!
	for(int y=0; y<4; y++){
		for(int x=0; x<4; x++){
			GLKVector4 position = GLKMatrix4MultiplyVector4(interpolatePosition, GLKVector4Make(alphaX[x], alphaY[y], 0.0f, 1.0f));
			GLKVector3 texCoord = GLKMatrix3MultiplyVector3(interpolateTexCoord, GLKVector3Make(alphaTexX[x], alphaTexY[y], 1.0f));
			CCRenderBufferSetVertex(buffer, y*4 + x, (CCVertex){position, GLKVector2Make(texCoord.x, texCoord.y), GLKVector2Make(0.0f, 0.0f), color});
		}
	}
	
	// Output lots of triangles.
	for(int y=0; y<3; y++){
		for(int x=0; x<3; x++){
			CCRenderBufferSetTriangle(buffer, y*6 + x*2 + 0, (y + 0)*4 + (x + 0), (y + 0)*4 + (x + 1), (y + 1)*4 + (x + 1));
			CCRenderBufferSetTriangle(buffer, y*6 + x*2 + 1, (y + 0)*4 + (x + 0), (y + 1)*4 + (x + 1), (y + 1)*4 + (x + 0));
		}
	}
}

// ---------------------------------------------------------------------
#pragma mark - properties
// ---------------------------------------------------------------------

- (float)margin
{
    // if margins are not the same, a unified margin can nort be read
    NSAssert(_marginLeft == _marginRight &&
             _marginLeft == _marginTop &&
             _marginLeft == _marginBottom, @"Margin can not be read. Do not know which margin to return");

    // just return any of them
    return(_marginLeft);
}

- (void)setMargin:(float)margin
{
    margin = clampf(margin, 0, 0.5);
    _marginLeft = margin;
    _marginRight = margin;
    _marginTop = margin;
    _marginBottom = margin;
}

// ---------------------------------------------------------------------

- (void)setMarginLeft:(float)marginLeft
{
    _marginLeft = clampf(marginLeft, 0, 1);
    // sum of left and right margin, can not exceed 1
    NSAssert((_marginLeft + _marginRight) <= 1, @"Sum of left and right margine, can not exceed 1");
}

- (void)setMarginRight:(float)marginRight
{
    _marginRight = clampf(marginRight, 0, 1);
    // sum of left and right margin, can not exceed 1
    NSAssert((_marginLeft + _marginRight) <= 1, @"Sum of left and right margine, can not exceed 1");
}

- (void)setMarginTop:(float)marginTop
{
    _marginTop = clampf(marginTop, 0, 1);
    // sum of top and bottom margin, can not exceed 1
    NSAssert((_marginTop + _marginBottom) <= 1, @"Sum of top and bottom margine, can not exceed 1");
}

- (void)setMarginBottom:(float)marginBottom
{
    _marginBottom = clampf(marginBottom, 0, 1);
    // sum of top and bottom margin, can not exceed 1
    NSAssert((_marginTop + _marginBottom) <= 1, @"Sum of top and bottom margine, can not exceed 1");
}

// ---------------------------------------------------------------------

@end
