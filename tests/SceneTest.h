#import <UIKit/UIKit.h>
#import "Layer.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end


@interface Layer1 : Layer
{
	Menu * menu;
}
-(void) onOptions;
-(void) onVoid;
-(void) onQuit;
@end

@interface Layer2 : Layer
{
	Menu * menu;
}
-(void) onGoBack;
-(void) onFullscreen;
@end

@interface Layer3: ColorLayer
{
}
@end

