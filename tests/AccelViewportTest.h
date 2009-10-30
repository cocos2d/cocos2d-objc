#import "cocos2d.h"

#import "chipmunk.h"	// needed for cpBB

//#import "VirtualAccelerometer.h"

@class CCSprite;

#define NUM_GROSSINIS 20
#define ACC_FACTOR 5.0f

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface AccelViewportDemo : CCLayer
{
	CCSprite * grossini[NUM_GROSSINIS];
	CCSprite *clouds;
	CGPoint cloudsCentered;
	CGPoint cloudsPos;
	CGPoint cloudsSize;
	CGPoint screenSize;
	CGPoint halfCloudsSize;
	cpBB visibleArea;
	CCAction * rotateForever;
	CCLabel * label;
	double accels[3];
	int num_g;
}
//-(void) centerSprites;
-(NSString*) title;
-(CCSprite *) addNewSpritePosition:(CGPoint)pos scale:(double)scle;

@end
