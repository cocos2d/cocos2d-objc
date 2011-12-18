#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface Layer1 : CCLayerColor
{
}
-(void) onPushScene: (id) sender;
-(void) onPushSceneTran: (id) sender;
-(void) onVoid: (id) sender;
-(void) onQuit: (id) sender;
@end

@interface Layer2 : CCLayerColor
{
	float	timeCounter;
}
-(void) onGoBack: (id) sender;
-(void) onReplaceScene: (id) sender;
-(void) onReplaceSceneTran: (id) sender;
@end

@interface Layer3: CCLayerColor
{
}
@end

