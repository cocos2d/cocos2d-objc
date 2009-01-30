#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
}
@end

@interface TextureDemo : Layer
{
}
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface TextureLabel : TextureDemo
{
}
@end

@interface TextureLabel2 : TextureDemo
{
}
@end
