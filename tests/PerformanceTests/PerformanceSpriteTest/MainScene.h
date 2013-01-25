//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

Class nextAction();


@interface SubTest : NSObject
{
	int					subtestNumber;
	CCSpriteBatchNode	*batchNode;
	id					parent;
}
-(id) createSpriteWithTag:(int)tag;
-(void) removeByTag:(int)tag;
-(id) initWithSubTest:(int) subtest parent:(id)parent;
@end

@interface MainScene : CCScene {
	int			lastRenderedCount;
	int			quantityNodes;
	SubTest		*subTest;
	int			subtestNumber;
}

+(id) testWithSubTest:(int)subtest nodes:(int)nodes;
-(id) initWithSubTest:(int)subtest nodes:(int)nodes;
-(void)updateNodes;
-(NSString*) title;

-(void) onIncrease:(id) sender;
-(void) onDecrease:(id) sender;

-(void) doTest:(id) sprite;
@end


@interface PerformanceTest1 : MainScene
{}
@end
@interface PerformanceTest2 : MainScene
{}
@end
@interface PerformanceTest3 : MainScene
{}
@end
@interface PerformanceTest4 : MainScene
{}
@end
@interface PerformanceTest5 : MainScene
{}
@end
@interface PerformanceTest6 : MainScene
{}
@end
@interface PerformanceTest7 : MainScene
{}
@end
@interface PerformanceTest8 : MainScene
{}
@end
@interface PerformanceTest9 : MainScene
{}
@end


