#import <UIKit/UIKit.h>
#import "Layer.h"
//#import "VirtualAccelerometer.h"

@class Sprite;

#define NUM_BALLS 20
#define ACC_FACTOR 5.0

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface AccelViewportDemo : Layer
{
	Sprite * grossini[NUM_BALLS];
	Sprite * clouds;
	cpVect cloudsCentered;
	cpVect cloudsPos;
	cpVect cloudsSize;
	cpBB visibleArea;
	Action * rotateForever;
	double accels[3];
	int num_g;
}
//-(void) centerSprites;
-(NSString*) title;
-(Sprite *) addNewSpritePosition:(cpVect)pos scale:(double)scle;

@end
