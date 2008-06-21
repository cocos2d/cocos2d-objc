#import <UIKit/UIKit.h>
#import "Layer.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface SpriteDemo : Layer
{
	Sprite * grossini;
	Sprite *tamara;
}
-(void) centerSprites;
-(NSString*) title;
@end

@interface SpriteMove : SpriteDemo
{
	NSOutputStream *oStream;
    NSInputStream *iStream;
}
- (void) setupSocket;
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;

@end