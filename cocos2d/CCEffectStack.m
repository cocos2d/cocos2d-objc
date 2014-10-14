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
    if ((self = [super init]))
    {
        if (effects)
        {
            _effects = [effects mutableCopy];
            for (CCEffect *effect in _effects)
            {
                NSAssert(!effect.owningStack, @"Adding an effect to this stack that is already contained by another stack. That's not allowed.");
                effect.owningStack = self;
            }
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

- (void)dealloc
{
    for (CCEffect *effect in _effects)
    {
        effect.owningStack = nil;
    }
}

#pragma mark - CCEffect overrides

- (CCEffectPrepareStatus)prepareForRenderingWithSprite:(CCSprite *)sprite
{
    CCEffectPrepareStatus result = CCEffectPrepareNothingToDo;
    if (_passesDirty)
    {
        CGSize maxPadding = self.padding;
        
        // Start by populating the flattened list with this stack's effects.
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
        
        for (CCEffect *effect in flattenedEffects)
        {
            // Make sure all the contained effects are ready for rendering
            // before we do anything else.
            [effect prepareForRenderingWithSprite:sprite];
            
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

        NSMutableArray *stitchedEffects = [[NSMutableArray alloc] init];
        {
            NSMutableArray *stitchLists = [[NSMutableArray alloc] init];
            NSMutableArray *currentStitchList = [[NSMutableArray alloc] initWithArray:@[[flattenedEffects firstObject]]];
            [stitchLists addObject:currentStitchList];

            // Iterate over the original effects array building sets of effects
            // that can be stitched together based on their stitch flags.
            for (CCEffect *effect in [flattenedEffects subarrayWithRange:NSMakeRange(1, flattenedEffects.count - 1)])
            {
                CCEffect *prevEffect = [currentStitchList lastObject];
                if (_stitchingEnabled && [prevEffect stitchSupported:CCEffectFunctionStitchAfter] && [effect stitchSupported:CCEffectFunctionStitchBefore])
                {
                    [currentStitchList addObject:effect];
                }
                else
                {
                    currentStitchList = [[NSMutableArray alloc] initWithArray:@[effect]];
                    [stitchLists addObject:currentStitchList];
                }
            }

            int effectIndex = 0;
            for (NSArray *stitchList in stitchLists)
            {
                [stitchedEffects addObject:[CCEffectStack stitchEffects:stitchList startIndex:effectIndex]];
                effectIndex += stitchList.count;
            }
        }
        
        // Extract passes and uniforms from the stacked and stitched effects and build a flat list of
        // both.
        NSMutableArray *passes = [[NSMutableArray alloc] init];
        NSMutableDictionary *uniforms = [[NSMutableDictionary alloc] init];
        for (CCEffect *effect in stitchedEffects)
        {
            for (CCEffectRenderPass *pass in effect.renderPasses)
            {
                [passes addObject:pass];
            }
            
            [uniforms addEntriesFromDictionary:effect.shaderUniforms];
        }
        self.renderPasses = [passes copy];
        self.shaderUniforms = uniforms;
        self.padding = maxPadding;
        
        _passesDirty = NO;
        result = CCEffectPrepareSuccess;
    }
    return result;
}

- (BOOL)readyForRendering
{
    return !_passesDirty;
}

#pragma mark - Internal

+ (CCEffect *)stitchEffects:(NSArray*)stitchList startIndex:(int)startIndex
{
    NSAssert(stitchList.count > 0, @"Encountered an empty stitch list which shouldn't happen.");

    NSMutableArray* allFragFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allFragUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* allVertexUniforms = [[NSMutableArray alloc] init];
    NSMutableArray* allVaryings = [[NSMutableArray alloc] init];
    
    // Even if we're only handed one effect in this stitch list, we have to run it through the
    // name mangling code below because all effects in a stack share one uniform namespace.
    int effectIndex = startIndex;
    for(CCEffect* effect in stitchList)
    {
        // Construct the prefix to use for name mangling.
        NSString *effectPrefix = [NSString stringWithFormat:@"%@_%d_", effect.debugName, effectIndex];

        // Mangle the names of the current effect's varyings and record the results.
        NSDictionary *varyingReplacements = [CCEffectStack varyingsByApplyingPrefix:effectPrefix toVaryings:effect.varyingVars];
        [allVaryings addObjectsFromArray:varyingReplacements.allValues];

        // Mangle the names of the current effect's fragment uniforms and record the results.
        NSArray *fragmentUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effect.fragmentUniforms withNamesListedInSet:[CCEffect defaultEffectFragmentUniformNames]];
        NSDictionary *fragUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:fragmentUniforms];
        [allFragUniforms addObjectsFromArray:fragUniformReplacements.allValues];

        // Mangle the names of the current effect's fragment functions.
        for(CCEffectFunction *function in effect.fragmentFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:fragUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allFragFunctions addObject:prefixedFunction];
        }
        
        // Mangle the names of the current effect's vertex uniforms and record the results.
        NSArray *vertexUniforms = [CCEffectStack uniformsByRemovingUniformsFrom:effect.vertexUniforms withNamesListedInSet:[CCEffect defaultEffectVertexUniformNames]];
        NSDictionary *vtxUniformReplacements = [CCEffectStack uniformsByApplyingPrefix:effectPrefix toUniforms:vertexUniforms];
        [allVertexUniforms addObjectsFromArray:vtxUniformReplacements.allValues];
        
        // Mangle the names of the current effect's vertex functions.
        for(CCEffectFunction* function in effect.vertexFunctions)
        {
            CCEffectFunction *prefixedFunction = [CCEffectStack effectFunctionByApplyingPrefix:effectPrefix uniformReplacements:vtxUniformReplacements varyingReplacements:varyingReplacements toEffectFunction:function];
            [allVertexFunctions addObject:prefixedFunction];
        }
        
        // Update the original effect's translation table so it reflects the new mangled
        // uniform names.
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
    
    // Build a new effect that is the accumulation of all the mangled fragment and vertex functions.
    BOOL firstInStack = (startIndex == 0) ? YES : NO;
    CCEffect* stitchedEffect = [[CCEffect alloc] initWithFragmentFunction:allFragFunctions vertexFunctions:allVertexFunctions fragmentUniforms:allFragUniforms vertexUniforms:allVertexUniforms varyings:allVaryings firstInStack:firstInStack];
    stitchedEffect.debugName = @"CCEffectStack_Stitched";
    
    // Set the stitch flags of the resulting effect based on the flags of the first
    // and last effects in the stitch list. If the "stitch before" flag is set on the
    // first effect then set it in the resulting effect. If the "stitch after" flag is
    // set in the last effect then set it in the resulting effect.
    CCEffect *firstEffect = [stitchList firstObject];
    CCEffect *lastEffect = [stitchList lastObject];
    stitchedEffect.stitchFlags = (firstEffect.stitchFlags & CCEffectFunctionStitchBefore) | (lastEffect.stitchFlags & CCEffectFunctionStitchAfter);
    
    if (stitchList.count == 1)
    {
        // If there was only one effect in the stitch list copy its render
        // passes into the output stitched effect. Update the copied passes
        // so they point to the new shader in the stitched effect.

        NSMutableArray *renderPasses = [[NSMutableArray alloc] init];
        for (CCEffectRenderPass *pass in firstEffect.renderPasses)
        {
            CCEffectRenderPass *newPass = [pass copy];
            newPass.shader = stitchedEffect.shader;
            [renderPasses addObject:newPass];
        }
        stitchedEffect.renderPasses = renderPasses;
    }
    else
    {
        // If there were multiple effects in the stitch list, create a new render
        // pass object, set its shader to the shader from the stitched effect, and
        // copy all blocks from the input passes.
        CCEffectRenderPass *newPass = [[CCEffectRenderPass alloc] init];
        newPass.debugLabel = @"CCEffectStack_Stitched pass 0";
        newPass.shader = stitchedEffect.shader;

        NSMutableArray *beginBlocks = [[NSMutableArray alloc] init];
        NSMutableArray *endBlocks = [[NSMutableArray alloc] init];

        for (CCEffect *effect in stitchList)
        {
            // Copy the begin and end blocks from the input passes into the new pass.
            for (CCEffectRenderPass *pass in effect.renderPasses)
            {
                [beginBlocks addObjectsFromArray:pass.beginBlocks];
                [endBlocks addObjectsFromArray:pass.endBlocks];
            }
        }

        newPass.beginBlocks = beginBlocks;
        newPass.endBlocks = endBlocks;

        stitchedEffect.renderPasses = @[newPass];
    }

    return stitchedEffect;
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

#pragma mark - CCEffectStackProtocol

- (void)passesDidChange:(id)sender
{
    // Mark this stack's passes as dirty and propagate the
    // change notification up the tree (if we're not at the
    // top).
    _passesDirty = YES;
    [self.owningStack passesDidChange:self];
}


@end
