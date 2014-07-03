//
//  CCEffect_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"
#import "CCEffectStackProtocol.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS

#ifndef GAUSSIANBLUR_OPTMIZIED_RADIUS_MAX
#define GAUSSIANBLUR_OPTMIZIED_RADIUS_MAX 6
#endif

@interface CCEffect()

@property (nonatomic, weak) id<CCEffectStackProtocol> owningStack;
@property (nonatomic) NSMutableArray* vertexFunctions;
@property (nonatomic) NSMutableArray* fragmentFunctions;
@property (nonatomic) NSArray* fragmentUniforms;
@property (nonatomic) NSArray* vertexUniforms;
@property (nonatomic) NSArray* varyingVars;
@property (nonatomic) NSArray* renderPasses;
@property (nonatomic) CCEffectFunctionStitchFlags stitchFlags;
@property (nonatomic) NSMutableDictionary* uniformTranslationTable;

-(void)buildEffectShader;
-(void)buildFragmentFunctions;
-(void)buildVertexFunctions;
-(void)buildRenderPasses;
-(void)buildUniformTranslationTable;

+ (NSSet *)defaultEffectFragmentUniformNames;
+ (NSSet *)defaultEffectVertexUniformNames;

@end
#endif
