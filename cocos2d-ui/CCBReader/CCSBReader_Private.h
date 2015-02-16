//
//  CCSBReader_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 11/13/13.
//
//

#import "CCSBReader.h"

#define kCCVersion 11

enum {
    kCCPropTypePosition = 0,
    kCCPropTypeSize,
    kCCPropTypePoint,
    kCCPropTypePointLock,
    kCCPropTypeScaleLock,
    kCCPropTypeDegrees,
    kCCPropTypeInteger,
    kCCPropTypeFloat,
    kCCPropTypeFloatVar,
    kCCPropTypeCheck,
    kCCPropTypeSpriteFrame,
    kCCPropTypeTexture,
    kCCPropTypeByte,
    kCCPropTypeColor3,
    kCCPropTypeColor4FVar,
    kCCPropTypeFlip,
    kCCPropTypeBlendmode,
    kCCPropTypeFntFile,
    kCCPropTypeText,
    kCCPropTypeFontTTF,
    kCCPropTypeIntegerLabeled,
    kCCPropTypeBlock,
	kCCPropTypeAnimation,
    kCCPropTypeCCBFile,
    kCCPropTypeString,
    kCCPropTypeBlockCCControl,
    kCCPropTypeFloatScale,
    kCCPropTypeFloatXY,
    kCCPropTypeColor4,
    kCCPropTypeNodeReference,
    kCCPropTypeFloatCheck,
    kCCPropTypeEffects,
    kCCPropTypeTokenArray
};

enum {
    kCCFloat0 = 0,
    kCCFloat1,
    kCCFloatMinus1,
    kCCFloat05,
    kCCFloatInteger,
    kCCFloatFull
};

enum {
    kCCPlatformAll = 0,
    kCCPlatformIOS,
    kCCPlatformMac
};

enum {
    kCCTargetTypeNone = 0,
    kCCTargetTypeDocumentRoot = 1,
    kCCTargetTypeOwner = 2,
};

enum
{
    kCCKeyframeEasingInstant,
    
    kCCKeyframeEasingLinear,
    
    kCCKeyframeEasingCubicIn,
    kCCKeyframeEasingCubicOut,
    kCCKeyframeEasingCubicInOut,
    
    kCCKeyframeEasingElasticIn,
    kCCKeyframeEasingElasticOut,
    kCCKeyframeEasingElasticInOut,
    
    kCCKeyframeEasingBounceIn,
    kCCKeyframeEasingBounceOut,
    kCCKeyframeEasingBounceInOut,
    
    kCCKeyframeEasingBackIn,
    kCCKeyframeEasingBackOut,
    kCCKeyframeEasingBackInOut,
};
