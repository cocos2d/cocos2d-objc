//
//  CCLightNode.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCLightNode.h"


@implementation CCLightNode

-(id)init
{
    return [self initWithType:CCLightPoint color:[CCColor whiteColor] intensity:1.0f ambientColor:[CCColor whiteColor] ambientIntensity:0.5f];
}


-(id)initWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    if ((self = [super init]))
    {
        _type = type;
        _color = color.ccColor4f;
        _intensity = intensity;
        _ambientColor = ambientColor;
        _ambientIntensity = ambientIntensity;
    }
    
    return self;
}

+(id)lightWithType:(CCLightType)type color:(CCColor *)color intensity:(float)intensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    return [[self alloc] initWithType:type color:color intensity:intensity ambientColor:ambientColor ambientIntensity:ambientIntensity];
}

-(void)setIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _intensity = intensity;
}

-(void)setAmbientIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _ambientIntensity = intensity;
}

@end
