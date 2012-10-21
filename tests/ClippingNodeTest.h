
#import "BaseAppController.h"

@class CCLayer;

@class CCAction;

@class CCNode;
@class CCDrawNode;
@class CCSprite;
@class CCClippingNode;

@interface AppController : BaseAppController
@end

@interface BaseClippingNodeTest : CCLayer

- (NSString *)title;
- (NSString *)subtitle;

- (void)backCallback:(id)sender;
- (void)nextCallback:(id)sender;
- (void)restartCallback:(id)sender;

- (void)setup;

@end

@interface BasicTest : BaseClippingNodeTest

- (CCAction *)actionRotate;
- (CCAction *)actionScale;

- (CCDrawNode *)shape;
- (CCSprite *)gossini;

- (CCNode *)stencil;
- (CCClippingNode *)clipper;
- (CCNode *)content;

@end

@interface ShapeTest : BasicTest
@end

@interface ShapeInvertedTest : ShapeTest
@end

@interface SpriteTest : BasicTest
@end

@interface SpriteNoAlphaTest : SpriteTest
@end

@interface SpriteInvertedTest : SpriteTest
@end

@interface NestedTest : BaseClippingNodeTest
@end

@interface ScrollViewDemo : BaseClippingNodeTest
@end
