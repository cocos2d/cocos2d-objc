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
    [sb.children[0] addChild:bird];
    
	[self.contentNode addChild:sb];
}

-(void)setupAnimatedSpriteBuilderFileTest
{
    self.subTitle =
    @"Load SpriteBuilder animation, add a bird:\n"
    @"Bird should move around.";
    
    CCNode *sb = [CCBReader load:@"Resources-shared/SimpleAnimation"];
    CCSprite *bird = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    [sb.children[0] addChild:bird];
    
    [self.contentNode addChild:sb];
    
    // start animation:
    CCAnimationManager* am = sb.userObject;
    [am runAnimationsForSequenceNamed:@"Default Timeline"];
}


@end

