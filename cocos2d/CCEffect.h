//
//  CCEffect.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "CCShader.h"
#import <ccTypes.h>

@interface CCEffectFunction : NSObject

@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* returnType;
@property (nonatomic, readonly) NSString* function;
@property (nonatomic, readonly) NSString* method;

-(id)initWithName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType;
+(id)functionName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType;

@end

@interface CCEffectUniform : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSValue* value;

-(id)initWithUniform:(NSString*)type name:(NSString*)name value:(NSValue*)value;
+(id)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value;

@end

@interface CCEffect : NSObject

@property (nonatomic, readonly) CCShader* shader;
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;

-(id)initWithUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms;

// TODO: add a way for effect implementations to update uniforms dynamically

@end
