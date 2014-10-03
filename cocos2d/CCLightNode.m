//
//  CCLightNode.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/3/14.
//
//

#import "CCLightNode.h"

@implementation CCLightNode

-(id)initWithColor:(CCColor *)color intensity:(float)intensity
{
    if ((self = [super init]))
    {
        _color = color.ccColor4f;
        _intensity = intensity;
    }
    
    return self;
}

+(id)lightWithColor:(CCColor *)color intensity:(float)intensity
{
    return [[self alloc] initWithColor:color intensity:intensity];
}


@end
