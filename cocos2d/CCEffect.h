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
extern const NSString *CCShaderUniformPreviousPassTexture;

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

typedef void (^CCEffectRenderPassBeginBlock)(CCTexture *previousPassTexture);
typedef void (^CCEffectRenderPassUpdateBlock)();
typedef void (^CCEffectRenderPassEndBlock)();

// Note to self: I don't like this pattern, refactor it. I think there should be a CCRenderPass that is used by CCEffect instead. NOTE: convert this to a CCRnderPassProtocol
@interface CCEffectRenderPass : NSObject

@property (nonatomic) NSInteger renderPassId;
@property (nonatomic) CCRenderer* renderer;
@property (nonatomic) CCSpriteVertexes verts;
@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) CCBlendMode* blendMode;
@property (nonatomic) CCShader* shader;
@property (nonatomic) NSMutableDictionary* shaderUniforms;
@property (nonatomic) BOOL needsClear;
@property (nonatomic,copy) CCEffectRenderPassBeginBlock beginBlock;
@property (nonatomic,copy) CCEffectRenderPassUpdateBlock updateBlock;
@property (nonatomic,copy) CCEffectRenderPassEndBlock endBlock;

-(void)enqueueTriangles;

@end

@interface CCEffect : NSObject

@property (nonatomic, readonly) CCShader* shader; // Note: consider adding multiple shaders (one for reach renderpass, this will help break up logic and avoid branching in a potential uber shader).
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;
@property (nonatomic, readonly) NSInteger renderPassesRequired;
@property (nonatomic, readonly) BOOL supportsDirectRendering;
@property (nonatomic, copy) NSString *debugName;


-(id)initWithUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;

-(BOOL)prepareForRendering;
-(CCEffectRenderPass *)renderPassAtIndex:(NSInteger)passIndex;

@end
#endif
