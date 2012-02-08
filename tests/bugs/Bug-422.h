#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface Layer1 : CCLayer
{
}

-(void) reset;
-(void) check:(CCNode *)target;
-(void) menuCallback:(id) sender;
@end
