//
//  CCEffect.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import "CCEffect.h"
#import "CCEffect_Private.h"

@implementation CCEffectFunction

-(id)initWithName:(NSString *)name body:(NSString*)body returnType:(NSString *)returnType
{
    if(self = [super init])
    {
        _body = body;
        _name = name;
        _returnType = returnType;
        return self;
    }
    
    return self;
}

+(id)functionName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType
{
    return [[self alloc] initWithName:name body:body returnType:returnType];
}

-(NSString*)function
{
    NSString* function = [NSString stringWithFormat:@"%@ %@(void)\n{\n%@\n}", _returnType, _name, _body];
    return function;
}

-(NSString*)method
{
    NSString* method = [NSString stringWithFormat:@"%@()", _name];
    return method;
}

@end

@implementation CCEffectUniform

-(id)initWithUniform:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    if(self = [super init])
    {
        _name = name;
        _type = type;
        _value = value;
        
        return self;
    }
    
    return self;
}

+(id)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    return [[self alloc] initWithUniform:type name:name value:value];
}

-(NSString*)declaration
{
    NSString* declaration = [NSString stringWithFormat:@"uniform %@ %@;", _type, _name];
    return declaration;
}

@end

@implementation CCEffectRenderPass

//

@end


@implementation CCEffect {
    NSMutableArray* _effects;
}

-(id)init
{
    if(self = [super init])
    {
        _fragmentFunctions = [[NSMutableArray alloc] init];
        _vertexFunctions = [[NSMutableArray alloc] init];
        
        [self buildFragmentFunctions];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms
{
    if(self = [super init])
    {
        _fragmentUniforms = fragmentUniforms;
        _vertexUniforms = vertexUniforms;
        _fragmentFunctions = [[NSMutableArray alloc] init];
        _vertexFunctions = [[NSMutableArray alloc] init];
        
        [self buildShaderUniforms:fragmentUniforms vertexUniforms:vertexUniforms];
        [self buildFragmentFunctions];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms
{
    if(self = [super init])
    {
        _fragmentUniforms = fragmentUniforms;
        _vertexUniforms = vertexUniforms;
        _fragmentFunctions = fragmentFunctions;
        [self buildShaderUniforms:fragmentUniforms vertexUniforms:vertexUniforms];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms
{
    if(self = [super init])
    {
        _fragmentUniforms = fragmentUniforms;
        _vertexUniforms = vertexUniforms;
        _fragmentFunctions = fragmentFunctions;
        _vertexFunctions = vertextFunctions;
        [self buildShaderUniforms:fragmentUniforms vertexUniforms:vertexUniforms];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(void)buildShaderUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms
{
    for(CCEffectUniform* uniform in fragmentUniforms)
    {
        if(_shaderUniforms == nil)
            _shaderUniforms = [[NSMutableDictionary alloc] init];
        
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
    
    for(CCEffectUniform* uniform in vertexUniforms)
    {
        if(_shaderUniforms == nil)
            _shaderUniforms = [[NSMutableDictionary alloc] init];
        
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
}

-(void)buildEffectShader
{
    // Build fragment body
    NSString* fragBase =
    @"%@\n\n"   // uniforms
    @"%@\n"     // function defs
    @"void main() {\n"
    @"gl_FragColor = %@;\n"
    @"}\n";
    
    NSMutableString* fragUniforms = [[NSMutableString alloc] init];
    for(CCEffectUniform* uniform in _fragmentUniforms)
    {
        [fragUniforms appendFormat:@"%@\n", uniform.declaration];
    }
    
    NSMutableString* fragFunctions = [[NSMutableString alloc] init];
    NSMutableString* effectFunctionBody = [[NSMutableString alloc] init];
    [effectFunctionBody appendString:@"return "];
    
    for(CCEffectFunction* curFunction in _fragmentFunctions)
    {
        [fragFunctions appendFormat:@"%@\n", curFunction.function];
        
        [effectFunctionBody appendString:curFunction.method];
        if([_fragmentFunctions lastObject] != curFunction)
            [effectFunctionBody appendString:@" + "];
        else
            [effectFunctionBody appendString:@";"];
    }
    
    CCEffectFunction* effectFunction = [[CCEffectFunction alloc] initWithName:@"effectFunction" body:effectFunctionBody returnType:@"vec4"];
    [fragFunctions appendFormat:@"%@\n", effectFunction.function];
    
    NSString* fragBody = [NSString stringWithFormat:fragBase, fragUniforms, fragFunctions, effectFunction.method];
    //NSLog(@"\n------------fragBody:\n %@", fragBody);
    
    // Build vertex body
    NSString* vertBase =
    @"%@\n\n"   // uniforms
    @"%@\n"     // function defs
    @"void main(){\n"
    @"	cc_FragColor = cc_Color;\n"
    @"	cc_FragTexCoord1 = cc_TexCoord1;\n"
    @"	cc_FragTexCoord2 = cc_TexCoord2;\n"
    @"	gl_Position = %@;\n"
    @"}\n";
    
    NSMutableString* vertexUniforms = [[NSMutableString alloc] init];
    for(CCEffectUniform* uniform in _vertexUniforms)
    {
        [vertexUniforms appendFormat:@"%@\n", uniform.declaration];
    }

    
    NSMutableString* vertexFunctions = [[NSMutableString alloc] init];
    effectFunctionBody = [[NSMutableString alloc] init];
    [effectFunctionBody appendString:@"return "];
    
    for(CCEffectFunction* curFunction in _vertexFunctions)
    {
        [vertexFunctions appendFormat:@"%@\n", curFunction.function];
        
        [effectFunctionBody appendString:curFunction.method];
        if([_vertexFunctions lastObject] != curFunction)
            [effectFunctionBody appendString:@" + "];
        else
            [effectFunctionBody appendString:@";"];
    }
    
    effectFunction = [[CCEffectFunction alloc] initWithName:@"effectFunction" body:effectFunctionBody returnType:@"vec4"];
    [vertexFunctions appendFormat:@"%@\n", effectFunction.function];
    
    NSString* vertBody = [NSString stringWithFormat:vertBase, vertexUniforms, vertexFunctions, effectFunction.method];
    //NSLog(@"\n------------vert:\n %@", vertBody);
    
    _shader = [[CCShader alloc] initWithVertexShaderSource:vertBody fragmentShaderSource:fragBody];

}

-(void)buildFragmentFunctions
{
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_FragColor;" returnType:@"vec4"];
    [_fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_Position;" returnType:@"vec4"];
    [_vertexFunctions addObject:vertexFunction];
}

-(void)renderPassBegin:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

-(void)renderPassEnd:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

@end
