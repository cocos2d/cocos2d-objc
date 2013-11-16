//
//  CCFontAtlas.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface CCFontLetterDefinition : NSObject
@property (assign) unichar letteCharUTF16;
@property (assign) float U;
@property (assign) float V;
@property (assign) float width;
@property (assign) float height;
@property (assign) float offsetX;
@property (assign) float offsetY;
@property (assign) int textureID;
@property (assign) float commonLineHeight;
@property (assign) float anchorX;
@property (assign) float anchorY;
@property (assign) BOOL validDefinition;
@end


@class CCFont;
@interface CCFontAtlas : NSObject

- (instancetype) initWithFont:(CCFont*)font;

- (void) addFontLetterDefinition:(CCFontLetterDefinition*)letterDefinition;
- (CCFontLetterDefinition*) fontLetterDefinitionForCharacter:(unichar)theChar;
- (BOOL) prepareLetterDefinitions:(NSString*)letters;

- (void) addTexture:(CCTexture*)texture atSlot:(NSInteger)slot;
- (CCTexture*) textureAtSlot:(NSInteger)slot;

@property (assign) CGFloat commonLineHeight;


@property (retain, readonly) CCFont* font;
@property (retain, readonly) CCTexture* texture;
@end
