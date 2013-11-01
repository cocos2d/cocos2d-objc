/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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
 */


/**
 @file
 cocos2d (cc) types
*/

#import <Foundation/Foundation.h>
#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import <CoreGraphics/CGGeometry.h>	// CGPoint
#endif

#import "Platforms/CCGL.h"

/** RGB color composed of bytes 3 bytes
@since v0.8
 */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _ccColor3B
{
	GLubyte	r;
	GLubyte	g;
	GLubyte b;
} ccColor3B;

//! helper macro that creates an ccColor3B type
static inline ccColor3B
ccc3(const GLubyte r, const GLubyte g, const GLubyte b)
{
	ccColor3B c = {r, g, b};
	return c;
}

	//ccColor3B predefined colors
//! White color (255,255,255)
static const ccColor3B ccWHITE = {255,255,255};
//! Yellow color (255,255,0)
static const ccColor3B ccYELLOW = {255,255,0};
//! Blue color (0,0,255)
static const ccColor3B ccBLUE = {0,0,255};
//! Green Color (0,255,0)
static const ccColor3B ccGREEN = {0,255,0};
//! Red Color (255,0,0,)
static const ccColor3B ccRED = {255,0,0};
//! Magenta Color (255,0,255)
static const ccColor3B ccMAGENTA = {255,0,255};
//! Black Color (0,0,0)
static const ccColor3B ccBLACK = {0,0,0};
//! Orange Color (255,127,0)
static const ccColor3B ccORANGE = {255,127,0};
//! Gray Color (166,166,166)
static const ccColor3B ccGRAY = {166,166,166};

/** RGBA color composed of 4 bytes
@since v0.8
*/
typedef struct _ccColor4B
{
	GLubyte	r;
	GLubyte	g;
	GLubyte	b;
	GLubyte a;
} ccColor4B;
//! helper macro that creates an ccColor4B type
static inline ccColor4B
ccc4(const GLubyte r, const GLubyte g, const GLubyte b, const GLubyte o)
{
	ccColor4B c = {r, g, b, o};
	return c;
}

/** returns YES if both ccColor4F are equal. Otherwise it returns NO.
 @since v0.99.1
 */
static inline BOOL ccc4BEqual(ccColor4B a, ccColor4B b)
{
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

/** RGBA color composed of 4 floats
@since v0.8
*/
typedef struct _ccColor4F {
	GLfloat r;
	GLfloat g;
	GLfloat b;
	GLfloat a;
} ccColor4F;

//! helper that creates a ccColor4f type
static inline ccColor4F ccc4f(const GLfloat r, const GLfloat g, const GLfloat b, const GLfloat a)
{
	return (ccColor4F){r, g, b, a};
}

/** Returns a ccColor4F from a ccColor3B. Alpha will be 1.
 @since v0.99.1
 */
static inline ccColor4F ccc4FFromccc3B(ccColor3B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, 1.f};
}

/** Returns a ccColor4F from a ccColor4B.
 @since v0.99.1
 */
static inline ccColor4F ccc4FFromccc4B(ccColor4B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, c.a/255.f};
}

/** returns YES if both ccColor4F are equal. Otherwise it returns NO.
 @since v0.99.1
 */
static inline BOOL ccc4FEqual(ccColor4F a, ccColor4F b)
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}
	
static inline ccColor4B ccc4BFromccc4F(ccColor4F c)
{
	return (ccColor4B){(GLubyte)(c.r*255), (GLubyte)(c.g*255), (GLubyte)(c.b*255), (GLubyte)(c.a*255)};
}


/** A vertex composed of 2 GLfloats: x, y
 @since v0.8
 */
typedef struct _ccVertex2F
{
	GLfloat x;
	GLfloat y;
} ccVertex2F;

/** A vertex composed of 2 floats: x, y
 @since v0.8
 */
typedef struct _ccVertex3F
{
	GLfloat x;
	GLfloat y;
	GLfloat z;
} ccVertex3F;

/** A texcoord composed of 2 floats: u, y
 @since v0.8
 */
typedef struct _ccTex2F {
	 GLfloat u;
	 GLfloat v;
} ccTex2F;


//! Point Sprite component
typedef struct _ccPointSprite
{
	ccVertex2F	pos;		// 8 bytes
	ccColor4B	color;		// 4 bytes
	GLfloat		size;		// 4 bytes
} ccPointSprite;

//!	A 2D Quad. 4 * 2 floats
typedef struct _ccQuad2 {
	ccVertex2F		tl;
	ccVertex2F		tr;
	ccVertex2F		bl;
	ccVertex2F		br;
} ccQuad2;


//!	A 3D Quad. 4 * 3 floats
typedef struct _ccQuad3 {
	ccVertex3F		bl;
	ccVertex3F		br;
	ccVertex3F		tl;
	ccVertex3F		tr;
} ccQuad3;

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct _ccV2F_C4B_T2F
{
	//! vertices (2F)
	ccVertex2F		vertices;
	//! colors (4B)
	ccColor4B		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4B_T2F;

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct _ccV2F_C4F_T2F
{
	//! vertices (2F)
	ccVertex2F		vertices;
	//! colors (4F)
	ccColor4F		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4F_T2F;

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct _ccV3F_C4F_T2F
{
	//! vertices (3F)
	ccVertex3F		vertices;
	//! colors (4F)
	ccColor4F		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV3F_C4F_T2F;

//! 4 ccV3F_C4F_T2F
typedef struct _ccV3F_C4F_T2F_Quad
{
	//! top left
	ccV3F_C4F_T2F	tl;
	//! bottom left
	ccV3F_C4F_T2F	bl;
	//! top right
	ccV3F_C4F_T2F	tr;
	//! bottom right
	ccV3F_C4F_T2F	br;
} ccV3F_C4F_T2F_Quad;

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct _ccV3F_C4B_T2F
{
	//! vertices (3F)
	ccVertex3F		vertices;			// 12 bytes
//	char __padding__[4];

	//! colors (4B)
	ccColor4B		colors;				// 4 bytes
//	char __padding2__[4];

	// tex coords (2F)
	ccTex2F			texCoords;			// 8 byts
} ccV3F_C4B_T2F;

	
//! A Triangle of ccV2F_C4B_T2F 
typedef struct _ccV2F_C4B_T2F_Triangle
{
	//! Point A
	ccV2F_C4B_T2F a;
	//! Point B
	ccV2F_C4B_T2F b;
	//! Point B
	ccV2F_C4B_T2F c;
} ccV2F_C4B_T2F_Triangle;
	
//! A Quad of ccV2F_C4B_T2F
typedef struct _ccV2F_C4B_T2F_Quad
{
	//! bottom left
	ccV2F_C4B_T2F	bl;
	//! bottom right
	ccV2F_C4B_T2F	br;
	//! top left
	ccV2F_C4B_T2F	tl;
	//! top right
	ccV2F_C4B_T2F	tr;
} ccV2F_C4B_T2F_Quad;

//! 4 ccVertex3FTex2FColor4B
typedef struct _ccV3F_C4B_T2F_Quad
{
	//! top left
	ccV3F_C4B_T2F	tl;
	//! bottom left
	ccV3F_C4B_T2F	bl;
	//! top right
	ccV3F_C4B_T2F	tr;
	//! bottom right
	ccV3F_C4B_T2F	br;
} ccV3F_C4B_T2F_Quad;

//! 4 ccVertex2FTex2FColor4F Quad
typedef struct _ccV2F_C4F_T2F_Quad
{
	//! bottom left
	ccV2F_C4F_T2F	bl;
	//! bottom right
	ccV2F_C4F_T2F	br;
	//! top left
	ccV2F_C4F_T2F	tl;
	//! top right
	ccV2F_C4F_T2F	tr;
} ccV2F_C4F_T2F_Quad;

//! Blend Function used for textures
typedef struct _ccBlendFunc
{
	//! source blend function
	GLenum src;
	//! destination blend function
	GLenum dst;
} ccBlendFunc;

static const ccBlendFunc kCCBlendFuncDisable = {GL_ONE, GL_ZERO};

//! ccResolutionType
typedef NS_ENUM(NSUInteger, CCResolutionType)
{
	//! Unknown resolution type
	CCResolutionTypeUnknown,
#ifdef __CC_PLATFORM_IOS
	//! iPhone resolution type
	CCResolutionTypeiPhone,
	//! iPhone RetinaDisplay resolution type
	CCResolutionTypeiPhoneRetinaDisplay,
	//! iPhone5 resolution type
	CCResolutionTypeiPhone5,
	//! iPhone 5 RetinaDisplay resolution type
	CCResolutionTypeiPhone5RetinaDisplay,
	//! iPad resolution type
	CCResolutionTypeiPad,
	//! iPad Retina Display resolution type
	CCResolutionTypeiPadRetinaDisplay,
	
#elif defined(__CC_PLATFORM_MAC)
	//! Mac resolution type
	CCResolutionTypeMac,

	//! Mac RetinaDisplay resolution type
	CCResolutionTypeMacRetinaDisplay,
#endif // platform

};

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Vertical text alignment type
typedef NS_ENUM(NSUInteger, CCVerticalTextAlignment)
{
    CCVerticalTextAlignmentTop,
    CCVerticalTextAlignmentCenter,
    CCVerticalTextAlignmentBottom,
};

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Horizontal text alignment type
typedef NS_ENUM(NSUInteger, CCTextAlignment)
{
	CCTextAlignmentLeft,
	CCTextAlignmentCenter,
	CCTextAlignmentRight,
};

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Line break modes
    /*
typedef NS_ENUM(NSUInteger, CCLineBreakMode)
{
	CCLineBreakModeWordWrap,
	CCLineBreakModeCharacterWrap,
	CCLineBreakModeClip,
	CCLineBreakModeHeadTruncation,
	CCLineBreakModeTailTruncation,
	CCLineBreakModeMiddleTruncation
};*/

//! delta time type
typedef double CCTime;

//typedef float CCMat4[16];
    
enum
{
    //! Position is set in points (this is the default)
    CCPositionUnitPoints,
    
    //! Position is scaled by the global positionScaleFactor (as defined by CCDirector)
    CCPositionUnitScaled,
    
    //! Position is a normalized value multiplied by the content size of the parent's container
    CCPositionUnitNormalized,
    
};
typedef unsigned char CCPositionUnit;

enum
{
    //! Content size is set in points (this is the default)
    CCContentSizeUnitPoints,
    
    //! Content size is scaled by the global positionScaleFactor (as defined by CCDirector)
    CCContentSizeUnitScaled,
    
    //! Content size is a normalized value multiplied by the content size of the parent's container
    CCContentSizeUnitNormalized,
    
    //! Content size is the size of the parents container inset by the supplied value
    CCContentSizeUnitInsetPoints,
    
    //! Content size is the size of the parents container inset by the supplied value multiplied by the positionScaleFactor (as defined by CCDirector)
    CCContentSizeUnitInsetScaled,
    
};
typedef unsigned char CCContentSizeUnit;
    
enum
{
    //! Position is relative to the bottom left corner of the parent container (this is the default)
    CCPositionReferenceCornerBottomLeft,
    
    //! Position is relative to the top left corner of the parent container
    CCPositionReferenceCornerTopLeft,
    
    //! Position is relative to the top right corner of the parent container
    CCPositionReferenceCornerTopRight,
    
    //! Position is relative to the bottom right corner of the parent container
    CCPositionReferenceCornerBottomRight,
    
};
typedef unsigned char CCPositionReferenceCorner;

typedef struct _CCPositionType
{
    CCPositionUnit xUnit;
    CCPositionUnit yUnit;
    CCPositionReferenceCorner corner;
} CCPositionType;

typedef struct _CCContentSizeType
{
    CCContentSizeUnit widthUnit;
    CCContentSizeUnit heightUnit;
} CCContentSizeType;

//! helper that creates a CCPositionType type
static inline CCPositionType CCPositionTypeMake(CCPositionUnit xUnit, CCPositionUnit yUnit, CCPositionReferenceCorner corner)
{
    CCPositionType pt;
    pt.xUnit = xUnit;
    pt.yUnit = yUnit;
    pt.corner = corner;
    return pt;
}

//! helper that creates a CCContentSizeType type
static inline CCContentSizeType CCContentSizeTypeMake(CCContentSizeUnit widthUnit, CCContentSizeUnit heightUnit)
{
    CCContentSizeType cst;
    cst.widthUnit = widthUnit;
    cst.heightUnit = heightUnit;
    return cst;
}

#define CCPositionTypePoints CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft)

#define CCPositionTypeScaled CCPositionTypeMake(CCPositionUnitScaled, CCPositionUnitScaled, CCPositionReferenceCornerBottomLeft)

#define CCPositionTypeNormalized CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft)


#define CCContentSizeTypePoints CCContentSizeTypeMake(CCContentSizeUnitPoints, CCContentSizeUnitPoints)
#define CCContentSizeTypeScaled CCContentSizeTypeMake(CCContentSizeUnitScaled, CCContentSizeUnitScaled)
#define CCContentSizeTypeNormalized CCContentSizeTypeMake(CCContentSizeUnitNormalized, CCContentSizeUnitNormalized)

typedef NS_ENUM(char, CCScaleType) {
    CCScaleTypePoints,
    CCScaleTypeScaled,
};
    
#ifdef __cplusplus
}
#endif

