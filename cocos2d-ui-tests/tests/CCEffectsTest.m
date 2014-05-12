#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
#import "CCEffectNode.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS

@interface CCEffectsTest : TestBase @end
@implementation CCEffectsTest

-(id)init
{
	if((self = [super init])){
		// Delay setting the color until the first frame.
		// Otherwise the scene will not exist yet.
		[self scheduleBlock:^(CCTimer *timer){self.scene.color = [CCColor lightGrayColor];} delay:0];
		
        // Alternatively, set up some rotating colors.
//		float delay = 1.0f;
//		[self scheduleBlock:^(CCTimer *timer) {
//			GLKMatrix4 colorMatrix = GLKMatrix4MakeRotation(timer.invokeTime*1e0, 1, 1, 1);
//			GLKVector4 color = GLKMatrix4MultiplyVector4(colorMatrix, GLKVector4Make(1, 0, 0, 1));
//			self.scene.color = [CCColor colorWithGLKVector4:color];
//
//			[timer repeatOnceWithInterval:delay];
//		} delay:delay];
	}
	
	return self;
}

//#define GLOW_WITHOUT_AUTO_DRAW
-(void)setupGlowEffectNodeTest
{
//    CCSprite *testSprite = [CCSprite spriteWithImageNamed:@"sample_hollow_circle.png"];
//    testSprite.anchorPoint = ccp(0.5, 0.5);
//    testSprite.positionType = CCPositionTypeNormalized;
//    testSprite.position = ccp(0.55, 0.5);
//    [self.contentNode addChild:testSprite];
    
    self.subTitle = @"Glow Effect Node Test";
    
    // Create a hollow circle
    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"sample_hollow_circle.png"];
    sampleSprite.anchorPoint = ccp(0.5, 0.5);
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;
    
    // Blend glow maps test
    CCEffectNode* glowEffectNode = [[CCEffectNode alloc] initWithWidth:80 height:80];
    glowEffectNode.clearFlags = GL_COLOR_BUFFER_BIT;
	glowEffectNode.clearColor = [CCColor clearColor];
    glowEffectNode.positionType = CCPositionTypeNormalized;
    glowEffectNode.position = ccp(0.1, 0.5);
    [glowEffectNode addChild:sampleSprite];
    CCEffectGlow* glowEffect = [CCEffectGlow effectWithRadius:0.01f];
    glowEffectNode.effect = glowEffect;
    
#ifdef GLOW_WITHOUT_AUTO_DRAW
    [glowEffectNode visit];

    CCSprite* testSrpite = [CCSprite spriteWithTexture:glowEffectNode.texture];
    testSrpite.positionType = CCPositionTypeNormalized;
    testSrpite.position = ccp(0.6, 0.5);
    [self.contentNode addChild:testSrpite];
    
    CCSprite *defaultSprite = [CCSprite spriteWithImageNamed:@"sample_hollow_circle.png"];
    defaultSprite.anchorPoint = ccp(0.5, 0.5);
    defaultSprite.positionType = CCPositionTypeNormalized;
    defaultSprite.position = ccp(0.1, 0.5);
    [self.contentNode addChild:defaultSprite];
    
#else
    
    CGSize size = CGSizeMake(1.0, 1.0);
    [glowEffectNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [CCActionMoveTo actionWithDuration:4.0 position:ccp(0, 0.5)],
                                                                  [CCActionMoveTo actionWithDuration:4.0 position:ccp(size.width, 0.5)],
                                                                  nil
                                                                  ]]];

    
    [self.contentNode addChild:glowEffectNode];
#endif
    
}

-(void)setupEffectNodeTest
{
    self.subTitle = @"Effect Node Test";
    
    CGSize size = CGSizeMake(128, 128);
	
    CCEffectNode* effectNode1 = [[CCEffectNode alloc] initWithWidth:size.width height:size.height];
	effectNode1.positionType = CCPositionTypeNormalized;
	effectNode1.position = ccp(0.25, 0.5);
    [self renderTextureHelper:effectNode1 size:size];
    CCEffectColorPulse* effectColorPulse = [[CCEffectColorPulse alloc] initWithColor:[CCColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] toColor:[CCColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]];
    CCEffectTexture* effectTexture = [[CCEffectTexture alloc] init];
    CCEffect* compositeEffect = [CCEffectStack effects:effectColorPulse, effectTexture, nil];
    effectNode1.effect = compositeEffect;
	[self.contentNode addChild:effectNode1];
}

-(void)setupBrightnessAndContrastEffectNodeTest
{
    self.subTitle = @"Brightness and Contrast Effect Test";
    
    CCSprite *sprite = nil;
    
    // Add a couple sprites directly to the scene
    sprite = [CCSprite spriteWithImageNamed:@"f1.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.4, 0.5);
    [self.contentNode addChild:sprite];

    sprite = [CCSprite spriteWithImageNamed:@"f1.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5, 0.6);
    [self.contentNode addChild:sprite];

    // Create third sprite for use with the effect. It does
    // not get added to the scene directly.
    sprite = [CCSprite spriteWithImageNamed:@"f1.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5, 0.5);

    // Brightness and contrast test
    float effectDim = MAX(sprite.contentSize.width, sprite.contentSize.width);
    CCEffectNode* effectNode = [[CCEffectNode alloc] initWithWidth:effectDim height:effectDim];
    effectNode.anchorPoint = ccp(0.5, 0.5);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.5, 0.4);
    effectNode.effect = [[CCEffectBrightnessAndContrast alloc] initWithBrightness:0.25f contrast:2.0f];
    [effectNode addChild:sprite];

    [self.contentNode addChild:effectNode];
}

-(void)renderTextureHelper:(CCNode *)stage size:(CGSize)size
{
	CCColor *color = [CCColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.5];
	CCNode *node = [CCNodeColor nodeWithColor:color width:128 height:128];
	[stage addChild:node];
	
	CCNodeColor *colorNode = [CCNodeColor nodeWithColor:[CCColor greenColor] width:32 height:32];
	colorNode.anchorPoint = ccp(0.5, 0.5);
	colorNode.position = ccp(size.width, 0);
	[colorNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [CCActionMoveTo actionWithDuration:1.0 position:ccp(0, size.height)],
                                                                  [CCActionMoveTo actionWithDuration:1.0 position:ccp(size.width, 0)],
                                                                  nil
                                                                  ]]];
	[node addChild:colorNode];
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
	sprite.opacity = 0.5;
	[sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                               [CCActionMoveTo actionWithDuration:1.0 position:ccp(size.width, size.height)],
                                                               [CCActionMoveTo actionWithDuration:1.0 position:ccp(0, 0)],
                                                               nil
                                                               ]]];
	[node addChild:sprite];
}

@end
#endif