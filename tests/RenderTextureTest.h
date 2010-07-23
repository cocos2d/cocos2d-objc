#import <UIKit/UIKit.h>
#import "Cocos2d.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface RenderTextureTest : CCLayer
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface RenderTextureSave : RenderTextureTest
{
	CCRenderTexture* target;
	CCSprite* brush;
}
@end

@interface RenderTextureIssue937 : RenderTextureTest
{
}
@end


