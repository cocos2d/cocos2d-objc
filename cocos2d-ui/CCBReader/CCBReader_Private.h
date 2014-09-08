//
//  CCBReader_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 11/13/13.
//
//

#import "CCBReader.h"

#define kCCBVersion 10

enum {
    kCCBPropTypePosition = 0,
    kCCBPropTypeSize,
    kCCBPropTypePoint,
    kCCBPropTypePointLock,
    kCCBPropTypeScaleLock,
    kCCBPropTypeDegrees,
    kCCBPropTypeInteger,
    kCCBPropTypeFloat,
    kCCBPropTypeFloatVar,
    kCCBPropTypeCheck,
    kCCBPropTypeSpriteFrame,
    kCCBPropTypeTexture,
    kCCBPropTypeByte,
    kCCBPropTypeColor3,
    kCCBPropTypeColor4FVar,
    kCCBPropTypeFlip,
    kCCBPropTypeBlendmode,
    kCCBPropTypeFntFile,
    kCCBPropTypeText,
    kCCBPropTypeFontTTF,
    kCCBPropTypeIntegerLabeled,
    kCCBPropTypeBlock,
	kCCBPropTypeAnimation,
    kCCBPropTypeCCBFile,
    kCCBPropTypeString,
    kCCBPropTypeBlockCCControl,
    kCCBPropTypeFloatScale,
    kCCBPropTypeFloatXY,
    kCCBPropTypeColor4,
    kCCBPropTypeNodeReference,
    kCCBPropTypeFloatCheck,
	kCCBPropTypeEffects,
    
};

enum {
    kCCBFloat0 = 0,
    kCCBFloat1,
    kCCBFloatMinus1,
    kCCBFloat05,
    kCCBFloatInteger,
    kCCBFloatFull
};

enum {
    kCCBPlatformAll = 0,
    kCCBPlatformIOS,
    kCCBPlatformMac
};

enum {
    kCCBTargetTypeNone = 0,
    kCCBTargetTypeDocumentRoot = 1,
    kCCBTargetTypeOwner = 2,
};

enum
{
    kCCBKeyframeEasingInstant,
    
    kCCBKeyframeEasingLinear,
    
    kCCBKeyframeEasingCubicIn,
    kCCBKeyframeEasingCubicOut,
    kCCBKeyframeEasingCubicInOut,
    
    kCCBKeyframeEasingElasticIn,
    kCCBKeyframeEasingElasticOut,
    kCCBKeyframeEasingElasticInOut,
    
    kCCBKeyframeEasingBounceIn,
    kCCBKeyframeEasingBounceOut,
    kCCBKeyframeEasingBounceInOut,
    
    kCCBKeyframeEasingBackIn,
    kCCBKeyframeEasingBackOut,
    kCCBKeyframeEasingBackInOut,
};

@interface CCBReader ()

@end
