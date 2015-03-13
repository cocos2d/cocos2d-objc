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


@implementation CCEffectStack

#pragma mark - API

- (id)init
{
    return [self initWithArray:nil];
}

- (id)initWithArray:(NSArray *)effects
{
    NSAssert(effects.count, @"CCEffectStack unexpectedly supplied a nil or empty effects array.");
    if ((self = [super init]))
    {
        _effects = [effects copy];
        _stitchingEnabled = YES;

        // Flatten the supplied effects array, collapsing any sub-stacks up into this one.
        NSMutableArray *flattenedEffects = [[NSMutableArray alloc] initWithArray:_effects];
        NSUInteger index = 0;
        while (index < flattenedEffects.count)
        {
            // Visit each effect in the current flattened list.
            CCEffect *effect = flattenedEffects[index];
            if ([effect isKindOfClass:[CCEffectStack class]])
            {
                // If the current effect is a stack, get the effects it contains
                // and put them in our flattened list. Don't increment index though
                // because the first effect that we just inserted might also be
                // a stack so we need to stay at this position and inspect it in
                // the next loop iteration.
                CCEffectStack *stack = (CCEffectStack *)effect;
                [flattenedEffects replaceObjectsInRange:NSMakeRange(index, 1) withObjectsFromArray:stack.effects];
            }
            else
            {
                // The current effect is not a stack so just advance to the
                // next effect.
                index++;
            }
        }
        _flattenedEffects = [flattenedEffects copy];
        
        self.debugName = @"CCEffectStack";
    }
    return self;
}

- (id)initWithEffect:(CCEffect*)effect1 vaList:(va_list)args
{
    NSMutableArray *effects = [[NSMutableArray alloc] init];
	
    CCEffect *effect = effect1;
	while(effect)
    {
        [effects addObject:effect];
		effect = va_arg(args, CCEffect*);
	}
    
	return [self initWithArray:effects];
}

- (id)initWithEffects:(CCEffect*)effect1, ...
{
	va_list args;
	va_start(args, effect1);
    
	id ret = [self initWithEffect:effect1 vaList:args];
    
	va_end(args);
    
	return ret;
}


+ (id)effectWithArray:(NSArray *)arrayOfEffects
{
    return [[self alloc] initWithArray:arrayOfEffects];
}

+ (id)effects:(CCEffect*)effect1, ...
{
	va_list args;
	va_start(args, effect1);
    
	id ret = [[self alloc] initWithEffect:effect1 vaList:args];
    
	va_end(args);
    
	return ret;
}

- (NSUInteger)effectCount
{
    return _effects.count;
}

- (CCEffect *)effectAtIndex:(NSUInteger)effectIndex
{
    NSAssert(effectIndex < _effects.count,@"Effect index out of range.");
    return _effects[effectIndex];
}

#pragma mark - CCEffect overrides

- (CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite
{
    CCEffectPrepareResult finalResult = CCEffectPrepareNoop;

    CGSize maxPadding = CGSizeZero;;
    for (CCEffect *effect in _flattenedEffects)
    {
        // Make sure all the contained effects are ready for rendering
        // before we do anything else.
        CCEffectPrepareResult prepResult = [effect prepareForRenderingWithSprite:sprite];
        NSAssert(prepResult.status == CCEffectPrepareSuccess, @"Effect preparation failed.");
        
        // Anything that changed in a sub-effect should be flagged as changed for the entire stack.
        finalResult.changes |= prepResult.changes;
        
        // And find the max padding values of all contained effects.
        if (effect.padding.width > maxPadding.width)
        {
            maxPadding.width = effect.padding.width;
        }
        
        if (effect.padding.height > maxPadding.height)
        {
            maxPadding.height = effect.padding.height;
        }
    }
    self.padding = maxPadding;
    
    if (!self.effectImpl.renderPasses.count || finalResult.changes)
    {
        self.effectImpl = [CCEffectStack processEffects:_flattenedEffects withStitching:_stitchingEnabled];
        if (!self.effectImpl)
        {
            self.effectImpl = [CCEffectStack processEffects:_flattenedEffects withStitching:NO];
            NSAssert(self.effectImpl, @"Effect creation failed with stitching disabled.");
        }
        
        // Stitching and name mangling changes the uniform dictionary so flag it
        // as changed. If we're here then the render passes are already flagged
        // as changed so we don't have to do that now.
        finalResult.changes |= CCEffectPrepareUniformsChanged;
    }
    
    return finalResult;
}

#pragma mark - Internal

+ (CCEffectImpl *)processEffects:(NSArray *)effects withStitching:(BOOL)stitchingEnabled
{
    NSMutableArray *stitchedEffects = [[NSMutableArray alloc] init];
    NSMutableArray *stitchLists = [[NSMutableArray alloc] init];
    
    CCEffect *firstEffect = [effects firstObject];
    NSMutableArray *currentStitchList = [[NSMutableArray alloc] initWithArray:@[firstEffect.effectImpl]];
    [stitchLists addObject:currentStitchList];
    
    // Iterate over the original effects array building sets of effects
    // that can be stitched together based on their stitch flags.
    for (CCEffect *effect in [effects subarrayWithRange:NSMakeRange(1, effects.count - 1)])
    {
        CCEffectImpl *prevEffectImpl = [currentStitchList lastObject];
        if (stitchingEnabled && [prevEffectImpl stitchSupported:CCEffectFunctionStitchAfter] && [effect.effectImpl stitchSupported:CCEffectFunctionStitchBefore])
        {
            [currentStitchList addObject:effect.effectImpl];
        }
        else
        {
            currentStitchList = [[NSMutableArray alloc] initWithArray:@[effect.effectImpl]];
            [stitchLists addObject:currentStitchList];
        }
    }
    
    int effectIndex = 0;
    for (NSArray *stitchList in stitchLists)
    {
        CCEffectImpl *effectImpl = [CCEffectStack stitchEffects:stitchList startIndex:effectIndex];
        if (!effectImpl)
        {
            return nil;
        }
        [stitchedEffects addObject:effectImpl];
        effectIndex += stitchList.count;
    }
    
    // Extract passes and uniforms from the stacked and stitched effects and build a flat list of
    // both.
    NSMutableArray *passes = [[NSMutableArray alloc] init];
    NSMutableDictionary *uniforms = [[NSMutableDictionary alloc] init];
    for (CCEffectImpl *effectImpl in stitchedEffects)
    {
        for (CCEffectRenderPass *pass in effectImpl.renderPasses)
        {
            [passes addObject:pass];
        }
        
        [uniforms addEntriesFromDictionary:effectImpl.shaderUniforms];
    }
    return [[CCEffectImpl alloc] initWithRenderPasses:passes shaderUniforms:uniforms];
}

+ (CCEffectImpl *)stitchEffects:(NSArray*)stitchList startIndex:(int)startIndex
{
    NSAssert(stitchList.count > 0, @"Encountered an empty stitch list which shouldn't happen.");

    NSMutableArray* allFragFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allFragUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVaryings = [[NSMutableArray alloc] init];
    NSMutableArray* allUTTs = [[NSMutableArray alloc] init];

    // Even if we're only handed one effect in this stitch list, we have to run it through the
    // name mangling code below because all effects in a stack share one uniform namespace.
    int effectIndex = startIndex;
    for(CCEffectImpl* effectImpl in stitchList)
    {
        // Construct the prefix to use for name mangling.
        NSString *effectPrefix = [NSString stringWithFormat:@"%@_%d_", effectImpl.debugName, effectIndex];

        // Mangle the names of the current effect's varyings and record the results.
        NSDictionary *varyingReplacements = [CCEffectStack varyingsByApplyingPrefix:effectPrefix toVaryings:effectImpl.varyingVars];
        [allVaryings addObjectsFromArray:varyingReplacements.allValues];

        // Mangle the names of the current effect's fragment uniforms and record the results.
        NSArray *fragmentUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effectImpl.fragmentUniforms withNamesListedInSet:[CCEffectImpl defaultEffectFragmentUniformNames]];
        NSDictionary *fragUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:fragmentUniforms];
        [allFragUniforms addObjectsFromArray:fragUniformReplacements.allValues];

        // Mangle the names of the current effect's fragment functions.
        for(CCEffectFunction *function in effectImpl.fragmentFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:fragUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allFragFunctions addObject:prefixedFunction];
        }
        
        // Mangle the names of the current effect's vertex uniforms and record the results.
        NSArray *vertexUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effectImpl.vertexUniforms withNamesListedInSet:[CCEffectImpl defaultEffectVertexUniformNames]];
        NSDictionary *vtxUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:vertexUniforms];
        [allVertexUniforms addObjectsFromArray:vtxUniformReplacements.allValues];
        
        // Mangle the names of the current effect's vertex functions.
        for(CCEffectFunction* function in effectImpl.vertexFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:vtxUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allVertexFunctions addObject:prefixedFunction];
        }

        // Build a new translation table from the mangled vertex and fragment
        // uniform names.
        NSMutableDictionary* uniformTranslationTable = [[NSMutableDictionary alloc] init];
        for (NSString *key in vtxUniformReplacements)
        {
            CCEffectUniform *uniform = vtxUniformReplacements[key];
            uniformTranslationTable[key] = uniform.name;
        }

        for (NSString *key in fragUniformReplacements)
        {
            CCEffectUniform *uniform = fragUniformReplacements[key];
            uniformTranslationTable[key] = uniform.name;
        }
        [allUTTs addObject:uniformTranslationTable];

        effectIndex++;
    }
    
    // Build a new effect that is the accumulation of all the mangled fragment and vertex functions.
    BOOL firstInStack = (startIndex == 0) ? YES : NO;
    
    CCEffectImpl *firstEffectImpl = [stitchList firstObject];
    CCEffectImpl *lastEffectImpl = [stitchList lastObject];

    CCEffectImpl* stitchedEffectImpl = nil;
    if (stitchList.count == 1)
    {
        // If there was only one effect in the stitch list copy its render
        // passes into the output stitched effect. Update the copied passes
        // so they point to the new shader in the stitched effect.
        NSDictionary *utt = [allUTTs firstObject];
        
        NSMutableArray *renderPasses = [[NSMutableArray alloc] init];
        for (CCEffectRenderPass *pass in firstEffectImpl.renderPasses)
        {
            CCEffectRenderPass *newPass = [pass copy];
            newPass.shader = stitchedEffectImpl.shader;
            [renderPasses addObject:newPass];
            
            // Update the uniform translation table in the new pass's begin blocks
            for (CCEffectRenderPassBeginBlockContext *blockContext in newPass.beginBlocks)
            {
                blockContext.uniformTranslationTable = utt;
            }
        }

        stitchedEffectImpl = [[CCEffectImpl alloc] initWithRenderPasses:renderPasses
                                                      fragmentFunctions:allFragFunctions
                                                        vertexFunctions:allVertexFunctions
                                                       fragmentUniforms:allFragUniforms
                                                         vertexUniforms:allVertexUniforms
                                                               varyings:allVaryings
                                                           firstInStack:firstInStack];
    }
    else
    {
        // If there were multiple effects in the stitch list, create a new render
        // pass object, set its shader to the shader from the stitched effect, and
        // copy all blocks from the input passes.
        CCEffectRenderPass *newPass = [[CCEffectRenderPass alloc] init];
        newPass.debugLabel = @"CCEffectStack_Stitched pass 0";
        newPass.shader = stitchedEffectImpl.shader;

        NSMutableArray *allBeginBlocks = [[NSMutableArray alloc] init];
        NSMutableArray *allUpdateBlocks = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < stitchList.count; i++)
        {
            CCEffectImpl *effectImpl = stitchList[i];
            NSDictionary *utt = allUTTs[i];

            // Copy the begin and update blocks from the input passes into the new pass.
            for (CCEffectRenderPass *pass in effectImpl.renderPasses)
            {
                // Update the uniform translation table in the new pass's begin blocks
                for (CCEffectRenderPassBeginBlockContext *blockContext in pass.beginBlocks)
                {
                    CCEffectRenderPassBeginBlockContext *newContext = [blockContext copy];
                    newContext.uniformTranslationTable = utt;
                    [allBeginBlocks addObject:newContext];
                }
                
                // Copy the update blocks
                [allUpdateBlocks addObjectsFromArray:[pass.updateBlocks copy]];
            }
        }
        
        // Add all blocks to the pass.
        newPass.beginBlocks = allBeginBlocks;
        newPass.updateBlocks = allUpdateBlocks;

        stitchedEffectImpl = [[CCEffectImpl alloc] initWithRenderPasses:@[newPass]
                                                      fragmentFunctions:allFragFunctions
                                                        vertexFunctions:allVertexFunctions
                                                       fragmentUniforms:allFragUniforms
                                                         vertexUniforms:allVertexUniforms
                                                               varyings:allVaryings
                                                           firstInStack:firstInStack];
    }

    // Set the stitch flags of the resulting effect based on the flags of the first
    // and last effects in the stitch list. If the "stitch before" flag is set on the
    // first effect then set it in the resulting effect. If the "stitch after" flag is
    // set in the last effect then set it in the resulting effect.
    stitchedEffectImpl.stitchFlags = (firstEffectImpl.stitchFlags & CCEffectFunctionStitchBefore) | (lastEffectImpl.stitchFlags & CCEffectFunctionStitchAfter);

    return stitchedEffectImpl;
}

+ (NSDictionary *)varyingsByApplyingPrefix:(NSString *)prefix toVaryings:(NSArray *)varyings
{
    NSMutableDictionary *varyingReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectVarying *varying in varyings)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, varying.name];
        CCEffectVarying *prefixedVarying = [[CCEffectVarying alloc] initWithType:varying.type name:prefixedName count:varying.count];
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
