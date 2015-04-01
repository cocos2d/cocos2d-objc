//
//  CCEffectVarying.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import <Foundation/Foundation.h>

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

