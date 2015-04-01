//
//  CCEffectUniform.h
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import <Foundation/Foundation.h>

@interface CCEffectUniform : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* declaration;
@property (nonatomic, readonly) NSValue* value;

-(id)initWithType:(NSString*)type name:(NSString*)name value:(NSValue*)value;
+(instancetype)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value;

@end

