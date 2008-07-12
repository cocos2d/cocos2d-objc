#import <UIKit/UIKit.h>
#import "Layer.h"
#import "VirtualAccelerometer.h"

@class Sprite;

#define NUM_BALLS 100
#define ACC_FACTOR 1.0

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface SpriteDemo : Layer
{
	Sprite * grossini[NUM_BALLS];
	Sprite * clouds;
	cpVect screenCenter;
	cpVect cloudsPos;
	cpVect cloudsSize;
	Action * rotateForever;
}
//-(void) centerSprites;
-(NSString*) title;
@end

@interface SpriteMove : SpriteDemo <UIAccelerometerDelegate>

@end
