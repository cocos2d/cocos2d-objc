//
// cocos2d performance dispatcher test by 'cocos'
// Based on the test by Valentin Milea
// Based on the Children Node Performance by 'araker'
//

#import "cocos2d.h"

//run this in release mode to see the timings clearly

Class nextAction(void);
Class backAction(void);
Class restartAction(void);
int myComparatorArg(const void * first, const void * second);

@class CCProfilingTimer;

enum {
	kMaxNodes = 15000,
	kNodesIncrease = 20,
};

@interface MainScene : CCScene {
	int			lastRenderedCount;
	int			quantityOfNodes;
	int			currentQuantityOfNodes;
	
}

+(id) testWithQuantityOfNodes:(unsigned int)nodes;
-(id) initWithQuantityOfNodes:(unsigned int)nodes;
-(NSString*) title;
-(NSString*) subtitle;

-(void) onIncrease:(id) sender;
-(void) onDecrease:(id) sender;

-(void) updateQuantityLabel;
-(void) updateQuantityOfNodes;

@end

@interface SGSprite : CCSprite <CCTargetedTouchDelegate,CCStandardTouchDelegate> 
{	
}
-(id) init;
@end


//			ONLY OLD API

@interface IterateSpriteSheet : MainScene
{
	CCSpriteBatchNode	*batchNode;
	CCProfilingTimer* _profilingTimer;
}
-(NSString*) profilerName;
@end

@interface AddingDelegatesTypical : IterateSpriteSheet   //0
{}
@end

@interface AddingDelegates : IterateSpriteSheet   //1
{}
@end

@interface RemovingDelegates : IterateSpriteSheet  //2
{}
@end

@interface AddRemoveSpriteSheet : MainScene
{
	CCSpriteBatchNode	*batchNode;
	CCProfilingTimer* _profilingTimer;
}
-(NSString*) profilerName;
@end

@interface AddRandomPriorityDelegates : AddRemoveSpriteSheet //3
{}
@end

@interface RemoveDelegatesWithRandomPriority : AddRemoveSpriteSheet //4
{}
@end

@interface ReorderDelegates : AddRemoveSpriteSheet //5
{}
@end

//				NEW (and old) API

@interface FastAdd : AddRemoveSpriteSheet //1a
{}
@end

@interface FastRemoval : AddRemoveSpriteSheet //2a
{}
@end

@interface FastCompoundRemoval : AddRemoveSpriteSheet // 2b
{}
@end

@interface ReorderingOneByOneQSORT : AddRemoveSpriteSheet  // 5a
{}
@end

@interface ReorderingOneByOneMERGESORT : AddRemoveSpriteSheet  // 5b
{}
@end

@interface UltraFastReordering : AddRemoveSpriteSheet  // 5c
{}
@end

@interface BasicSpriteSheet : MainScene
{
	CCSpriteBatchNode	*batchNode;
	CCProfilingTimer* _profilingTimer;
}
-(NSString*) profilerName;
@end

@interface Various : BasicSpriteSheet  // 6
{}
@end

#if 0
 SUMMARY OF TEST RESULTS FOR iPod 1gen iOS 3.1.3 (in debug mode)
Test setup: 200 delegates (100 Standard delegates and 100 targeted delegates)
//  NSArray OLD API
0-Adding delegates-typical  (0x00222020) : avg time, 41.871648ms
0-Adding delegates-typical  (0x00222020) : avg time, 42.388987ms
0-Adding delegates-typical  (0x00222020) : avg time, 42.211356ms
1-Adding delegates (0x0025a7b0) : avg time, 38.335520ms
1-Adding delegates (0x0025a7b0) : avg time, 38.474818ms
1-Adding delegates (0x0025a7b0) : avg time, 38.628836ms
2-Removing delegates (0x00218160) : avg time, 31.570366ms
2-Removing delegates (0x00218160) : avg time, 31.573528ms
2-Removing delegates (0x00218160) : avg time, 31.610793ms
3- Add delegates with RANDOM priority (0x002399c0) : avg time, 40.152800ms
3- Add delegates with RANDOM priority (0x002399c0) : avg time, 40.811739ms
3- Add delegates with RANDOM priority (0x002399c0) : avg time, 40.993834ms
4 - Delete delegates with RANDOM priority (0x00242ca0) : avg time, 32.034090ms
4 - Delete delegates with RANDOM priority (0x00242ca0) : avg time, 31.269717ms
4 - Delete delegates with RANDOM priority (0x00242ca0) : avg time, 31.321482ms
5 - Reorder delegates NSMutableASort/InsertSort (0x0025a230) : avg time, 223.752753ms
5 - Reorder delegates NSMutableASort/InsertSort (0x0025a230) : avg time, 221.252547ms
5 - Reorder delegates NSMutableASort/InsertSort (0x0025a230) : avg time, 222.701722ms

//  CCArray new files servicing OLD API
0-Adding delegates-typical  (0x00222340) : avg time, 40.552564ms
0-Adding delegates-typical  (0x00222340) : avg time, 40.209269ms
0-Adding delegates-typical  (0x00222340) : avg time, 39.789110ms
// speed gain:		about 5.25%  TYPICAL
1-Adding delegates (0x0022cb90) : avg time, 39.056501ms
1-Adding delegates (0x0022cb90) : avg time, 39.337446ms
1-Adding delegates (0x0022cb90) : avg time, 39.305130ms
// speed gain		about -1.9% WORST CASE
2-Removing delegates (0x00222750) : avg time, 19.787355ms
2-Removing delegates (0x00222750) : avg time, 19.466457ms
2-Removing delegates (0x00222750) : avg time, 19.690112ms
// speed gain        62% 
3- Add delegates with RANDOM priority (0x00237720) : avg time, 40.726427ms
3- Add delegates with RANDOM priority (0x00237720) : avg time, 41.668953ms
3- Add delegates with RANDOM priority (0x00237720) : avg time, 40.969164ms
// speed gain		about -1.4%
4 - Delete delegates with RANDOM priority (0x00222340) : avg time, 21.059382ms
4 - Delete delegates with RANDOM priority (0x00222340) : avg time, 20.993250ms
4 - Delete delegates with RANDOM priority (0x00222340) : avg time, 20.890169ms
// speed gain         49.6% 
5 - Reorder delegates NSMutableASort/InsertSort (0x00237720) : avg time, 59.239157ms
5 - Reorder delegates NSMutableASort/InsertSort (0x00237720) : avg time, 59.061102ms
5 - Reorder delegates NSMutableASort/InsertSort (0x00237720) : avg time, 59.396493ms
// speed gain        275%

// ADVENTAGE OF NEW API

1 a - FAST ADD (0x0023cd00) : avg time, 33.023032ms
1 a - FAST ADD (0x0023cd00) : avg time, 32.198968ms
1 a - FAST ADD (0x0023cd00) : avg time, 31.350551ms
//  SPEED GAIN	 > 33.0%
2a FAST REMOVAL (0x002564c0) : avg time, 1.504204ms
2a FAST REMOVAL (0x002564c0) : avg time, 1.578540ms
2a FAST REMOVAL (0x002564c0) : avg time, 1.489650ms
// SPEED GAIN	 > 1500% 
2b Fast Compound removal (0x0024c260) : avg time, 1.958303ms
2b Fast Compound removal (0x0024c260) : avg time, 2.066753ms
2b Fast Compound removal (0x0024c260) : avg time, 2.045931ms
// SPEED GAIN	> 1500%
5a QSort (0x002564c0) : avg time, 134.083539ms
5a QSort (0x002564c0) : avg time, 134.018829ms
5a QSort (0x002564c0) : avg time, 134.094870ms
// SPEED GAIN	> 65%
5b MSort (0x0023cd00) : avg time, 149.510898ms
5b MSort (0x0023cd00) : avg time, 149.723841ms
5b MSort (0x0023cd00) : avg time, 150.293651ms
// SPEED GAIN	> 45%
5c UltraFast(delayed)Reordering (0x002222c0) : avg time, 24.026498ms
5c UltraFast(delayed)Reordering (0x002222c0) : avg time, 23.920655ms
5c UltraFast(delayed)Reordering (0x002222c0) : avg time, 24.230325ms
// SPEED GAIN	> 820% 
#endif
