#import "cocos2d.h"
#import "BaseAppController.h"
@class CCLabel;

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface MainLayer : CCLayer

- (void)nextStep;

@end

@interface TouchSprite : CCSprite

@end

@interface SlideSprite : CCSprite

@end

@interface CrashSprite : CCSprite

@end
