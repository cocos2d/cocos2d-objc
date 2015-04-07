#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"

@interface CCSBLoadingTest : TestBase @end
@implementation CCSBLoadingTest


-(void)setupLoadSpriteBuilderFileTest
{
	self.subTitle =
		@"Load SpriteBuilder file, add a bird:\n"
		@"Should show a bird without crashing.";
	
    CCNode *sb = [CCBReader load:@"Resources-shared/SimpleAnimation"];
    NSAssert(sb != nil, @"Unable to load spritebuilder file.");
    
    CCSprite *bird = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    [(CCNode *)sb.children[0] addChild:bird];
    
	[self.contentNode addChild:sb];
}

-(void)setupAnimatedSpriteBuilderFileTest
{
    self.subTitle =
    @"Load SpriteBuilder animation, add a bird:\n"
    @"Bird should move around.";
    
    CCNode *sb = [CCBReader load:@"Resources-shared/SimpleAnimation"];
    CCSprite *bird = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    [(CCNode *)sb.children[0] addChild:bird];
    
    [self.contentNode addChild:sb];
    
    // start animation:
    CCAnimationManager* am = sb.userObject;
    [am runAnimationsForSequenceNamed:@"Default Timeline"];
}

-(void)setupRepeatedLoadTest
{
    self.subTitle =
    @"Load SpriteBuilder animation, add a bird:\n"
    @"Keep making new birds every second. This tests for timer removal and cleanup issues.";
    
    __block CCNode *prev;
    [self scheduleBlock:^(CCTimer *timer) {
        if(prev){
            [self.contentNode removeChild:prev];
        }
        
        CCNode *sb = [CCBReader load:@"Resources-shared/SimpleAnimation"];
        CCSprite *bird = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
        [(CCNode *)sb.children[0] addChild:bird];
        
        sb.positionType = CCPositionTypeNormalized;
        sb.position = ccp(CCRANDOM_0_1() * 0.7f, CCRANDOM_0_1() * 0.5f);
        [self.contentNode addChild:sb];
        
        // start animation:
        CCAnimationManager* am = sb.userObject;
        [am runAnimationsForSequenceNamed:@"Default Timeline"];
        
        prev = sb;
        [timer repeatOnceWithInterval:1.0f];
    } delay:1.0f];

    
}


@end

