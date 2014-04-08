#import "TestBase.h"
#import "CCTextureCache.h"

@interface CCRendererTest : TestBase @end
@implementation CCRendererTest

-(void)setupClippingNodeTest
{
	CGSize size = [CCDirector sharedDirector].designSize;
	
	CCNode *parent = self.contentNode;
	
//	CCRenderTexture *parent = [CCRenderTexture renderTextureWithWidth:size.width height:size.height pixelFormat:CCTexturePixelFormat_RGBA8888 depthStencilFormat:GL_DEPTH24_STENCIL8_OES];
//	parent.positionType = CCPositionTypeNormalized;
//	parent.position = ccp(0.5, 0.5);
//	parent.autoDraw = YES;
//	parent.clearColor = [CCColor blackColor];
//	parent.clearDepth = 1.0;
//	parent.clearStencil = 0;
//	parent.clearFlags = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT;
//	[self.contentNode addChild:parent];
	
	CCNodeGradient *grad = [CCNodeGradient nodeWithColor:[CCColor redColor] fadingTo:[CCColor blueColor] alongVector:ccp(1, 1)];
//	[parent addChild:grad];
	
	CCNode *stencil = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
//	[parent addChild:stencil];
	stencil.position = ccp(size.width/2, size.height/2);
	stencil.scale = 5.0;
	[stencil runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1.0 angle:90.0]]];
	
	CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
	[parent addChild:clip];
	clip.alphaThreshold = 0.5;
	[clip addChild:grad];
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

-(void)setupRenderTextureTest
{
	self.subTitle = @"Testing CCRenderTexture.";
	
	CGSize size = CGSizeMake(128, 128);
	
	CCNode *stage = [CCNode node];
	stage.contentSize = size;
	stage.anchorPoint = ccp(0.5, 0.5);
	stage.positionType = CCPositionTypeNormalized;
	stage.position = ccp(0.25, 0.5);
	[self.contentNode addChild:stage];
	
	[self renderTextureHelper:stage size:size];
	
	CCRenderTexture *renderTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height pixelFormat:CCTexturePixelFormat_RGBA8888];
	renderTexture.positionType = CCPositionTypeNormalized;
	renderTexture.position = ccp(0.75, 0.5);
	[self.contentNode addChild:renderTexture];
	
	[self renderTextureHelper:renderTexture size:size];
	renderTexture.autoDraw = YES;
}

- (void)setupMotionStreakNodeTest
{
	self.subTitle = @"Testing CCMotionStreak";
	
	CCNode *stage = [CCNode node];
	stage.anchorPoint = ccp(0.5, 0.5);
	stage.positionType = CCPositionTypeNormalized;
	stage.position = ccp(0.5, 0.5);
	stage.contentSizeType = CCSizeTypeNormalized;
	stage.contentSize = CGSizeMake(0.75, 0.75);
	[self.contentNode addChild:stage];
	
	// Maybe want to find a better texture than a random tile graphic?
	{
		CCMotionStreak *streak = [CCMotionStreak streakWithFade:15.0 minSeg:5 width:3 color:[CCColor whiteColor] textureFilename:@"Tiles/05.png"];
		[stage addChild:streak];
		
		[streak scheduleBlock:^(CCTimer *timer) {
			CCTime t = timer.invokeTime;
			CGSize size = stage.contentSizeInPoints;
			
			streak.position = ccp(size.width*(0.5 + 0.5*sin(3.1*t)), size.height*(0.5 + 0.5*cos(4.3*t)));
			
			[timer repeatOnceWithInterval:0.01];
		} delay:0.0];
	}{
		CCMotionStreak *streak = [CCMotionStreak streakWithFade:0.5 minSeg:5 width:3 color:[CCColor redColor] textureFilename:@"Tiles/05.png"];
		[stage addChild:streak];
		
		[streak scheduleBlock:^(CCTimer *timer) {
			CCTime t = timer.invokeTime;
			CGSize size = stage.contentSizeInPoints;
			
			streak.position = ccp(size.width*(0.5 + 0.5*sin(1.6*t)), size.height*(0.5 + 0.5*cos(5.1*t)));
			
			[timer repeatOnceWithInterval:0.01];
		} delay:0.0];
	}
}

- (void)setupProgressNodeTest
{
	self.subTitle = @"Testing various CCProgressNode setups.";
	
	// Radial timer
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.1, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeRadial;
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	// Radial timer with animating midpoint.
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.1, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeRadial;
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.midpoint = ccpAdd(ccp(0.5, 0.5), ccpMult(ccpForAngle(timer.invokeTime), 0.25));
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.2, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0);
		progress.barChangeRate = ccp(0, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.2, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0, 0.5);
		progress.barChangeRate = ccp(1, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.3, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(1, 0.5);
		progress.barChangeRate = ccp(1, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.3, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 1);
		progress.barChangeRate = ccp(0, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.4, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0.5);
		progress.barChangeRate = ccp(1, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/05.png";
		CGPoint position = ccp(0.4, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0.5);
		progress.barChangeRate = ccp(0, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = 100.0*(0.5 + 0.5*sin(timer.invokeTime*M_PI));
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
}

- (void)setupDrawNodeTest
{
	self.subTitle = @"Testing CCDrawNode";
	
	CCDrawNode *draw = [CCDrawNode node];
	
	[draw drawDot:ccp(100, 100) radius:50 color:[CCColor redColor]];
	[draw drawSegmentFrom:ccp(100, 200) to:ccp(200, 200) radius:25 color:[CCColor blueColor]];
	
	CGPoint points1[] = {
		{300, 100},
		{350,  50},
		{400, 100},
		{400, 200},
		{350, 250},
		{300, 200},
	};
	[draw drawPolyWithVerts:points1 count:sizeof(points1)/sizeof(*points1) fillColor:[CCColor greenColor] borderWidth:5.0 borderColor:[CCColor whiteColor]];
	
	CGPoint points2[] = {
		{325, 125},
		{375, 125},
		{350, 200},
	};
	[draw drawPolyWithVerts:points2 count:sizeof(points2)/sizeof(*points2) fillColor:[CCColor blackColor] borderWidth:0.0 borderColor:[CCColor whiteColor]];
	
	[self.contentNode addChild:draw];
}

@end

