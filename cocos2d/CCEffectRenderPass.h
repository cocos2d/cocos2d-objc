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

typedef struct CCEffectTexCoordsMapping
{
    CCEffectTexCoordMapping tc1;
    CCEffectTexCoordMapping tc2;
    
} CCEffectTexCoordsMapping;

static const CCEffectTexCoordsMapping CCEffectTexCoordsMappingDefault = { CCEffectTexCoordMapPreviousPassTex, CCEffectTexCoordMapCustomTex };



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

typedef void (^CCEffectBeginBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);
typedef void (^CCEffectUpdateBlock)(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs);


@interface CCEffectBeginBlockContext : NSObject <NSCopying>

@property (nonatomic, readonly) CCEffectBeginBlock block;
@property (nonatomic, readonly) NSDictionary *uniformTranslationTable;

-(id)initWithBlock:(CCEffectBeginBlock)block uniformTranslationTable:(NSDictionary *)utt;
-(id)initWithBlock:(CCEffectBeginBlock)block;

@end


@interface CCEffectRenderPassDescriptor : NSObject <NSCopying>

@property (nonatomic, assign) NSUInteger shaderIndex;
@property (nonatomic, assign) CCEffectTexCoordsMapping texCoordsMapping;
@property (nonatomic, strong) CCBlendMode* blendMode;
@property (nonatomic, copy) NSArray* beginBlocks;
@property (nonatomic, copy) NSArray* updateBlocks;
@property (nonatomic, copy) NSString *debugLabel;

-(id)init;
+(instancetype)descriptor;

@end


@interface CCEffectRenderPass : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger indexInEffect;
@property (nonatomic, readonly) CCEffectTexCoordsMapping texCoordsMapping;
@property (nonatomic, readonly) CCBlendMode *blendMode;
@property (nonatomic, readonly) NSUInteger shaderIndex;
@property (nonatomic, readonly) CCEffectShader *effectShader;
@property (nonatomic, readonly) NSArray *beginBlocks;
@property (nonatomic, readonly) NSArray *updateBlocks;
@property (nonatomic, readonly) NSString *debugLabel;

-(id)initWithIndex:(NSUInteger)indexInEffect
  texCoordsMapping:(CCEffectTexCoordsMapping)texCoordsMapping
         blendMode:(CCBlendMode *)blendMode
       shaderIndex:(NSUInteger)shaderIndex
      effectShader:(CCEffectShader *)effectShader
       beginBlocks:(NSArray *)beginBlocks
      updateBlocks:(NSArray *)updateBlocks
        debugLabel:(NSString *)debugLabel;

-(void)begin:(CCEffectRenderPassInputs *)passInputs;
-(void)update:(CCEffectRenderPassInputs *)passInputs;
-(void)enqueueTriangles:(CCEffectRenderPassInputs *)passInputs;

@end


