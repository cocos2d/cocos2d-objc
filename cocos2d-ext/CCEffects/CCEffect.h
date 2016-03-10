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


/**
 CCEffect is the abstract base class of the Cocos2D effects classes. Subclasses of CCEffect can be used to easily add exciting
 visual effects such has blur, bloom, reflection, refraction, and other image processing filters to your applications.
 
 ### Subclasses
 
 - CCEffectBloom
 - CCEffectBlur, CCEffectPixellate
 - CCEffectBrightness, CCEffectContrast, CCEffectHue, CCEffectSaturation, CCEffectInvert, CCEffectColorChannelOffset
 - CCEffectDropShadow
 - CCEffectGlass, CCEffectReflection, CCEffectRefraction
 - CCEffectLighting
 - CCEffectStack
 - Experimental as of v3.4: CCEffectDistanceField, CCEffectDFInnerGlow, CCEffectDFOutline
 */

extern NSString * const CCShaderUniformPreviousPassTexture;
extern NSString * const CCShaderUniformTexCoord1Center;
extern NSString * const CCShaderUniformTexCoord1Extents;
extern NSString * const CCShaderUniformTexCoord2Center;
extern NSString * const CCShaderUniformTexCoord2Extents;
extern NSString * const CCEffectDefaultInitialInputSnippet;
extern NSString * const CCEffectDefaultInputSnippet;


typedef NS_ENUM(NSUInteger, CCEffectPrepareStatus)
{
    CCEffectPrepareFailure       = 0,
    CCEffectPrepareSuccess       = 1,
};

typedef NS_OPTIONS(NSUInteger, CCEffectPrepareWhatChanged)
{
    CCEffectPrepareNothingChanged  = 0,
    CCEffectPreparePassesChanged   = (1 << 0),
    CCEffectPrepareShaderChanged   = (1 << 1),
    CCEffectPrepareUniformsChanged = (1 << 2)
};

typedef struct CCEffectPrepareResult
{
    CCEffectPrepareStatus status;
    CCEffectPrepareWhatChanged changes;
} CCEffectPrepareResult;

extern const CCEffectPrepareResult CCEffectPrepareNoop;

typedef NS_ENUM(NSUInteger, CCEffectFunctionStitchFlags)
{
    CCEffectFunctionStitchBefore     = 1 << 0,
    CCEffectFunctionStitchAfter      = 1 << 1,
    CCEffectFunctionStitchBoth       = (CCEffectFunctionStitchBefore | CCEffectFunctionStitchAfter),
};

typedef NS_ENUM(NSUInteger, CCEffectTexCoordMapping)
{
    CCEffectTexCoordMapMainTex              = 0,
    CCEffectTexCoordMapPreviousPassTex      = 1,
    CCEffectTexCoordMapCustomTex            = 2,
    CCEffectTexCoordMapCustomTexNoTransform = 3
};

@interface CCEffectFunction : NSObject

@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSArray* inputs;
@property (nonatomic, readonly) NSString* inputString;
@property (nonatomic, readonly) NSString* returnType;
@property (nonatomic, readonly) NSString* function;

-(id)initWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;
+(instancetype)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;

-(NSString*)callStringWithInputs:(NSArray*)inputs;

@end

@interface CCEffectFunctionInput : NSObject

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* initialSnippet;
@property (nonatomic, readonly) NSString* snippet;

-(id)initWithType:(NSString*)type name:(NSString*)name initialSnippet:(NSString*)initialSnippet snippet:(NSString*)snippet;
+(instancetype)inputWithType:(NSString*)type name:(NSString*)name initialSnippet:(NSString*)initialSnippet snippet:(NSString*)snippet;

@end

@interface CCEffectUniform : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSValue* value;

-(id)initWithType:(NSString*)type name:(NSString*)name value:(NSValue*)value;
+(instancetype)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value;

@end

@interface CCEffectVarying : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSInteger count;

-(id)initWithType:(NSString*)type name:(NSString*)name;
-(id)initWithType:(NSString*)type name:(NSString*)name count:(NSInteger)count;
+(instancetype)varying:(NSString*)type name:(NSString*)name;
+(instancetype)varying:(NSString*)type name:(NSString*)name count:(NSInteger)count;

@end



@interface CCEffectRenderPassInputs : NSObject

@property (nonatomic, assign) NSInteger renderPassId;
@property (nonatomic, strong) CCRenderer* renderer;
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic, assign) CCSpriteVertexes verts;
@property (nonatomic, strong) CCTexture *previousPassTexture;
@property (nonatomic, assign) GLKMatrix4 transform;
@property (nonatomic, assign) GLKMatrix4 ndcToNodeLocal;
@property (nonatomic, assign) GLKVector2 texCoord1Center;
@property (nonatomic, assign) GLKVector2 texCoord1Extents;
@property (nonatomic, assign) GLKVector2 texCoord2Center;
@property (nonatomic, assign) GLKVector2 texCoord2Extents;
@property (nonatomic, strong) NSMutableDictionary* shaderUniforms;
@property (nonatomic, strong) NSDictionary* uniformTranslationTable;
@property (nonatomic, assign) BOOL needsClear;

-(void)setVertsWorkAround:(CCSpriteVertexes*)verts;

@end


@class CCEffectRenderPass;

typedef void (^CCEffectRenderPassBeginBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);
typedef void (^CCEffectRenderPassUpdateBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);


@interface CCEffectRenderPassBeginBlockContext : NSObject

@property (nonatomic, copy) CCEffectRenderPassBeginBlock block;
@property (nonatomic, strong) NSDictionary *uniformTranslationTable;

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block;

@end


@interface CCEffectRenderPass : NSObject

@property (nonatomic, readonly) NSUInteger indexInEffect;
@property (nonatomic, assign) CCEffectTexCoordMapping texCoord1Mapping;
@property (nonatomic, assign) CCEffectTexCoordMapping texCoord2Mapping;
@property (nonatomic, strong) CCBlendMode* blendMode;
@property (nonatomic, strong) CCShader* shader;
@property (nonatomic, copy) NSArray* beginBlocks;
@property (nonatomic, copy) NSArray* updateBlocks;
@property (nonatomic, copy) NSString *debugLabel;

-(id)initWithIndex:(NSUInteger)indexInEffect;

-(void)begin:(CCEffectRenderPassInputs *)passInputs;
-(void)update:(CCEffectRenderPassInputs *)passInputs;
-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs;

@end


@interface CCEffectImpl : NSObject

@property (nonatomic, copy) NSString *debugName;

@property (nonatomic, readonly) BOOL supportsDirectRendering;

@property (nonatomic, readonly) CCShader* shader;
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;
@property (nonatomic, readonly) NSArray* vertexFunctions;
@property (nonatomic, readonly) NSArray* fragmentFunctions;
@property (nonatomic, readonly) NSArray* fragmentUniforms;
@property (nonatomic, readonly) NSArray* vertexUniforms;
@property (nonatomic, readonly) NSArray* varyingVars;

@property (nonatomic, readonly) NSArray* renderPasses;
@property (nonatomic, assign) CCEffectFunctionStitchFlags stitchFlags;

@property (nonatomic, readonly) BOOL firstInStack;


-(id)initWithRenderPasses:(NSArray *)renderPasses fragmentFunctions:(NSArray*)fragmentFunctions vertexFunctions:(NSArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings firstInStack:(BOOL)firstInStack;
-(id)initWithRenderPasses:(NSArray *)renderPasses fragmentFunctions:(NSArray*)fragmentFunctions vertexFunctions:(NSArray*)vertexFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms varyings:(NSArray*)varyings;

-(id)initWithRenderPasses:(NSArray *)renderPasses shaderUniforms:(NSMutableDictionary *)uniforms;

-(CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite;
-(CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex;

-(BOOL)stitchSupported:(CCEffectFunctionStitchFlags)stitch;

+ (NSSet *)defaultEffectFragmentUniformNames;
+ (NSSet *)defaultEffectVertexUniformNames;

@end


@interface CCEffect : NSObject

/// -----------------------------------------------------------------------
/// @name Effect Properties
/// -----------------------------------------------------------------------

/** An identifier for debugging effects.
 *  @since v3.2 and later
*/
@property (nonatomic, copy) NSString *debugName;

/** Padding in points that will be applied to affected sprites to avoid clipping the
  * effect's visuals at the sprite's boundary. For example, if you create a blur effect
  * whose radius will animate over time but will never exceed 8 points then you should
  * set the padding to at least 8 to avoid clipping.
 *  @since v3.2 and later
  */
@property (nonatomic, assign) CGSize padding;

@property (nonatomic, strong) CCEffectImpl *effectImpl;

@property (nonatomic, readonly) BOOL supportsDirectRendering;
@property (nonatomic, readonly) NSUInteger renderPassCount;

-(CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite;;
-(CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex;
@end
