#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
#import "CCEffectNode.h"
#import "CCEffectBlur.h"


@interface CCEffectsTest : TestBase @end
@implementation CCEffectsTest

-(id)init
{
	if((self = [super init])){
		// Delay setting the color until the first frame.
		[self scheduleBlock:^(CCTimer *timer){self.scene.color = [CCColor blackColor];} delay:0];
	}
	
	return self;
}

-(void)setupGlassEffectTest
{
    self.subTitle = @"Glass Effect Test";
    
    CGPoint p1, p2;
    
    CCSprite *reflectEnvironment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    reflectEnvironment.positionType = CCPositionTypeNormalized;
    reflectEnvironment.position = ccp(0.5f, 0.5f);
    reflectEnvironment.visible = NO;
    
    [self.contentNode addChild:reflectEnvironment];

    
    CCSprite *refractEnvironment = [CCSprite spriteWithImageNamed:@"Images/StoneWall.jpg"];
    refractEnvironment.positionType = CCPositionTypeNormalized;
    refractEnvironment.position = ccp(0.5f, 0.5f);
    refractEnvironment.scale = 0.5;
    
    [self.contentNode addChild:refractEnvironment];
    
    
    CCSpriteFrame *normalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    CCEffectGlass *glass = [[CCEffectGlass alloc] initWithShininess:1.0f refraction:1.0f refractionEnvironment:refractEnvironment reflectionEnvironment:reflectEnvironment];
    glass.fresnelBias = 0.1f;
    glass.fresnelPower = 2.0f;
    glass.refraction = 0.75f;
    
    p1 = CGPointMake(0.1f, 0.1f);
    p2 = CGPointMake(0.9f, 0.9f);
    
    CCSprite *sprite1 = [[CCSprite alloc] init];
    sprite1.positionType = CCPositionTypeNormalized;
    sprite1.position = ccp(0.5f, 0.5f);
    sprite1.normalMapSpriteFrame = normalMap;
    sprite1.effect = glass;
    sprite1.scale = 0.5f;
    sprite1.colorRGBA = [CCColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    [sprite1 runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:4.0 position:ccp(p2.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p1.y)],
                                                                [CCActionMoveTo actionWithDuration:4.0 position:ccp(p1.x, p1.y)],
                                                                nil
                                                                ]]];
    [self.contentNode addChild:sprite1];
}

-(void)setupReflectEffectTest
{
    self.subTitle = @"Reflection Effect Test";
    
    CGPoint p1, p2;
    
    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.position = ccp(0.5f, 0.5f);
    environment.visible = NO;
    
    [self.contentNode addChild:environment];
    
    CCSpriteFrame *normalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    CCEffectReflection *reflection = [[CCEffectReflection alloc] initWithShininess:1.0f environment:environment];
    reflection.fresnelBias = 0.0f;
    reflection.fresnelPower = 0.0f;
    
    p1 = CGPointMake(0.1f, 0.1f);
    p2 = CGPointMake(0.9f, 0.9f);
    
    CCSprite *sprite1 = [[CCSprite alloc] init];
    sprite1.positionType = CCPositionTypeNormalized;
    sprite1.position = ccp(0.5f, 0.5f);
    sprite1.normalMapSpriteFrame = normalMap;
    sprite1.effect = reflection;
    sprite1.scale = 0.5f;
    sprite1.colorRGBA = [CCColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];

    [sprite1 runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:4.0 position:ccp(p2.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p1.y)],
                                                                [CCActionMoveTo actionWithDuration:4.0 position:ccp(p1.x, p1.y)],
                                                                nil
                                                                ]]];
    [self.contentNode addChild:sprite1];
}


-(void)setupRefractionEffectTest
{
    self.subTitle = @"Refraction Effect Test";
    
    CGPoint p1, p2;
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/starynight.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5, 0.5);
    CGSize bgSize = background.contentSize;

    
    p1 = CGPointMake(0.1f, 0.5f);
    p2 = CGPointMake(0.9f, 0.5f);

    CCSprite *planet = [CCSprite spriteWithImageNamed:@"Images/planet1.png"];
    planet.positionType = CCPositionTypeNormalized;
    planet.position = p2;

    [planet runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                               [CCActionMoveTo actionWithDuration:4.0 position:ccp(p1.x, p1.y)],
                                                               [CCActionMoveTo actionWithDuration:4.0 position:ccp(p2.x, p2.y)],
                                                                nil
                                                                ]]];

    
    CCRenderTexture *renderTexture = [CCRenderTexture renderTextureWithWidth:bgSize.width height:bgSize.height];
    renderTexture.positionType = CCPositionTypeNormalized;
    renderTexture.position = ccp(0.5, 0.5);
    renderTexture.anchorPoint = ccp(0.5, 0.5);
    renderTexture.autoDraw = YES;
    renderTexture.sprite.anchorPoint = ccp(0.0f, 0.0f);

    [renderTexture addChild:background];
    [renderTexture addChild:planet];
    
    [self.contentNode addChild:renderTexture];
    
    NSString *sphereTextureFile = @"Images/ShinyBallColor.png";
    CCTexture *sphereTexture = [CCTexture textureWithFile:sphereTextureFile];
    CCSpriteFrame *sphereNormalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    CCEffectRefraction *sphereRefraction = [[CCEffectRefraction alloc] initWithRefraction:0.1f environment:renderTexture.sprite];
    sphereRefraction.refraction = 0.75f;
    
    p1 = CGPointMake(0.1f, 0.8f);
    p2 = CGPointMake(0.35f, 0.2f);
    CCSprite *sprite1 = [self spriteWithEffects:@[sphereRefraction] image:sphereTextureFile atPosition:p1];
    sprite1.normalMapSpriteFrame = sphereNormalMap;
    sprite1.scale = 0.5f;
    [sprite1 runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:1.0 position:ccp(p2.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p1.y)],
                                                                [CCActionMoveTo actionWithDuration:1.0 position:ccp(p1.x, p1.y)],
                                                                nil
                                                                ]]];
    [self.contentNode addChild:sprite1];

    NSString *torusTextureFile = @"Images/ShinyTorusColor.png";
    CCTexture *torusTexture = [CCTexture textureWithFile:torusTextureFile];
    CCSpriteFrame *torusNormalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyTorusNormals.png"];
    CCEffectRefraction *torusRefraction = [[CCEffectRefraction alloc] initWithRefraction:0.1f environment:renderTexture.sprite normalMap:torusNormalMap];
    torusRefraction.refraction = 0.75f;
    
    p1 = CGPointMake(0.65f, 0.2f);
    p2 = CGPointMake(0.9f, 0.8f);
    CCSprite *sprite2 = [self spriteWithEffects:@[torusRefraction] image:torusTextureFile atPosition:p1];
    sprite2.scale = 0.5f;
    [sprite2 runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p2.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p1.y)],
                                                                [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p1.y)],
                                                                nil
                                                                ]]];
    [self.contentNode addChild:sprite2];
    
    __block NSUInteger spriteConfig = 0;
    
    CCActionCallBlock *blockAction = [CCActionCallBlock actionWithBlock:^{
        spriteConfig++;
        if (spriteConfig > 8)
        {
            spriteConfig = 0;
        }
        
        switch (spriteConfig)
        {
            case 0:
                sprite1.normalMapSpriteFrame = nil;
                sphereRefraction.normalMap = nil;
                sprite1.texture = [CCTexture none];
                
                NSLog(@"Sprite: nil      Effect: nil    - You should see a rectangle.");
                break;
            case 1:
                sprite1.normalMapSpriteFrame = sphereNormalMap;
                sphereRefraction.normalMap = nil;
                sprite1.texture = sphereTexture;
                
                NSLog(@"Sprite: Sphere   Effect: nil    - You should see a sphere.");
                break;
            case 2:
                sprite1.normalMapSpriteFrame = torusNormalMap;
                sphereRefraction.normalMap = nil;
                sprite1.texture = torusTexture;
                
                NSLog(@"Sprite: Torus    Effect: nil    - You should see a torus.");
                break;
            case 3:
                sprite1.normalMapSpriteFrame = nil;
                sphereRefraction.normalMap = sphereNormalMap;
                sprite1.texture = sphereTexture;
                
                NSLog(@"Sprite: nil      Effect: Sphere - You should see a sphere.");
                break;
            case 4:
                sprite1.normalMapSpriteFrame = sphereNormalMap;
                sphereRefraction.normalMap = sphereNormalMap;
                sprite1.texture = sphereTexture;

                NSLog(@"Sprite: Sphere   Effect: Sphere - You should see a sphere.");
                break;
            case 5:
                sprite1.normalMapSpriteFrame = torusNormalMap;
                sphereRefraction.normalMap = sphereNormalMap;
                sprite1.texture = sphereTexture;

                NSLog(@"Sprite: Torus    Effect: Sphere - You should see a sphere.");
                break;
            case 6:
                sprite1.normalMapSpriteFrame = nil;
                sphereRefraction.normalMap = torusNormalMap;
                sprite1.texture = torusTexture;
                
                NSLog(@"Sprite: nil      Effect: Torus  - You should see a torus.");
                break;
            case 7:
                sprite1.normalMapSpriteFrame = sphereNormalMap;
                sphereRefraction.normalMap = torusNormalMap;
                sprite1.texture = torusTexture;
                
                NSLog(@"Sprite: Sphere   Effect: Torus  - You should see a torus.");
                break;
            case 8:
                sprite1.normalMapSpriteFrame = torusNormalMap;
                sphereRefraction.normalMap = torusNormalMap;
                sprite1.texture = torusTexture;
                
                NSLog(@"Sprite: Torus    Effect: Torus  - You should see a torus.");
                break;
        }
    }];
    [sprite2 runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                [CCActionDelay actionWithDuration:4.0f],
                                                                blockAction,
                                                                nil
                                                                ]]];
    
}

-(void)setupBlurEffectNodeTest
{
    self.subTitle = @"Blur Effect Node Test";

    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/f1.png"];
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;


    CCEffectNode* effectNode = [[CCEffectNode alloc] init];
    effectNode.contentSize = CGSizeMake(80, 80);
    effectNode.anchorPoint = ccp(0.5, 0.5);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.1, 0.5);
    [effectNode addChild:sampleSprite];
    CCEffectBlur* effect = [CCEffectBlur effectWithBlurRadius:1.0];
    effectNode.effect = effect;
    
    [self.contentNode addChild:effectNode];
    
    // Vertical
    CCSprite *sampleSprite2 = [CCSprite spriteWithImageNamed:@"Images/f1.png"];
    sampleSprite2.position = ccp(0.5, 0.5);
    sampleSprite2.positionType = CCPositionTypeNormalized;
    
    CCEffectNode* effectNode2 = [[CCEffectNode alloc] initWithWidth:80 height:80];
    effectNode2.positionType = CCPositionTypeNormalized;
    effectNode2.position = ccp(0.21, 0.5);
    [effectNode2 addChild:sampleSprite2];
    CCEffectBlur* effect2 = [CCEffectBlur effectWithBlurRadius:7.0];
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
    CCEffectBlur* effect3 = [CCEffectBlur effectWithBlurRadius:1.0];
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
    CCEffectBlur* effect4 = [CCEffectBlur effectWithBlurRadius:7.0];
    effectNode4.effect = effect4;
        
    [self.contentNode addChild:effectNode4];
}

-(void)setupBloomEffectTest
{
    self.subTitle = @"Bloom Effect Test";
    
    CCSprite *sampleSprite_base = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite_base.anchorPoint = ccp(0.0, 0.0);
    sampleSprite_base.position = ccp(0.27, 0.52);
    sampleSprite_base.positionType = CCPositionTypeNormalized;
    
    [self.contentNode addChild:sampleSprite_base];
    
    // Create a hollow circle
    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite.anchorPoint = ccp(0.5, 0.5);
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;
    
    // Blend glow maps test
    CCEffectNode* glowEffectNode = [[CCEffectNode alloc] initWithWidth:sampleSprite.contentSize.width + 7
                                                                height:sampleSprite.contentSize.height + 7];
    glowEffectNode.clearFlags = GL_COLOR_BUFFER_BIT;
	glowEffectNode.clearColor = [CCColor clearColor];
    glowEffectNode.positionType = CCPositionTypeNormalized;
    glowEffectNode.position = ccp(0.1, 0.5);
    [glowEffectNode addChild:sampleSprite];
    CCEffectBloom* glowEffect = [CCEffectBloom effectWithBlurRadius:8 intensity:1.0f luminanceThreshold:0.0f];
    glowEffectNode.effect = glowEffect;
    
    [self.contentNode addChild:glowEffectNode];
    
    
    CCSprite *sampleSprite_base2 = [CCSprite spriteWithImageNamed:@"Images/grossini_dance_08.png"];
    sampleSprite_base2.anchorPoint = ccp(0.0, 0.0);
    sampleSprite_base2.position = ccp(0.53, 0.515);
    sampleSprite_base2.positionType = CCPositionTypeNormalized;
    
    [self.contentNode addChild:sampleSprite_base2];
    
    // Create a hollow circle
    CCSprite *sampleSprite2 = [CCSprite spriteWithImageNamed:@"Images/grossini_dance_08.png"];
    sampleSprite2.anchorPoint = ccp(0.5, 0.5);
    sampleSprite2.position = ccp(0.5, 0.5);
    sampleSprite2.positionType = CCPositionTypeNormalized;
    
    // Blend glow maps test
    CCEffectNode* glowEffectNode2 = [[CCEffectNode alloc] initWithWidth:sampleSprite2.contentSize.width + 7
                                                                height:sampleSprite2.contentSize.height + 7];
    glowEffectNode2.clearFlags = GL_COLOR_BUFFER_BIT;
	glowEffectNode2.clearColor = [CCColor clearColor];
    glowEffectNode2.positionType = CCPositionTypeNormalized;
    glowEffectNode2.position = ccp(0.4, 0.5);
    [glowEffectNode2 addChild:sampleSprite2];
    CCEffectBloom* glowEffect2 = [CCEffectBloom effectWithBlurRadius:2 intensity:0.0f luminanceThreshold:0.0f];
    glowEffectNode2.effect = glowEffect2;
    
    [self.contentNode addChild:glowEffectNode2];

    // Create a sprite to blur
    const int steps = 5;
    for (int i = 0; i < steps; i++)
    {
        CCSprite *sampleSprite3 = [CCSprite spriteWithImageNamed:@"Images/grossini_dance_08.png"];
        sampleSprite3.anchorPoint = ccp(0.5, 0.5);
        sampleSprite3.position = ccp(0.1f + i * (0.8f / (steps - 1)), 0.2f);
        sampleSprite3.positionType = CCPositionTypeNormalized;
        
        // Blend glow maps test
        CCEffectBloom* glowEffect3 = [CCEffectBloom effectWithBlurRadius:8 intensity:1.0f luminanceThreshold:1.0f - ((float)i/(float)(steps-1))];
        sampleSprite3.effect = glowEffect3;
        
        [self.contentNode addChild:sampleSprite3];
    }
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
                         [[CCEffectSaturation alloc] initWithSaturation:1.0f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.8f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.4f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.2f],
                         [[CCEffectSaturation alloc] initWithSaturation:0.0f],
                         [[CCEffectSaturation alloc] initWithSaturation:-0.2f],
                         [[CCEffectSaturation alloc] initWithSaturation:-0.4f],
                         [[CCEffectSaturation alloc] initWithSaturation:-0.8f],
                         [[CCEffectSaturation alloc] initWithSaturation:-1.0f],
                         ];

    // Effect nodes that use the effects in different combinations.
    [self.contentNode addChild:[self spriteWithEffects:@[effects[0]] image:@"Images/grossini.png" atPosition:ccp(0.1, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[1]] image:@"Images/grossini.png" atPosition:ccp(0.2, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[2]] image:@"Images/grossini.png" atPosition:ccp(0.3, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[3]] image:@"Images/grossini.png" atPosition:ccp(0.4, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[4]] image:@"Images/grossini.png" atPosition:ccp(0.5, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[5]] image:@"Images/grossini.png" atPosition:ccp(0.6, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[6]] image:@"Images/grossini.png" atPosition:ccp(0.7, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[7]] image:@"Images/grossini.png" atPosition:ccp(0.8, 0.5)]];
    [self.contentNode addChild:[self spriteWithEffects:@[effects[8]] image:@"Images/grossini.png" atPosition:ccp(0.9, 0.5)]];
}

-(void)setupHueEffectTest
{
    self.subTitle = @"Hue Effect Test";
    
    // Effect nodes that use the effects in different combinations.
    int stepCount = 12;
    
    float startX = 0.05f;
    float endX = 0.95f;
    float stepX = (endX - startX) / stepCount;
    float x = startX;
    float y = 0.5f;

    float startHue = 180.0f;
    float endHue = -180.0f;
    float stepHue = (endHue - startHue) / stepCount;
    float hue = startHue;
    
    for (int i = 0; i <= stepCount; i++)
    {
        [self.contentNode addChild:[self spriteWithEffects:@[[[CCEffectHue alloc] initWithHue:hue]] image:@"Images/grossini.png" atPosition:ccp(x, y)]];
        x += stepX;
        hue += stepHue;
    }
}

-(void)setupStackTest
{
    self.subTitle = @"Effect Stacking Test";
    
    CCSprite *reflectEnvironment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    reflectEnvironment.positionType = CCPositionTypeNormalized;
    reflectEnvironment.position = ccp(0.5f, 0.5f);
    reflectEnvironment.visible = NO;
    [self.contentNode addChild:reflectEnvironment];
    
    CCSprite *refractEnvironment = [CCSprite spriteWithImageNamed:@"Images/StoneWall.jpg"];
    refractEnvironment.positionType = CCPositionTypeNormalized;
    refractEnvironment.position = ccp(0.5f, 0.5f);
    refractEnvironment.scale = 0.5;
    [self.contentNode addChild:refractEnvironment];
    
    NSArray *effects = @[
                         [CCEffectBlur effectWithBlurRadius:7.0],
                         [CCEffectBloom effectWithBlurRadius:8 intensity:1.0f luminanceThreshold:0.0f],
                         [CCEffectBrightness effectWithBrightness:0.25f],
                         [CCEffectContrast effectWithContrast:1.0f],
                         [CCEffectPixellate effectWithBlockSize:8.0f],
                         [CCEffectSaturation effectWithSaturation:-1.0f],
                         [CCEffectHue effectWithHue:90.0f],
                         [CCEffectGlass effectWithShininess:1.0f refraction:0.75f refractionEnvironment:refractEnvironment reflectionEnvironment:reflectEnvironment],
                         [CCEffectRefraction effectWithRefraction:0.75f environment:refractEnvironment],
                         [CCEffectReflection effectWithShininess:1.0f fresnelBias:0.1f fresnelPower:2.0f environment:reflectEnvironment],
                         ];
    
    
//    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/ShinyBallColor.png"];
    CCSprite *sprite = [[CCSprite alloc] init];
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5f, 0.5f);
    sprite.scale = 0.5f;

    sprite.effect = [CCEffectStack effects:effects[7], effects[4], nil];
    
    sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    sprite.colorRGBA = [CCColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:0.75f];
    sprite.colorRGBA = [CCColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    [self.contentNode addChild:sprite];
    
    CGPoint p1 = CGPointMake(0.1f, 0.1f);
    CGPoint p2 = CGPointMake(0.9f, 0.9f);
    
    [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                               [CCActionMoveTo actionWithDuration:2.0 position:ccp(p1.x, p2.y)],
                                                               [CCActionMoveTo actionWithDuration:4.0 position:ccp(p2.x, p2.y)],
                                                               [CCActionMoveTo actionWithDuration:2.0 position:ccp(p2.x, p1.y)],
                                                               [CCActionMoveTo actionWithDuration:4.0 position:ccp(p1.x, p1.y)],
                                                               nil
                                                               ]]];
}

-(void)setupPerformanceTest
{
    self.subTitle = @"Effect Performance Test";

    CCSprite *reflectEnvironment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    reflectEnvironment.positionType = CCPositionTypeNormalized;
    reflectEnvironment.position = ccp(0.5f, 0.5f);
    reflectEnvironment.visible = NO;

    CCSprite *refractEnvironment = [CCSprite spriteWithImageNamed:@"Images/StoneWall.jpg"];
    refractEnvironment.positionType = CCPositionTypeNormalized;
    refractEnvironment.position = ccp(0.5f, 0.5f);
    refractEnvironment.scale = 0.5;
    
    NSArray *allEffects = @[
                            [CCEffectBlur effectWithBlurRadius:7.0],
                            [CCEffectBloom effectWithBlurRadius:8 intensity:1.0f luminanceThreshold:0.0f],
                            [CCEffectBrightness effectWithBrightness:0.25f],
                            [CCEffectContrast effectWithContrast:1.0f],
                            [CCEffectPixellate effectWithBlockSize:4.0f],
                            [CCEffectSaturation effectWithSaturation:-1.0f],
                            [CCEffectHue effectWithHue:90.0f],
                            [CCEffectGlass effectWithShininess:1.0f refraction:0.5f refractionEnvironment:refractEnvironment reflectionEnvironment:reflectEnvironment],
                            [CCEffectRefraction effectWithRefraction:0.5f environment:refractEnvironment],
                            [CCEffectReflection effectWithShininess:1.0f fresnelBias:0.1f fresnelPower:4.0f environment:reflectEnvironment],
                            ];
    CCEffect *selectedEffect = allEffects[8];

    
    CCSpriteFrame *normalMap = nil;
    if ([selectedEffect.debugName isEqualToString:@"CCEffectGlass"])
    {
        [self.contentNode addChild:reflectEnvironment];
        [self.contentNode addChild:refractEnvironment];
        normalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    }
    else if ([selectedEffect.debugName isEqualToString:@"CCEffectRefraction"])
    {
        [self.contentNode addChild:refractEnvironment];
        normalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    }
    else if ([selectedEffect.debugName isEqualToString:@"CCEffectReflection"])
    {
        [self.contentNode addChild:reflectEnvironment];
        normalMap = [CCSpriteFrame frameWithImageNamed:@"Images/ShinyBallNormals.png"];
    }
    
    
    CGSize containerSize = self.contentNode.contentSizeInPoints;
    
    const float footprintScale = 1.1f;
    
    NSString *spriteImage = @"Images/r1.png";
    CCSprite *sprite = [CCSprite spriteWithImageNamed:spriteImage];
    
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
            if (normalMap)
            {
                sprite = [[CCSprite alloc] init];
                sprite.normalMapSpriteFrame = normalMap;
                sprite.scale = 0.1f;
                sprite.colorRGBA = [CCColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
            }
            else
            {
                sprite = [CCSprite spriteWithImageNamed:spriteImage];
            }
            
            sprite.positionType = CCPositionTypePoints;
            sprite.position = ccp(xPos, yPos);
            sprite.anchorPoint = ccp(0.0f, 0.0f);
            sprite.effect = selectedEffect;

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
        CCEffectStack *stack = [CCEffectStack effectWithArray:effects];
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
        CCEffectStack *stack = [CCEffectStack effectWithArray:effects];
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

