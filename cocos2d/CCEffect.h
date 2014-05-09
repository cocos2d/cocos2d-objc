//
//  CCEffect.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "CCShader.h"
#import "ccConfig.h"
#import "ccTypes.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectFunction : NSObject

@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* returnType;
@property (nonatomic, readonly) NSString* function;
@property (nonatomic, readonly) NSString* method;

-(id)initWithName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType;
+(id)functionWithName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType;

@end

@interface CCEffectUniform : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSValue* value;

-(id)initWithType:(NSString*)type name:(NSString*)name value:(NSValue*)value;
+(id)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value;

@end

@interface CCEffectVarying : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;

-(id)initWithType:(NSString*)type name:(NSString*)name;
+(id)varying:(NSString*)type name:(NSString*)name;

@end


// Note to self: I don't like this pattern, refactor it. I think there should be a CCRenderPass that is used by CCEffect instead.
@interface CCEffectRenderPass : NSObject

@property (nonatomic) NSInteger renderPassId;
@property (nonatomic) CCSprite* sprite;
@property (nonatomic) NSMutableArray* textures; // indexed by renderPassId
@property (nonatomic) CCRenderer* renderer;
@property (nonatomic) GLKMatrix4 transform;

@end

@interface CCEffect : NSObject

@property (nonatomic, readonly) CCShader* shader; // Note: consider adding multiple shaders (one for reach renderpass, this will help break up logic and avoid branching in a potential uber shader).
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;
@property (nonatomic, readonly) NSInteger renderPassesRequired;

-(id)initWithUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;

-(void)renderPassBegin:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock;
-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock;
-(void)renderPassEnd:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock;

@end
#endif
