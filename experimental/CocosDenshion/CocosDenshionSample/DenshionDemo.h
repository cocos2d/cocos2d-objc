#import "cocos2d.h"
#import "CocosDenshion.h"
#import "CDAudioManager.h"

typedef enum {
	kAppStateAudioManagerInitialising,	//Audio manager is being initialised
	kAppStateSoundBuffersLoading,		//Sound buffers are loading
	kAppStateReady						//Everything is loaded
} tAppState;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
-(void) setUpAudioManager:(NSObject*) data;
@end


@interface DenshionLayer : Layer
{
	CDAudioManager *am;
	CDSoundEngine  *soundEngine;
	Sprite *slider;
	NSMutableArray *padFlashes;
	tAppState		_appState;
	
}
//-(void) setUpSoundEngine;

-(void) loadSoundBuffers:(NSObject*) data;
-(void) backgroundMusicFinished;

@end

