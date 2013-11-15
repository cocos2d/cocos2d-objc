//
//  CCFontAtlas.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"


typedef struct {
    unichar  letteCharUTF16;
    float U;
    float V;
    float width;
    float height;
    float offsetX;
    float offsetY;
    int textureID;
    float commonLineHeight;
    float anchorX;
    float anchorY;
    BOOL validDefinition;
} CCFontLetterDefinition;

@class CCFont;
@interface CCFontAtlas : NSObject

- (instancetype) initWithFont:(CCFont*)font;

- (void) addFontLetterDefinition:(const CCFontLetterDefinition*)letterDefinition;
- (BOOL) getFontLetterDefinition:(CCFontLetterDefinition*)letterDefinition forCharacter:(unichar)theChar;
- (BOOL) prepareLetterDefinitions:(NSString*)letters;

- (void) addTexture:(CCTexture*)texture atSlot:(NSInteger)slot;
- (CCTexture*) textureAtSlot:(NSInteger)slot;

@property (assign) CGFloat commonLineHeight;


@property (retain, readonly) CCFont* font;
@property (retain, readonly) CCTexture* texture;
@end
