//
//  CCEffect.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//


#import "CCEffect_Private.h"
#import "CCTexture.h"
#import "CCColor.h"
#import "CCRenderer.h"


NSString * const CCShaderUniformPreviousPassTexture = @"cc_PreviousPassTexture";
NSString * const CCShaderUniformTexCoord1Center     = @"cc_FragTexCoord1Center";
NSString * const CCShaderUniformTexCoord1Extents    = @"cc_FragTexCoord1Extents";
NSString * const CCShaderUniformTexCoord2Center     = @"cc_FragTexCoord2Center";
NSString * const CCShaderUniformTexCoord2Extents    = @"cc_FragTexCoord2Extents";

NSString * const CCEffectDefaultInitialInputSnippet = @"cc_FragColor * texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);\nvec2 compare = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\ntmp *= step(0.0, min(compare.x, compare.y))";
NSString * const CCEffectDefaultInputSnippet = @"texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);\nvec2 compare = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\ntmp *= step(0.0, min(compare.x, compare.y))";

const CCEffectPrepareResult CCEffectPrepareNoop     = { CCEffectPrepareSuccess, CCEffectPrepareNothingChanged };

static NSString* fragBase =
@"%@\n\n"   // uniforms
@"%@\n"     // varying vars
@"%@\n"     // function defs
@"void main() {\n"
@"gl_FragColor = %@;\n"
@"}\n";

static NSString* vertBase =
@"%@\n\n"   // uniforms
@"%@\n"     // varying vars
@"%@\n"     // function defs
@"void main(){\n"
@"	cc_FragColor = cc_Color;\n"
@"	cc_FragTexCoord1 = cc_TexCoord1;\n"
@"	cc_FragTexCoord2 = cc_TexCoord2;\n"
@"	gl_Position = %@;\n"
@"}\n";


#pragma mark CCEffectImpl

@implementation CCEffectImpl

+ (NSArray *)defaultEffectFragmentUniforms
{
    return @[
             [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]],
             [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
             [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
             [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord2Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
             [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord2Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]]
            ];
}

+ (NSArray *)defaultEffectVertexUniforms
{
    return @[];
}

+ (NSSet *)defaultEffectFragmentUniformNames
{
    return [[NSSet alloc] initWithArray:@[
                                          CCShaderUniformPreviousPassTexture,
                                          CCShaderUniformTexCoord1Center,
                                          CCShaderUniformTexCoord1Extents,
                                          CCShaderUniformTexCoord2Center,
                                          CCShaderUniformTexCoord2Extents
                                          ]];
}

+ (NSSet *)defaultEffectVertexUniformNames
{
    return [[NSSet alloc] initWithArray:@[]];
}

-(id)initWithRenderPasses:(NSArray *)renderPasses fragmentFunctions:(NSArray*)fragmentFunctions vertexFunctions:(NSArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings firstInStack:(BOOL)firstInStack
{
    if((self = [super init]))
    {
        if (fragmentFunctions)
        {
            _fragmentFunctions = [fragmentFunctions copy];
        }
        else
        {
            _fragmentFunctions = @[[[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_FragColor;" inputs:nil returnType:@"vec4"]];
        }
        
        if (vertexFunctions)
        {
            _vertexFunctions = [vertexFunctions copy];
        }
        else
        {
            _vertexFunctions = @[[[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_Position;" inputs:nil returnType:@"vec4"]];
        }
        
        _fragmentUniforms = [[CCEffectImpl defaultEffectFragmentUniforms] arrayByAddingObjectsFromArray:fragmentUniforms];
        _vertexUniforms = [[CCEffectImpl defaultEffectVertexUniforms] arrayByAddingObjectsFromArray:vertexUniforms];
        _varyingVars = [varyings copy];
        
        _stitchFlags = CCEffectFunctionStitchBoth;
        _firstInStack = firstInStack;
        
        _shaderUniforms = [CCEffectImpl buildShaderUniforms:_fragmentUniforms vertexUniforms:_vertexUniforms];
        
        // Create a default UTT.
        NSDictionary *uniformTranslationTable = [CCEffectImpl buildUniformTranslationTable:_fragmentUniforms vertexUniforms:_vertexUniforms];
        
        NSString *fragBody = [CCEffectImpl buildShaderSourceFromBase:fragBase functions:_fragmentFunctions uniforms:_fragmentUniforms varyings:_varyingVars firstInStack:_firstInStack];
        NSString *vertBody = [CCEffectImpl buildShaderSourceFromBase:vertBase functions:_vertexFunctions uniforms:_vertexUniforms varyings:_varyingVars firstInStack:_firstInStack];

//        NSLog(@"\n------------vertBody:\n%@", vertBody);
//        NSLog(@"\n------------fragBody:\n%@", fragBody);
        
        _shader = [[CCShader alloc] initWithVertexShaderSource:vertBody fragmentShaderSource:fragBody];
        if (!_shader)
        {
            return nil;
        }
        
        _renderPasses = [renderPasses copy];
        for (CCEffectRenderPass *pass in _renderPasses)
        {
            pass.shader = _shader;
            
            // If a uniform translation table is not set already, set it to the default.
            for (CCEffectRenderPassBeginBlockContext *blockContext in pass.beginBlocks)
            {
                if (!blockContext.uniformTranslationTable)
                {
                    blockContext.uniformTranslationTable = uniformTranslationTable;
                }
            }
        }
    }
    return self;
}

-(id)initWithRenderPasses:(NSArray *)renderPasses fragmentFunctions:(NSArray*)fragmentFunctions vertexFunctions:(NSArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings
{
    return [self initWithRenderPasses:renderPasses fragmentFunctions:fragmentFunctions vertexFunctions:vertexFunctions fragmentUniforms:fragmentUniforms vertexUniforms:vertexUniforms varyings:varyings firstInStack:YES];
}

-(id)initWithRenderPasses:(NSArray *)renderPasses shaderUniforms:(NSMutableDictionary *)uniforms
{
    if((self = [super init]))
    {
        _renderPasses = [renderPasses copy];
        _shaderUniforms = [uniforms copy];
    }
    return self;
}

+ (NSString *)buildShaderSourceFromBase:(NSString *)shaderBase functions:(NSArray *)functions uniforms:(NSArray *)uniforms varyings:(NSArray *)varyings firstInStack:(BOOL)firstInStack
{
    // Build the varying string
    NSMutableString* varyingString = [[NSMutableString alloc] init];
    for(CCEffectVarying* varying in varyings)
    {
        [varyingString appendFormat:@"%@\n", varying.declaration];
    }
    
    // Build the uniform string
    NSMutableString* uniformString = [[NSMutableString alloc] init];
    for(CCEffectUniform* uniform in uniforms)
    {
        [uniformString appendFormat:@"%@\n", uniform.declaration];
    }
    
    // Build the function body strings
    NSMutableString* functionString = [[NSMutableString alloc] init];
    NSMutableString* effectFunctionBody = [[NSMutableString alloc] init];
    [effectFunctionBody appendString:@"vec4 tmp;\n"];
    
    for(CCEffectFunction* curFunction in functions)
    {
        [functionString appendFormat:@"%@\n", curFunction.function];
        
        if([functions firstObject] == curFunction)
        {
            if (firstInStack)
            {
                for (CCEffectFunctionInput *input in curFunction.inputs)
                {
                    [effectFunctionBody appendFormat:@"tmp = %@;\n", input.initialSnippet];
                }
            }
            else
            {
                for (CCEffectFunctionInput *input in curFunction.inputs)
                {
                    [effectFunctionBody appendFormat:@"tmp = %@;\n", input.snippet];
                }
            }
        }
        
        NSMutableArray *inputs = [[NSMutableArray alloc] init];
        if (curFunction.inputs.count)
        {
            [inputs addObject:@"tmp"];
        }
        
        [effectFunctionBody appendFormat:@"tmp = %@;\n", [curFunction callStringWithInputs:inputs]];
    }
    [effectFunctionBody appendString:@"return tmp;\n"];
    
    CCEffectFunction* effectFunction = [[CCEffectFunction alloc] initWithName:@"effectFunction" body:effectFunctionBody inputs:nil returnType:@"vec4"];
    [functionString appendFormat:@"%@\n", effectFunction.function];
    
    // Put it all together
    NSString *shaderSource = [NSString stringWithFormat:shaderBase, uniformString, varyingString, functionString, [effectFunction callStringWithInputs:nil]];
    return shaderSource;
}


+ (NSMutableDictionary *)buildShaderUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms
{
    NSMutableDictionary *allUniforms = [[NSMutableDictionary alloc] init];
    
    for(CCEffectUniform* uniform in fragmentUniforms)
    {
        [allUniforms setObject:uniform.value forKey:uniform.name];
    }
    
    for(CCEffectUniform* uniform in vertexUniforms)
    {
        [allUniforms setObject:uniform.value forKey:uniform.name];
    }
    
    return allUniforms;
}

+ (NSMutableDictionary *)buildUniformTranslationTable:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms
{
    NSMutableDictionary *translationTable = [[NSMutableDictionary alloc] init];
    for(CCEffectUniform* uniform in vertexUniforms)
    {
        translationTable[uniform.name] = uniform.name;
    }
    
    for(CCEffectUniform* uniform in fragmentUniforms)
    {
        translationTable[uniform.name] = uniform.name;
    }
    return translationTable;
}

-(NSUInteger)renderPassCount
{
    return _renderPasses.count;
}

- (BOOL)supportsDirectRendering
{
    return YES;
}

- (CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite
{
    return CCEffectPrepareNoop;
}

-(CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex
{
    NSAssert((passIndex < _renderPasses.count), @"Pass index out of range.");
    return _renderPasses[passIndex];
}

-(BOOL)stitchSupported:(CCEffectFunctionStitchFlags)stitch
{
    NSAssert(stitch && ((stitch & CCEffectFunctionStitchBoth) == stitch), @"Invalid stitch flag specified");
    return ((stitch & _stitchFlags) == stitch);
}


@end

#pragma mark CCEffect

@implementation CCEffect

- (id)init
{
    return [super init];
}

- (BOOL)supportsDirectRendering
{
    NSAssert(_effectImpl, @"The effect has a nil implementation. Something is terribly wrong.");
    return _effectImpl.supportsDirectRendering;
}

- (NSUInteger)renderPassCount
{
    NSAssert(_effectImpl, @"The effect has a nil implementation. Something is terribly wrong.");
    return _effectImpl.renderPasses.count;
}

- (CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite;
{
    NSAssert(_effectImpl, @"The effect has a nil implementation. Something is terribly wrong.");
    return [_effectImpl prepareForRenderingWithSprite:sprite];
}

- (CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex
{
    NSAssert(_effectImpl, @"The effect has a nil implementation. Something is terribly wrong.");
    return [_effectImpl renderPassAtIndex:passIndex];
}

@end


