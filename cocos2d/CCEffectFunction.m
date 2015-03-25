//
//  CCEffectFunction.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffectFunction.h"

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
        
        NSString *inputString = @"void";
        if (_inputs.count)
        {
            NSMutableString *tmpString = [[NSMutableString alloc] init];
            for (CCEffectFunctionInput *input in _inputs)
            {
                [tmpString appendFormat:@"%@ %@", input.type, input.name];
            }
            inputString = tmpString;
        }
        
        _declaration = [NSString stringWithFormat:@"%@ %@(%@)", _returnType, _name, inputString];
        _definition = [NSString stringWithFormat:@"%@\n{\n%@\n}", _declaration, _body];
        
        return self;
    }
    
    return self;
}

+(instancetype)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType
{
    return [[self alloc] initWithName:name body:body inputs:inputs returnType:returnType];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    CCEffectFunction *newFunction = [[CCEffectFunction allocWithZone:zone] initWithName:_name body:_body inputs:_inputs returnType:_returnType];
    return newFunction;
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

-(id)initWithType:(NSString*)type name:(NSString*)name
{
    if((self = [super init]))
    {
        _type = [type copy];
        _name = [name copy];
        return self;
    }
    
    return self;
}

+(instancetype)inputWithType:(NSString*)type name:(NSString*)name
{
    return [[self alloc] initWithType:type name:name];
}

@end


#pragma mark CCEffectFunctionCall

@implementation CCEffectFunctionCall

-(id)initWithFunction:(CCEffectFunction *)function outputName:(NSString *)outputName inputs:(NSDictionary *)inputs
{
    NSAssert(function, @"");
    NSAssert(outputName, @"");
//    NSAssert(inputs, @"");
    
    if((self = [super init]))
    {
        _function = [function copy];
        _outputName = [outputName copy];
        _inputs = [inputs copy];
        
        // TODO Check that all of the functions inputs are represented in the inputs dictionary.
    }
    return self;
}

@end


#pragma mark CCEffectFunctionTemporary

@implementation CCEffectFunctionTemporary

-(id)initWithType:(NSString*)type name:(NSString*)name initializer:(CCEffectFunctionInitializer)initializer;
{
    NSAssert(type.length, @"");
    NSAssert(name.length, @"");
    
    if((self = [super init]))
    {
        _type = [type copy];
        _name = [name copy];
        _initializer = initializer;
    }
    return self;
}

+(instancetype)temporaryWithType:(NSString*)type name:(NSString*)name initializer:(CCEffectFunctionInitializer)initializer
{
    return [[CCEffectFunctionTemporaryGL alloc] initWithType:type name:name initializer:initializer];
}

- (NSString *)declaration
{
    NSAssert(0, @"Subclasses must override this.");
    return nil;
}

@end


#pragma mark CCEffectFunctionTemporaryGL

@interface CCEffectFunctionTemporaryGL ()

@property (nonatomic, strong) NSString *cachedDeclaration;

@end

@implementation CCEffectFunctionTemporaryGL

-(id)initWithType:(NSString*)type name:(NSString*)name initializer:(CCEffectFunctionInitializer)initializer;
{
    if((self = [super initWithType:type name:name initializer:initializer]))
    {
        _cachedDeclaration = nil;
    }
 
    return self;
}

- (NSString *)declaration
{
    if (!_cachedDeclaration)
    {
        switch (self.initializer)
        {
            case CCEffectInitFragColor:
                _cachedDeclaration = [NSString stringWithFormat:@"%@ %@ = cc_FragColor", self.type, self.name];
                break;
            case CCEffectInitMainTexture:
                _cachedDeclaration = [NSString stringWithFormat:@"vec2 compare_%@ = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\n"
                                      @"%@ %@ = cc_FragColor * texture2D(cc_MainTexture, cc_FragTexCoord1) * step(0.0, min(compare_%@.x, compare_%@.y))", self.name, self.type, self.name, self.name, self.name];
                break;
            case CCEffectInitPreviousPass:
                _cachedDeclaration = [NSString stringWithFormat:@"vec2 compare_%@ = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\n"
                                      @"%@ %@ = cc_FragColor * texture2D(cc_PreviousPassTexture, cc_FragTexCoord1) * step(0.0, min(compare_%@.x, compare_%@.y))", self.name, self.type, self.name, self.name, self.name];
                break;
            case CCEffectInitReserved0:
                _cachedDeclaration = [NSString stringWithFormat:@"%@ %@ = vec4(1)", self.type, self.name];
                break;
            case CCEffectInitReserved1:
                _cachedDeclaration = [NSString stringWithFormat:@"vec2 compare_%@ = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\n"
                                      @"%@ %@ = texture2D(cc_MainTexture, cc_FragTexCoord1) * step(0.0, min(compare_%@.x, compare_%@.y))", self.name, self.type, self.name, self.name, self.name];
                break;
            case CCEffectInitReserved2:
                _cachedDeclaration = [NSString stringWithFormat:@"vec2 compare_%@ = cc_FragTexCoord1Extents - abs(cc_FragTexCoord1 - cc_FragTexCoord1Center);\n"
                                      @"%@ %@ = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1) * step(0.0, min(compare_%@.x, compare_%@.y))", self.name, self.type, self.name, self.name, self.name];
                break;
        }
    }
    return _cachedDeclaration;
}

@end
