//
//  CCEffectRenderer.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/21/14.
//
//

#import <Foundation/Foundation.h>
#import "ccTypes.h"

@class CCEffectStack;
@class CCRenderer;
@class CCSprite;
@class CCTexture;

@interface CCEffectRenderer : NSObject

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, readonly) CCTexture *outputTexture;

-(id)init;
-(id)initWithWidth:(int)width height:(int)height;
-(void)drawSprite:(CCSprite *)sprite withEffects:(CCEffectStack *)effectStack renderer:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

@end
