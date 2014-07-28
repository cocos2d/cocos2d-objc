//
//  CCEffect_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"
#import "CCEffectStackProtocol.h"


#ifndef GAUSSIANBLUR_OPTMIZIED_RADIUS_MAX
#define GAUSSIANBLUR_OPTMIZIED_RADIUS_MAX 6
#endif

extern NSString * const CCShaderUniformPreviousPassTexture;

typedef NS_ENUM(NSUInteger, CCEffectFunctionStitchFlags)
{
    CCEffectFunctionStitchBefore     = 1 << 0,
    CCEffectFunctionStitchAfter      = 1 << 1,
    CCEffectFunctionStitchBoth       = (CCEffectFunctionStitchBefore | CCEffectFunctionStitchAfter),
};

typedef NS_ENUM(NSUInteger, CCEffectPrepareStatus)
{
    CCEffectPrepareNothingToDo   = 0,
    CCEffectPrepareFailure       = 1,
    CCEffectPrepareSuccess       = 2,
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
@property (nonatomic, readonly) NSInteger count;

-(id)initWithType:(NSString*)type name:(NSString*)name;
-(id)initWithType:(NSString*)type name:(NSString*)name count:(NSInteger)count;
+(id)varying:(NSString*)type name:(NSString*)name;
+(id)varying:(NSString*)type name:(NSString*)name count:(NSInteger)count;

@end

@class CCEffectRenderPass;

typedef void (^CCEffectRenderPassBeginBlock)(CCEffectRenderPass *pass, CCTexture *previousPassTexture);
typedef void (^CCEffectRenderPassUpdateBlock)(CCEffectRenderPass *pass);
typedef void (^CCEffectRenderPassEndBlock)(CCEffectRenderPass *pass);

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
@property (nonatomic,copy) NSArray* beginBlocks;
@property (nonatomic,copy) NSArray* updateBlocks;
@property (nonatomic,copy) NSArray* endBlocks;
@property (nonatomic,copy) NSString *debugLabel;

-(void)begin:(CCTexture *)previousPassTexture;
-(void)update;
-(void)end;
-(void)enqueueTriangles;

@end

@interface CCEffect ()

@property (nonatomic, readonly) CCShader* shader; // Note: consider adding multiple shaders (one for reach renderpass, this will help break up logic and avoid branching in a potential uber shader).
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;
@property (nonatomic, readonly) NSInteger renderPassesRequired;
@property (nonatomic, readonly) BOOL supportsDirectRendering;
@property (nonatomic, readonly) BOOL readyForRendering;

@property (nonatomic, weak) id<CCEffectStackProtocol> owningStack;
@property (nonatomic) NSMutableArray* vertexFunctions;
@property (nonatomic) NSMutableArray* fragmentFunctions;
@property (nonatomic) NSArray* fragmentUniforms;
@property (nonatomic) NSArray* vertexUniforms;
@property (nonatomic) NSArray* varyingVars;
@property (nonatomic) NSArray* renderPasses;
@property (nonatomic) CCEffectFunctionStitchFlags stitchFlags;
@property (nonatomic) NSMutableDictionary* uniformTranslationTable;


-(id)initWithFragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;
-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying;

-(CCEffectPrepareStatus)prepareForRendering;
-(CCEffectRenderPass *)renderPassAtIndex:(NSInteger)passIndex;

-(BOOL)stitchSupported:(CCEffectFunctionStitchFlags)stitch;

-(void)setVarying:(NSArray*)varying;


-(void)buildEffectShader;
-(void)buildFragmentFunctions;
-(void)buildVertexFunctions;
-(void)buildRenderPasses;
-(void)buildUniformTranslationTable;

+ (NSSet *)defaultEffectFragmentUniformNames;
+ (NSSet *)defaultEffectVertexUniformNames;

@end

