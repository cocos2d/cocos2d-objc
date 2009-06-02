#import "cocos2d.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
@end


@interface DenshionLayer : Layer
{
	CDAudioManager *am;
	CDSoundEngine  *soundEngine;
	Sprite *slider;
	NSMutableArray *padFlashes;
	
}
-(void) setUpSoundEngine;
-(void) backgroundMusicFinished;
@end

