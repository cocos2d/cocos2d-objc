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
@property (nonatomic, assign) unichar letteCharUTF16;
@property (nonatomic, assign) float U;
@property (nonatomic, assign) float V;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float offsetX;
@property (nonatomic, assign) float offsetY;
@property (nonatomic, assign) int textureID;
@property (nonatomic, assign) float commonLineHeight;
@property (nonatomic, assign) float anchorX;
@property (nonatomic, assign) float anchorY;
@property (nonatomic, assign) BOOL validDefinition;
@end


@class CCFont;
@interface CCFontAtlas : NSObject

- (instancetype) initWithFont:(CCFont*)font;

- (void) addFontLetterDefinition:(CCFontLetterDefinition*)letterDefinition;
- (CCFontLetterDefinition*) fontLetterDefinitionForCharacter:(unichar)theChar;
- (BOOL) prepareLetterDefinitions:(NSString*)letters;

- (void) addTexture:(CCTexture*)texture atSlot:(NSInteger)slot;
- (CCTexture*) textureAtSlot:(NSInteger)slot;

@property (nonatomic, assign) CGFloat commonLineHeight;


@property (nonatomic, retain, readonly) CCFont* font;
@property (nonatomic, retain, readonly) CCTexture* texture;
@end
