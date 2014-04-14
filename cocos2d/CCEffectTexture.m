//
//  CCEffectTexture.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffectTexture.h"
#import "CCEffect_Private.h"

@implementation CCEffectTexture

-(void)buildFragmentFunctions
{
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"textureFunction" body:@"return texture2D(cc_MainTexture, cc_FragTexCoord1);" returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

@end
