
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
- (CCSprite *)grossini;

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

@interface HoleDemo : BaseClippingNodeTest
@end

@interface ScrollViewDemo : BaseClippingNodeTest
@end

@interface NegativeCoordinateTest : BaseClippingNodeTest
@end

#if COCOS2D_DEBUG > 1

@interface RawStencilBufferTest : BaseClippingNodeTest
{
    CCSprite *sprite_;
}

- (void)setupStencilForClippingOnPlane:(GLint)plane;

- (void)setupStencilForDrawingOnPlane:(GLint)plane;

@end

@interface RawStencilBufferTest2 : RawStencilBufferTest
@end

@interface RawStencilBufferTest3 : RawStencilBufferTest
@end

@interface RawStencilBufferTest4 : RawStencilBufferTest
@end

@interface RawStencilBufferTest5 : RawStencilBufferTest
@end

@interface RawStencilBufferTest6 : RawStencilBufferTest
@end

#endif
