#import <UIKit/UIKit.h>
#import "cocos2d.h"
//#import "VirtualAccelerometer.h"

@class Sprite;

#define NUM_GROSSINIS 20
#define ACC_FACTOR 5.0

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
}
@end

@interface AccelViewportDemo : Layer
{
	Sprite * grossini[NUM_GROSSINIS];
	Sprite * clouds;
	cpVect cloudsCentered;
	cpVect cloudsPos;
	cpVect cloudsSize;
	cpVect screenSize;
	cpVect halfCloudsSize;
	cpBB visibleArea;
	Action * rotateForever;
	Label * label;
	double accels[3];
	int num_g;
}
//-(void) centerSprites;
-(NSString*) title;
-(Sprite *) addNewSpritePosition:(cpVect)pos scale:(double)scle;

@end
