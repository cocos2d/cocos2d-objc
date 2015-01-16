#import "TestBase.h"
#import "CCScheduler_Private.h"

#define CLASS_NAME CCActionTest

@interface CLASS_NAME : TestBase @end
@implementation CLASS_NAME

- (void) setupBasicLoopTest
{
	self.subTitle = @"Bird should running a looping rotation action.";
    
    CGSize size = [CCDirector sharedDirector].designSize;
    // Tests pausing actions
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    sprite.position = ccp(size.width * 0.5, size.height * 0.5);
    [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:90]]];
    [self.contentNode addChild:sprite];
}

- (void) setupAlternatingLoopTest
{
    self.subTitle = @"Bird should run sequence: rotate, change red, repeat forever.";
    
    CGSize size = [CCDirector sharedDirector].designSize;
    // Tests pausing actions
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    sprite.position = ccp(size.width * 0.5, size.height * 0.5);
    CCActionSequence *seq = [CCActionSequence actions:
                     [CCActionRotateBy actionWithDuration:0.5 angle:90],
                     [CCActionTintTo actionWithDuration:0.25 color:[CCColor redColor]],
                     [CCActionTintTo actionWithDuration:0.25 color:[CCColor whiteColor]],
                     nil];
    [sprite runAction:[CCActionRepeatForever actionWithAction:seq]];
    [self.contentNode addChild:sprite];
}


- (void) setupOneActionPerSpritePerformanceTest
{
    self.subTitle = @"1000 offscreen birds with individual actions.\nRun the profiler here.";
    
    CGSize size = [CCDirector sharedDirector].designSize;
    
    for(int i = 0; i < 1000; i++){
        // Tests pausing actions
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
        sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
        sprite.position = ccp(-10, -10);
        [self.contentNode addChild:sprite];
        [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:CCRANDOM_MINUS1_1() * 90]]];
    }
 
}


@end
