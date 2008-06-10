//
//  Label.h
//  cocos2d
//

#import <UIKit/UIKit.h>

#import "Texture2D.h"

#import "CocosNode.h"

/** A Label */
@interface Label : CocosNode {

	/* OpenGL name for the sprite texture */
	Texture2D *texture;
}

/** creates a label from a font */
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font;
/** creates a label from a fontname and font size */
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the label with a font name and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the label with font class */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font;

- (void) draw;
- (void) initAnchors;


@end