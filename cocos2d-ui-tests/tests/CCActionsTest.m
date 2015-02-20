#import "TestBase.h"
#import "CCScheduler_Private.h"

#define CLASS_NAME CCActionsTest

@interface CLASS_NAME : TestBase @end
@implementation CLASS_NAME

- (void) setupBasicLoopTest
{
	self.subTitle = @"Bird should running a looping rotation action.\nAction added after node.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    // Tests pausing actions
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    sprite.position = ccp(size.width * 0.5, size.height * 0.5);
    [self.contentNode addChild:sprite];
    [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:90]]];
}

- (void) setupBasicLoopActionFirstTest
{
    self.subTitle = @"Bird should running a looping rotation action.\nAction added before node.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    // Tests pausing actions
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    sprite.position = ccp(size.width * 0.5, size.height * 0.5);
    [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:90]]];
    [self.contentNode addChild:sprite];
}


- (void) setupAlternatingLoopTest
{
    self.subTitle = @"Bird should run sequence: rotate, change red, repeat forever.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    // Tests pausing actions
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    sprite.position = ccp(size.width * 0.5, size.height * 0.5);
    [self.contentNode addChild:sprite];
    CCActionSequence *seq = [CCActionSequence actions:
                     [CCActionRotateBy actionWithDuration:0.5 angle:90],
                     [CCActionTintTo actionWithDuration:0.25 color:[CCColor redColor]],
                     [CCActionTintTo actionWithDuration:0.25 color:[CCColor whiteColor]],
                     nil];
    [sprite runAction:[CCActionRepeatForever actionWithAction:seq]];
}


- (void) setupOneActionPerSpritePerformanceTest
{
    self.subTitle = @"1000 offscreen birds with individual actions.\nRun the profiler here.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    
    for(int i = 0; i < 1000; i++){
        // Tests pausing actions
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
        sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
        sprite.position = ccp(-10, -10);
        [self.contentNode addChild:sprite];
        [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:CCRANDOM_MINUS1_1() * 90]]];
    }
 
}

- (void) setupNonrepeatingActionTest
{
    self.subTitle = @"1000 offscreen birds with nonrepeating actions.\nRun the profiler here.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    __block NSMutableArray* birds = [NSMutableArray array];
    
    for(int i = 0; i < 1000; i++){
        // Tests pausing actions
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
        sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
        sprite.position = ccp(-10, -10);
        [birds addObject:sprite];
        [self.contentNode addChild:sprite];
    }
    
    CCTimer *timer = [self scheduleBlock:^(CCTimer *timer) {
        for (CCSprite *bird in birds) {
            [bird runAction:[CCActionRotateBy actionWithDuration:0.1 angle:1]];
        }

    }delay:0.2f];
    timer.repeatCount = 100;
    
}

- (void) setupNonrepeatingActionVariedDurationTest
{
    self.subTitle = @"1000 offscreen birds with nonrepeating actions. Varied Durations.\nRun the profiler here.";
    
    CGSize size = [CCDirector currentDirector].designSize;
    __block NSMutableArray* birds = [NSMutableArray array];
    
    for(int i = 0; i < 1000; i++){
        // Tests pausing actions
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
        sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
        sprite.position = ccp(-10, -10);
        [birds addObject:sprite];
        [self.contentNode addChild:sprite];
    }
    
    CCTimer *timer = [self scheduleBlock:^(CCTimer *timer) {
        for (CCSprite *bird in birds) {
            [bird runAction:[CCActionRotateBy actionWithDuration:CCRANDOM_0_1() * 0.2f angle:1]];
        }
        
    }delay:0.2f];
    timer.repeatCount = 100;
    
}


@end
