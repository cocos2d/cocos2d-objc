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
 */


/**
 @file
 cocos2d (cc) types
*/

#import <Foundation/Foundation.h>
#import "ccMacros.h"

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID
#import <CoreGraphics/CGGeometry.h>	// CGPoint
#endif

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
#import <GLKit/GLKMath.h>
#endif

#if __CC_PLATFORM_ANDROID
#import "CCMathTypesAndroid.h"

#import "CCMatrix3.h"
#import "CCMatrix4.h"
#import "CCVector2.h"
#import "CCVector3.h"
#import "CCVector4.h"
#import "CCQuaternion.h"

#import "CCMathUtilsAndroid.h"
#endif 

#import "Platforms/CCGL.h"

/** RGB color composed of bytes 3 bytes
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
 */
static inline BOOL ccc4BEqual(ccColor4B a, ccColor4B b)
{
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

/** RGBA color composed of 4 floats
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
 */
static inline ccColor4F ccc4FFromccc3B(ccColor3B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, 1.f};
}

/** Returns a ccColor4F from a ccColor4B.
 */
static inline ccColor4F ccc4FFromccc4B(ccColor4B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, c.a/255.f};
}
	
/** returns YES if both ccColor4F are equal. Otherwise it returns NO.
 */
static inline BOOL ccc4FEqual(ccColor4F a, ccColor4F b)
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}
	
/**
 * Returns a ccColor4B from a ccColor4F.
 */
static inline ccColor4B ccc4BFromccc4F(ccColor4F c)
{
	return (ccColor4B){
		(GLubyte)(clampf(c.r, 0, 1)*255),
		(GLubyte)(clampf(c.g, 0, 1)*255),
		(GLubyte)(clampf(c.b, 0, 1)*255),
		(GLubyte)(clampf(c.a, 0, 1)*255)
	};
}
	
/**
 * Returns a ccColor3B from a ccColor4F.
 */
static inline ccColor3B ccc3BFromccc4F(ccColor4F c)
{
	return (ccColor3B){
		(GLubyte)(clampf(c.r, 0, 1)*255),
		(GLubyte)(clampf(c.g, 0, 1)*255),
		(GLubyte)(clampf(c.b, 0, 1)*255),
	};
}

/**
 * Returns a ccColor3B from a ccColor4F.
 */
static inline ccColor4F ccc4FInterpolated(ccColor4F start, ccColor4F end, float t)
{
	end.r = start.r + (end.r - start.r ) * t;
	end.g = start.g	+ (end.g - start.g ) * t;
	end.b = start.b + (end.b - start.b ) * t;
	end.a = start.a	+ (end.a - start.a ) * t;
	return  end;
}

/** A vertex composed of 2 GLfloats: x, y
 */
typedef struct _ccVertex2F
{
	GLfloat x;
	GLfloat y;
} ccVertex2F;

/** A vertex composed of 2 floats: x, y
 */
typedef struct _ccVertex3F
{
	GLfloat x;
	GLfloat y;
	GLfloat z;
} ccVertex3F;

/** A texcoord composed of 2 floats: u, y
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

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
/// Vertical text alignment type. Used by CCLabelTTF and CCButton.
typedef NS_ENUM(NSUInteger, CCVerticalTextAlignment)
{
    /** Top aligned */
    CCVerticalTextAlignmentTop,
    /** Center aligned */
    CCVerticalTextAlignmentCenter,
    /** Bottom aligned */
    CCVerticalTextAlignmentBottom,
};

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
// NOTE: changed enum from 'unsigned char' to 'uint8_t' because appledoc v2 apparently doesn't handle enum types with a space in between them (creates an enum named 'comma')
/// Horizontal text alignment type. Used by the label nodes CCLabelTTF and CCLabelBMFont.
typedef NS_ENUM(uint8_t, CCTextAlignment)
{
    /** Left aligned */
	CCTextAlignmentLeft,
    /** Center aligned */
	CCTextAlignmentCenter,
    /** Right aligned */
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

/// delta time type
typedef double CCTime;

//typedef float CCMat4[16];

// NOTE: changed enum from 'unsigned char' to 'uint8_t' because appledoc v2 apparently doesn't handle enum types with a space in between them (creates an enum named 'comma')
/** Position unit types alter how a node's position property values are interpreted. Used by, for instance, [CCNode setPositionType:]. */
typedef NS_ENUM(uint8_t, CCPositionUnit)
{
    /// Position is set in points (this is the default)
    CCPositionUnitPoints,
    
    /// Position is UI points, on iOS this corresponds to the native point system
    CCPositionUnitUIPoints,
    
    /// Position is a normalized value multiplied by the content size of the parent's container
    CCPositionUnitNormalized,
    
};

// NOTE: changed enum from 'unsigned char' to 'uint8_t' because appledoc v2 apparently doesn't handle enum types with a space in between them (creates an enum named 'comma')
/** Size unit types alter how a node's contentSize property values are interpreted. Used by, for instance, [CCNode setContentSizeType:]. */
typedef NS_ENUM(uint8_t, CCSizeUnit)
{
    /// Content size is set in points (this is the default)
    CCSizeUnitPoints,
    
    /// Position is UI points, on iOS this corresponds to the native point system
    CCSizeUnitUIPoints,
    
    /// Content size is a normalized value (percentage) multiplied by the content size of the parent's container
    CCSizeUnitNormalized,
    
    /// Content size is the size of the parents container inset by the supplied value
    CCSizeUnitInsetPoints,
    
    /// Content size is the size of the parents container inset by the supplied value multiplied by the UIScaleFactor (as defined by CCDirector)
    CCSizeUnitInsetUIPoints,
    
};
    
// NOTE: changed enum from 'unsigned char' to 'uint8_t' because appledoc v2 apparently doesn't handle enum types with a space in between them (creates an enum named 'comma')
/** Reference corner determines a node's origin and affects how the position property values are interpreted. Used by, for instance, [CCNode setPositionType:]. */
typedef NS_ENUM(uint8_t, CCPositionReferenceCorner)
{
    /// Position is relative to the bottom left corner of the parent container (this is the default)
    CCPositionReferenceCornerBottomLeft,
    
    /// Position is relative to the top left corner of the parent container
    CCPositionReferenceCornerTopLeft,
    
    /// Position is relative to the top right corner of the parent container
    CCPositionReferenceCornerTopRight,
    
    /// Position is relative to the bottom right corner of the parent container
    CCPositionReferenceCornerBottomRight,
    
};

/** Position type compines CCPositionUnit and CCPositionReferenceCorner. */
typedef struct _CCPositionType
{
    CCPositionUnit xUnit;
    CCPositionUnit yUnit;
    CCPositionReferenceCorner corner;
} CCPositionType;

/** Position type compines CCSizeUnit. */
typedef struct _CCSizeType
{
    CCSizeUnit widthUnit;
    CCSizeUnit heightUnit;
} CCSizeType;

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
static inline CCSizeType CCSizeTypeMake(CCSizeUnit widthUnit, CCSizeUnit heightUnit)
{
    CCSizeType cst;
    cst.widthUnit = widthUnit;
    cst.heightUnit = heightUnit;
    return cst;
}

static const CCPositionType CCPositionTypePoints = {CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft};
static const CCPositionType CCPositionTypeUIPoints = {CCPositionUnitUIPoints, CCPositionUnitUIPoints, CCPositionReferenceCornerBottomLeft};
static const CCPositionType CCPositionTypeNormalized = {CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft};


static const CCSizeType CCSizeTypePoints = {CCSizeUnitPoints, CCSizeUnitPoints};
static const CCSizeType CCSizeTypeUIPoints = {CCSizeUnitUIPoints, CCSizeUnitUIPoints};
static const CCSizeType CCSizeTypeNormalized = {CCSizeUnitNormalized, CCSizeUnitNormalized};

// NOTE: changed enum from 'char' to 'int8_t' for consistency with above enums that had to be renamed from "unsigned char" due to an appledoc bug
/** Scale types alter how a node's scale property values are interpreted. Used by, for instance, [CCNode setScaleType:]. */
typedef NS_ENUM(int8_t, CCScaleType) {
    /** Scale is assumed to be in points */
    CCScaleTypePoints,
    /** Scale is assumed to be in UI points */
    CCScaleTypeScaled,
};
    
static inline BOOL CCPositionTypeIsBasicPoints(CCPositionType type)
{
    return (type.xUnit == CCPositionUnitPoints
            && type.yUnit == CCPositionUnitPoints
            && type.corner == CCPositionReferenceCornerBottomLeft);
}

static inline BOOL CCSizeTypeIsBasicPoints(CCSizeType type)
{
    return (type.widthUnit == CCSizeUnitPoints
            && type.heightUnit == CCSizeUnitPoints);
}
    
#ifdef __cplusplus
}
#endif

