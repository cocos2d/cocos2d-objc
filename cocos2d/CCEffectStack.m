//
//  CCEffectStack.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffectStack.h"
#import "CCEffectStitcher.h"
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
        self.effectImpl = [CCEffectStack processEffectsWithStitcher:_flattenedEffects withStitching:_stitchingEnabled];
        if (!self.effectImpl)
        {
            self.effectImpl = [CCEffectStack processEffectsWithStitcher:_flattenedEffects withStitching:NO];
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

+ (CCEffectImpl *)processEffectsWithStitcher:(NSArray *)effects withStitching:(BOOL)stitchingEnabled
{
    NSMutableArray *stitchLists = [[NSMutableArray alloc] init];
    
    CCEffect *firstEffect = [effects firstObject];
    NSMutableArray *currentStitchList = [[NSMutableArray alloc] initWithArray:@[firstEffect.effectImpl]];
    [stitchLists addObject:currentStitchList];
    
    // Iterate over the original effects array building sets of effects
    // that can be stitched together.
    for (CCEffect *effect in [effects subarrayWithRange:NSMakeRange(1, effects.count - 1)])
    {
        CCEffectImpl *prevEffectImpl = [currentStitchList lastObject];
        CCEffectImpl *currEffectImpl = effect.effectImpl;
        
        // Two effects can be stitched together if stitching is enabled, the previous supports stitching
        // to effects after it, and the current supports stitching to effects before it.
        BOOL prevStitchCompatible = [prevEffectImpl stitchSupported:CCEffectFunctionStitchAfter];
        BOOL currStitchCompatible = [currEffectImpl stitchSupported:CCEffectFunctionStitchBefore];
        if (stitchingEnabled && prevStitchCompatible && currStitchCompatible)
        {
            // The current effect can be stitched to the previous effect so add
            // it to the running stitch list.
            [currentStitchList addObject:currEffectImpl];
        }
        else
        {
            // The current effect cannot be stitched to the previous effect so
            // start a new stitch list.
            currentStitchList = [[NSMutableArray alloc] initWithArray:@[currEffectImpl]];
            [stitchLists addObject:currentStitchList];
        }
    }
    
    // Stitch the stitch lists and collect the resulting render passes and shaders.
    NSMutableArray *outputPassDescriptors = [[NSMutableArray alloc] init];
    NSMutableArray *outputShaders = [[NSMutableArray alloc] init];
    for (int stitchListIndex = 0; stitchListIndex < stitchLists.count; stitchListIndex++)
    {
        NSArray *stitchList = stitchLists[stitchListIndex];
        
        NSString *prefix = [NSString stringWithFormat:@"SL%d_", stitchListIndex];
        CCEffectStitcher *stitcher = [CCEffectStitcher stitcherWithEffects:stitchList manglePrefix:prefix stitchListIndex:stitchListIndex shaderStartIndex:outputShaders.count];
        
        [outputPassDescriptors addObjectsFromArray:stitcher.renderPassDescriptors];
        [outputShaders addObjectsFromArray:stitcher.shaders];
    }
    
    // Create a new effect implementation from all the collected passes and shaders.
    return [[CCEffectImpl alloc] initWithRenderPassDescriptors:outputPassDescriptors shaders:outputShaders];
}

@end
