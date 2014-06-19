//
//  CCEffectStack.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffectStack.h"
#import "CCEffectStack_Private.h"
#import "CCEffect_Private.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectStack

- (id)init
{
    return [self initWithEffects:nil];
}

- (id)initWithEffects:(NSArray *)effects
{
    if ((self = [super init]))
    {
        if (effects)
        {
            _effects = [effects mutableCopy];
        }
        else
        {
            _effects = [[NSMutableArray alloc] init];
        }
        _passesDirty = YES;
        _stitchingEnabled = YES;

        self.debugName = @"CCEffectStack";
        self.stitchFlags = 0;
    }
    return self;
}

- (void)addEffect:(CCEffect *)effect
{
    _passesDirty = YES;
    [_effects addObject:effect];
}

- (void)removeEffect:(CCEffect *)effect
{
    _passesDirty = YES;
    [_effects removeObject:effect];
}

- (NSUInteger)effectCount
{
    return _effects.count;
}

- (CCEffect *)effectAtIndex:(NSUInteger)effectIndex
{
    NSAssert(effectIndex < _effects.count,@"Pass index out of range.");
    return _effects[effectIndex];
}

- (BOOL)prepareForRendering
{
    if (_passesDirty)
    {
        // Make sure stacked effects are also ready for rendering before
        // we do anything else.
        for (CCEffect *effect in _effects)
        {
            [effect prepareForRendering];
        }

        NSMutableArray *stitchedEffects = [[NSMutableArray alloc] init];
        if ((_effects.count == 1) || !_stitchingEnabled)
        {
            // If there's only one effect or if stitching is disabled, just
            // use the original effects array.
            [stitchedEffects addObjectsFromArray:_effects];
        }
        else if (_effects.count > 1)
        {
            NSMutableArray *stitchList = [[NSMutableArray alloc] init];
            CCEffect *prevEffect = [_effects firstObject];
            [stitchList addObject:prevEffect];

            // Iterate over the original effects array building sets of effects
            // that can be stitched together based on their stitch flags.
            for (CCEffect *effect in [_effects subarrayWithRange:NSMakeRange(1, _effects.count - 1)])
            {
                if ([prevEffect stitchSupported:CCEffectFunctionStitchAfter] && [effect stitchSupported:CCEffectFunctionStitchBefore])
                {
                    [stitchList addObject:effect];
                }
                else
                {
                    [stitchedEffects addObject:[self stitchEffects:stitchList]];
                    
                    [stitchList removeAllObjects];
                    [stitchList addObject:prevEffect];
                }
                prevEffect = effect;
            }
            
            if (stitchList.count)
            {
                [stitchedEffects addObject:[self stitchEffects:stitchList]];
            }
        }
        
        // Extract passes from the stacked effects and build a flat list of
        // passes.
        NSMutableArray *passes = [[NSMutableArray alloc] init];
        for (CCEffect *effect in stitchedEffects)
        {
            for (CCEffectRenderPass *pass in effect.renderPasses)
            {
                [passes addObject:pass];
            }
        }
        self.renderPasses = [passes copy];
        _passesDirty = NO;
    }
    return YES;
}

-(CCEffect *)stitchEffects:(NSArray*)effects
{
    NSMutableArray* allFragFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allFragUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVaryings = [[NSMutableArray alloc] init];
    
    int effectIndex = 0;
    for(CCEffect* effect in effects)
    {
        NSString *effectPrefix = [NSString stringWithFormat:@"%@_%d_", effect.debugName, effectIndex];

        NSDictionary *varyingReplacements = [CCEffectStack varyingsByApplyingPrefix:effectPrefix toVaryings:effect.varyingVars];
        [allVaryings addObjectsFromArray:varyingReplacements.allValues];
        
        NSArray *fragmentUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effect.fragmentUniforms withNamesListedInSet:[CCEffect defaultEffectFragmentUniformNames]];
        NSDictionary *fragUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:fragmentUniforms];
        [allFragUniforms addObjectsFromArray:fragUniformReplacements.allValues];
        
        for(CCEffectFunction *function in effect.fragmentFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:fragUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allFragFunctions addObject:prefixedFunction];
        }

        NSArray *vertexUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effect.vertexUniforms withNamesListedInSet:[CCEffect defaultEffectVertexUniformNames]];
        NSDictionary *vtxUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:vertexUniforms];
        [allVertexUniforms addObjectsFromArray:vtxUniformReplacements.allValues];
        
        for(CCEffectFunction* function in effect.vertexFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:vtxUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allVertexFunctions addObject:prefixedFunction];
        }
        
        effect.uniformTranslationTable = [[NSMutableDictionary alloc] init];
        for (NSString *key in vtxUniformReplacements)
        {
            CCEffectUniform *uniform = vtxUniformReplacements[key];
            effect.uniformTranslationTable[key] = uniform.name;
        }

        for (NSString *key in fragUniformReplacements)
        {
            CCEffectUniform *uniform = fragUniformReplacements[key];
            effect.uniformTranslationTable[key] = uniform.name;
        }

        effectIndex++;
    }
    
    CCEffect* stitchedEffect = [[CCEffect alloc] initWithFragmentFunction:allFragFunctions vertexFunctions:allVertexFunctions fragmentUniforms:allFragUniforms vertextUniforms:allVertexUniforms varying:allVaryings];
    stitchedEffect.debugName = @"CCEffectStack_Stitched";
    
    // Copy the shader for this new pass from the stitched effect.
    CCEffectRenderPass *newPass = [[CCEffectRenderPass alloc] init];
    newPass.shader = stitchedEffect.shader;
    newPass.shaderUniforms = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *beginBlocks = [[NSMutableArray alloc] init];
    NSMutableArray *endBlocks = [[NSMutableArray alloc] init];
    
    for (CCEffect *effect in effects)
    {
        // Copy the shader uniforms from each input effect to a shared
        // dictionary for the new pass. For example, if we stitch two effects
        // together, one with uniforms A and B and one with uniforms C and D,
        // we will get one dictionary with A, B, C, and D.
        //
        // Similarly, copy the begin and end blocks from the input passes into
        // the new pass.
        [newPass.shaderUniforms addEntriesFromDictionary:effect.shaderUniforms];
        for (CCEffectRenderPass *pass in effect.renderPasses)
        {
            [beginBlocks addObjectsFromArray:pass.beginBlocks];
            [endBlocks addObjectsFromArray:pass.endBlocks];
        }
    }
    
    newPass.beginBlocks = beginBlocks;
    newPass.endBlocks = endBlocks;
    
    stitchedEffect.renderPasses = @[newPass];
    
    return stitchedEffect;
}

+ (NSDictionary *)varyingsByApplyingPrefix:(NSString *)prefix toVaryings:(NSArray *)varyings
{
    NSMutableDictionary *varyingReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectVarying *varying in varyings)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, varying.name];
        CCEffectVarying *prefixedVarying = [[CCEffectVarying alloc] initWithType:varying.type name:prefixedName];
        [varyingReplacements setObject:prefixedVarying forKey:varying.name];
    }
    return [varyingReplacements copy];
}

+ (NSArray *)uniformsByRemovingUniformsFrom:(NSArray *)uniforms withNamesListedInSet:(NSSet *)toRemove
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CCEffectUniform *uniform = evaluatedObject;
        return ![toRemove containsObject:uniform.name];
    }];
    return [uniforms filteredArrayUsingPredicate:predicate];
}

+ (NSDictionary *)uniformsByApplyingPrefix:(NSString *)prefix toUniforms:(NSArray *)uniforms
{
    NSMutableDictionary *uniformReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectUniform* uniform in uniforms)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, uniform.name];
        CCEffectUniform *prefixedUniform = [[CCEffectUniform alloc] initWithType:uniform.type name:prefixedName value:uniform.value];
        [uniformReplacements setObject:prefixedUniform forKey:uniform.name];
    }
    return [uniformReplacements copy];
}

+ (CCEffectFunction *)effectFunctionByApplyingPrefix:(NSString *)prefix uniformReplacements:(NSDictionary *)uniformReplacements varyingReplacements:(NSDictionary *)varyingReplacements toEffectFunction:(CCEffectFunction *)function
{
    NSString *prefixedBody = [CCEffectStack functionBodyByApplyingUniformReplacements:uniformReplacements varyingReplacements:varyingReplacements toFunctionBody:function.body];
    NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, function.name];
    CCEffectFunction *prefixedFunction = [[CCEffectFunction alloc] initWithName:prefixedName body:prefixedBody inputs:function.inputs returnType:function.returnType];
    return prefixedFunction;
}

+ (NSString *)functionBodyByApplyingUniformReplacements:(NSDictionary *)uniformReplacements varyingReplacements:(NSDictionary *)varyingReplacements toFunctionBody:(NSString *)body
{
    for (NSString *oldUniformName in uniformReplacements)
    {
        CCEffectUniform *newUniform = uniformReplacements[oldUniformName];
        body = [body stringByReplacingOccurrencesOfString:oldUniformName withString:newUniform.name];
    }
    
    for (NSString *oldVaryingName in varyingReplacements)
    {
        CCEffectVarying *newVarying = varyingReplacements[oldVaryingName];
        body = [body stringByReplacingOccurrencesOfString:oldVaryingName withString:newVarying.name];
    }
    
    return body;
}

@end
#endif
