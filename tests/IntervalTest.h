//
// cocos2d
//

#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Layer1 : CCLayer
{
	CCBitmapFontAtlas *label0;
	CCBitmapFontAtlas *label1;
	CCBitmapFontAtlas *label2;
	CCBitmapFontAtlas *label3;
	CCBitmapFontAtlas *label4;
	
	ccTime time0, time1, time2, time3, time4;
}

-(void) step1: (ccTime) dt;
-(void) step2: (ccTime) dt;
-(void) step3: (ccTime) dt;
-(void) step4: (ccTime) dt;

@end
