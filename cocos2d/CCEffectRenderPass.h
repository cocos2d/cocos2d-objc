//
//  CCEffectRenderPass.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffect.h"


@class CCEffectShader;


typedef NS_ENUM(NSUInteger, CCEffectTexCoordMapping)
{
    CCEffectTexCoordMapMainTex              = 0,
    CCEffectTexCoordMapPreviousPassTex      = 1,
    CCEffectTexCoordMapCustomTex            = 2,
    CCEffectTexCoordMapCustomTexNoTransform = 3
};


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

@end


@class CCEffectRenderPass;

typedef void (^CCEffectRenderPassBeginBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);
typedef void (^CCEffectRenderPassUpdateBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);


@interface CCEffectRenderPassBeginBlockContext : NSObject

@property (nonatomic, copy) CCEffectRenderPassBeginBlock block;
@property (nonatomic, strong) NSDictionary *uniformTranslationTable;

-(id)initWithBlock:(CCEffectRenderPassBeginBlock)block;

@end


@interface CCEffectRenderPass : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger indexInEffect;
@property (nonatomic, assign) NSUInteger shaderIndex;
@property (nonatomic, assign) CCEffectTexCoordMapping texCoord1Mapping;
@property (nonatomic, assign) CCEffectTexCoordMapping texCoord2Mapping;
@property (nonatomic, strong) CCBlendMode* blendMode;
@property (nonatomic, strong) CCEffectShader* effectShader;
@property (nonatomic, copy) NSArray* beginBlocks;
@property (nonatomic, copy) NSArray* updateBlocks;
@property (nonatomic, copy) NSString *debugLabel;

-(id)initWithIndex:(NSUInteger)indexInEffect;

-(void)begin:(CCEffectRenderPassInputs *)passInputs;
-(void)update:(CCEffectRenderPassInputs *)passInputs;
-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs;

@end


