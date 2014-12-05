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

#import "CGPointExtension.h"

#import "ccMacros.h"
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

#ifdef __cplusplus
extern "C" {
#endif

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

