/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCTexture2D.h"

#import "CCTextureNode.h"

/** CCLabel is a subclass of CCTextureNode that knows how to render text labels
 *
 * All features from CCTextureNode are valid in CCLabel
 *
 * CCLabel objects are slow. Consider using CCLabelAtlas or CCBitmapFontAtlas instead.
 */
@interface CCLabel : CCTextureNode <CCLabelProtocol>
{
	CGSize _dimensions;
	UITextAlignment _alignment;
	NSString * _fontName;
	CGFloat _fontSize;	
}

/** creates a CCLabel from a fontname, alignment, dimension and font size */
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** creates a CCLabel from a fontname and font size */
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the CCLabel with a font name, alignment, dimension and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the CCLabel with a font name and font size */
- (id) initWithString:(NSString*)string  fontName:(NSString*)name fontSize:(CGFloat)size;

/** changes the string to render
 * @warning Changing the string is as expensive as creating a new CCLabel. To obtain better performance use CCLabelAtlas
 */
- (void) setString:(NSString*)string;

@end
