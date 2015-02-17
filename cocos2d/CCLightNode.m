//
//  CCLightNode.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCLightNode.h"
#import "CCLightCollection.h"
#import "CCScene.h"

#import "CCLightNode_Private.h"


@implementation CCLightNode

-(id)init
{
    return [self initWithType:CCLightPoint groups:nil color:[CCColor whiteColor] intensity:1.0f];
}

-(id)initWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity
{
    return [self initWithType:type groups:groups color:color intensity:intensity specularColor:color specularIntensity:intensity ambientColor:[CCColor whiteColor] ambientIntensity:0.5f];
}

-(id)initWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    if ((self = [super init]))
    {
        _type = type;
        
        _groups = [groups copy];
        
        _color = color.ccColor4f;
        _intensity = intensity;
        
        _specularColor = specularColor;
        _specularIntensity = specularIntensity;
        
        _ambientColor = ambientColor;
        _ambientIntensity = ambientIntensity;
        
        _cutoffRadius = 0.0f;
        _halfRadius = 0.5f;
        
        _depth = 100.0f;
    }
    
    return self;
}

+(instancetype)lightWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity
{
    return [[self alloc] initWithType:type groups:groups color:color intensity:intensity];
}

+(instancetype)lightWithType:(CCLightType)type groups:(NSArray*)groups color:(CCColor *)color intensity:(float)intensity specularColor:(CCColor *)specularColor specularIntensity:(float)specularIntensity ambientColor:(CCColor *)ambientColor ambientIntensity:(float)ambientIntensity
{
    return [[self alloc] initWithType:type groups:groups color:color intensity:intensity specularColor:specularColor specularIntensity:specularIntensity ambientColor:ambientColor ambientIntensity:ambientIntensity];
}

- (void)onEnter
{
    [super onEnter];
    [self.scene.lights addLight:self];

    CCLightCollection *lightCollection = self.scene.lights;
    NSAssert(lightCollection, @"The light node is in a scene but there's no light collection.");
    _groupMask = [lightCollection maskForGroups:_groups];
}

- (void)onExit
{
    _groupMask = 0;
    
    [self.scene.lights removeLight:self];
    [super onExit];
}

-(void)setGroups:(NSArray *)groups
{
    _groups = [groups copy];

    CCLightCollection *lightCollection = self.scene.lights;
    _groupMask = [lightCollection maskForGroups:_groups];
}

-(void)setIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _intensity = clampf(intensity, 0.0f, 1.0f);
}

-(void)setSpecularIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _specularIntensity = clampf(intensity, 0.0f, 1.0f);
}

-(void)setAmbientIntensity:(float)intensity
{
    NSCAssert((intensity >= 0.0) && (intensity <= 1.0), @"Supplied intensity out of range [0..1].");
    _ambientIntensity = clampf(intensity, 0.0f, 1.0f);
}

-(void)setCutoffRadius:(float)radius
{
    NSCAssert(radius >= 0.0, @"Supplied radius out of range [0..inf).");
    _cutoffRadius = MAX(0.0f, radius);
}

-(void)setHalfRadius:(float)radius
{
    NSCAssert((radius >= 0.0) && (radius <= 1.0), @"Supplied radius out of range [0..1].");
    _halfRadius = clampf(radius, 0.0f, 1.0f);
}

@end
