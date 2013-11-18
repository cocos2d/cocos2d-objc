//
//  CCFontDefinition.h
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 18.11.13.
//
//

#import <Foundation/Foundation.h>

@class CCFont;
@class CCFontAtlas;

@interface CCFontDefinitionTTF : NSObject
- (instancetype) initWithFont:(CCFont*)font andTextureSize:(NSUInteger)textureSize;
- (instancetype) initWithFont:(CCFont*)font;

- (CCFontAtlas*) makeFontAtlas;

@end
