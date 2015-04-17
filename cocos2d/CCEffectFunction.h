//
//  CCEffectFunction.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffect.h"


typedef NS_ENUM(NSUInteger, CCEffectFunctionInitializer)
{
    CCEffectInitFragColor                    = 0,
    CCEffectInitMainTexture                  = 1,
    CCEffectInitPreviousPass                 = 2,
    
    CCEffectInitReserveOffset                = 8,
    CCEffectInitReserved0                    = CCEffectInitFragColor    + CCEffectInitReserveOffset,
    CCEffectInitReserved1                    = CCEffectInitMainTexture  + CCEffectInitReserveOffset,
    CCEffectInitReserved2                    = CCEffectInitPreviousPass + CCEffectInitReserveOffset
};

@interface CCEffectFunction : NSObject

@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSArray* inputs;
@property (nonatomic, readonly) NSString* returnType;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSString* definition;


-(id)initWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;
+(instancetype)functionWithName:(NSString*)name body:(NSString*)body inputs:(NSArray*)inputs returnType:(NSString*)returnType;

-(NSString*)callStringWithInputs:(NSArray*)inputs;

@end

@interface CCEffectFunctionInput : NSObject

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* name;

-(id)initWithType:(NSString*)type name:(NSString*)name;
+(instancetype)inputWithType:(NSString*)type name:(NSString*)name;

@end


@interface CCEffectFunctionCall : NSObject

@property (nonatomic, readonly) CCEffectFunction* function;
@property (nonatomic, readonly) NSString* outputName;
@property (nonatomic, readonly) NSDictionary* inputs;

-(id)initWithFunction:(CCEffectFunction *)function outputName:(NSString *)outputName inputs:(NSDictionary *)inputs;

@end


@interface CCEffectFunctionTemporary : NSObject

@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) CCEffectFunctionInitializer initializer;

-(id)initWithType:(NSString*)type name:(NSString*)name initializer:(CCEffectFunctionInitializer)initializer;

@end

