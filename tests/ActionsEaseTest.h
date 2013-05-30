#import "cocos2d.h"
#import "BaseAppController.h"

@class CCSprite;


@interface AppController : BaseAppController
@end

@interface SpriteDemo : CCLayer
{
	CCSprite * grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}
-(void) positionForTwo;
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SpriteEase : SpriteDemo
{}
@end

@interface SpriteEaseInOut : SpriteDemo
{}
@end


@interface SpriteEaseExponential : SpriteDemo
{}
@end

@interface SpriteEaseExponentialInOut : SpriteDemo
{}
@end

@interface SpriteEasePolynomial : SpriteDemo
{}
@end

@interface SpriteEasePolynomialInOut : SpriteDemo
{}
@end

@interface SpriteEaseSine : SpriteDemo
{}
@end

@interface SpriteEaseSineInOut : SpriteDemo
{}
@end

@interface SpriteEaseElastic : SpriteDemo
{}
@end

@interface SpriteEaseElasticInOut : SpriteDemo
{}
@end

@interface SpriteEaseBounce : SpriteDemo
{}
@end

@interface SpriteEaseBounceInOut : SpriteDemo
{}
@end

@interface SpriteEaseBack : SpriteDemo
{}
@end

@interface SpriteEaseBackInOut : SpriteDemo
{}
@end


@interface SpeedTest : SpriteDemo
{}
@end
