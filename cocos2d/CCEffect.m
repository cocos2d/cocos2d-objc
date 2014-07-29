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

+(id)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType
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

-(id)initWithType:(NSString*)type name:(NSString*)name snippet:(NSString*)snippet
{
    if((self = [super init]))
    {
        _type = [type copy];
        _name = [name copy];
        _snippet = [snippet copy];
        return self;
    }
    
    return self;
}

+(id)inputWithType:(NSString*)type name:(NSString*)name snippet:(NSString*)snippet
{
    return [[self alloc] initWithType:type name:name snippet:snippet];
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

+(id)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value
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

+(id)varying:(NSString*)type name:(NSString*)name
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

+(id)varying:(NSString*)type name:(NSString*)name count:(NSInteger)count
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

#pragma mark CCEffectRenderPass

@implementation CCEffectRenderPass

-(id)init
{
    if((self = [super init]))
    {
        _beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){} copy]];
        _endBlocks = @[[^(CCEffectRenderPass *pass){} copy]];

        CCEffectRenderPassUpdateBlock updateBlock = ^(CCEffectRenderPass *pass){
            if (pass.needsClear)
            {
                [pass.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:[CCColor clearColor].glkVector4 depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
            }
            [pass enqueueTriangles];
        };
        _updateBlocks = @[[updateBlock copy]];
        _blendMode = [CCBlendMode premultipliedAlphaMode];
        
        return self;
    }
    
    return self;
}

-(void)begin:(CCTexture *)previousPassTexture
{
    for (CCEffectRenderPassBeginBlock block in _beginBlocks)
    {
        block(self, previousPassTexture);
    }
}

-(void)update
{
    for (CCEffectRenderPassUpdateBlock block in _updateBlocks)
    {
        block(self);
    }
}

-(void)end
{
    for (CCEffectRenderPassUpdateBlock block in _endBlocks)
    {
        block(self);
    }
}

-(void)enqueueTriangles
{
    CCRenderState *renderState = [[CCRenderState alloc] initWithBlendMode:_blendMode shader:_shader shaderUniforms:_shaderUniforms copyUniforms:YES];
    
    CCRenderBuffer buffer = [_renderer enqueueTriangles:2 andVertexes:4 withState:renderState globalSortOrder:0];
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(_verts.bl, &_transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(_verts.br, &_transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(_verts.tr, &_transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(_verts.tl, &_transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

@end

#pragma mark CCEffect

@implementation CCEffect

+ (NSArray *)defaultEffectFragmentUniforms
{
    return @[
             [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]]
            ];
}

+ (NSArray *)defaultEffectVertexUniforms
{
    return @[];
}

+ (NSSet *)defaultEffectFragmentUniformNames
{
    return [[NSSet alloc] initWithArray:@[CCShaderUniformPreviousPassTexture]];
}

+ (NSSet *)defaultEffectVertexUniformNames
{
    return [[NSSet alloc] initWithArray:@[]];
}


-(id)init
{
    return [self initWithFragmentFunction:nil vertexFunctions:nil fragmentUniforms:nil vertexUniforms:nil varyings:nil];
}

-(id)initWithFragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings
{
    return [self initWithFragmentFunction:nil vertexFunctions:nil fragmentUniforms:fragmentUniforms vertexUniforms:vertexUniforms varyings:varyings];
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings
{
    return [self initWithFragmentFunction:fragmentFunctions vertexFunctions:nil fragmentUniforms:fragmentUniforms vertexUniforms:vertexUniforms varyings:varyings];
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings
{
    if((self = [super init]))
    {
        [self buildEffectWithFragmentFunction:fragmentFunctions vertexFunctions:vertexFunctions fragmentUniforms:fragmentUniforms vertexUniforms:vertexUniforms varyings:varyings];
    }
    return self;
}

- (void)buildEffectWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings
{
    if (fragmentFunctions)
    {
        _fragmentFunctions = fragmentFunctions;
    }
    else
    {
        [self buildFragmentFunctions];
    }
    
    if (vertexFunctions)
    {
        _vertexFunctions = vertexFunctions;
    }
    else
    {
        [self buildVertexFunctions];
    }
    
    if (fragmentUniforms)
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] arrayByAddingObjectsFromArray:fragmentUniforms];
    }
    else
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] copy];
    }
    
    if (vertexUniforms)
    {
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] arrayByAddingObjectsFromArray:vertexUniforms];
        
    }
    else
    {
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] copy];
    }
    
    [self setVaryings:varyings];
    
    _stitchFlags = CCEffectFunctionStitchBoth;
    
    [self buildShaderUniforms:_fragmentUniforms vertexUniforms:_vertexUniforms];
    [self buildUniformTranslationTable];
    
    [self buildEffectShader];
    [self buildRenderPasses];
}

-(void)buildShaderUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms
{
    _shaderUniforms = [[NSMutableDictionary alloc] init];
    
    for(CCEffectUniform* uniform in fragmentUniforms)
    {
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
    
    for(CCEffectUniform* uniform in vertexUniforms)
    {
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
}

-(void)buildUniformTranslationTable
{
    self.uniformTranslationTable = [[NSMutableDictionary alloc] init];
    for(CCEffectUniform* uniform in _vertexUniforms)
    {
        self.uniformTranslationTable[uniform.name] = uniform.name;
    }

    for(CCEffectUniform* uniform in _fragmentUniforms)
    {
        self.uniformTranslationTable[uniform.name] = uniform.name;
    }
}

-(void)setVaryings:(NSArray*)varyings
{
    if (varyings)
    {
        _varyingVars = [varyings copy];
    }
    else
    {
        _varyingVars = nil;
    }
}

-(void)buildEffectShader
{
    NSString *fragBody = [self  buildShaderSourceFromBase:fragBase functions:_fragmentFunctions uniforms:_fragmentUniforms varyings:_varyingVars];
//    NSLog(@"\n------------fragBody:\n%@", fragBody);
    
    NSString *vertBody = [self  buildShaderSourceFromBase:vertBase functions:_vertexFunctions uniforms:_vertexUniforms varyings:_varyingVars];
//    NSLog(@"\n------------vertBody:\n%@", vertBody);
    
    _shader = [[CCShader alloc] initWithVertexShaderSource:vertBody fragmentShaderSource:fragBody];

}

-(NSString *)buildShaderSourceFromBase:(NSString *)shaderBase functions:(NSArray *)functions uniforms:(NSArray *)uniforms varyings:(NSArray *)varyings
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
            for (CCEffectFunctionInput *input in curFunction.inputs)
            {
                [effectFunctionBody appendFormat:@"tmp = %@;\n", input.snippet];
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

-(void)buildFragmentFunctions
{
    _fragmentFunctions = [[NSMutableArray alloc] init];
    [_fragmentFunctions addObject:[[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_FragColor;" inputs:nil returnType:@"vec4"]];
}

-(void)buildVertexFunctions
{
    _vertexFunctions = [[NSMutableArray alloc] init];
    [_vertexFunctions addObject:[[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_Position;" inputs:nil returnType:@"vec4"]];
}

-(void)buildRenderPasses
{
    self.renderPasses = @[];
}

-(NSUInteger)renderPassesRequired
{
    return _renderPasses.count;
}

- (BOOL)supportsDirectRendering
{
    return YES;
}

- (BOOL)readyForRendering
{
    return YES;
}

- (CCEffectPrepareStatus)prepareForRendering
{
    return CCEffectPrepareNothingToDo;
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



