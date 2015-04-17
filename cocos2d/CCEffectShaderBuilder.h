//
//  CCEffectShaderBuilder.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/9/15.
//
//

#import "CCShader.h"

typedef NS_ENUM(NSUInteger, CCEffectShaderBuilderType)
{
    CCEffectShaderBuilderVertex   = 0,
    CCEffectShaderBuilderFragment = 1,
};

@interface CCEffectShaderBuilder : NSObject

@property (nonatomic, readonly) NSString* shaderSource;
@property (nonatomic, readonly) CCEffectShaderBuilderType type;
@property (nonatomic, readonly) NSArray* functions;
@property (nonatomic, readonly) NSArray* calls;
@property (nonatomic, readonly) NSArray* temporaries;
@property (nonatomic, readonly) NSArray* uniforms;

- (id)initWithType:(CCEffectShaderBuilderType)type functions:(NSArray *)functions calls:(NSArray *)calls temporaries:(NSArray *)temporaries uniforms:(NSArray *)uniforms;

@end
