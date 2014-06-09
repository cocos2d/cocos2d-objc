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
        
        // Extract passes from the stacked effects and build a flat list
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
    NSMutableArray* fragFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* fragUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* vertexFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* vertexUniforms = [[NSMutableArray alloc] init];
    
    int effectIndex = 0;
    for(CCEffect* effect in effects)
    {
        NSString *effectPrefix = [NSString stringWithFormat:@"%@_%d_", effect.debugName, effectIndex];
        
        NSDictionary *fragUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:effect.fragmentUniforms];
        [fragUniforms addObjectsFromArray:fragUniformReplacements.allValues];
        
        for(CCEffectFunction *function in effect.fragmentFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix andUniformReplacements:fragUniformReplacements toEffectFunction:function];
            [fragFunctions addObject:prefixedFunction];
        }

        NSDictionary *vtxUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:effect.vertexUniforms];
        [vertexUniforms addObjectsFromArray:vtxUniformReplacements.allValues];
        
        for(CCEffectFunction* function in effect.vertexFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix andUniformReplacements:vtxUniformReplacements toEffectFunction:function];
            [vertexFunctions addObject:prefixedFunction];
        }
        
        effectIndex++;
    }
    
    CCEffect* stitchedEffect = [[CCEffect alloc] initWithFragmentFunction:fragFunctions vertexFunctions:vertexFunctions fragmentUniforms:fragUniforms vertextUniforms:vertexUniforms varying:nil];
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

+ (CCEffectFunction *)effectFunctionByApplyingPrefix:(NSString *)prefix andUniformReplacements:(NSDictionary *)uniformReplacements toEffectFunction:(CCEffectFunction *)function
{
    NSString *prefixedBody = [CCEffectStack functionBodyByApplyingUniformReplacements:uniformReplacements toFunctionBody:function.body];
    NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, function.name];
    CCEffectFunction *prefixedFunction = [[CCEffectFunction alloc] initWithName:prefixedName body:prefixedBody inputs:function.inputs returnType:function.returnType];
    return prefixedFunction;
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

+ (NSString *)functionBodyByApplyingUniformReplacements:(NSDictionary *)uniformReplacements toFunctionBody:(NSString *)body
{
    for (NSString *oldUniformName in uniformReplacements)
    {
        CCEffectUniform *newUniform = uniformReplacements[oldUniformName];
        body = [body stringByReplacingOccurrencesOfString:oldUniformName withString:newUniform.name];
    }
    return body;
}

#if 0
+(void)extractFragmentData:(NSArray*)effects functions:(NSMutableArray*)functions uniforms:(NSMutableArray*)uniforms
{
    // Check for duplicate function and uniform names.
    //
    // Initialize the uniform name set with the default CCEffect uniform names
    // so these don't get returned. The logic is that these are automatically
    // added to each effect, not created by the user, so we don't want to return
    // them here. This way the user gets back what they originally specified and
    // no more.
    NSMutableSet* functionNames = [[NSMutableSet alloc] init];
    NSMutableSet* uniformNames = [[NSMutableSet alloc] initWithArray:@[CCShaderUniformPreviousPassTexture]];
    
    // Extract all fragment functions and uniforms
    for(CCEffect* effect in effects)
    {
        for(CCEffectFunction* function in effect.fragmentFunctions)
        {
            if(![functionNames containsObject:function.name])
            {
                [functions addObject:function];
                [functionNames addObject:function.name];
            }
        }

        for(CCEffectUniform* uniform in effect.fragmentUniforms)
        {
            if(![uniformNames containsObject:uniform.name])
            {
                [uniforms addObject:uniform];
                [uniformNames addObject:uniform.name];
            }
        }
    }
}

+(void)extractVertexData:(NSArray*)effects functions:(NSMutableArray*)functions uniforms:(NSMutableArray*)uniforms
{
    // Check for duplicate function and uniform names.
    //
    // Initialize the uniform name set with the default CCEffect uniform names
    // so these don't get returned. The logic is that these are automatically
    // added to each effect, not created by the user, so we don't want to return
    // them here. This way the user gets back what they originally specified and
    // no more.
    NSMutableSet* functionNames = [[NSMutableSet alloc] init];
    NSMutableSet* uniformNames = [[NSMutableSet alloc] initWithArray:@[CCShaderUniformPreviousPassTexture]];
    
    // Extract all vertex functions and uniforms
    for(CCEffect* effect in effects)
    {
        for(CCEffectFunction* function in effect.vertexFunctions)
        {
            if(![functionNames containsObject:function.name])
            {
                [functions addObject:function];
                [functionNames addObject:function.name];
            }
        }
        
        for(CCEffectUniform* uniform in effect.vertexUniforms)
        {
            if(![uniformNames containsObject:uniform.name])
            {
                [uniforms addObject:uniform];
                [uniformNames addObject:uniform.name];
            }
        }
    }
}
#endif

@end
#endif
