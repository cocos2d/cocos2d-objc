//
//  CCLightNode.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCLightNode.h"

#if CC_EFFECTS_EXPERIMENTAL

@implementation CCLightNode

-(id)init
{
    return [self initWithType:CCLightPoint color:[CCColor whiteColor] intensity:1.0f];
}

-(id)initWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity
{
    return [self initWithType:type color:color intensity:intensity specularColor:color specularIntensity:intensity ambientColor:[CCColor whiteColor] ambientIntensity:0.5f];
}

-(id)initWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    if ((self = [super init]))
    {
        _type = type;
        
        _color = color.ccColor4f;
        _intensity = intensity;
        
        _specularColor = specularColor;
        _specularIntensity = specularIntensity;
        
        _ambientColor = ambientColor;
        _ambientIntensity = ambientIntensity;
        
        _cutoffRadius = 0.0f;
        if (type == CCLightDirectional)
        {
            _depth = 1.0f;
        }
        else
        {
            _depth = 500.0f;
        }
    }
    
    return self;
}

+(id)lightWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity
{
    return [[self alloc] initWithType:type color:color intensity:intensity];
}

+(id)lightWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    return [[self alloc] initWithType:type color:color intensity:intensity specularColor:specularColor specularIntensity:specularIntensity ambientColor:ambientColor ambientIntensity:ambientIntensity];
}

-(void)setIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _intensity = intensity;
}

-(void)setSpecularIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _specularIntensity = intensity;
}

-(void)setAmbientIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _ambientIntensity = intensity;
}

@end

#endif
