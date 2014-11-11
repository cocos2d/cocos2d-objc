//
//  CCEffect_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"


#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffect()

@property (nonatomic) NSMutableArray* vertexFunctions;
@property (nonatomic) NSMutableArray* fragmentFunctions;
@property (nonatomic) NSArray* fragmentUniforms;
@property (nonatomic) NSArray* vertexUniforms;
@property (nonatomic) NSArray* varyingVars;

-(void)buildEffectShader;
-(void)buildFragmentFunctions;
-(void)buildVertexFunctions;

@end
#endif
