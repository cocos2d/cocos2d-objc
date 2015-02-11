//
//  CCEffectRenderer.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import "ccTypes.h"

@class CCEffect;
@class CCRenderer;
@class CCSprite;
@class CCTexture;

// not documented, considered a private class
@interface CCEffectRenderer : NSObject

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) float contentScale;

-(id)init;
-(void)drawSprite:(CCSprite *)sprite withEffect:(CCEffect *)effect uniforms:(NSMutableDictionary *)uniforms renderer:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

@end
