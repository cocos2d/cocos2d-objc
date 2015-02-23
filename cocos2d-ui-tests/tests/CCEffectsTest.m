#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
#import "CCEffectNode.h"
#import "CCEffectBlur.h"
#import "CCEffectInvert.h"

#import "CCEffect_Private.h"
#import "CCEffectStack_Private.h"
#import "CCLightCollection.h"

@interface CCEffectsTest : TestBase @end
@implementation CCEffectsTest {
#if CC_EFFECTS_EXPERIMENTAL
    CCEffectDistanceField* _distanceFieldEffect;
    CCEffectDFOutline* _outlineEffect;
    CCEffectDFInnerGlow* _innerGlowEffect;
#endif
}

-(id)init
{
	if((self = [super init])){
		// Delay setting the color until the first frame.
		[self scheduleBlock:^(CCTimer *timer){self.scene.color = [CCColor blackColor];} delay:0];
	}
	
	return self;
}


#if CC_EFFECTS_EXPERIMENTAL

#pragma mark Outline

-(void)setupOutlineTest
{
    self.subTitle = @"Outline Effect Test";
    
    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.anchorPoint = ccp(0.5, 0.5);
    environment.position = ccp(0.5f, 0.5f);
    
    CCColor* outlineColor = [CCColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    CCEffectOutline* outline = [CCEffectOutline effectWithOutlineColor:outlineColor outlineWidth:2];
    
    // df_sprite.png grossini.png
    CCSprite *dfSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
    dfSprite.position = ccp(0.5, 0.5);
    dfSprite.positionType = CCPositionTypeNormalized;
    dfSprite.effect = outline;
    dfSprite.scale = 1.0f;

    [self.contentNode addChild:environment];
    [self.contentNode addChild:dfSprite];
}

#pragma mark Distance Fields

#define INNER_GLOW_MAX_WIDTH 6

-(void)setupDFInnerGlowTest
{
    self.subTitle = @"Distance Field Inner Glow Test";
    
    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.anchorPoint = ccp(0.5, 0.5);
    environment.position = ccp(0.5f, 0.5f);
    
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:@"Images/output.png"];
    
    CCColor* fillColor = [CCColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    _innerGlowEffect = [CCEffectDFInnerGlow effectWithGlowColor:[CCColor redColor] fillColor:fillColor glowWidth:INNER_GLOW_MAX_WIDTH fieldScale:32 distanceField:texture];
    
    CCSprite *dfSprite = [CCSprite spriteWithImageNamed:@"Images/df_sprite.png"];
    dfSprite.position = ccp(0.5, 0.5);
    dfSprite.positionType = CCPositionTypeNormalized;
    dfSprite.effect = _innerGlowEffect;
    dfSprite.scale = 1.0f;
    
    CCSpriteFrame* background = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background.png"];
    CCSpriteFrame* backgroundHilite = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background-hilite.png"];
    CCSpriteFrame* handle = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-handle.png"];
    
    CCSlider* slider = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider.positionType = CCPositionTypeNormalized;
    slider.position = ccp(0.1f, 0.5f);
    slider.sliderValue = 1.0;
    slider.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider.preferredSize = CGSizeMake(0.5f, 10);
    slider.rotation = 90;
    slider.anchorPoint = ccp(0.5f, 0.5f);
    slider.scale = 0.8;
    slider.continuous = YES;
    
    [slider setTarget:self selector:@selector(innerGlowWidthChanged:)];
    
    [self.contentNode addChild:environment];
    [self.contentNode addChild:slider];
    [self.contentNode addChild:dfSprite];
}

- (void)innerGlowWidthChanged:(id)sender
{
    const int innerGloWMax = INNER_GLOW_MAX_WIDTH;
    CCSlider* slider = sender;
    _innerGlowEffect.glowWidth = slider.sliderValue * innerGloWMax;
}

#define OUTLINE_MAX_WIDTH 6

-(void)setupDFOutlineEffectTest
{
    self.subTitle = @"Distance Field Outline Test";
    
    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.anchorPoint = ccp(0.5, 0.5);
    environment.position = ccp(0.5f, 0.5f);
    
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:@"Images/output.png"];
    
    CCColor* fillColor = [CCColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.0];
    _outlineEffect = [CCEffectDFOutline effectWithOutlineColor:[CCColor redColor] fillColor:fillColor outlineWidth:OUTLINE_MAX_WIDTH fieldScale:32 distanceField:texture];

    CCSprite *dfSprite = [CCSprite spriteWithImageNamed:@"Images/df_sprite.png"];
    dfSprite.position = ccp(0.5, 0.5);
    dfSprite.positionType = CCPositionTypeNormalized;
    dfSprite.effect = _outlineEffect;
    dfSprite.scale = 1.0f;
    
    CCSpriteFrame* background = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background.png"];
    CCSpriteFrame* backgroundHilite = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background-hilite.png"];
    CCSpriteFrame* handle = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-handle.png"];
    
    CCSlider* slider = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider.positionType = CCPositionTypeNormalized;
    slider.position = ccp(0.1f, 0.5f);
    slider.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider.preferredSize = CGSizeMake(0.5f, 10);
    slider.rotation = 90;
    slider.anchorPoint = ccp(0.5f, 0.5f);
    slider.scale = 0.8;
    slider.sliderValue = 1.0;
    slider.continuous = YES;
    
    [slider setTarget:self selector:@selector(outlineWidthChagne:)];
    
    [self.contentNode addChild:environment];
    [self.contentNode addChild:slider];
    [self.contentNode addChild:dfSprite];
    
    // 6 pixel block used for comparison;
    CCNodeColor* block = [CCNodeColor nodeWithColor:[CCColor greenColor]];
    block.contentSize = CGSizeMake(6.0, 6.0);
    block.position = ccp(0.424, 0.324);
    block.positionType = CCPositionTypeNormalized;
    block.rotation = 32;
//    [self.contentNode addChild:block];
}

- (void)outlineWidthChagne:(id)sender
{
    const int outlineWidthMax = OUTLINE_MAX_WIDTH;
    CCSlider* slider = sender;
    _outlineEffect.outlineWidth = slider.sliderValue * outlineWidthMax;
}

-(void)setupDistanceFieldEffectTest
{
    self.subTitle = @"Distance Field Effect Test";
    
    //    CCNodeColor* environment = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.anchorPoint = ccp(0.5, 0.5);
    environment.position = ccp(0.5f, 0.5f);

    [self.contentNode addChild:environment];

    CCColor *glowColor = [CCColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    _distanceFieldEffect = [CCEffectDistanceField effectWithGlowColor:glowColor outlineColor:[CCColor redColor]];
    _distanceFieldEffect.outlineInnerWidth = 1.0f;
    _distanceFieldEffect.outlineOuterWidth = 1.0f;
    _distanceFieldEffect.glowWidth = 1.0f;
    
    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/output.png"];
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;
    sampleSprite.effect = _distanceFieldEffect;
    sampleSprite.scale = 1.0f;
    
    CCSpriteFrame* background = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background.png"];
    CCSpriteFrame* backgroundHilite = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background-hilite.png"];
    CCSpriteFrame* handle = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-handle.png"];
    
    CCSlider* slider = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider.positionType = CCPositionTypeNormalized;
    slider.position = ccp(0.1f, 0.5f);
    
    slider.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider.preferredSize = CGSizeMake(0.5f, 10);
    slider.rotation = 90;
    slider.anchorPoint = ccp(0.5f, 0.5f);
    slider.scale = 0.8;
    slider.sliderValue = 1.0;
    slider.continuous = YES;
    
    [slider setTarget:self selector:@selector(outlineInnerWidthChange:)];
    
    CCSlider* slider2 = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider2 setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider2.positionType = CCPositionTypeNormalized;
    slider2.position = ccp(0.15f, 0.5f);
    
    slider2.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider2.preferredSize = CGSizeMake(0.5f, 10);
    slider2.rotation = 90;
    slider2.anchorPoint = ccp(0.5f, 0.5f);
    slider2.scale = 0.8;
    slider2.sliderValue = 1.0;
    slider2.continuous = YES;
    
    [slider2 setTarget:self selector:@selector(outlineOuterWidthChange:)];
    
    CCSlider* slider3 = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider3 setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider3.positionType = CCPositionTypeNormalized;
    slider3.position = ccp(0.20f, 0.5f);
    
    slider3.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider3.preferredSize = CGSizeMake(0.5f, 10);
    slider3.rotation = 90;
    slider3.anchorPoint = ccp(0.5f, 0.5f);
    slider3.scale = 0.8;
    slider3.sliderValue = 1.0;
    slider3.continuous = YES;

    [slider3 setTarget:self selector:@selector(glowWidthChange:)];
    
    CCButton* enableGlow = [CCButton buttonWithTitle:@"Outer Glow"];
    enableGlow.positionType = CCPositionTypeNormalized;
    enableGlow.anchorPoint = ccp(0.5f, 0.5f);
    enableGlow.position = ccp(0.9, 0.8);
    [enableGlow setTarget:self selector:@selector(enableGlow:)];
    
    CCButton* enableOutline = [CCButton buttonWithTitle:@"Outline"];
    enableOutline.positionType = CCPositionTypeNormalized;
    enableOutline.anchorPoint = ccp(0.5f, 0.5f);
    enableOutline.position = ccp(0.9, 0.7);
    [enableOutline setTarget:self selector:@selector(enableOutline:)];

    [self.contentNode addChild:enableOutline];
    [self.contentNode addChild:enableGlow];
    [self.contentNode addChild:sampleSprite];
    [self.contentNode addChild:slider];
    [self.contentNode addChild:slider2];
    [self.contentNode addChild:slider3];
}

- (void)outlineInnerWidthChange:(id)sender
{
    CCSlider* slider = sender;
    _distanceFieldEffect.outlineInnerWidth = slider.sliderValue;
}

- (void)outlineOuterWidthChange:(id)sender
{
    CCSlider* slider = sender;
    _distanceFieldEffect.outlineOuterWidth = slider.sliderValue;
}

- (void)glowWidthChange:(id)sender
{
    CCSlider* slider = sender;
    _distanceFieldEffect.glowWidth = slider.sliderValue;
}

- (void)enableGlow:(id)sender
{
    _distanceFieldEffect.glow = !_distanceFieldEffect.glow;
}

- (void)enableOutline:(id)sender
{
    _distanceFieldEffect.outline = !_distanceFieldEffect.outline;
}
#endif

-(void)setupSimpleLightingTest
{
    self.subTitle = @"Simple Lighting Test";
    
    [self.contentNode.scene.lights flushGroupNames];
    
    NSString *normalMapImage = @"Images/powered_normals.png";
    NSString *diffuseImage = @"Images/powered.png";
    
    void (^setupBlock)(CGPoint position, CCLightType type, float lightDepth, NSString *title) = ^void(CGPoint position, CCLightType type, float lightDepth, NSString *title)
    {
        CCLightNode *light = [[CCLightNode alloc] init];
        light.type = type;
        light.groups = @[title];
        light.positionType = CCPositionTypeNormalized;
        light.position = ccp(0.5f, 0.5f);
        light.anchorPoint = ccp(0.5f, 0.5f);
        light.intensity = 1.0f;
        light.ambientIntensity = 0.2f;
        light.cutoffRadius = 0.0f;
        light.depth = lightDepth;
        
        CCSprite *lightSprite = [CCSprite spriteWithImageNamed:@"Images/snow.png"];
        
        CCEffectLighting *lightingEffect = [[CCEffectLighting alloc] init];
        lightingEffect.groups = @[title];
        lightingEffect.shininess = 0.1f;
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:diffuseImage];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.5f, 0.5f);
        sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:normalMapImage];
        sprite.effect = lightingEffect;
        sprite.scale = 0.5f;
        
        [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [CCActionDelay actionWithDuration:1.0],
                                                                  [CCActionRotateBy actionWithDuration:4.0 angle:360.0],
                                                                  [CCActionDelay actionWithDuration:8.0],
                                                                  nil
                                                                  ]]];
        
        CCNode *root = [[CCNode alloc] init];
        root.positionType = CCPositionTypeNormalized;
        root.position = position;
        root.anchorPoint = ccp(0.5f, 0.5f);
        root.contentSizeType = CCSizeTypePoints;
        root.contentSize = CGSizeMake(200.0f, 200.0f);

        CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:@"HelveticaNeue-Light" fontSize:12 * [CCDirector sharedDirector].UIScaleFactor];
        label.color = [CCColor whiteColor];
        label.positionType = CCPositionTypeNormalized;
        label.position = ccp(0.5f, 1.0f);
        label.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:root];
        [root addChild:label];
        [root addChild:sprite];
        [root addChild:light];
        [light addChild:lightSprite];

        [light runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [CCActionMoveTo actionWithDuration:1.0 position:ccp(1.0f, 1.0f)],
                                                                  [CCActionDelay actionWithDuration:4.0],
                                                                  [CCActionMoveTo actionWithDuration:2.0 position:ccp(0.0f, 0.0f)],
                                                                  [CCActionRotateBy actionWithDuration:5.0 angle:360.0],
                                                                  [CCActionMoveTo actionWithDuration:1.0 position:ccp(0.5f, 0.5f)],
                                                                  nil
                                                                  ]]];
    };
    setupBlock(ccp(0.25f, 0.5f), CCLightPoint, 50.0f, @"Point Light\nPosition matters, orientation does not.");
    setupBlock(ccp(0.75f, 0.5f), CCLightDirectional, 0.5f, @"Directional Light\nPosition does not matter, orientation does.");
}

-(void)setupLightingRenderTextureTest
{
    self.subTitle = @"Lighting + Render Texture Test";
    
    [self.contentNode.scene.lights flushGroupNames];
    
    NSString *normalMapImage = @"Images/powered_normals.png";
    NSString *diffuseImage = @"Images/powered.png";
    
    CCNode* (^setupBlock)(CGPoint position, CCLightType type, float lightDepth, NSString *title) = ^CCNode* (CGPoint position, CCLightType type, float lightDepth, NSString *title)
    {
        CCLightNode *light = [[CCLightNode alloc] init];
        light.type = type;
        light.groups = @[title];
        light.positionType = CCPositionTypeNormalized;
        light.position = ccp(0.8f, 0.8f);
        light.anchorPoint = ccp(0.5f, 0.5f);
        light.intensity = 1.0f;
        light.ambientIntensity = 0.2f;
        light.cutoffRadius = 0.0f;
        light.depth = lightDepth;
        
        CCSprite *lightSprite = [CCSprite spriteWithImageNamed:@"Images/snow.png"];
        
        CCEffectLighting *lightingEffect = [[CCEffectLighting alloc] init];
        lightingEffect.groups = @[title];
        lightingEffect.shininess = 0.1f;
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:diffuseImage];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.5f, 0.5f);
        sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:normalMapImage];
        sprite.effect = lightingEffect;
        sprite.scale = 0.5f;
        
        CCNode *root = [[CCNode alloc] init];
        root.positionType = CCPositionTypeNormalized;
        root.position = position;
        root.anchorPoint = ccp(0.5f, 0.5f);
        root.contentSizeType = CCSizeTypePoints;
        root.contentSize = CGSizeMake(200.0f, 200.0f);
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:@"HelveticaNeue-Light" fontSize:12 * [CCDirector sharedDirector].UIScaleFactor];
        label.color = [CCColor whiteColor];
        label.positionType = CCPositionTypeNormalized;
        label.position = ccp(0.5f, 1.0f);
        label.horizontalAlignment = CCTextAlignmentCenter;
        
        [root addChild:label];
        [root addChild:sprite];
        [root addChild:light];
        [light addChild:lightSprite];
        
        return root;
    };

    CCNode *subgraph = nil;
    
    const float border = 0.12f;
    const float step = (1.0f - 2.0f * border) / 3.0f;
    float xPos = border;
    
    // Case 1
    // Create a sprite and light and add them directly to the scene
    subgraph = setupBlock(ccp(xPos, 0.5f), CCLightPoint, 50.0f, @"No Render Texture\nLit Correctly");
    [self.contentNode addChild:subgraph];
    xPos += step;
    
    // Case 2
    // Create a sprite and light and add them as children of a render texture with autodraw
    // enabled.
    CCRenderTexture *rt1 = [CCRenderTexture renderTextureWithWidth:256 height:256];
    rt1.positionType = CCPositionTypeNormalized;
    rt1.position = ccp(xPos, 0.5f);
    rt1.anchorPoint = ccp(0.5f, 0.5f);
    rt1.autoDraw = YES;
    rt1.sprite.anchorPoint = ccp(0.0f, 0.0f);
    [self.contentNode addChild:rt1];

    subgraph = setupBlock(ccp(0.5f, 0.5f), CCLightPoint, 50.0f, @"Render Texture\nAuto Draw\nLit Correctly");
    [rt1 addChild:subgraph];
    xPos += step;
    
    // Case 3
    // Create a sprite and light and render them into a render texture with a manual
    // call to visit. The sprite should be all black because it is not part of the scene
    // and therefore the effect cannot access the light collection.
    CCRenderTexture *rt2 = [CCRenderTexture renderTextureWithWidth:256 height:256];
    rt2.positionType = CCPositionTypeNormalized;
    rt2.position = ccp(xPos, 0.5f);
    rt2.anchorPoint = ccp(0.5f, 0.5f);
    rt2.autoDraw = NO;
    rt2.sprite.anchorPoint = ccp(0.0f, 0.0f);
    [self.contentNode addChild:rt2];
    
    subgraph = setupBlock(ccp(0.5f, 0.5f), CCLightPoint, 50.0f, @"Render Texture\nManual Draw\nSprite is Black");
    subgraph.positionType = CCPositionTypePoints;
    subgraph.position = ccp(128.0f, 128.0f);
    
    [rt2 beginWithClear:0 g:0 b:0 a:0];
    [subgraph visit];
    [rt2 end];
    xPos += step;
    
    // Case 4
    // Create a sprite and light and add them to a render texture but still draw them with a
    // manual call to visit. The sprite should render correctly because it is now part of the
    // scene and the effect will be able to fine the light collection.
    CCRenderTexture *rt3 = [CCRenderTexture renderTextureWithWidth:256 height:256];
    rt3.positionType = CCPositionTypeNormalized;
    rt3.position = ccp(xPos, 0.5f);
    rt3.anchorPoint = ccp(0.5f, 0.5f);
    rt3.autoDraw = NO;
    rt3.sprite.anchorPoint = ccp(0.0f, 0.0f);
    [self.contentNode addChild:rt3];
    
    subgraph = setupBlock(ccp(0.5f, 0.5f), CCLightPoint, 50.0f, @"Render Texture\nSprite in Scene\nLit Correctly");
    subgraph.positionType = CCPositionTypePoints;
    subgraph.position = ccp(128.0f, 128.0f);
    [rt3 addChild:subgraph];
    
    [rt3 beginWithClear:0 g:0 b:0 a:0];
    [subgraph visit];
    [rt3 end];
    xPos += step;
}

-(void)setupLightingParameterTest
{
    self.subTitle = @"Varying Light Parameter Test";
    
    [self.contentNode.scene.lights flushGroupNames];

    NSString *normalMapImage = @"Images/ShinyTorusNormals.png";
    NSString *diffuseImage = @"Images/ShinyTorusColor.png";
    
    CCLightNode* (^setupBlock)(CGPoint position, NSString *title, CCAction *action) = ^CCLightNode*(CGPoint position, NSString *title, CCAction *action)
    {
        CCLightNode *light = [[CCLightNode alloc] init];
        light.groups = @[title];
        light.positionType = CCPositionTypeNormalized;
        light.position = ccp(1.0f, 1.0f);
        light.anchorPoint = ccp(0.5f, 0.5f);
        light.intensity = 1.0f;
        light.ambientIntensity = 0.2f;
        light.cutoffRadius = 0.0f;
        light.depth = 100.0f;
        
        CCSprite *lightSprite = [CCSprite spriteWithImageNamed:@"Images/snow.png"];
        [light addChild:lightSprite];
        
        CCEffectLighting *lightingEffect = [[CCEffectLighting alloc] init];
        lightingEffect.groups = @[title];
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:diffuseImage];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = position;
        sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:normalMapImage];
        sprite.effect = lightingEffect;
        sprite.scale = 0.3f;
        
        [self.contentNode addChild:sprite];
        
        [sprite addChild:light];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:@"HelveticaNeue-Light" fontSize:36 * [CCDirector sharedDirector].UIScaleFactor];
        label.color = [CCColor whiteColor];
        label.positionType = CCPositionTypeNormalized;
        label.position = ccp(0.5f, 1.1f);
        label.horizontalAlignment = CCTextAlignmentCenter;
        
        [sprite addChild:label];
        
        if (action)
        {
            [light runAction:action];
        }
        return light;
    };

    
    CCLightNode *light = nil;
    CCSprite *sprite = nil;
    CCEffectLighting *lighting = nil;

    
    // Primary color
    //
    light = setupBlock(ccp(0.1f, 0.65f), @"Primary Intensity", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                                        [CCActionTween actionWithDuration:2 key:@"intensity" from:0.0f to:1.0f],
                                                                                                        [CCActionDelay actionWithDuration:2],
                                                                                                        [CCActionTween actionWithDuration:2 key:@"intensity" from:1.0f to:0.0f],
                                                                                                        nil
                                                                                                        ]]);
    light.ambientIntensity = 0.0f;
    light = setupBlock(ccp(0.1f, 0.25f), @"Primary Color", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                                     [CCActionTintTo actionWithDuration:2 color:[CCColor redColor]],
                                                                                                     [CCActionDelay actionWithDuration:1],
                                                                                                     [CCActionTintTo actionWithDuration:2 color:[CCColor greenColor]],
                                                                                                     [CCActionDelay actionWithDuration:1],
                                                                                                     [CCActionTintTo actionWithDuration:2 color:[CCColor blueColor]],
                                                                                                     [CCActionDelay actionWithDuration:1],
                                                                                                     [CCActionTintTo actionWithDuration:2 color:[CCColor whiteColor]],
                                                                                                     [CCActionDelay actionWithDuration:1],
                                                                                                     nil
                                                                                                     ]]);

    
    // Ambient color
    //
    light = setupBlock(ccp(0.3f, 0.65f), @"Ambient Intensity", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                                        [CCActionTween actionWithDuration:2 key:@"ambientIntensity" from:0.0f to:1.0f],
                                                                                                        [CCActionDelay actionWithDuration:2],
                                                                                                        [CCActionTween actionWithDuration:2 key:@"ambientIntensity" from:1.0f to:0.0f],
                                                                                                        nil
                                                                                                        ]]);
    light = setupBlock(ccp(0.3f, 0.25f), @"Ambient Color", nil);
    light.intensity = 0.5f;
    light.ambientIntensity = 0.5f;
    
    const float timeStep = 0.017f;
    const float duration = 2.0f;
    const float delta = timeStep / duration;
    
    typedef void (^AmbientLerpBlock)();
    typedef void (^AmbientLerpBuilderBlock)(ccColor4F deltaC);
    
    __weak CCLightNode *weakLight = light;
    AmbientLerpBlock (^ambientLerpBuilder)(ccColor4F deltaC) = ^AmbientLerpBlock(ccColor4F deltaC)
    {
        AmbientLerpBlock lerpBlock = ^{
            ccColor4F c = weakLight.ambientColor.ccColor4f;
            c.r += deltaC.r;
            c.g += deltaC.g;
            c.b += deltaC.b;
            weakLight.ambientColor = [CCColor colorWithCcColor4f:c];
        };
        return lerpBlock;
    };

    AmbientLerpBlock whiteRedLerp;
    AmbientLerpBlock redGreenLerp;
    AmbientLerpBlock greenBlueLerp;
    AmbientLerpBlock blueWhiteLerp;
    CCActionInterval *whiteRedLerpAction;
    CCActionInterval *redGreenLerpAction;
    CCActionInterval *greenBlueLerpAction;
    CCActionInterval *blueWhiteLerpAction;
    
    whiteRedLerp = ambientLerpBuilder(ccc4f(0.0f, -delta, -delta, 0.0f));
    whiteRedLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:whiteRedLerp]] times:120];
    
    redGreenLerp = ambientLerpBuilder(ccc4f(-delta, delta, 0.0f, 0.0f));
    redGreenLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:redGreenLerp]] times:120];
    
    greenBlueLerp = ambientLerpBuilder(ccc4f(0.0f, -delta, delta, 0.0f));
    greenBlueLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:greenBlueLerp]] times:120];
    
    blueWhiteLerp = ambientLerpBuilder(ccc4f(delta, delta, 0.0f, 0.0f));
    blueWhiteLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:blueWhiteLerp]] times:120];
    
    CCAction *ambientLerpAction = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           whiteRedLerpAction,
                                                                           [CCActionDelay actionWithDuration:1],
                                                                           redGreenLerpAction,
                                                                           [CCActionDelay actionWithDuration:1],
                                                                           greenBlueLerpAction,
                                                                           [CCActionDelay actionWithDuration:1],
                                                                           blueWhiteLerpAction,
                                                                           [CCActionDelay actionWithDuration:1],
                                                                           nil
                                                                           ]];
    [light runAction:ambientLerpAction];

    
    // Specular color
    //
    light = setupBlock(ccp(0.5f, 0.65f), @"Specular Intensity", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                                         [CCActionTween actionWithDuration:2 key:@"specularIntensity" from:0.0f to:1.0f],
                                                                                                         [CCActionDelay actionWithDuration:2],
                                                                                                         [CCActionTween actionWithDuration:2 key:@"specularIntensity" from:1.0f to:0.0f],
                                                                                                         nil
                                                                                                         ]]);
    light = setupBlock(ccp(0.5f, 0.25f), @"Specular Color", nil);
    light.intensity = 0.5f;
    light.ambientIntensity = 0.5f;
    light.specularIntensity = 1.0f;
    
    typedef void (^SpecularLerpBlock)();
    typedef void (^SpecularLerpBuilderBlock)(ccColor4F deltaC);
    
    weakLight = light;
    SpecularLerpBlock (^specularLerpBuilder)(ccColor4F deltaC) = ^SpecularLerpBlock(ccColor4F deltaC)
    {
        SpecularLerpBlock lerpBlock = ^{
            ccColor4F c = weakLight.specularColor.ccColor4f;
            c.r += deltaC.r;
            c.g += deltaC.g;
            c.b += deltaC.b;
            weakLight.specularColor = [CCColor colorWithCcColor4f:c];
        };
        return lerpBlock;
    };
    
    whiteRedLerp = specularLerpBuilder(ccc4f(0.0f, -delta, -delta, 0.0f));
    whiteRedLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:whiteRedLerp]] times:120];
    
    redGreenLerp = specularLerpBuilder(ccc4f(-delta, delta, 0.0f, 0.0f));
    redGreenLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:redGreenLerp]] times:120];
    
    greenBlueLerp = specularLerpBuilder(ccc4f(0.0f, -delta, delta, 0.0f));
    greenBlueLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:greenBlueLerp]] times:120];
    
    blueWhiteLerp = specularLerpBuilder(ccc4f(delta, delta, 0.0f, 0.0f));
    blueWhiteLerpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:blueWhiteLerp]] times:120];
    
    CCAction *specularLerpAction = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                            whiteRedLerpAction,
                                                                            [CCActionDelay actionWithDuration:1],
                                                                            redGreenLerpAction,
                                                                            [CCActionDelay actionWithDuration:1],
                                                                            greenBlueLerpAction,
                                                                            [CCActionDelay actionWithDuration:1],
                                                                            blueWhiteLerpAction,
                                                                            [CCActionDelay actionWithDuration:1],
                                                                            nil
                                                                            ]];
    [light runAction:specularLerpAction];
    

    // Cutoff, depth, and shininess
    //
    
    light = setupBlock(ccp(0.7f, 0.65f), @"Shininess", nil);
    sprite = (CCSprite *)light.parent;
    lighting = (CCEffectLighting *)sprite.effect;
    lighting.shininess = 0.1f;
    
    typedef void (^ShininessLerpBlock)();
    typedef void (^ShininessLerpBuilderBlock)(float delta);
    ShininessLerpBlock (^shininessLerpBuilder)(float delta) = ^ShininessLerpBlock(float delta)
    {
        ShininessLerpBlock lerpBlock = ^{
            lighting.shininess += delta;
        };
        return lerpBlock;
    };
    
    ShininessLerpBlock shininessRampUp = shininessLerpBuilder(delta * 0.5f);
    CCActionInterval *shininessRampUpAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:shininessRampUp]] times:120];
    
    ShininessLerpBlock shininessRampDown = shininessLerpBuilder(-delta * 0.5f);
    CCActionInterval *shininessRampDownAction = [CCActionRepeat actionWithAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:timeStep] two:[CCActionCallBlock actionWithBlock:shininessRampDown]] times:120];
    
    [light runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                              shininessRampUpAction,
                                                              [CCActionDelay actionWithDuration:2],
                                                              shininessRampDownAction,
                                                              nil
                                                              ]]];

    light = setupBlock(ccp(0.7f, 0.25f), @"Cutoff", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                             [CCActionTween actionWithDuration:2 key:@"cutoffRadius" from:1.0f to:1000.0f],
                                                                                             [CCActionDelay actionWithDuration:2],
                                                                                             [CCActionTween actionWithDuration:2 key:@"cutoffRadius" from:1000.0f to:1.0f],
                                                                                             nil
                                                                                             ]]);
    light.cutoffRadius = 1.0f;
    light.halfRadius = 1.0f;
    light.ambientIntensity = 0.0f;
    light.intensity = 1.0f;
    light = setupBlock(ccp(0.9f, 0.65f), @"Depth", [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                                            [CCActionTween actionWithDuration:2 key:@"depth" from:1.0f to:500.0f],
                                                                                            [CCActionTween actionWithDuration:2 key:@"depth" from:500.0f to:1.0f],
                                                                                            nil
                                                                                            ]]);
    light.depth = 1.0f;
    sprite = (CCSprite *)light.parent;
    lighting = (CCEffectLighting *)sprite.effect;
    lighting.shininess = 0.2f;
    
}

-(void)setupLightingCollectionTest
{
    self.subTitle = @"Lighting Collection Test";
    
    [self.contentNode.scene.lights flushGroupNames];
    
    NSString *normalMapImage = @"Images/ShinyTorusNormals.png";
    NSString *diffuseImage = @"Images/ShinyTorusColor.png";
    
    CCLightNode* (^setupBlock)(CGPoint position, float depth, float radius) = ^CCLightNode *(CGPoint position, float depth, float radius)
    {
        CCLightNode *light = [[CCLightNode alloc] init];
        light.type = CCLightPoint;
        light.positionType = CCPositionTypeNormalized;
        light.position = position;
        light.anchorPoint = ccp(0.5f, 0.5f);
        light.intensity = 0.2f;
        light.ambientIntensity = 0.0f;
        light.cutoffRadius = radius;
        light.depth = depth;
        
        CCSprite *lightSprite = [CCSprite spriteWithImageNamed:@"Images/snow.png"];
        
        [light addChild:lightSprite];
        
        return light;
    };
    
    static const float nearRadius = 0.0f;
    static const float farRadius = 10.0f;
    
    // Bottom row
    [self.contentNode addChild:setupBlock(ccp(0.25f,  0.25f), 50.0f, nearRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.375f, 0.25f), 50.0f, farRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.5f,   0.25f), 50.0f, nearRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.625f, 0.25f), 50.0f, farRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.75f,  0.25f), 50.0f, nearRadius)];
    
    // Middle row
    [self.contentNode addChild:setupBlock(ccp(0.25f, 0.5f), 50.0f, nearRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.75f, 0.5f), 50.0f, nearRadius)];
    
    // Top row
    [self.contentNode addChild:setupBlock(ccp(0.25f,  0.75f), 50.0f, nearRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.375f, 0.75f), 50.0f, farRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.5f,   0.75f), 50.0f, nearRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.625f, 0.75f), 50.0f, farRadius)];
    [self.contentNode addChild:setupBlock(ccp(0.75f,  0.75f), 50.0f, nearRadius)];
    
    
    CCEffectLighting *lightingEffect = [[CCEffectLighting alloc] init];
    lightingEffect.shininess = 1.0f;
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:diffuseImage];
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5f, 0.5f);
    sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:normalMapImage];
    sprite.effect = lightingEffect;
    sprite.scale = 0.3f;
    
    [self.contentNode addChild:sprite];
}

-(void)setupLightingPerformanceTest
{
    self.subTitle = @"Lighting Performance Test";
    
    [self.contentNode.scene.lights flushGroupNames];
    
    NSString *normalMapImage = @"Images/ShinyTorusNormals.png";
    NSString *diffuseImage = @"Images/ShinyTorusColor.png";
    
    CCSprite* (^setupSpriteBlock)(CGPoint position) = ^CCSprite*(CGPoint position)
    {
        CCEffectLighting *lightingEffect = [[CCEffectLighting alloc] init];
        lightingEffect.shininess = 1.0f;
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:diffuseImage];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = position;
        sprite.anchorPoint = ccp(0.0f, 0.0f);
        sprite.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:normalMapImage];
        sprite.effect = lightingEffect;
        sprite.scale = 0.1f;
        
        return sprite;
    };
    
    int xCount = 2;
    int yCount = 2;
    for (int y = 0; y < yCount; y++)
    {
        for (int x = 0; x < xCount; x++)
        {
            CCSprite *sprite = setupSpriteBlock(ccp((float)x/(float)xCount, (float)y/(float)yCount));
            [self.contentNode addChild:sprite];
        }
    }
    
    NSLog(@"setupPerformanceTest: Laid out %d sprites.", xCount * yCount);

    
    CCNode* (^setupLightBlock)(CGPoint position, float radius, float speed, CCColor *specularColor) = ^CCNode *(CGPoint position, float radius, float speed, CCColor *specularColor)
    {
        CCLightNode *light = [[CCLightNode alloc] init];
        light.type = CCLightPoint;
        light.positionType = CCPositionTypePoints;
        light.position = ccp(radius, 0.0f);
        light.anchorPoint = ccp(0.5f, 0.5f);
        light.intensity = 0.2f;
        light.color = [CCColor whiteColor];
        light.ambientIntensity = 0.0f;
        light.ambientColor = [CCColor whiteColor];
        light.specularIntensity = 1.0f;
        light.specularColor = specularColor;
        light.cutoffRadius = 0.0f;
        light.depth = 50.0;
        
        CCNode *parent = [[CCNode alloc] init];
        parent.positionType = CCPositionTypeNormalized;
        parent.position = position;
        [parent addChild:light];
        
        [parent runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:speed angle:90.0]]];
        
        return parent;
    };
    
    CCColor *colors[] = {
        [CCColor whiteColor],
        [CCColor redColor],
        [CCColor greenColor],
        [CCColor yellowColor]
    };
    
    for (int i = 0; i < 8; i++)
    {
        int c = arc4random_uniform(4);
        
        float x = arc4random_uniform(1000) / 1000.0f;
        float y = arc4random_uniform(1000) / 1000.0f;
        
        float r = arc4random_uniform(1000) / 10.0f + 50.0f;
        float d = 2.0f * r * M_PI;
        float v = arc4random_uniform(1000) / 2.0f + 100.0f;
        float t = d / v;
        
        [self.contentNode addChild:setupLightBlock(ccp(x,y), r, t, colors[c])];
    }
}

-(void)setupInvertTest
{
    self.subTitle = @"Invert Test";
    
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
    sprite.position = ccp((CGFloat) (winSize.width / 2.0 + 80.0), (CGFloat) (winSize.height / 2.0));
    [self.contentNode addChild:sprite];
    
    CCSprite *sprite2 = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
    sprite2.position = ccp((CGFloat) (winSize.width / 2.0 + 140.0), (CGFloat) (winSize.height / 2.0));
    [self.contentNode addChild:sprite2];
    sprite2.effect = [[CCEffectInvert alloc] init];
    
    CCSprite *sprite3 = [CCSprite spriteWithImageNamed:@"Images/palette.png"];
    sprite3.position = ccp((CGFloat) (winSize.width / 2.0 - 40.0), (CGFloat) (winSize.height / 2.0));
    [self.contentNode addChild:sprite3];
    
    CCSprite *sprite4 = [CCSprite spriteWithImageNamed:@"Images/palette.png"];
    sprite4.position = ccp((CGFloat) (winSize.width / 2.0 - 150.0), (CGFloat) (winSize.height / 2.0));
    [self.contentNode addChild:sprite4];
    sprite4.effect = [[CCEffectInvert alloc] init];    
}

-(void)setupPaddingEffectTest
{
    self.subTitle = @"Effect Padding Test";

    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.75f, 0.8f);
        
        [self.contentNode addChild:sprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Original Sprite" fontName:@"HelveticaNeue-Light" fontSize:14 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor whiteColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(0.25f, 0.8f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    }
    
    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.75f, 0.65f);
        
        CCEffectColorChannelOffset *offset = [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:CGPointMake(5.0f, 0.0f) greenOffsetWithPoint:CGPointMake(-4.0f, 4.0f) blueOffsetWithPoint:CGPointMake(-4.0f, -4.0f)];
        sprite.effect = offset;
        
        [self.contentNode addChild:sprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Color channel offset without padding" fontName:@"HelveticaNeue-Light" fontSize:14 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor whiteColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(0.25f, 0.65f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    }
    
    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.75f, 0.5f);
        
        CCEffectColorChannelOffset *offset = [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:CGPointMake(5.0f, 0.0f) greenOffsetWithPoint:CGPointMake(-4.0f, 4.0f) blueOffsetWithPoint:CGPointMake(-4.0f, -4.0f)];
        offset.padding = CGSizeMake(5.0f, 5.0f);
        sprite.effect = offset;
        
        [self.contentNode addChild:sprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Color channel offset with padding" fontName:@"HelveticaNeue-Light" fontSize:14 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor whiteColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(0.25f, 0.5f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    }

    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.75f, 0.35f);
        
        CCEffectColorChannelOffset *offset = [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:CGPointMake(5.0f, 0.0f) greenOffsetWithPoint:CGPointMake(-4.0f, 4.0f) blueOffsetWithPoint:CGPointMake(-4.0f, -4.0f)];
        offset.padding = CGSizeMake(5.0f, 5.0f);
        CCEffectHue *hue = [CCEffectHue effectWithHue:60.0f];
        sprite.effect = [CCEffectStack effectWithArray:@[offset, hue]];
        
        [self.contentNode addChild:sprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Padded effect stack (offset then hue)" fontName:@"HelveticaNeue-Light" fontSize:14 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor whiteColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(0.25f, 0.35f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    }
    
    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.75f, 0.2f);
        
        CCEffectColorChannelOffset *offset = [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:CGPointMake(5.0f, 0.0f) greenOffsetWithPoint:CGPointMake(-4.0f, 4.0f) blueOffsetWithPoint:CGPointMake(-4.0f, -4.0f)];
        offset.padding = CGSizeMake(5.0f, 5.0f);
        CCEffectHue *hue = [CCEffectHue effectWithHue:60.0f];
        sprite.effect = [CCEffectStack effectWithArray:@[hue, offset]];
        
        [self.contentNode addChild:sprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Padded efect stack (hue then offset)" fontName:@"HelveticaNeue-Light" fontSize:14 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor whiteColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(0.25f, 0.2f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    }
}

-(void)setupColorChannelOffsetTest
{
    self.subTitle = @"Color Channel Offset Effect Test";
    
    CCEffectColorChannelOffset *effect = [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:CGPointMake(0.0f, 0.0f) greenOffsetWithPoint:CGPointMake(0.0f, 0.0f) blueOffsetWithPoint:CGPointMake(0.0f, 0.0f)];
    effect.padding = CGSizeMake(5.0f, 5.0f);
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/particles.png"];
    sprite.scale = 1.0f;
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5f, 0.5f);
    sprite.effect = effect;
    
    [self.contentNode addChild:sprite];
    
    const float thetaStep = CC_DEGREES_TO_RADIANS(10.0f);
    __block float redTheta = CC_DEGREES_TO_RADIANS(0.0f);
    __block float greenTheta = CC_DEGREES_TO_RADIANS(120.0f);
    __block float blueTheta = CC_DEGREES_TO_RADIANS(240.0f);
    void (^updateBlock)() = ^{
        
        float redRadius = 3.0f;
        effect.redOffsetWithPoint = CGPointMake(redRadius * cosf(redTheta), redRadius * sinf(redTheta));
        
        float greenRadius = 3.0f;
        effect.greenOffsetWithPoint = CGPointMake(greenRadius * cosf(greenTheta), greenRadius * sinf(greenTheta));
        
        float blueRadius = 3.0f;
        effect.blueOffsetWithPoint = CGPointMake(blueRadius * cosf(blueTheta), blueRadius * sinf(blueTheta));
        
        redTheta += thetaStep;
        greenTheta += thetaStep;
        blueTheta += thetaStep;
    };
    updateBlock();
    
    [sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                               [CCActionDelay actionWithDuration:0.1f],
                                                               [CCActionCallBlock actionWithBlock:updateBlock],
                                                               nil
                                                               ]]];
}

#pragma mark DropShadow

-(void)setupDropShadowEffectTest
{
    self.subTitle = @"DropShadow Effect Test";

    CCSprite *environment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    environment.positionType = CCPositionTypeNormalized;
    environment.position = ccp(0.5f, 0.5f);

    [self.contentNode addChild:environment];
    
    CCColor *shadowColor = [CCColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    CCEffectDropShadow* effect = [CCEffectDropShadow effectWithShadowOffset:GLKVector2Make(2.0, -2.0) shadowColor:shadowColor blurRadius:5];
   
    CCSprite *sampleSprite = [CCSprite spriteWithImageNamed:@"Images/Ohm.png"];
    sampleSprite.position = ccp(0.5, 0.5);
    sampleSprite.positionType = CCPositionTypeNormalized;
    
    CCEffectNode* effectNode = [[CCEffectNode alloc] init];
    effectNode.contentSize = CGSizeMake(300, 300);
    effectNode.anchorPoint = ccp(0.5, 0.5);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.5, 0.5);
    [effectNode addChild:sampleSprite];
    effectNode.effect = effect;
    
    [self.contentNode addChild:effectNode];
}

#pragma mark Glass

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
    CCEffectBlur* effect = [CCEffectBlur effectWithBlurRadius:4.0];
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
    CCEffectBlur* effect2 = [CCEffectBlur effectWithBlurRadius:10.0];
    effectNode2.effect = effect2;
    
    [self.contentNode addChild:effectNode2];
    
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
    
    CCSprite *sampleSprite4 = [CCSprite spriteWithImageNamed:@"Images/sample_hollow_circle.png"];
    sampleSprite4.position = ccp(0.5, 0.5);
    sampleSprite4.positionType = CCPositionTypeNormalized;
    
    CCEffectNode* effectNode4 = [[CCEffectNode alloc] initWithWidth:80 height:80];
    effectNode4.positionType = CCPositionTypeNormalized;
    effectNode4.position = ccp(0.6, 0.5);
    [effectNode4 addChild:sampleSprite4];
    CCEffectBlur* effect4 = [CCEffectBlur effectWithBlurRadius:12.0];
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
    CCEffectBloom* glowEffect = [CCEffectBloom effectWithBlurRadius:8 intensity:0.5f luminanceThreshold:0.0f];
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
        CCSprite *sampleSprite3 = [CCSprite spriteWithImageNamed:@"Images/f1.png"];
        sampleSprite3.anchorPoint = ccp(0.5, 0.5);
        sampleSprite3.position = ccp(0.1f + i * (0.8f / (steps - 1)), 0.4f);
        sampleSprite3.positionType = CCPositionTypeNormalized;
        
        // Blend glow maps test
        CCEffectHue *hueEffect = [CCEffectHue effectWithHue:60.0f];
        CCEffectBloom* glowEffect3 = [CCEffectBloom effectWithBlurRadius:10 intensity:0.5f luminanceThreshold:1.0f - ((float)i/(float)(steps-1))];
        glowEffect3.padding = CGSizeMake(10.0f, 10.0f);
        
        sampleSprite3.effect = [CCEffectStack effectWithArray:@[glowEffect3, hueEffect]];

        [self.contentNode addChild:sampleSprite3];
    }
    
    for (int i = 0; i < steps; i++)
    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/f1.png"];
        sprite.anchorPoint = ccp(0.5, 0.5);
        sprite.position = ccp(0.1f + i * (0.8f / (steps - 1)), 0.2f);
        sprite.positionType = CCPositionTypeNormalized;
        
        // Blend glow maps test
        CCEffectBloom* bloomEffect = [CCEffectBloom effectWithBlurRadius:10 intensity:((float)i/(float)(steps-1)) luminanceThreshold:0.0f];
        bloomEffect.padding = CGSizeMake(10.0f, 10.0f);
        sprite.effect = bloomEffect;
        
        [self.contentNode addChild:sprite];
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
                         [CCEffectSaturation effectWithSaturation:1.0f],
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

    CCEffectStack *stack1 = [CCEffectStack effects:effects[7], effects[6], nil];
    CCEffectStack *stack2 = [CCEffectStack effects:effects[5], effects[4], nil];
    sprite.effect = [CCEffectStack effects:stack1, stack2, nil];
    
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
    
    const float footprintScale = 0.5f;
    
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

-(void)setupSpriteColorTest
{
    self.subTitle = @"Sprite Color + Effects Test\nColors in the bottom row should look like the top";

    // Make a solid gray background (there's got to be a better way to do this).
    CCEffectNode* background = [[CCEffectNode alloc] init];
    background.clearFlags = GL_COLOR_BUFFER_BIT;
    background.clearColor = [CCColor grayColor];
    background.contentSizeType = CCSizeTypeNormalized;
    background.contentSize = CGSizeMake(1.0f, 1.0f);
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    
    [self.contentNode addChild:background];

    // Add row titles
    CCLabelTTF *plainTitle = [CCLabelTTF labelWithString:@"No FX" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
    plainTitle.color = [CCColor blackColor];
    plainTitle.positionType = CCPositionTypeNormalized;
    plainTitle.position = ccp(0.05f, 0.7f);
    plainTitle.horizontalAlignment = CCTextAlignmentRight;
    
    [self.contentNode addChild:plainTitle];
    
    
    CCLabelTTF *effectTitle = [CCLabelTTF labelWithString:@"FX" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
    effectTitle.color = [CCColor blackColor];
    effectTitle.positionType = CCPositionTypeNormalized;
    effectTitle.position = ccp(0.05f, 0.3f);
    effectTitle.horizontalAlignment = CCTextAlignmentRight;
    
    [self.contentNode addChild:effectTitle];

    float x = 0.15f;
    float step = 0.1875f;
    
    // Sprite with solid red
    {
        CCEffect *saturation = [CCEffectSaturation effectWithSaturation:0.0f];

        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, 0.7f);
        plainSprite.color = [CCColor redColor];
        [self.contentNode addChild:plainSprite];

        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x, 0.3f);
        effectSprite.color = [CCColor redColor];
        effectSprite.effect = saturation;
        [self.contentNode addChild:effectSprite];

        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Is color preserved?" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x, 0.05f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
    
        x += step;
    }

    
    // Sprite with opacity = 0.5
    {
        CCEffect *saturation = [CCEffectSaturation effectWithSaturation:0.0f];

        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, 0.7f);
        plainSprite.opacity = 0.5f;
        [self.contentNode addChild:plainSprite];
        
        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x, 0.3f);
        effectSprite.opacity = 0.5f;
        effectSprite.effect = saturation;
        [self.contentNode addChild:effectSprite];

        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Opacity?" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x, 0.05f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
        
        x += step;
    }


    // Sprite with 50% transparent red
    {
        CCEffect *saturation = [CCEffectSaturation effectWithSaturation:0.0f];
        CCEffect *hue = [CCEffectHue effectWithHue:0.0f];

        CCEffectStack *stack = [CCEffectStack effectWithArray:@[saturation, hue]];
        
        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, 0.7f);
        plainSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self.contentNode addChild:plainSprite];
        
        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x, 0.3f);
        effectSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectSprite.effect = stack;
        [self.contentNode addChild:effectSprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Stack (all stitching)" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x, 0.05f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
        
        x += step;
    }
    
    
    // Sprite with 50% transparent red and three stacked effects, the third of which
    // does not support being stitched to the effect before it. This tests that the
    // sprite color and texture are multiplied together at the begining of the stack
    // but not also by the input snippet to the third effect.
    {
        CCEffect *saturation = [CCEffectSaturation effectWithSaturation:0.0f];
        CCEffect *brightness = [CCEffectBrightness effectWithBrightness:0.0f];
        CCEffect *pixellate = [CCEffectPixellate effectWithBlockSize:1.0f];
        
        CCEffectStack *stack = [CCEffectStack effectWithArray:@[saturation, brightness, pixellate]];
        
        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, 0.7f);
        plainSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self.contentNode addChild:plainSprite];
        
        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x, 0.3f);
        effectSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectSprite.effect = stack;
        [self.contentNode addChild:effectSprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Stack (some stitching)" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x, 0.05f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
        
        x += step;
    }

    
    // Sprite with 50% transparent red and two stacked effects but no stitching
    {
        CCEffect *saturation = [CCEffectSaturation effectWithSaturation:0.0f];
        CCEffect *hue = [CCEffectHue effectWithHue:0.0f];
        
        CCEffectStack *stack = [CCEffectStack effectWithArray:@[saturation, hue]];
        stack.stitchingEnabled = NO;
        
        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, 0.7f);
        plainSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self.contentNode addChild:plainSprite];
        
        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x, 0.3f);
        effectSprite.color = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectSprite.effect = stack;
        [self.contentNode addChild:effectSprite];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Stack (no stitching)" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x, 0.05f);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];
        
        x += step;
    }
}

-(void)setupMoreSpriteColorTest
{
    self.subTitle = @"Sprite Color + Effects Test 2\nThe colors of all sprite pairs should look the same.";
    
    CCSprite *reflectEnvironment = [CCSprite spriteWithImageNamed:@"Images/MountainPanorama.jpg"];
    reflectEnvironment.positionType = CCPositionTypeNormalized;
    reflectEnvironment.position = ccp(0.5f, 0.5f);
    reflectEnvironment.visible = NO;
    [self.contentNode addChild:reflectEnvironment];
    
    CCSprite *refractEnvironment = [CCSprite spriteWithImageNamed:@"Images/StoneWall.jpg"];
    refractEnvironment.positionType = CCPositionTypeNormalized;
    refractEnvironment.position = ccp(0.5f, 0.5f);
    refractEnvironment.visible = NO;
    [self.contentNode addChild:refractEnvironment];
    
    CCLightNode *lightNode = [CCLightNode lightWithType:CCLightPoint groups:@[] color:[CCColor whiteColor] intensity:1.0f];
    [self.contentNode addChild:lightNode];
    
    CCSpriteFrame *normalMapFrame = [CCSpriteFrame frameWithTextureFilename:@"Images/fire.png" rectInPixels:CGRectMake(0.0f, 0.0f, 4.0f, 4.0f) rotated:NO offset:CGPointZero originalSize:CGSizeMake(32.0f, 32.0f)];
    
    GLKVector2 zeroVec = GLKVector2Make(0.0f, 0.0f);
    CGPoint zeroPoint = CGPointMake(0.0f, 0.0f);
    
    NSArray *effects = @[
                         [CCEffectBloom effectWithBlurRadius:1 intensity:0.0f luminanceThreshold:0.0f],
                         [CCEffectBlur effectWithBlurRadius:1.0],
                         [CCEffectBrightness effectWithBrightness:0.0f],
                         [CCEffectColorChannelOffset effectWithRedOffsetWithPoint:zeroPoint greenOffsetWithPoint:zeroPoint blueOffsetWithPoint:zeroPoint],
                         [CCEffectContrast effectWithContrast:0.0f],
                         [CCEffectDropShadow effectWithShadowOffset:zeroVec shadowColor:[CCColor clearColor] blurRadius:1.0f],
                         [CCEffectGlass effectWithShininess:1.0f refraction:0.75f refractionEnvironment:refractEnvironment reflectionEnvironment:reflectEnvironment],
                         [CCEffectHue effectWithHue:0.0f],
                         [CCEffectStack effectWithArray:@[[[CCEffectInvert alloc] init], [[CCEffectInvert alloc] init]]],
                         [CCEffectLighting effectWithGroups:@[] specularColor:[CCColor whiteColor] shininess:0.0f],
                         [CCEffectPixellate effectWithBlockSize:1.0f],
                         [CCEffectReflection effectWithShininess:1.0f fresnelBias:0.1f fresnelPower:2.0f environment:reflectEnvironment],
                         [CCEffectRefraction effectWithRefraction:0.75f environment:refractEnvironment],
                         [CCEffectSaturation effectWithSaturation:0.0f],
#if CC_EFFECTS_EXPERIMENTAL
                         [CCEffectOutline effectWithOutlineColor:[CCColor clearColor] outlineWidth:0.0f]
#endif
                         ];
    
    NSMutableArray *effects2 = [NSMutableArray arrayWithArray:effects];
    for (CCEffect *effect in effects)
    {
        [effects2 addObject:[CCEffectStack effectWithArray:@[[CCEffectHue effectWithHue:0.0f], effect]]];
    }
    
    // Make a solid gray background (there's got to be a better way to do this).
    CCEffectNode* background = [[CCEffectNode alloc] init];
    background.clearFlags = GL_COLOR_BUFFER_BIT;
    background.clearColor = [CCColor grayColor];
    background.contentSizeType = CCSizeTypeNormalized;
    background.contentSize = CGSizeMake(1.0f, 1.0f);
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    
    [self.contentNode addChild:background];

    float bigFontSize = 15.0f;
    float smallFontSize = 10.0f;
    
    CCLabelTTF *title = nil;
    title = [CCLabelTTF labelWithString:@"Stacked Effects" fontName:@"HelveticaNeue-Light" fontSize:bigFontSize * [CCDirector sharedDirector].UIScaleFactor];
    title.color = [CCColor blackColor];
    title.positionType = CCPositionTypeNormalized;
    title.position = ccp(0.5f, 0.85f);
    title.horizontalAlignment = CCTextAlignmentCenter;
    
    [self.contentNode addChild:title];

    title = [CCLabelTTF labelWithString:@"Solo Effects" fontName:@"HelveticaNeue-Light" fontSize:bigFontSize * [CCDirector sharedDirector].UIScaleFactor];
    title.color = [CCColor blackColor];
    title.positionType = CCPositionTypeNormalized;
    title.position = ccp(0.5f, 0.45f);
    title.horizontalAlignment = CCTextAlignmentCenter;
    
    [self.contentNode addChild:title];

    
    float xStart = 0.075f;
    float x = xStart;
    float xStep1 = 0.05f;
    float xStep2 = 0.2f;

    float y = 0.15f;
    float yStep = 0.11f;

    NSString *imageName = @"Images/stars-grayscale.png";
    
    // Sprite with solid red
    int effectCount = 0;
    for (CCEffect *effect in effects2)
    {
        CCSprite *plainSprite = [CCSprite spriteWithImageNamed:imageName];
        plainSprite.positionType = CCPositionTypeNormalized;
        plainSprite.position = ccp(x, y);
        plainSprite.color = [CCColor redColor];
        [self.contentNode addChild:plainSprite];
        
        CCSprite *effectSprite = [CCSprite spriteWithImageNamed:imageName];
        effectSprite.positionType = CCPositionTypeNormalized;
        effectSprite.position = ccp(x + xStep1, y);
        effectSprite.color = [CCColor redColor];
        effectSprite.effect = effect;
        effectSprite.normalMapSpriteFrame = normalMapFrame;
        [self.contentNode addChild:effectSprite];

        NSString *effectName = NSStringFromClass([effect class]);
        if ([effect isKindOfClass:[CCEffectStack class]])
        {
            CCEffectStack *stack = (CCEffectStack *)effect;
            CCEffect *effect = [stack effectAtIndex:1];
            effectName = NSStringFromClass([effect class]);
        }
        
        title = [CCLabelTTF labelWithString:effectName fontName:@"HelveticaNeue-Light" fontSize:smallFontSize * [CCDirector sharedDirector].UIScaleFactor];
        title.color = [CCColor blackColor];
        title.positionType = CCPositionTypeNormalized;
        title.position = ccp(x + 0.5f * xStep1, y - 0.35f * yStep);
        title.horizontalAlignment = CCTextAlignmentCenter;
        
        [self.contentNode addChild:title];

        x += xStep2;
        if (x > 1.0f)
        {
            x = xStart;
            y += yStep;
        }

        effectCount++;
        if (effectCount == effects.count)
        {
            x = xStart;
            y = 0.55f;
        }
    }
}

-(void)setupClipWithEffectsTest
{
    self.subTitle = @"Clipping + Effects Test.";
	
	CGSize size = [CCDirector sharedDirector].designSize;
    
    CCNodeGradient *grad = [CCNodeGradient nodeWithColor:[CCColor redColor] fadingTo:[CCColor blueColor] alongVector:ccp(1, 0)];
    
	CCNode *stencil = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
	stencil.position = ccp(size.width/2, size.height/2);
	stencil.scale = 4.0;
	[stencil runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1.0 angle:90.0]]];
	
	CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
	clip.alphaThreshold = 0.5;
    
    CCEffectNode* parent = [CCEffectNode effectNodeWithWidth:size.width height:size.height pixelFormat:CCTexturePixelFormat_RGBA8888 depthStencilFormat:GL_DEPTH24_STENCIL8];
	parent.clearFlags = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT;
	parent.clearColor = [CCColor blackColor];
	parent.clearDepth = 1.0;
	parent.clearStencil = 0;
    parent.contentSizeType = CCSizeTypeNormalized;
    parent.contentSize = CGSizeMake(1.0f, 1.0f);
    parent.anchorPoint = ccp(0.5f, 0.5f);
    parent.positionType = CCPositionTypeNormalized;
    parent.position = ccp(0.5f, 0.5f);
    
    CCEffectPixellate *effect = [CCEffectStack effectWithArray:@[[CCEffectPixellate effectWithBlockSize:4.0f], [CCEffectSaturation effectWithSaturation:1.0f]]];
    parent.effect = effect;
    
    [clip addChild:grad];
    [parent addChild:clip];
    [self.contentNode addChild:parent];
}

-(void)setupEffectNodeAnchorTest
{
    self.subTitle = @"Effect Node Anchor Point Test\nTransparent RGB quads from lower-left to upper-right.";
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:background];

    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSize = CGSizeMake(80, 80);
        effectNode.anchorPoint = ccp(1.0, 1.0);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5, 0.5);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:0.0f];
        effectNode.effect = effect;

        [self.contentNode addChild:effectNode];
    }
    
    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSize = CGSizeMake(80, 80);
        effectNode.anchorPoint = ccp(0.5, 0.5);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5, 0.5);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:120.0f];
        effectNode.effect = effect;

        [self.contentNode addChild:effectNode];
    }

    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSize = CGSizeMake(80, 80);
        effectNode.anchorPoint = ccp(0.0, 0.0);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5, 0.5);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:-120.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
    }
}

-(void)setupEffectNodeSizeTypeTest
{
    self.subTitle = @"Effect Node Size Type Test\nSmall red and big blue transparent quads centered on screen.\nRed bar on left. Green bar on bottom.";
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:background];
    
    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSizeType = CCSizeTypeNormalized;
        effectNode.contentSize = CGSizeMake(0.5f, 0.5f);
        effectNode.anchorPoint = ccp(0.5f, 0.5f);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5f, 0.5f);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:-120.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
    }

    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSizeType = CCSizeTypePoints;
        effectNode.contentSize = CGSizeMake(80.0f, 80.0f);
        effectNode.anchorPoint = ccp(0.5f, 0.5f);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5f, 0.5f);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:0.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
    }
    
    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
        effectNode.contentSizeType = CCSizeTypeMake(CCSizeUnitPoints, CCSizeUnitNormalized);
        effectNode.contentSize = CGSizeMake(20.0f, 0.9f);
        effectNode.anchorPoint = ccp(0.0f, 0.0f);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.05f, 0.05f);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:0.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
    }

    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
        effectNode.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
        effectNode.contentSize = CGSizeMake(0.9f, 20.0f);
        effectNode.anchorPoint = ccp(0.0f, 0.0f);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.05f, 0.05f);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:120.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
    }
}

-(void)setupEffectNodeResizeTest
{
    NSArray *subTitles = @[
                           @"Effect Node Resize Test\nSmall transparent blue node with grossini",
                           @"Effect Node Resize Test\nMedium transparent blue node with grossini",
                           @"Effect Node Resize Test\nBig transparent blue node with grossini",
                           @"Effect Node Resize Test\nNothing",
                           @"Effect Node Resize Test\nTransparent blue square with grossini"
                           ];
    
    self.subTitle = subTitles[0];
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:background];
    
    CCEffectNode* effectNode = [[CCEffectNode alloc] init];
    effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
    effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    effectNode.contentSizeType = CCSizeTypeNormalized;
    effectNode.contentSize = CGSizeMake(0.25f, 0.25f);
    effectNode.anchorPoint = ccp(0.5f, 0.5f);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.5f, 0.5f);
    
    CCEffectHue *effect = [CCEffectHue effectWithHue:-120.0f];
    effectNode.effect = effect;
    
    [self.contentNode addChild:effectNode];
    
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5f, 0.5f);
    [effectNode addChild:sprite];
    
    
    __weak CCEffectsTest *weakSelf = self;
    __block NSUInteger callCount = 0;
    CCActionCallBlock *blockAction = [CCActionCallBlock actionWithBlock:^{
        callCount = (callCount + 1) % 5;
        
        if (callCount == 0)
        {
            effectNode.contentSizeType = CCSizeTypeNormalized;
        }
        
        if (callCount == 3)
        {
            effectNode.contentSizeType = CCSizeTypePoints;
        }
        else if (callCount == 4)
        {
            effectNode.contentSize = CGSizeMake(256.0f, 256.0f);
        }
        else
        {
            float nodeSize = 0.25f + 0.25f * callCount;
            effectNode.contentSize = CGSizeMake(nodeSize, nodeSize);
        }
        
        weakSelf.subTitle = subTitles[callCount];
    }];
    [effectNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                   [CCActionDelay actionWithDuration:1.0f],
                                                                   blockAction,
                                                                   nil
                                                                   ]]];
}

-(void)setupEffectNodeParentResizeTest
{
    NSArray *subTitles = @[
                           @"Effect Node Parent Resize Test\nSmall transparent red rect with grossini",
                           @"Effect Node Parent Resize Test\nMedium transparent red rect with grossini",
                           @"Effect Node Parent Resize Test\nBig transparent red rect with grossini",
                           @"Effect Node Parent Resize Test\nNothing",
                           @"Effect Node Parent Resize Test\nTransparent red square with grossini"
                           ];
    
    self.subTitle = subTitles[0];
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:background];

    
    CCNode *grandparent = [[CCNode alloc] init];
    grandparent.contentSizeType = CCSizeTypeNormalized;
    grandparent.contentSize = CGSizeMake(0.25f, 0.25f);
    grandparent.anchorPoint = ccp(0.5f, 0.5f);
    grandparent.positionType = CCPositionTypeNormalized;
    grandparent.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:grandparent];
    
    
    CCNode *parent = [[CCNode alloc] init];
    parent.contentSizeType = CCSizeTypeNormalized;
    parent.contentSize = CGSizeMake(1.0f, 1.0f);
    parent.anchorPoint = ccp(0.5f, 0.5f);
    parent.positionType = CCPositionTypeNormalized;
    parent.position = ccp(0.5f, 0.5f);
    [grandparent addChild:parent];
    
    
    CCEffectNode *effectNode = [[CCEffectNode alloc] init];
    effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
    effectNode.clearColor = [CCColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
    effectNode.contentSizeType = CCSizeTypeNormalized;
    effectNode.contentSize = CGSizeMake(1.0f, 1.0f);
    effectNode.anchorPoint = ccp(0.5f, 0.5f);
    effectNode.positionType = CCPositionTypeNormalized;
    effectNode.position = ccp(0.5f, 0.5f);
    
    CCEffectHue *effect = [CCEffectHue effectWithHue:120.0f];
    effectNode.effect = effect;
    
    [parent addChild:effectNode];
    
    
    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
    sprite.anchorPoint = ccp(0.5, 0.5);
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5f, 0.5f);
    [effectNode addChild:sprite];
    
    
    __weak CCEffectsTest *weakSelf = self;
    __block NSUInteger callCount = 0;
    CCActionCallBlock *blockAction = [CCActionCallBlock actionWithBlock:^{
        callCount = (callCount + 1) % 5;
        
        if (callCount == 0)
        {
            grandparent.contentSizeType = CCSizeTypeNormalized;
        }
        
        if (callCount == 3)
        {
            grandparent.contentSizeType = CCSizeTypePoints;
        }
        else if (callCount == 4)
        {
            grandparent.contentSize = CGSizeMake(256.0f, 256.0f);
        }
        else
        {
            float grandparentSize = 0.25f + 0.25f * callCount;
            grandparent.contentSize = CGSizeMake(grandparentSize, grandparentSize);
        }
        
        weakSelf.subTitle = subTitles[callCount];
    }];
    [effectNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                   [CCActionDelay actionWithDuration:1.0f],
                                                                   blockAction,
                                                                   nil
                                                                   ]]];
}

-(void)setupEffectNodeChildPositioningTest
{
    self.subTitle = @"Effect Node Child Positioning Test\nBig transparent purple quad and small opaque green quad (both with grossini).\n";
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self.contentNode addChild:background];
    
    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        effectNode.contentSizeType = CCSizeTypeNormalized;
        effectNode.contentSize = CGSizeMake(0.75, 0.75);
        effectNode.anchorPoint = ccp(0.5, 0.5);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.5, 0.5);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:-60.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        sprite.anchorPoint = ccp(0.5, 0.5);
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.25f, 0.5f);
        [effectNode addChild:sprite];
    }

    {
        CCEffectNode* effectNode = [[CCEffectNode alloc] init];
        effectNode.clearFlags = GL_COLOR_BUFFER_BIT;
        effectNode.clearColor = [CCColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
        effectNode.contentSizeType = CCSizeTypeMake(CCSizeUnitPoints, CCSizeUnitNormalized);
        effectNode.contentSize = CGSizeMake(128, 0.5);
        effectNode.anchorPoint = ccp(0.5, 0.5);
        effectNode.positionType = CCPositionTypeNormalized;
        effectNode.position = ccp(0.75, 0.5);
        
        CCEffectHue *effect = [CCEffectHue effectWithHue:120.0f];
        effectNode.effect = effect;
        
        [self.contentNode addChild:effectNode];
        
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Images/grossini.png"];
        sprite.anchorPoint = ccp(0.5, 0.5);
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(0.5f, 0.5f);
        [effectNode addChild:sprite];
    }
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
