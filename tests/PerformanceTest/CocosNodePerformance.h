//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

@interface CocosNode (PerformanceTest)
- (void)performanceRotationScale;
- (void)performanceScale;
- (void)performancePosition;

- (void)performanceActions;
- (void) die;	
@end
