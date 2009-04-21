#import "cocos2d.h"

#import "chipmunk.h"	// needed for cpBB

//#import "VirtualAccelerometer.h"

@class Sprite;

#define NUM_GROSSINIS 20
#define ACC_FACTOR 5.0f

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface AccelViewportDemo : Layer
{
	Sprite * grossini[NUM_GROSSINIS];
	Sprite *clouds;
	CGPoint cloudsCentered;
	CGPoint cloudsPos;
	CGPoint cloudsSize;
	CGPoint screenSize;
	CGPoint halfCloudsSize;
	cpBB visibleArea;
	Action * rotateForever;
	Label * label;
	double accels[3];
	int num_g;
}
//-(void) centerSprites;
-(NSString*) title;
-(Sprite *) addNewSpritePosition:(CGPoint)pos scale:(double)scle;

@end
