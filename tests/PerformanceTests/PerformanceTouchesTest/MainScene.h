//
// cocos2d performance touches test
//

#import "cocos2d.h"

Class nextAction();

@interface MainScene : CCLayer {
	CCLabelBMFont *label;
	int			numberOfTouchesB;
	int			numberOfTouchesM;
	int			numberOfTouchesE;
	int			numberOfTouchesC;
	ccTime		elapsedTime;
}

-(NSString*) title;
@end


@interface PerformanceTest1 : MainScene
{}
@end

@interface PerformanceTest2 : MainScene
{}
@end

