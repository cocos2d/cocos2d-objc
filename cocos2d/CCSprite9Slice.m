/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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
#import "CCTexture_Private.h"

// ---------------------------------------------------------------------

const float CCSprite9SliceMarginDefault         = 1.0f/3.0f;

typedef NS_ENUM(NSInteger, CCSprite9SliceSizes)
{
    CCSprite9SliceStrips                        = 3,
    CCSprite9SliceVerticesX                     = 4,
    CCSprite9SliceVerticesY                     = 4,
    CCSprite9SliceVertices                      = 8,
};

// ---------------------------------------------------------------------

@implementation CCSprite9Slice
{
    CGSize _originalContentSize;
    ccV3F_C4B_T2F _quadNine[(CCSprite9SliceVerticesX * CCSprite9SliceVerticesY) + CCSprite9SliceVertices];
    BOOL _quadNineDirty;
}

// ---------------------------------------------------------------------
#pragma mark - create and destroy
// ---------------------------------------------------------------------

- (id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    NSAssert(self != nil, @"Unable to create class");
    
    // initialize new parts in 9slice
    _marginLeft = CCSprite9SliceMarginDefault;
    _marginRight = CCSprite9SliceMarginDefault;
    _marginTop = CCSprite9SliceMarginDefault;
    _marginBottom = CCSprite9SliceMarginDefault;
    
    _quadNineDirty = YES;
    
    // done
    return(self);
}

// ---------------------------------------------------------------------
#pragma mark - overridden properties
// ---------------------------------------------------------------------

- (void)setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
    CGSize oldContentSize = self.contentSize;
    CCContentSizeType oldContentSizeType = self.contentSizeType;
    
    [super setTextureRect:rect rotated:rotated untrimmedSize:untrimmedSize];
    
    // save the original sizes for texture calculations
    _originalContentSize = self.contentSizeInPoints;
    _quadNineDirty = YES;
    
    if (!CGSizeEqualToSize(oldContentSize, CGSizeZero))
    {
        self.contentSizeType = oldContentSizeType;
        self.contentSize = oldContentSize;
    }
}

// ---------------------------------------------------------------------
#pragma mark - lerping functions
// ---------------------------------------------------------------------

- (ccVertex3F)vertex3FLerp:(ccVertex3F)min max:(ccVertex3F)max alpha:(CGPoint)alpha
{
    return((ccVertex3F)
           {
               (min.x * (1 - alpha.x)) + (max.x * alpha.x),
               (min.y * (1 - alpha.y)) + (max.y * alpha.y),
               min.z
           });
}

- (ccTex2F)tex2FLerp:(ccTex2F)min max:(ccTex2F)max alpha:(CGPoint)alpha
{
    if (_rectRotated)
        return((ccTex2F)
               {
                   (min.u * (1 - alpha.y)) + (max.u * alpha.y),
                   (min.v * (1 - alpha.x)) + (max.v * alpha.x)
               });
    return((ccTex2F)
           {
               (min.u * (1 - alpha.x)) + (max.u * alpha.x),
               (min.v * (1 - alpha.y)) + (max.v * alpha.y)
           });
}

- (ccColor4B)color4BLerp:(ccColor4B)min max:(ccColor4B)max alpha:(CGPoint)alpha
{
    return(min);
}

// ---------------------------------------------------------------------
#pragma mark - vertice calculation
// ---------------------------------------------------------------------
// TODO: Implement a dirty flag

- (void)calculateQuadNine
{
    float alphaX[CCSprite9SliceVerticesX];
    float alphaY[CCSprite9SliceVerticesY];
    float alphaTexX[CCSprite9SliceVerticesX];
    float alphaTexY[CCSprite9SliceVerticesY];
    ccV3F_C4B_T2F min, max;
    
    // calculate interpolation min and max
    min.vertices = _quad.bl.vertices;
    min.texCoords = _quad.bl.texCoords;
    
    CGSize physicalSize = CGSizeMake(
                                     self.contentSizeInPoints.width + _rect.size.width - _originalContentSize.width,
                                     self.contentSizeInPoints.height + _rect.size.height - _originalContentSize.height);
    max.vertices = (ccVertex3F)
    {
        _quad.bl.vertices.x + physicalSize.width,
        _quad.bl.vertices.y + physicalSize.height,
        _quad.tr.vertices.z
    };
    max.texCoords = _quad.tr.texCoords;
    
    // calculate alpha
    alphaX[0] = 0;
    alphaX[1] = _marginLeft / (physicalSize.width / _rect.size.width);
    alphaX[2] = 1 - _marginRight / (physicalSize.width / _rect.size.width);
    alphaX[3] = 1;
    
    alphaY[0] = 0;
    alphaY[1] = _marginBottom / (physicalSize.height / _rect.size.height);
    alphaY[2] = 1 - _marginTop / (physicalSize.height / _rect.size.height);
    alphaY[3] = 1;
    
    alphaTexX[0] = 0;
    alphaTexX[1] = _marginLeft;
    alphaTexX[2] = 1 - _marginRight;
    alphaTexX[3] = 1;
    
    alphaTexY[0] = 0;
    alphaTexY[1] = _marginBottom;
    alphaTexY[2] = 1 - _marginTop;
    alphaTexY[3] = 1;
    
    
    for (int strip = 0; strip < CCSprite9SliceStrips; strip ++)
    {
        for (int col = 0; col < CCSprite9SliceVerticesX; col ++)
        {
            int index = 2 * ((strip * CCSprite9SliceVerticesX) + col);
            
            _quadNine[index].vertices = [self vertex3FLerp:min.vertices max:max.vertices alpha:ccp(alphaX[col],alphaY[strip])];
            _quadNine[index].texCoords = [self tex2FLerp:min.texCoords max:max.texCoords alpha:ccp(alphaTexX[col],alphaTexY[strip])];
            _quadNine[index].colors = _quad.bl.colors;

            index ++;
            
            _quadNine[index].vertices = [self vertex3FLerp:min.vertices max:max.vertices alpha:ccp(alphaX[col],alphaY[strip+1])];
            _quadNine[index].texCoords = [self tex2FLerp:min.texCoords max:max.texCoords alpha:ccp(alphaTexX[col],alphaTexY[strip+1])];
            _quadNine[index].colors = _quad.bl.colors;

        }
    }
    
    _quadNineDirty = NO;
}

// ---------------------------------------------------------------------
#pragma mark - draw
// ---------------------------------------------------------------------
// this completely overrides draw of CCSprite
// sprite is divided into 9 quads, and rendered as 3 triangle strips
// 

-( void )draw
{
    if (!_texture) return;
    
    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite9Slice - draw");
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc(_blendFunc.src, _blendFunc.dst);
    
	ccGLBindTexture2D([_texture name]);
    
	// enable buffers
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    
    // calculate quad 9
    // TODO: Enable dirty functionality
    // Disabled, as it for some reason does not work on CCButton
    
    // if (_quadNineDirty) [self calculateQuadNine];
    [self calculateQuadNine];
    
    // set the buffer positions
    // position
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(ccV3F_C4B_T2F), (void *)&_quadNine[0].vertices);
    // texCoods
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(ccV3F_C4B_T2F), (void *)&_quadNine[0].texCoords);
    // color
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(ccV3F_C4B_T2F), (void *)&_quadNine[0].colors);
    
    // loop through strips
    for (int strip = 0; strip < CCSprite9SliceStrips; strip ++)
    {
        // draw
        glDrawArrays(GL_TRIANGLE_STRIP, strip * CCSprite9SliceVertices, CCSprite9SliceVertices);
    }
    
    // check for errors
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4] =
    {
		ccp(_quad.bl.vertices.x,_quad.bl.vertices.y),
		ccp(_quad.bl.vertices.x + _contentSize.width,_quad.bl.vertices.y),
		ccp(_quad.bl.vertices.x + _contentSize.width,_quad.bl.vertices.y + _contentSize.height),
		ccp(_quad.bl.vertices.x,_quad.bl.vertices.y + _contentSize.height),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] =
    {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite9Slice - draw");
}

// ---------------------------------------------------------------------
#pragma mark - properties
// ---------------------------------------------------------------------

- (float)margin
{
    // if margins are not the same, a unified margin can nort be read
    NSAssert(_marginLeft == _marginRight == _marginTop == _marginBottom, @"Margin can not be read. Do not know which margin to return");
    // just return any of them
    return(_marginLeft);
}

- (void)setMargin:(float)margin
{
    margin = clampf(margin, 0, 1);
    _marginLeft = margin;
    _marginRight = margin;
    _marginTop = margin;
    _marginBottom = margin;
    _quadNineDirty = YES;
}

// ---------------------------------------------------------------------

- (void)setMarginLeft:(float)marginLeft
{
    _marginLeft = clampf(marginLeft, 0, 1);
    _quadNineDirty = YES;
    // sum of left and right margin, can not exceed 1
    NSAssert((_marginLeft + _marginRight) <= 1, @"Sum of left and right margine, can not exceed 1");
}

- (void)setMarginRight:(float)marginRight
{
    _marginRight = clampf(marginRight, 0, 1);
    _quadNineDirty = YES;
    // sum of left and right margin, can not exceed 1
    NSAssert((_marginLeft + _marginRight) <= 1, @"Sum of left and right margine, can not exceed 1");
}

- (void)setMarginTop:(float)marginTop
{
    _marginTop = clampf(marginTop, 0, 1);
    _quadNineDirty = YES;
    // sum of top and bottom margin, can not exceed 1
    NSAssert((_marginTop + _marginBottom) <= 1, @"Sum of top and bottom margine, can not exceed 1");
}

- (void)setMarginBottom:(float)marginBottom
{
    _marginBottom = clampf(marginBottom, 0, 1);
    _quadNineDirty = YES;
    // sum of top and bottom margin, can not exceed 1
    NSAssert((_marginTop + _marginBottom) <= 1, @"Sum of top and bottom margine, can not exceed 1");
}

// ---------------------------------------------------------------------

- (void)setBatchNode:(CCSpriteBatchNode *)batchNode
{
    NSAssert(batchNode == nil, @"CCSprite9Slice can not be rendered as a batch node!");
}

// ---------------------------------------------------------------------

@end












































