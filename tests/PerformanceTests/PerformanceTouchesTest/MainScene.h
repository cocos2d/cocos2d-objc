//
// cocos2d performance touches test
//

#import "cocos2d.h"

Class nextAction();

@interface MainScene : CCLayer {
}

-(NSString*) title;
@end


@interface PerformanceTest1 : MainScene
{
	CCBitmapFontAtlas *label;
	int			numberOfTouchesB;
	int			numberOfTouchesM;
	int			numberOfTouchesE;
	int			numberOfTouchesC;
	ccTime		elapsedTime;
}
@end

