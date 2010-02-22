#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	UIWindow	*window;
}
@end

@interface SpriteDemo : CCLayer
{
}
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SpriteProgressToRadial : SpriteDemo
{}
@end

@interface SpriteProgressToHorizontal : SpriteDemo
{}
@end

@interface SpriteProgressToVertical : SpriteDemo
{}
@end


