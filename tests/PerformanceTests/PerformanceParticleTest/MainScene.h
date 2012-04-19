//
// cocos2d performance particle test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

Class nextAction();

enum {
	kMaxParticles = 14000,
	kNodesIncrease = 500,
};

@interface MainScene : CCScene {
	int			lastRenderedCount;
	int			quantityParticles;
	int			subtestNumber;
}

+(id) testWithSubTest:(int)subtest particles:(int)particles;
-(id) initWithSubTest:(int)subtest particles:(int)particles;
-(void) createParticleSystem;
-(NSString*) title;

-(void) onIncrease:(id) sender;
-(void) onDecrease:(id) sender;

-(void) updateQuantityLabel;

-(void) doTest;
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

