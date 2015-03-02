//
//  CCEffect.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import "CCEffect.h"
#import "CCEffect_Private.h"
#import "CCTexture.h"

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

#pragma mark CCEffectFunction

@implementation CCEffectFunction

-(id)initWithName:(NSString *)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString *)returnType
{
    if((self = [super init]))
    {
        NSAssert(inputs.count <= 1, @"Effect functions currently only support 0 or 1 inputs.");
        
        _body = [body copy];
        _name = [name copy];
        _inputs = [inputs copy];
        _returnType = [returnType copy];

        _inputString = @"void";
        if (_inputs.count)
        {
            NSMutableString *tmpString = [[NSMutableString alloc] init];
            for (CCEffectFunctionInput *input in _inputs)
            {
                [tmpString appendFormat:@"%@ %@", input.type, input.name];
            }
            _inputString = tmpString;
        }
        
        return self;
    }
    
    return self;
}

+(instancetype)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType
{
    return [[self alloc] initWithName:name body:body inputs:inputs returnType:returnType];
}

-(NSString*)function
{
    NSString* function = [NSString stringWithFormat:@"%@ %@(%@)\n{\n%@\n}", _returnType, _name, _inputString, _body];
    return function;
}

-(NSString*)callStringWithInputs:(NSArray*)inputs
{
    NSMutableString *callString = [[NSMutableString alloc] initWithFormat:@"%@(", _name];
    for (NSString *input in inputs)
    {
        if ([inputs lastObject] != input)
        {
            [callString appendFormat:@"%@, ", input];
        }
        else
        {
            [callString appendFormat:@"%@", input];
        }
    }
    [callString appendString:@")"];
    
    return callString;
}

@end

#pragma mark CCEffectFunctionInput

@implementation CCEffectFunctionInput

-(id)initWithType:(NSString*)type name:(NSString*)name initialSnippet:(NSString*)initialSnippet snippet:(NSString*)snippet
{
    if((self = [super init]))
    {
        _type = [type copy];
        _name = [name copy];
        _initialSnippet = [initialSnippet copy];
        _snippet = [snippet copy];
        return self;
    }
    
    return self;
}

+(instancetype)inputWithType:(NSString*)type name:(NSString*)name initialSnippet:(NSString*)initialSnippet snippet:(NSString*)snippet
{
    return [[self alloc] initWithType:type name:name initialSnippet:initialSnippet snippet:snippet];
}

@end

#pragma mark CCEffectUniform

@implementation CCEffectUniform

-(id)initWithType:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    if((self = [super init]))
    {
        _name = [name copy];
        _type = [type copy];
        _value = value;
        
        return self;
    }
    
    return self;
}

+(instancetype)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    return [[self alloc] initWithType:type name:name value:value];
}

-(NSString*)declaration
{
    NSString* declaration = [NSString stringWithFormat:@"uniform %@ %@;", _type, _name];
    return declaration;
}

@end

#pragma mark CCEffectVarying

@implementation CCEffectVarying

-(id)initWithType:(NSString*)type name:(NSString*)name
{
    if((self = [self initWithType:type name:name count:0]))
    {
        return self;
    }
    
    return self;
}

+(instancetype)varying:(NSString*)type name:(NSString*)name
{
    return [[self alloc] initWithType:type name:name];
}

-(id)initWithType:(NSString*)type name:(NSString*)name count:(NSInteger)count
{
    if((self = [super init]))
    {
        _name = name;
        _type = type;
        _count = count;
        
        return self;
    }
    
    return self;
}

+(instancetype)varying:(NSString*)type name:(NSString*)name count:(NSInteger)count
{
    return [[self alloc] initWithType:type name:name count:count];
}


-(NSString*)declaration
{
    NSString* declaration;

    if(_count == 0)
        declaration = [NSString stringWithFormat:@"varying %@ %@;", _type, _name];
    else
        declaration = [NSString stringWithFormat:@"varying %@ %@[%lu];", _type, _name, (long)_count];
    
    return declaration;
}

@end


#pragma mark CCEffectRenderPassInputs

@implementation CCEffectRenderPassInputs

-(id)init
{
    return [super init];
}

@end


#pragma mark CCEffectRenderPassBeginBlockContext

@implementation CCEffectRenderPassBeginBlockContext

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block;
{
    if (self = [super init])
    {
        _block = [block copy];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    CCEffectRenderPassBeginBlockContext *newContext = [[CCEffectRenderPassBeginBlockContext allocWithZone:zone] initWithBlock:_block];
    newContext.uniformTranslationTable = _uniformTranslationTable;
    return newContext;
}

@end


#pragma mark CCEffectRenderPass

@implementation CCEffectRenderPass

-(id)init
{
    return [self initWithIndex:0];
}

-(id)initWithIndex:(NSUInteger)indexInEffect
{
    if((self = [super init]))
    {
        _indexInEffect = indexInEffect;
        
        _texCoord1Mapping = CCEffectTexCoordMapPreviousPassTex;
        _texCoord2Mapping = CCEffectTexCoordMapCustomTex;
        
        _beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){}]];

        CCEffectRenderPassUpdateBlock updateBlock = ^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
            if (passInputs.needsClear)
            {
                [passInputs.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:[CCColor clearColor].glkVector4 depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
            }
            [pass enqueueTriangles:passInputs];
        };
        _updateBlocks = @[[updateBlock copy]];
        _blendMode = [CCBlendMode premultipliedAlphaMode];
        
        return self;
    }
    
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
	CCEffectRenderPass *newPass = [[CCEffectRenderPass allocWithZone:zone] initWithIndex:_indexInEffect];
    newPass.texCoord1Mapping = _texCoord1Mapping;
    newPass.texCoord2Mapping = _texCoord2Mapping;
    newPass.blendMode = _blendMode;
    newPass.shader = _shader;
    newPass.beginBlocks = [_beginBlocks copy];
    newPass.updateBlocks = [_updateBlocks copy];
    newPass.debugLabel = _debugLabel;
    return newPass;
}

-(void)begin:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassBeginBlockContext *blockContext in _beginBlocks)
    {
        passInputs.uniformTranslationTable = blockContext.uniformTranslationTable;
        blockContext.block(self, passInputs);
    }
}

-(void)update:(CCEffectRenderPassInputs *)passInputs
{
    for (CCEffectRenderPassUpdateBlock block in _updateBlocks)
    {
        block(self, passInputs);
    }
}

-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs
{
    CCRenderState *renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_shader shaderUniforms:passInputs.shaderUniforms copyUniforms:YES];
    
    GLKMatrix4 transform = passInputs.transform;
    CCRenderBuffer buffer = [passInputs.renderer enqueueTriangles:2 andVertexes:4 withState:renderState globalSortOrder:0];

    CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(passInputs.verts.bl, &transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(passInputs.verts.br, &transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(passInputs.verts.tr, &transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(passInputs.verts.tl, &transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

@end

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


