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

/** creates a label from a fontname and font size */
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the label with a font name and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;

- (void) draw;
- (void) initAnchors;

@property (readonly,assign) Texture2D* texture;

@end