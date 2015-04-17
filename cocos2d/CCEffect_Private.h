//
//  CCEffect_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/10/14.
//
//

#import "CCEffect.h"
#import "CCEffectFunction.h"
#import "CCEffectRenderPass.h"
#import "CCEffectStackProtocol.h"
#import "CCEffectUniform.h"
#import "CCEffectVarying.h"


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

@class CCEffectImpl;


@interface CCEffect ()

@property (nonatomic, strong) CCEffectImpl *effectImpl;

@property (nonatomic, readonly) BOOL supportsDirectRendering;
@property (nonatomic, readonly) NSUInteger renderPassCount;

-(CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite;;
-(CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex;

@end


@interface CCEffectImpl : NSObject

@property (nonatomic, copy) NSString *debugName;

@property (nonatomic, readonly) BOOL supportsDirectRendering;

@property (nonatomic, readonly) NSArray* shaders;
@property (nonatomic, readonly) NSMutableDictionary* shaderUniforms;

@property (nonatomic, readonly) NSArray* renderPasses;
@property (nonatomic, assign) CCEffectFunctionStitchFlags stitchFlags;

@property (nonatomic, readonly) BOOL firstInStack;


-(id)initWithRenderPasses:(NSArray *)renderPasses shaders:(NSArray *)shaders;

-(CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite;
-(CCEffectRenderPass *)renderPassAtIndex:(NSUInteger)passIndex;

-(BOOL)stitchSupported:(CCEffectFunctionStitchFlags)stitch;

@end

