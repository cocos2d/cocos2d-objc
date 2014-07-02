#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
#import "CCEffectNode.h"
#import "CCEffectGaussianBlur.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS

@interface CCEffectsTest : TestBase @end
@implementation CCEffectsTest

-(id)init
{
	if((self = [super init])){
		// Delay setting the color until the first frame.
		[self scheduleBlock:^(CCTimer *timer){self.scene.color = [CCColor lightGrayColor];} delay:0];
	}
	
	return self;
}

-(void)setupBlurEffectNodeTest
{
    self.subTitle = @"Blur Effect Node Test";

    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;


    CCEffectNode* effectNode = [[CCEffectNode alloc] init];
    effectNode.contentSize = CGSizeMake(80, 80);
    effectNode.anchorPoint = ccp(0.5, 0.5);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.1, 0.5);
    [effectNode addChild:sampleSprite];
    CCEffectGaussianBlur* effect = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(1.0, 0.0)];
    effectNode.effect = effect;
    
    [self.contentNode addChild:effectNode];

    
    // Vertical
    CCSprite *sampleSprite2 = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite2.position = ccp(0.5, 0.5);
    sampleSprite2.positionType = CCPositionTypeNormalized;
    
    CCEffectNode* effectNode2 = [[CCEffectNode alloc] initWithWidth:80 height:80];
    effectNode2.positionType = CCPositionTypeNormalized;
    effectNode2.position = ccp(0.21, 0.5);
    [effectNode2 addChild:sampleSprite2];
    CCEffectGaussianBlur* effect2 = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(0.0, 1.0)];
    effectNode2.effect = effect2;
    
    [self.contentNode addChild:effectNode2];
    
    // Tilt shift
    CCSprite *sampleSprite3 = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite3.position = ccp(0.5, 0.5);
    sampleSprite3.positionType = CCPositionTypeNormalized;
    
    
    CCEffectNode* effectNode3 = [[CCEffectNode alloc] initWithWidth:80 height:80];
    effectNode3.positionType = CCPositionTypeNormalized;
    effectNode3.position = ccp(0.5, 0.5);
    effectNode3.anchorPoint = ccp(0.5, 0.5);
    [effectNode3 addChild:sampleSprite3];
    CCEffectGaussianBlur* effect3 = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(1.0, 1.0)];
    effectNode3.effect = effect3;
    
    [self.contentNode addChild:effectNode3];
    
    // Tilt shift reversed
    CCSprite *sampleSprite4 = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite4.position = ccp(0.5, 0.5);
    sampleSprite4.positionType = CCPositionTypeNormalized;
    
    
    CCEffectNode* effectNode4 = [[CCEffectNode alloc] initWithWidth:80 height:80];
    effectNode4.positionType = CCPositionTypeNormalized;
    effectNode4.position = ccp(0.6, 0.5);
    [effectNode4 addChild:sampleSprite4];
    CCEffectGaussianBlur* effect4 = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(-1.0, 1.0)];
    effectNode4.effect = effect4;
    
    [self.contentNode addChild:effectNode4];
}

-(void)setupGlowEffectNodeTest
{
    self.subTitle = @"Glow Effect Node Test";
    
    // Create a hollow circle
    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
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
    CCEffectGlow* glowEffect = [CCEffectGlow effectWithBlurStrength:0.02f];
    glowEffectNode.effect = glowEffect;
    
    CGSize size = CGSizeMake(1.0, 1.0);
    [glowEffectNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [CCActionMoveTo actionWithDuration:4.0 position:ccp(0, 0.5)],
                                                                  [CCActionMoveTo actionWithDuration:4.0 position:ccp(size.width, 0.5)],
                                                                  nil
                                                                  ]]];

    
    [self.contentNode addChild:glowEffectNode];
}

-(void)setupBrightnessAndContrastEffectNodeTest
{
    self.subTitle = @"Brightness and Contrast Effect Test";
    
    // An unmodified sprite that is added directly to the scene.
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/f1.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.2, 0.5);
    [self.contentNode addChild:sprite];

    // The brightness and contrast effects.
    NSArray *effects1 = @[[[CCEffectBrightness alloc] initWithBrightness:0.25f]];
    NSArray *effects2 = @[[[CCEffectContrast alloc] initWithContrast:1.0f]];
    NSArray *effects3 = @[[[CCEffectBrightness alloc] initWithBrightness:0.25f], [[CCEffectContrast alloc] initWithContrast:1.0f]];
    NSArray *effects4 = @[[[CCEffectContrast alloc] initWithContrast:1.0f],[[CCEffectBrightness alloc] initWithBrightness:0.25f]];
    
    // Effect nodes that use the effects in different combinations.
    [self.contentNode addChild:[self effectNodeWithEffects:effects1 appliedToSpriteWithImage:@"Images/f1.png" atPosition:ccp(0.35, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:effects2 appliedToSpriteWithImage:@"Images/f1.png" atPosition:ccp(0.5, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:effects3 appliedToSpriteWithImage:@"Images/f1.png" atPosition:ccp(0.65, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:effects4 appliedToSpriteWithImage:@"Images/f1.png" atPosition:ccp(0.8, 0.5)]];
}

-(void)setupPixellateEffectNodeTest
{
    self.subTitle = @"Pixellate Effect Test";
    
    // Different configurations of the pixellate effect
    NSArray *effects = @[
                         [[CCEffectPixellate alloc] initWithBlockSize:1.0f],
                         [[CCEffectPixellate alloc] initWithBlockSize:2.0f],
                         [[CCEffectPixellate alloc] initWithBlockSize:4.0f],
                         [[CCEffectPixellate alloc] initWithBlockSize:8.0f],
                         [[CCEffectPixellate alloc] initWithBlockSize:16.0f]
                         ];
    
    // Effect nodes that use the effects in different combinations.
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[0]] appliedToSpriteWithImage:@"Images/grossini-hd.png" atPosition:ccp(0.1, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[1]] appliedToSpriteWithImage:@"Images/grossini-hd.png" atPosition:ccp(0.3, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[2]] appliedToSpriteWithImage:@"Images/grossini-hd.png" atPosition:ccp(0.5, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[3]] appliedToSpriteWithImage:@"Images/grossini-hd.png" atPosition:ccp(0.7, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[4]] appliedToSpriteWithImage:@"Images/grossini-hd.png" atPosition:ccp(0.9, 0.5)]];
}

-(void)setupSaturationEffectNodeTest
{
    self.subTitle = @"Saturation Effect Test";

    // Different configurations of the saturation effect
    NSArray *effects = @[
                         [[CCEffectSaturation alloc] initWithSaturation:2.0f],
                         [[CCEffectSaturation alloc] initWithSaturation:1.0f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.8f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.6f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.4f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.2f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.0f],
                         [[CCEffectSaturation alloc] initWithSaturation:-1.0f]
                         ];

    // Effect nodes that use the effects in different combinations.
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[0]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.15, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[1]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.25, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[2]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.35, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[3]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.45, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[4]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.55, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[5]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.65, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[6]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.75, 0.5)]];
    [self.contentNode addChild:[self effectNodeWithEffects:@[effects[7]] appliedToSpriteWithImage:@"Images/grossini.png" atPosition:ccp(0.85, 0.5)]];
}

-(void)setupPerformanceTest
{
    self.subTitle = @"Effect Performance Test";
    
//    CCEffect *glow = [CCEffectGlow effectWithBlurStrength:0.02f];
//    CCEffect *brightness = [[CCEffectBrightness alloc] initWithBrightness:0.25f];
//    CCEffect *contrast = [[CCEffectContrast alloc] initWithContrast:1.0f];
//    CCEffect *pixellate = [[CCEffectPixellate alloc] initWithBlockSize:4.0f];
//    CCEffect *blur = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(1.0, 1.0)];
    CCEffect *saturation = [[CCEffectSaturation alloc] initWithSaturation:0.0f];
    NSArray *effects = @[saturation];
    
    CGSize containerSize = self.contentNode.contentSizeInPoints;
    
    NSString *spriteImage = @"Images/snow.png";
    const float footprintScale = 1.1f;
    CCSprite *sprite = [self spriteWithEffects:effects image:spriteImage atPosition:ccp(0, 0)];
    CGSize spriteSize = sprite.contentSizeInPoints;
    CGSize spriteFootprint = CGSizeMake(spriteSize.width * footprintScale, spriteSize.height * footprintScale);
    CGSize allSpritesBounds = CGSizeMake(((int)(containerSize.width / spriteFootprint.width) * spriteFootprint.width),
                                         ((int)(containerSize.height / spriteFootprint.height) * spriteFootprint.height));
    CGPoint origin = CGPointMake((containerSize.width - allSpritesBounds.width) * 0.5f,
                                 (containerSize.height - allSpritesBounds.height) * 0.5f);
    
    int count = 0;
    for (float yPos = origin.y; (yPos + spriteFootprint.height) < containerSize.height; yPos += spriteFootprint.height)
    {
        for (float xPos = origin.x; (xPos + spriteFootprint.width) < containerSize.width; xPos += spriteFootprint.width)
        {
            sprite = [self spriteWithEffects:effects image:spriteImage atPosition:ccp(xPos, yPos)];
            sprite.anchorPoint = ccp(0.0f, 0.0f);
            sprite.positionType = CCPositionTypePoints;
            [self.contentNode addChild:sprite];
            count++;
        }
    }
    
    NSLog(@"setupPerformanceTest: Laid out %d sprites.", count);
}

- (CCNode *)effectNodeWithEffects:(NSArray *)effects appliedToSpriteWithImage:(NSString *)spriteImage atPosition:(CGPoint)position
{
    // Another sprite that will be added directly
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteImage];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5, 0.5);
    
    // Brightness and contrast test
    CCEffectNode* effectNode = [[CCEffectNode alloc] initWithWidth:sprite.contentSize.width height:sprite.contentSize.height];
    effectNode.anchorPoint = ccp(0.5, 0.5);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = position;
    [effectNode addChild:sprite];
    
    if (effects.count == 1)
    {
        effectNode.effect = effects[0];
    }
    else if (effects.count > 1)
    {
        CCEffectStack *stack = [[CCEffectStack alloc] initWithEffects:effects];
        effectNode.effect = stack;
    }
    
    return effectNode;
}

- (CCSprite *)spriteWithEffects:(NSArray *)effects image:(NSString *)spriteImage atPosition:(CGPoint)position
{
    // Another sprite that will be added directly
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteImage];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = position;
    
    if (effects.count == 1)
    {
        sprite.effect = effects[0];
    }
    else if (effects.count > 1)
    {
        CCEffectStack *stack = [[CCEffectStack alloc] initWithEffects:effects];
        sprite.effect = stack;
    }
    
    return sprite;
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

