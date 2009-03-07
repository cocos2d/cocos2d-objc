//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

Class nextAction();


@interface MainScene : Scene {
	int		lastRenderedCount;
	int		quantityNodes;
}

-(void)updateNodes;
-(NSString*) title;
@end



@interface PerformanceTest1 : MainScene
{}
@end

@interface PerformanceTest2 : MainScene
{
	AtlasSpriteManager	*spriteManager;
}
@end

@interface PerformanceTest3 : MainScene
{}
@end
