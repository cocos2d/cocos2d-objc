//
//  CCEffectStitcherGL.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/24/15.
//
//

#import "CCEffectStitcherGL.h"
#import "CCEffectFunction.h"
#import "CCEffectRenderPass.h"
#import "CCEffectShader.h"
#import "CCEffectShaderBuilderGL.h"
#import "CCEffectUniform.h"
#import "CCEffectVarying.h"
#import "CCEffect_Private.h"


static NSString * const CCEffectStitcherFunctions = @"CCEffectStitcherFunctions";
static NSString * const CCEffectStitcherCalls = @"CCEffectStitcherCalls";
static NSString * const CCEffectStitcherTemporaries = @"CCEffectStitcherTemporaries";
static NSString * const CCEffectStitcherUniforms = @"CCEffectStitcherUniforms";
static NSString * const CCEffectStitcherVaryings = @"CCEffectStitcherVaryings";


@interface CCEffectStitcherGL ()

// Inputs
@property (nonatomic, copy) NSArray *effects;
@property (nonatomic, copy) NSString *manglePrefix;
@property (nonatomic, assign) NSUInteger stitchListIndex;
@property (nonatomic, assign) NSUInteger shaderStartIndex;

// Outputs
@property (nonatomic, strong) NSArray *cachedRenderPassDescriptors;
@property (nonatomic, strong) NSArray *cachedShaders;

@end


@implementation CCEffectStitcherGL

- (id)initWithEffects:(NSArray *)effects manglePrefix:(NSString *)prefix stitchListIndex:(NSUInteger)stitchListIndex shaderStartIndex:(NSUInteger)shaderStartIndex;
{
    // Make sure these aren't nil, empty, etc.
    NSAssert(effects.count, @"");
    NSAssert(prefix.length, @"");
    
    if((self = [super init]))
    {
        _effects = [effects copy];
        _manglePrefix = [prefix copy];
        _stitchListIndex = stitchListIndex;
        _shaderStartIndex = shaderStartIndex;
        
        _cachedRenderPassDescriptors = nil;
        _cachedShaders = nil;
    }
    return self;
}

- (NSArray *)renderPassDescriptors
{
    // The output render pass and shader arrays are computed lazily when requested.
    // One method computes both of them so we need to make sure everything stays
    // in sync (ie if we don't have one we don't have the other and if one gets
    // created so does the other).
    if (!_cachedRenderPassDescriptors)
    {
        NSAssert(!_cachedShaders, @"The output render pass array is nil but the output shader array is not.");
        [self stitchEffects:self.effects manglePrefix:self.manglePrefix stitchListIndex:self.stitchListIndex shaderStartIndex:self.shaderStartIndex];

        NSAssert(_cachedRenderPassDescriptors, @"Failed to create an output render pass array.");
        NSAssert(_cachedShaders, @"Failed to create an output shader array.");
    }
    return _cachedRenderPassDescriptors;
}

- (NSArray *)shaders
{
    // The output render pass and shader arrays are computed lazily when requested.
    // One method computes both of them so we need to make sure everything stays
    // in sync (ie if we don't have one we don't have the other and if one gets
    // created so does the other).
    if (!_cachedShaders)
    {
        NSAssert(!_cachedRenderPassDescriptors, @"The output shader array is nil but the output render pass array is not.");
        [self stitchEffects:self.effects manglePrefix:self.manglePrefix stitchListIndex:self.stitchListIndex shaderStartIndex:self.shaderStartIndex];

        NSAssert(_cachedRenderPassDescriptors, @"Failed to create an output render pass array.");
        NSAssert(_cachedShaders, @"Failed to create an output shader array.");
    }
    return _cachedShaders;
}

- (void)stitchEffects:(NSArray *)effects manglePrefix:(NSString *)prefix stitchListIndex:(NSUInteger)stitchListIndex shaderStartIndex:(NSUInteger)shaderStartIndex
{
    NSAssert(effects.count > 0, @"Unexpectedly empty shader array.");
    
    NSMutableDictionary *allVtxComponents = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *allFragComponents = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *allUTTs = [[NSMutableDictionary alloc] init];
    
    // Decompose the input shaders into their component parts and generate mangled versions of any
    // "file scope" names that could have conflicts (functions, uniforms, varyings). Then merge them
    // into one big accumulated set of components.
    int shaderIndex = 0;
    for (CCEffectImpl *effect in effects)
    {
        for (CCEffectShader *shader in effect.shaders)
        {
            // Construct the prefix to use for name mangling.
            NSString *shaderPrefix = [NSString stringWithFormat:@"%@%d_", prefix, shaderIndex];

            NSAssert([shader.vertexShaderBuilder isKindOfClass:[CCEffectShaderBuilderGL class]], @"Supplied shader builder is not a GL shader builder.");
            CCEffectShaderBuilderGL *vtxBuilder = (CCEffectShaderBuilderGL *)shader.vertexShaderBuilder;
            NSDictionary *prefixedVtxComponents = [CCEffectStitcherGL prefixComponentsFromBuilder:vtxBuilder withPrefix:shaderPrefix stitchListIndex:stitchListIndex];
            [CCEffectStitcherGL mergePrefixedComponents:prefixedVtxComponents fromShaderAtIndex:shaderIndex intoAllComponents:allVtxComponents];

            NSAssert([shader.fragmentShaderBuilder isKindOfClass:[CCEffectShaderBuilderGL class]], @"Supplied shader builder is not a GL shader builder.");
            CCEffectShaderBuilderGL *fragBuilder = (CCEffectShaderBuilderGL *)shader.fragmentShaderBuilder;
            NSDictionary *prefixedFragComponents = [CCEffectStitcherGL prefixComponentsFromBuilder:fragBuilder withPrefix:shaderPrefix stitchListIndex:stitchListIndex];
            [CCEffectStitcherGL mergePrefixedComponents:prefixedFragComponents fromShaderAtIndex:shaderIndex intoAllComponents:allFragComponents];
            
            // Build a new translation table from the mangled vertex and fragment
            // uniform names.
            NSMutableDictionary* uniformTranslationTable = [[NSMutableDictionary alloc] init];
            for (NSString *key in prefixedVtxComponents[CCEffectStitcherUniforms])
            {
                CCEffectUniform *uniform = prefixedVtxComponents[CCEffectStitcherUniforms][key];
                uniformTranslationTable[key] = uniform.name;
            }
            
            for (NSString *key in prefixedFragComponents[CCEffectStitcherUniforms])
            {
                CCEffectUniform *uniform = prefixedFragComponents[CCEffectStitcherUniforms][key];
                uniformTranslationTable[key] = uniform.name;
            }
            allUTTs[shader] = uniformTranslationTable;
            
            shaderIndex++;
        }
    }
    
    // Create new shader builders from the accumulated, prefixed components.
    CCEffectShaderBuilder *vtxBuilder = [[CCEffectShaderBuilderGL alloc] initWithType:CCEffectShaderBuilderVertex
                                                                            functions:allVtxComponents[CCEffectStitcherFunctions]
                                                                                calls:allVtxComponents[CCEffectStitcherCalls]
                                                                          temporaries:allVtxComponents[CCEffectStitcherTemporaries]
                                                                             uniforms:[allVtxComponents[CCEffectStitcherUniforms] allValues]
                                                                             varyings:allVtxComponents[CCEffectStitcherVaryings]];
    
    CCEffectShaderBuilder *fragBuilder = [[CCEffectShaderBuilderGL alloc] initWithType:CCEffectShaderBuilderFragment
                                                                             functions:allFragComponents[CCEffectStitcherFunctions]
                                                                                 calls:allFragComponents[CCEffectStitcherCalls]
                                                                           temporaries:allFragComponents[CCEffectStitcherTemporaries]
                                                                              uniforms:[allFragComponents[CCEffectStitcherUniforms] allValues]
                                                                              varyings:allFragComponents[CCEffectStitcherVaryings]];
    
    // Create a new shader with the new builders.
    _cachedShaders = @[[[CCEffectShader alloc] initWithVertexShaderBuilder:vtxBuilder fragmentShaderBuilder:fragBuilder]];
    
    
    if (effects.count == 1)
    {
        // If there was only one effect in the stitch list copy its render
        // passes into the output stitched effect. Update the copied passes
        // so they point to the new shader in the stitched effect and update
        // the uniform translation table.
        
        CCEffectImpl *effect = [effects firstObject];
        NSMutableArray *renderPassDescriptors = [[NSMutableArray alloc] init];
        for (CCEffectRenderPass *pass in effect.renderPasses)
        {
            CCEffectRenderPassDescriptor *newDescriptor = [CCEffectRenderPassDescriptor descriptor];
            newDescriptor.shaderIndex = pass.shaderIndex + shaderStartIndex;
            newDescriptor.texCoordsMapping = pass.texCoordsMapping;
            newDescriptor.blendMode = pass.blendMode;

            // Update the uniform translation table in the new pass's begin blocks
            NSMutableArray *beginBlocks = [[NSMutableArray alloc] init];
            for (CCEffectRenderPassBeginBlockContext *blockContext in pass.beginBlocks)
            {
                [beginBlocks addObject:[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:blockContext.block uniformTranslationTable:allUTTs[pass.effectShader]]];
            }
            newDescriptor.beginBlocks = beginBlocks;
            newDescriptor.updateBlocks = pass.updateBlocks;
            newDescriptor.debugLabel = pass.debugLabel;
            
            [renderPassDescriptors addObject:newDescriptor];
        }
        
        _cachedRenderPassDescriptors = [renderPassDescriptors copy];
    }
    else
    {        
        CCEffectRenderPassDescriptor *newDescriptor = [CCEffectRenderPassDescriptor descriptor];
        newDescriptor.shaderIndex = shaderStartIndex;
        newDescriptor.texCoordsMapping = CCEffectTexCoordsMappingDefault;
        newDescriptor.blendMode = [CCBlendMode premultipliedAlphaMode];
        
        NSMutableArray *beginBlocks = [[NSMutableArray alloc] init];
        NSMutableArray *updateBlocks = [[NSMutableArray alloc] init];
        
        // Copy the begin and update blocks from the input passes into the new pass.
        for (CCEffectImpl *effect in effects)
        {
            for (CCEffectRenderPass *pass in effect.renderPasses)
            {
                for (CCEffectRenderPassBeginBlockContext *blockContext in pass.beginBlocks)
                {
                    [beginBlocks addObject:[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:blockContext.block uniformTranslationTable:allUTTs[pass.effectShader]]];
                }
                
                // Copy the update blocks. They don't need any adjustment so they can just
                // be copied outright.
                [updateBlocks addObjectsFromArray:pass.updateBlocks];
            }
        }

        newDescriptor.beginBlocks = beginBlocks;
        newDescriptor.updateBlocks = updateBlocks;
        newDescriptor.debugLabel = [NSString stringWithFormat:@"CCEffectStack_Stitched_%@", prefix];;
        
        _cachedRenderPassDescriptors = @[newDescriptor];
    }
}

+ (void)mergePrefixedComponents:(NSDictionary *)prefixedComponents fromShaderAtIndex:(NSUInteger)shaderIndex intoAllComponents:(NSMutableDictionary *)allComponents
{
    CCEffectFunctionCall *lastCall = nil;
    if (shaderIndex > 0)
    {
        NSAssert([allComponents[CCEffectStitcherCalls] count], @"");
        
        lastCall = [allComponents[CCEffectStitcherCalls] lastObject];
    }
    
    // Functions
    if (!allComponents[CCEffectStitcherFunctions])
    {
        allComponents[CCEffectStitcherFunctions] = [[NSMutableArray alloc] init];
    }
    [allComponents[CCEffectStitcherFunctions] addObjectsFromArray:[prefixedComponents[CCEffectStitcherFunctions] allValues]];
    
    // Uniforms
    if (!allComponents[CCEffectStitcherUniforms])
    {
        allComponents[CCEffectStitcherUniforms] = [[NSMutableDictionary alloc] init];
    }
    for (CCEffectUniform *uniform in [prefixedComponents[CCEffectStitcherUniforms] allValues])
    {
        allComponents[CCEffectStitcherUniforms][uniform.name] = uniform;
    }
    
    // Varyings
    if (!allComponents[CCEffectStitcherVaryings])
    {
        allComponents[CCEffectStitcherVaryings] = [[NSMutableArray alloc] init];
    }
    [allComponents[CCEffectStitcherVaryings] addObjectsFromArray:[prefixedComponents[CCEffectStitcherVaryings] allValues]];
    
    // Temporaries
    if (!allComponents[CCEffectStitcherTemporaries])
    {
        allComponents[CCEffectStitcherTemporaries] = [[NSMutableArray alloc] init];
    }
    if (shaderIndex == 0)
    {
        // For the first shader we just copy its temporaries. The temporaries of subsequent shaders aren't
        // needed because function call inputs that had referenced temporaries are remapped to reference
        // the output of the previous shader.
        [allComponents[CCEffectStitcherTemporaries] addObjectsFromArray:[prefixedComponents[CCEffectStitcherTemporaries] allValues]];
    }
    
    // Calls
    if (!allComponents[CCEffectStitcherCalls])
    {
        allComponents[CCEffectStitcherCalls] = [[NSMutableArray alloc] init];
    }
    
    if (shaderIndex == 0)
    {
        // If we're processing the first shader then we don't need to do anything special here and we can
        // just copy the function call information.
        [allComponents[CCEffectStitcherCalls] addObjectsFromArray:prefixedComponents[CCEffectStitcherCalls]];
    }
    else
    {
        // For shaders after the first one, we have to tweak each function call's input map if it has references
        // to any temporaries. Temporaries that would have been initialized with the previous pass output texture
        // are replaced with the output of the last shader's last function call.
        for (CCEffectFunctionCall *call in prefixedComponents[CCEffectStitcherCalls])
        {
            NSMutableDictionary *remappedInputs = [[NSMutableDictionary alloc] init];
            for (NSString *inputName in call.inputs)
            {
                NSString *connectedVariableName = call.inputs[inputName];
                if (prefixedComponents[CCEffectStitcherTemporaries][connectedVariableName])
                {
                    remappedInputs[inputName] = lastCall.outputName;
                }
                else
                {
                    remappedInputs[inputName] = connectedVariableName;
                }
            }
            if (remappedInputs.count)
            {
                CCEffectFunctionCall *newCall = [[CCEffectFunctionCall alloc] initWithFunction:call.function outputName:call.outputName inputs:remappedInputs];
                [allComponents[CCEffectStitcherCalls] addObject:newCall];
            }
            else
            {
                [allComponents[CCEffectStitcherCalls] addObject:call];
            }
        }
    }
}

+ (NSDictionary *)prefixComponentsFromBuilder:(CCEffectShaderBuilderGL *)builder withPrefix:(NSString *)prefix stitchListIndex:(NSUInteger)stitchListIndex
{
    NSMutableDictionary *prefixedComponents = [[NSMutableDictionary alloc] init];
    
    prefixedComponents[CCEffectStitcherUniforms] = [CCEffectStitcherGL uniformsByApplyingPrefix:prefix toUniforms:builder.uniforms withExclusions:[CCEffectShaderBuilderGL defaultUniformNames]];
    prefixedComponents[CCEffectStitcherVaryings] = [CCEffectStitcherGL varyingsByApplyingPrefix:prefix toVaryings:builder.varyings];
    prefixedComponents[CCEffectStitcherFunctions] = [CCEffectStitcherGL functionsByApplyingPrefix:prefix
                                                                              uniformReplacements:prefixedComponents[CCEffectStitcherUniforms]
                                                                              varyingReplacements:prefixedComponents[CCEffectStitcherVaryings]
                                                                                      toFunctions:builder.functions];
    prefixedComponents[CCEffectStitcherTemporaries] = [CCEffectStitcherGL temporariesByApplyingPrefix:prefix toTemporaries:builder.temporaries stitchListIndex:stitchListIndex];
    prefixedComponents[CCEffectStitcherCalls] = [CCEffectStitcherGL callsByApplyingPrefix:prefix functionReplacements:prefixedComponents[CCEffectStitcherFunctions] toCalls:builder.calls];
    
    return prefixedComponents;
}

+ (NSDictionary *)functionsByApplyingPrefix:(NSString *)prefix uniformReplacements:(NSDictionary *)uniformReplacements varyingReplacements:(NSDictionary *)varyingReplacements toFunctions:(NSArray *)functions
{
    // Functions
    NSMutableDictionary *functionReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectFunction* function in functions)
    {
        CCEffectFunction *prefixedFunction = [CCEffectStitcherGL effectFunctionByApplyingPrefix:prefix uniformReplacements:uniformReplacements varyingReplacements:varyingReplacements allFunctions:functions toEffectFunction:function];
        functionReplacements[function.name] = prefixedFunction;
    }
    return [functionReplacements copy];
}

+ (NSDictionary *)varyingsByApplyingPrefix:(NSString *)prefix toVaryings:(NSArray *)varyings
{
    NSMutableDictionary *varyingReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectVarying *varying in varyings)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, varying.name];
        varyingReplacements[varying.name] = [[CCEffectVarying alloc] initWithType:varying.type name:prefixedName count:varying.count];
    }
    return [varyingReplacements copy];
}

+ (NSDictionary *)uniformsByApplyingPrefix:(NSString *)prefix toUniforms:(NSArray *)uniforms withExclusions:(NSSet *)exclusions
{
    NSMutableDictionary *uniformReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectUniform* uniform in uniforms)
    {
        if (![exclusions containsObject:uniform.name])
        {
            NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, uniform.name];
            uniformReplacements[uniform.name] = [[CCEffectUniform alloc] initWithType:uniform.type name:prefixedName value:uniform.value];
        }
        else
        {
            uniformReplacements[uniform.name] = [[CCEffectUniform alloc] initWithType:uniform.type name:uniform.name value:uniform.value];
        }
    }
    return [uniformReplacements copy];
}

+ (NSDictionary *)temporariesByApplyingPrefix:(NSString *)prefix toTemporaries:(NSArray *)temporaries stitchListIndex:(NSUInteger)stitchListIndex
{
    NSMutableDictionary *temporaryReplacements = [[NSMutableDictionary alloc] init];
    for(CCEffectFunctionTemporary *temporary in temporaries)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, temporary.name];
        if (stitchListIndex == 0)
        {
            // If this stitch group is the first in the stack, we only need to adjust each temporary's name.
            temporaryReplacements[prefixedName] = [CCEffectFunctionTemporary temporaryWithType:temporary.type name:prefixedName initializer:temporary.initializer];
        }
        else
        {
            // If this stitch group is not first in the stack, we need to adjust each temporary's name _and_ adjust
            // its initializer to make sure cc_FragColor doesn't contribute to the initializer expression again.
            temporaryReplacements[prefixedName] = [CCEffectFunctionTemporary temporaryWithType:temporary.type name:prefixedName initializer:temporary.initializer + CCEffectInitReserveOffset];
        }
    }
    return [temporaryReplacements copy];
}

+ (NSArray *)callsByApplyingPrefix:(NSString *)prefix functionReplacements:(NSDictionary *)functionReplacements toCalls:(NSArray *)calls
{
    NSMutableArray *callReplacements = [[NSMutableArray alloc] init];
    for(CCEffectFunctionCall *call in calls)
    {
        NSString *prefixedOutputName = [NSString stringWithFormat:@"%@%@", prefix, call.outputName];
        
        CCEffectFunction *function = functionReplacements[call.function.name];
        
        NSMutableDictionary *prefixedInputs = [[NSMutableDictionary alloc] init];
        for (NSString *key in call.inputs.allKeys)
        {
            NSString *prefixedValue = [NSString stringWithFormat:@"%@%@", prefix, call.inputs[key]];
            prefixedInputs[key] = prefixedValue;
        }
        [callReplacements addObject:[[CCEffectFunctionCall alloc] initWithFunction:function outputName:prefixedOutputName inputs:prefixedInputs]];
    }
    return [callReplacements copy];
}

+ (CCEffectFunction *)effectFunctionByApplyingPrefix:(NSString *)prefix uniformReplacements:(NSDictionary *)uniformReplacements varyingReplacements:(NSDictionary *)varyingReplacements allFunctions:(NSArray*)allFunctions toEffectFunction:(CCEffectFunction *)function
{
    NSString *prefixedBody = [CCEffectStitcherGL functionBodyByApplyingPrefix:prefix uniformReplacements:uniformReplacements varyingReplacements:varyingReplacements allFunctions:(NSArray *)allFunctions toFunctionBody:function.body];
    NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, function.name];
    
    return [[CCEffectFunction alloc] initWithName:prefixedName body:prefixedBody inputs:function.inputs returnType:function.returnType];
}

+ (NSString *)functionBodyByApplyingPrefix:prefix uniformReplacements:(NSDictionary *)uniformReplacements varyingReplacements:(NSDictionary *)varyingReplacements allFunctions:(NSArray *)allFunctions toFunctionBody:(NSString *)body
{
    for (CCEffectFunction *function in allFunctions)
    {
        NSString *prefixedName = [NSString stringWithFormat:@"%@%@", prefix, function.name];
        body = [body stringByReplacingOccurrencesOfString:function.name withString:prefixedName];
    }
    
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


