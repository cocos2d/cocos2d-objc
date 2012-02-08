//
// cocos2d
//

#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface Layer1 : CCLayer
{
	CCLabelBMFont *label0;
	CCLabelBMFont *label1;
	CCLabelBMFont *label2;
	CCLabelBMFont *label3;
	CCLabelBMFont *label4;

	ccTime time0, time1, time2, time3, time4;
}

-(void) step1: (ccTime) dt;
-(void) step2: (ccTime) dt;
-(void) step3: (ccTime) dt;
-(void) step4: (ccTime) dt;

@end
