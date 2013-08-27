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

// ---------------------------------------------------------------------

const float CCSprite9SliceMarginDefault         = 0.1f;

typedef enum {
    CCSprite9SliceStrips                        = 3,
    CCSprite9SliceVerticesX                     = 4,
    CCSprite9SliceVerticesY                     = 4,
    CCSprite9SliceVertices                      = 8,
} CCSprite9SliceSizes;

// ---------------------------------------------------------------------

@implementation CCSprite9Slice {
    CGSize              _originalContentSize;
    CGPoint             _contentScale;
}

// ---------------------------------------------------------------------
#pragma mark - create and destroy
// ---------------------------------------------------------------------

-( id )initWithTexture:( CCTexture2D* )texture rect:( CGRect )rect rotated:( BOOL )rotated {
    self = [ super initWithTexture:texture rect:rect rotated:rotated ];
    
    // initialize new parts in 9slice
    _marginLeft = CCSprite9SliceMarginDefault;
    _marginRight = CCSprite9SliceMarginDefault;
    _marginTop = CCSprite9SliceMarginDefault;
    _marginBottom = CCSprite9SliceMarginDefault;
    
    // done
    return( self );
}

// ---------------------------------------------------------------------
// override to set original contentSize when a texture is assigned

-( void )setTextureRect:( CGRect )rect rotated:( BOOL )rotated untrimmedSize:( CGSize )untrimmedSize {
    [ super setTextureRect:rect rotated:rotated untrimmedSize:untrimmedSize ];
    _originalContentSize = self.contentSize;
}

// ---------------------------------------------------------------------
#pragma mark - draw
// ---------------------------------------------------------------------

-( ccV3F_C4B_T2F )calculateVertice:( CGPoint )mult andTexture:( CGPoint )texMult {
    ccV3F_C4B_T2F result;
    CGPoint invMult = ccp( 1 - mult.x, 1 - mult.y );
    CGPoint invTexMult = ccp( 1 - texMult.x, 1 - texMult.y );
    
    // calculate vertices, color and texture coordinates
    result.vertices.x = _contentScale.x * ( ( _quad.bl.vertices.x * invMult.x ) + ( _quad.br.vertices.x * mult.x ) );
    result.vertices.y = _contentScale.y * ( ( _quad.bl.vertices.y * invMult.y ) + ( _quad.tl.vertices.y * mult.y ) );
    result.vertices.z = _quad.bl.vertices.z;
    result.colors = _quad.bl.colors;
    result.texCoords.u = ( _quad.bl.texCoords.u * invTexMult.x ) + ( _quad.br.texCoords.u * texMult.x );
    result.texCoords.v = ( _quad.bl.texCoords.v * invTexMult.y ) + ( _quad.tl.texCoords.v * texMult.y );
    
    // done
    return( result );
}

// ---------------------------------------------------------------------
// this completely overrides draw of CCSprite
// sprite is divided into 9 quads, and rendered as 3 triangle strips
// 

-( void )draw {
    
    // create a clamped content size
    CGSize clampedSize = self.contentSize;
    if ( clampedSize.width < ( _originalContentSize.width * ( _marginLeft + _marginRight ) ) ) clampedSize.width = _originalContentSize.width * ( _marginLeft + _marginRight );
    if ( clampedSize.height < ( _originalContentSize.height * ( _marginTop + _marginBottom ) ) ) clampedSize.height = _originalContentSize.height * ( _marginTop + _marginBottom );
    
    _contentScale = CGPointMake( clampedSize.width / _originalContentSize.width, clampedSize.height / _originalContentSize.height );
    
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite9Slice - draw");
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	ccGLBindTexture2D( [ _texture name] );
    
	// enable buffers
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

    // create space for a single strip, and set single color
    ccV3F_C4B_T2F vertice[ CCSprite9SliceVertices ];

    // set the buffer positions
    // position
	glVertexAttribPointer( kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof( ccV3F_C4B_T2F ), ( void* )&vertice[ 0 ].vertices );
	// texCoods
	glVertexAttribPointer( kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof( ccV3F_C4B_T2F ), ( void* )&vertice[ 0 ].texCoords );
	// color
	glVertexAttribPointer( kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof( ccV3F_C4B_T2F ), ( void* )&vertice[ 0 ].colors );
    
    // create some helper vars
    float multX[ CCSprite9SliceVerticesX ] = { 0, _marginLeft / _contentScale.x, 1 - ( _marginRight / _contentScale.x ), 1 };
    float multY[ CCSprite9SliceVerticesY ] = { 0, _marginBottom / _contentScale.y, 1 - ( _marginTop / _contentScale.y ), 1 };

    float texMultX[ CCSprite9SliceVerticesX ] = { 0, _marginLeft, 1 - _marginRight, 1 };
    float texMultY[ CCSprite9SliceVerticesY ] = { 0, _marginBottom, 1 - _marginTop, 1 };

    // create bottow row vertices
    for ( int index = 0; index < CCSprite9SliceVerticesX; index ++ ) {
        vertice[ index * 2 ] = [ self calculateVertice:ccp( multX[ index ], multY[ 0 ] ) andTexture:ccp( texMultX[ index ], texMultY[ 0 ] ) ];
    }
    
    // scan through the strips
    for ( int strip = 0; strip < CCSprite9SliceStrips; strip ++ ) {
        
        // create top row vertices
        for ( int index = 0; index < CCSprite9SliceVerticesX; index ++ ) {
            vertice[ ( index * 2 ) + 1 ] = [ self calculateVertice:ccp( multX[ index ], multY[ strip + 1 ] ) andTexture:ccp( texMultX[ index ], texMultY[ strip + 1 ] )  ];
        }
        
        // draw
        glDrawArrays( GL_TRIANGLE_STRIP, 0, 8 );
    
        // copy top vertices to bottom vertices
        for ( int index = 0; index < CCSprite9SliceVerticesX; index ++ ) {
            vertice[ index * 2 ] = vertice[ ( index * 2 ) + 1 ];
        }
        
    }
    
    // check for errors
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(_quad.tl.vertices.x,_quad.tl.vertices.y),
		ccp(_quad.bl.vertices.x,_quad.bl.vertices.y),
		ccp(_quad.br.vertices.x,_quad.br.vertices.y),
		ccp(_quad.tr.vertices.x,_quad.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
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

-( float )margin {
    // if margins are not the same, a unified margin can nort be read
    NSAssert( _marginLeft == _marginRight == _marginTop == _marginBottom, @"Margin can not be read. Do not know which margin to return" );
    // just return any of them
    return( _marginLeft );
}

-( void )setMargin:( float )margin {
    margin = clampf( margin, 0, 1 );
    _marginLeft = margin;
    _marginRight = margin;
    _marginTop = margin;
    _marginBottom = margin;
}

// ---------------------------------------------------------------------

-( void )setMarginLeft:(float)marginLeft {
    _marginLeft = clampf( marginLeft, 0, 1 );
    // sum of left and right margin, can not exceed 1
    NSAssert( ( _marginLeft + _marginRight ) <= 1, @"Sum of left and right margine, can not exceed 1" );
}

-( void )setMarginRight:( float )marginRight {
    _marginRight = clampf( marginRight, 0, 1 );
    // sum of left and right margin, can not exceed 1
    NSAssert( ( _marginLeft + _marginRight ) <= 1, @"Sum of left and right margine, can not exceed 1" );
}

-( void )setMarginTop:( float )marginTop {
    _marginTop = clampf( marginTop, 0, 1 );
    // sum of top and bottom margin, can not exceed 1
    NSAssert( ( _marginTop + _marginBottom ) <= 1, @"Sum of top and bottom margine, can not exceed 1" );
}

-( void )setMarginBottom:( float )marginBottom {
    _marginBottom = clampf( marginBottom, 0, 1 );
    // sum of top and bottom margin, can not exceed 1
    NSAssert( ( _marginTop + _marginBottom ) <= 1, @"Sum of top and bottom margine, can not exceed 1" );
}

// ---------------------------------------------------------------------

-( void )setBatchNode:( CCSpriteBatchNode* )batchNode {
    NSAssert( batchNode == nil, @"CCSprite9Slice can not be rendered as a batch node!" );
}

// ---------------------------------------------------------------------

@end












































