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
@property (nonatomic, assign) CGFloat U;
@property (nonatomic, assign) CGFloat V;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) NSUInteger textureID;
@property (nonatomic, assign) CGFloat commonLineHeight;
@property (nonatomic, assign) CGFloat anchorX;
@property (nonatomic, assign) CGFloat anchorY;
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
