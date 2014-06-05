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
        NSMutableArray *passes = [[NSMutableArray alloc] init];
        for (CCEffect *effect in _effects)
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



+(CCEffect*)effects:(id)firstObject, ...
{
    NSMutableArray* effects = [[NSMutableArray alloc] init];
   
    id object;
    va_list argumentList;
    
    va_start(argumentList, firstObject);
    object = firstObject;
    
    while(object != nil)
    {
        [effects addObject:object];
        object = va_arg(argumentList, id);
    }
    
    va_end(argumentList);
    
    NSMutableArray* fragFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* fragUniforms = [[NSMutableArray alloc] init];
    [CCEffectStack extractFragmentData:effects functions:fragFunctions uniforms:fragUniforms];
   
    NSMutableArray* vertexFunctions = [[NSMutableArray alloc] init];
    NSMutableArray* vertexUniforms = [[NSMutableArray alloc] init];
    [CCEffectStack extractVertexData:effects functions:vertexFunctions uniforms:vertexUniforms];
    
    CCEffect* compositeEffect = [[CCEffect alloc] initWithFragmentFunction:fragFunctions vertexFunctions:vertexFunctions fragmentUniforms:fragUniforms vertextUniforms:vertexUniforms varying:nil];
    
    return compositeEffect;
}

+(void)extractFragmentData:(NSMutableArray*)effects functions:(NSMutableArray*)functions uniforms:(NSMutableArray*)uniforms
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

+(void)extractVertexData:(NSMutableArray*)effects functions:(NSMutableArray*)functions uniforms:(NSMutableArray*)uniforms
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

@end
#endif
