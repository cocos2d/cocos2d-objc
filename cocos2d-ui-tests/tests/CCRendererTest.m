#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNode_Private.h"

@interface CCRendererTest : TestBase @end
@implementation CCRendererTest

-(void)setupShader1Test
{
	self.subTitle = @"Shaders!";
	
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"TrippyTriangles.fsh"];
	NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor blueColor]];
	node.contentSizeType = CCSizeTypeNormalized;
	node.contentSize = CGSizeMake(1.0, 1.0);
	node.shaderProgram = [[CCGLProgram alloc] initWithFragmentShaderSource:source];
	
	[self.contentNode addChild:node];
}

-(void)setupShader2Test
{
	self.subTitle = @"Shaders!";
	
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"Raytrace.fsh"];
	NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor blueColor]];
	node.contentSizeType = CCSizeTypeNormalized;
	node.contentSize = CGSizeMake(1.0, 1.0);
	node.shaderProgram = [[CCGLProgram alloc] initWithFragmentShaderSource:source];
	
	[self.contentNode addChild:node];
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

