//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

@interface CCNode (PerformanceTest)
- (void)performanceRotationScale;
- (void)performanceScale;
- (void)performancePosition;
- (void)performanceOut100;
- (void)performanceout20;

- (void)performanceActions;
- (void)performanceActions20;

- (void)performanceMoveByActions;
- (void)performanceMoveToActions;

@end
