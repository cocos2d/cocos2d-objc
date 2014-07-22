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

typedef NS_ENUM(NSUInteger, CCEffectFunctionStitchFlags)
{
    CCEffectFunctionStitchBefore     = 1 << 0,
    CCEffectFunctionStitchAfter      = 1 << 1,
    CCEffectFunctionStitchBoth       = (CCEffectFunctionStitchBefore | CCEffectFunctionStitchAfter),
};


@interface CCEffectFunction : NSObject

@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSArray* inputs;
@property (nonatomic, readonly) NSString* inputString;
@property (nonatomic, readonly) NSString* returnType;
@property (nonatomic, readonly) NSString* function;

-(id)initWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;
+(id)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;

-(NSString*)callStringWithInputs:(NSArray*)inputs;

@end

@interface CCEffectFunctionInput : NSObject

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* snippet;

-(id)initWithType:(NSString*)type name:(NSString*)name snippet:(NSString*)snippet;
+(id)inputWithType:(NSString*)type name:(NSString*)name snippet:(NSString*)snippet;

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

@class CCEffectRenderPass;

typedef void (^CCEffectRenderPassBeginBlock)(CCEffectRenderPass *pass, CCTexture *previousPassTexture);
typedef void (^CCEffectRenderPassUpdateBlock)(CCEffectRenderPass *pass);
typedef void (^CCEffectRenderPassEndBlock)(CCEffectRenderPass *pass);

// Note to self: I don't like this pattern, refactor it. I think there should be a CCRenderPass that is used by CCEffect instead. NOTE: convert this to a CCRnderPassProtocol
@interface CCEffectRenderPass : NSObject

@property (nonatomic) NSInteger renderPassId;
@property (nonatomic) CCRenderer* renderer;
@property (nonatomic) CCMatrix4 transform;
@property (nonatomic) CCSpriteVertexes verts;
@property (nonatomic) CCBlendMode* blendMode;
@property (nonatomic) CCShader* shader;
@property (nonatomic) NSMutableDictionary* shaderUniforms;
@property (nonatomic) BOOL needsClear;
@property (nonatomic,copy) NSArray* beginBlocks;
@property (nonatomic,copy) NSArray* updateBlocks;
@property (nonatomic,copy) NSArray* endBlocks;

-(void)begin:(CCTexture *)previousPassTexture;
-(void)update;
-(void)end;
-(void)enqueueTriangles;

@end

@interface CCEffect : NSObject

@property (nonatomic, readonly) CCShader* shader; // Note: consider adding multiple shaders (one for reach renderpass, this will help break up logic and avoid branching in a potential uber shader).
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;
@property (nonatomic, readonly) NSInteger renderPassesRequired;
@property (nonatomic, readonly) BOOL supportsDirectRendering;
@property (nonatomic, copy) NSString *debugName;


-(id)initWithFragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;

-(BOOL)prepareForRendering;
-(CCEffectRenderPass *)renderPassAtIndex:(NSInteger)passIndex;

-(BOOL)stitchSupported:(CCEffectFunctionStitchFlags)stitch;

@end
#endif
