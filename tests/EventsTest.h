#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface EventTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface KeyboardTest : EventTest
{
}
@end

@interface MouseTest : EventTest
{
}
@end

@interface TouchTest : EventTest
{
	CCSpriteBatchNode *batch_;
	CCSprite **sprites_;
	NSUInteger nuSprites_;
	NSUInteger capacity;
}

- (void)resetToTouchesMatchingPhaseTouchingWithEvent:(NSEvent *)event;

@end
