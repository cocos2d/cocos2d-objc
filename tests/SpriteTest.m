//
// Sprite Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "SpriteTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {

	@"Sprite1",
	@"SpriteBatchNode1",
	@"SpriteFrameTest",
	@"SpriteFrameAliasNameTest",
	@"SpriteAnchorPoint",
	@"SpriteBatchNodeAnchorPoint",
	@"SpriteOffsetAnchorRotation",
	@"SpriteBatchNodeOffsetAnchorRotation",
	@"SpriteOffsetAnchorScale",
	@"SpriteBatchNodeOffsetAnchorScale",
	@"SpriteOffsetAnchorSkew",
	@"SpriteOffsetAnchorRotationalSkew",
	@"SpriteBatchNodeOffsetAnchorSkew",
	@"SpriteBatchNodeOffsetAnchorRotationalSkew",
	@"SpriteOffsetAnchorSkewScale",
	@"SpriteOffsetAnchorRotationalSkewScale",
	@"SpriteBatchNodeOffsetAnchorSkewScale",
	@"SpriteBatchNodeOffsetAnchorRotationalSkewScale",
	@"SpriteOffsetAnchorFlip",
	@"SpriteBatchNodeOffsetAnchorFlip",
	@"SpriteAnimationSplit",
	@"SpriteColorOpacity",
	@"SpriteBatchNodeColorOpacity",
	@"SpriteZOrder",
	@"SpriteBatchNodeZOrder",
	@"SpriteBatchNodeReorder",
	@"SpriteBatchNodeReorderIssue744",
	@"SpriteBatchNodeReorderIssue766",
	@"SpriteBatchNodeReorderIssue767",
	@"SpriteBatchNodeReorderSameIndex",
	@"SpriteBatchNodeReorderOneChild",
	@"NodeSort",
	@"SpriteZVertex",
	@"SpriteBatchNodeZVertex",
	@"Sprite6",
	@"SpriteFlip",
	@"SpriteBatchNodeFlip",
	@"SpriteAliased",
	@"SpriteBatchNodeAliased",
	@"SpriteNewTexture",
	@"SpriteBatchNodeNewTexture",
	@"SpriteHybrid",
	@"SpriteBatchNodeChildren",
	@"SpriteBatchNodeChildrenZ",
	@"SpriteChildrenVisibility",
	@"SpriteChildrenVisibilityIssue665",
	@"SpriteChildrenAnchorPoint",
	@"SpriteBatchNodeChildrenAnchorPoint",
	@"SpriteBatchNodeChildrenScale",
	@"SpriteChildrenChildren",
	@"SpriteBatchNodeChildrenChildren",
	@"SpriteSkewNegativeScaleChildren",
	@"SpriteRotationalSkewNegativeScaleChildren",
	@"SpriteBatchNodeSkewNegativeScaleChildren",
	@"SpriteBatchNodeRotationalSkewNegativeScaleChildren",
	@"SpriteNilTexture",
	@"SpriteSubclass",
	@"SpriteDoubleResolution",
	@"SpriteBatchBug1217",
	@"AnimationCache",
	@"AnimationCacheFile",
};

enum {
	kTagTileMap = 1,
	kTagSpriteBatchNode = 1,
	kTagNode = 2,
	kTagAnimation1 = 1,
	kTagSpriteLeft,
	kTagSpriteRight,
};

enum {
	kTagSprite1,
	kTagSprite2,
	kTagSprite3,
	kTagSprite4,
	kTagSprite5,
	kTagSprite6,
	kTagSprite7,
	kTagSprite8,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark -
#pragma mark SpriteDemo

@implementation SpriteDemo
-(id) init
{
	if( (self = [super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}

-(NSString*) subtitle
{
	return nil;
}
@end


#pragma mark -
#pragma mark Example Sprite 1


@implementation Sprite1

-(id) init
{
	if( (self=[super init]) ) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CGSize s = [[CCDirector sharedDirector] winSize];
		[self addNewSpriteWithCoords:ccp(s.width/2, s.height/2)];
	}
	return self;
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;


	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(x,y,85,121)];
	[self addChild:sprite];

	sprite.position = p;

	id action;
	float rand = CCRANDOM_0_1();

	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];

	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];

		[self addNewSpriteWithCoords: location];
	}
}
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteWithCoords: location];

	return YES;

}
#endif

-(NSString *) title
{
	return @"Sprite (tap screen)";
}
@end

@implementation SpriteBatchNode1

-(id) init
{
	if( (self=[super init]) ) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CGSize s = [[CCDirector sharedDirector] winSize];
		[self addNewSpriteWithCoords:ccp(s.width/2, s.height/2)];
	}
	return self;
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagSpriteBatchNode];

	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;


	CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(x,y,85,121)];
	[batch addChild:sprite];

	sprite.position = ccp( p.x, p.y);

	id action;
	float rand = CCRANDOM_0_1();

	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];

	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];

		[self addNewSpriteWithCoords: location];
	}
}
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteWithCoords: location];

	return YES;

}
#endif

-(NSString *) title
{
	return @"SpriteBatchNode (tap screen)";
}
@end


#pragma mark -
#pragma mark Example Sprite Color and Opacity

@implementation SpriteColorOpacity

-(id) init
{
	if( (self=[super init]) ) {

		CCSprite *sprite1 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite2 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite3 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite4 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*3, 121*1, 85, 121)];

		CCSprite *sprite5 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite6 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite7 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite8 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*3, 121*1, 85, 121)];

		CGSize s = [[CCDirector sharedDirector] winSize];
		sprite1.position = ccp( (s.width/5)*1, (s.height/3)*1);
		sprite2.position = ccp( (s.width/5)*2, (s.height/3)*1);
		sprite3.position = ccp( (s.width/5)*3, (s.height/3)*1);
		sprite4.position = ccp( (s.width/5)*4, (s.height/3)*1);
		sprite5.position = ccp( (s.width/5)*1, (s.height/3)*2);
		sprite6.position = ccp( (s.width/5)*2, (s.height/3)*2);
		sprite7.position = ccp( (s.width/5)*3, (s.height/3)*2);
		sprite8.position = ccp( (s.width/5)*4, (s.height/3)*2);

		id action = [CCFadeIn actionWithDuration:2];
		id action_back = [action reverse];
		id fade = [CCRepeatForever actionWithAction: [CCSequence actions: action, action_back, nil]];

		id tintred = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
		id tintred_back = [tintred reverse];
		id red = [CCRepeatForever actionWithAction: [CCSequence actions: tintred, tintred_back, nil]];

		id tintgreen = [CCTintBy actionWithDuration:2 red:-255 green:0 blue:-255];
		id tintgreen_back = [tintgreen reverse];
		id green = [CCRepeatForever actionWithAction: [CCSequence actions: tintgreen, tintgreen_back, nil]];

		id tintblue = [CCTintBy actionWithDuration:2 red:-255 green:-255 blue:0];
		id tintblue_back = [tintblue reverse];
		id blue = [CCRepeatForever actionWithAction: [CCSequence actions: tintblue, tintblue_back, nil]];


		[sprite5 runAction:red];
		[sprite6 runAction:green];
		[sprite7 runAction:blue];
		[sprite8 runAction:fade];

		// late add: test dirtyColor and dirtyPosition
		[self addChild:sprite1 z:0 tag:kTagSprite1];
		[self addChild:sprite2 z:0 tag:kTagSprite2];
		[self addChild:sprite3 z:0 tag:kTagSprite3];
		[self addChild:sprite4 z:0 tag:kTagSprite4];
		[self addChild:sprite5 z:0 tag:kTagSprite5];
		[self addChild:sprite6 z:0 tag:kTagSprite6];
		[self addChild:sprite7 z:0 tag:kTagSprite7];
		[self addChild:sprite8 z:0 tag:kTagSprite8];


		[self schedule:@selector(removeAndAddSprite:) interval:2];

	}
	return self;
}

// this function test if remove and add works as expected:
//   color array and vertex array should be reindexed
-(void) removeAndAddSprite:(ccTime) dt
{
	id sprite = [self getChildByTag:kTagSprite5];
	[sprite retain];

	[self removeChild:sprite cleanup:NO];
	[self addChild:sprite z:0 tag:kTagSprite5];

	[sprite release];
}

-(NSString *) title
{
	return @"Sprite: Color & Opacity";
}
@end

@implementation SpriteBatchNodeColorOpacity

-(id) init
{
	if( (self=[super init]) ) {

		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CCSprite *sprite1 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite2 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite3 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite4 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*3, 121*1, 85, 121)];

		CCSprite *sprite5 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite6 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite7 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite8 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*3, 121*1, 85, 121)];


		CGSize s = [[CCDirector sharedDirector] winSize];
		sprite1.position = ccp( (s.width/5)*1, (s.height/3)*1);
		sprite2.position = ccp( (s.width/5)*2, (s.height/3)*1);
		sprite3.position = ccp( (s.width/5)*3, (s.height/3)*1);
		sprite4.position = ccp( (s.width/5)*4, (s.height/3)*1);
		sprite5.position = ccp( (s.width/5)*1, (s.height/3)*2);
		sprite6.position = ccp( (s.width/5)*2, (s.height/3)*2);
		sprite7.position = ccp( (s.width/5)*3, (s.height/3)*2);
		sprite8.position = ccp( (s.width/5)*4, (s.height/3)*2);

		id action = [CCFadeIn actionWithDuration:2];
		id action_back = [action reverse];
		id fade = [CCRepeatForever actionWithAction: [CCSequence actions: action, action_back, nil]];

		id tintred = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
		id tintred_back = [tintred reverse];
		id red = [CCRepeatForever actionWithAction: [CCSequence actions: tintred, tintred_back, nil]];

		id tintgreen = [CCTintBy actionWithDuration:2 red:-255 green:0 blue:-255];
		id tintgreen_back = [tintgreen reverse];
		id green = [CCRepeatForever actionWithAction: [CCSequence actions: tintgreen, tintgreen_back, nil]];

		id tintblue = [CCTintBy actionWithDuration:2 red:-255 green:-255 blue:0];
		id tintblue_back = [tintblue reverse];
		id blue = [CCRepeatForever actionWithAction: [CCSequence actions: tintblue, tintblue_back, nil]];


		[sprite5 runAction:red];
		[sprite6 runAction:green];
		[sprite7 runAction:blue];
		[sprite8 runAction:fade];

		// late add: test dirtyColor and dirtyPosition
		[batch addChild:sprite1 z:0 tag:kTagSprite1];
		[batch addChild:sprite2 z:0 tag:kTagSprite2];
		[batch addChild:sprite3 z:0 tag:kTagSprite3];
		[batch addChild:sprite4 z:0 tag:kTagSprite4];
		[batch addChild:sprite5 z:0 tag:kTagSprite5];
		[batch addChild:sprite6 z:0 tag:kTagSprite6];
		[batch addChild:sprite7 z:0 tag:kTagSprite7];
		[batch addChild:sprite8 z:0 tag:kTagSprite8];


		[self schedule:@selector(removeAndAddSprite:) interval:2];

	}
	return self;
}

// this function test if remove and add works as expected:
//   color array and vertex array should be reindexed
-(void) removeAndAddSprite:(ccTime) dt
{
	id batch = [self getChildByTag:kTagSpriteBatchNode];
	id sprite = [batch getChildByTag:kTagSprite5];

	[sprite retain];

	[batch removeChild:sprite cleanup:NO];
	[batch addChild:sprite z:0 tag:kTagSprite5];

	[sprite release];
}

-(NSString *) title
{
	return @"SpriteBatchNode: Color & Opacity";
}
@end

#pragma mark -
#pragma mark Example Sprite Z Order and Reorder

@implementation SpriteZOrder

-(id) init
{
	if( (self=[super init]) ) {

		dir = 1;

		CGSize s = [[CCDirector sharedDirector] winSize];

		float step = s.width/11;
		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			[self addChild:sprite z:i];
		}

		for(int i=5;i<10;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			[self addChild:sprite z:14-i];
		}

		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*3, 121*0, 85, 121)];
		[self addChild:sprite z:-1 tag:kTagSprite1];
		sprite.position = ccp(s.width/2, s.height/2 - 20);
		sprite.scaleX = 6;
		[sprite setColor:ccRED];

		[self schedule:@selector(reorderSprite:) interval:1];
	}
	return self;
}

-(void) reorderSprite:(ccTime) dt
{
	id sprite = [self getChildByTag:kTagSprite1];

	NSInteger z = [sprite zOrder];

	if( z < -1 )
		dir = 1;
	if( z > 10 )
		dir = -1;

	z += dir * 3;

	[self reorderChild:sprite z:z];

}

-(NSString *) title
{
	return @"Sprite: Z order";
}
@end

@implementation SpriteBatchNodeZOrder

-(id) init
{
	if( (self=[super init]) ) {

		dir = 1;

		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CGSize s = [[CCDirector sharedDirector] winSize];

		float step = s.width/11;
		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			[batch addChild:sprite z:i];
		}

		for(int i=5;i<10;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			[batch addChild:sprite z:14-i];
		}

		CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*3, 121*0, 85, 121)];
		[batch addChild:sprite z:-1 tag:kTagSprite1];
		sprite.position = ccp(s.width/2, s.height/2 - 20);
		sprite.scaleX = 6;
		[sprite setColor:ccRED];

		[self schedule:@selector(reorderSprite:) interval:1];
	}
	return self;
}

-(void) reorderSprite:(ccTime) dt
{
	id batch = [self getChildByTag:kTagSpriteBatchNode];
	id sprite = [batch getChildByTag:kTagSprite1];

	NSInteger z = [sprite zOrder];

	if( z < -1 )
		dir = 1;
	if( z > 10 )
		dir = -1;

	z += dir * 3;

	[batch reorderChild:sprite z:z];

}

-(NSString *) title
{
	return @"SpriteBatchNode: Z order";
}
@end

@implementation SpriteBatchNodeReorder

-(id) init
{
	if( (self=[super init]) ) {

		NSMutableArray* a = [NSMutableArray arrayWithCapacity:10];
		CCSpriteBatchNode* asmtest = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];

		for(int i=0; i<10; i++)
		{
			CCSprite* s1 = [CCSprite spriteWithTexture:asmtest.texture rect:CGRectMake(0, 0, 50, 50)];
			[a addObject:s1];
			[asmtest addChild:s1 z:10];
		}

		for(int i=0; i<10; i++)
		{
			if(i!=5)
				[asmtest reorderChild:[a objectAtIndex:i] z:9];
		}

		//usually children get sorted before -transform but call sort now to verify order
		[asmtest sortAllChildren];

		NSInteger prev = -1;
		for(id child in asmtest.children)
		{
			NSUInteger currentIndex = [child atlasIndex];
			NSAssert( prev == currentIndex-1, @"Child order failed");
			NSLog(@"children %x - atlasIndex:%d", (unsigned int)child, (unsigned int) currentIndex);
			prev = currentIndex;
		}

		prev = -1;
		for(id child in asmtest.descendants)
		{
			NSUInteger currentIndex = [child atlasIndex];
			NSAssert( prev == currentIndex-1, @"Child order failed");
			NSLog(@"descendant %x - atlasIndex:%d", (unsigned int)child, (unsigned int) currentIndex);
			prev = currentIndex;
		}
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode: reorder #1";
}
-(NSString *) subtitle
{
	return @"Should not crash";
}
@end

@implementation SpriteBatchNodeReorderIssue744

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];


		// Testing issue #744
		// http://code.google.com/p/cocos2d-iphone/issues/detail?id=744
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:15];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(0, 0, 85, 121)];
		sprite.position = ccp(s.width/2, s.height/2);
		[batch addChild:sprite z:3];
		[batch reorderChild:sprite z:1];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode: reorder issue #744";
}

-(NSString *) subtitle
{
	return @"Should not crash";
}
@end

@implementation NodeSort

- (void) reorderSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	NSLog(@"Before reorder--");
	CCSprite *child;
	CCARRAY_FOREACH(node.children,child)
		NSLog(@"tag %i z %i",(int)child.tag,(int)child.zOrder);


	//z-4
	[node reorderChild:[[node children] objectAtIndex:0] z:-6];
	//[node reorderChild:[[node children] objectAtIndex:2] z:-4];
	//[node reorderChild:[[node children] objectAtIndex:1] z:-6];

	[node sortAllChildren];

	NSLog(@"After reorder--");
	CCARRAY_FOREACH(node.children,child)
		NSLog(@"tag %i z %i",(int)child.tag,(int)child.zOrder);

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		node = [CCNode node];
		[self addChild:node z:0 tag:0];

		sprite1 = [CCSprite spriteWithFile:@"piece.png" rect:CGRectMake(128,0,64,64)];
		sprite1.position = CGPointMake(100,160);
		[node addChild:sprite1 z:-6 tag:1];

		sprite2= [CCSprite spriteWithFile:@"piece.png" rect:CGRectMake(128,0,64,64)];
		sprite2.position = CGPointMake(164,160);
		[node addChild:sprite2 z:-6 tag:2];

		sprite4 = [CCSprite spriteWithFile:@"piece.png" rect:CGRectMake(128,0,64,64)];
		sprite4.position = CGPointMake(292,160);
		[node addChild:sprite4 z:-3 tag:4];

		sprite3 = [CCSprite spriteWithFile:@"piece.png" rect:CGRectMake(128,0,64,64)];
		sprite3.position = CGPointMake(228,160);
		[node addChild:sprite3 z:-4 tag:3];

		sprite5 = [CCSprite spriteWithFile:@"piece.png" rect:CGRectMake(128,0,64,64)];
		sprite5.position = CGPointMake(356,160);
		[node addChild:sprite5 z:-3 tag:5];


		[self schedule:@selector(reorderSprite:) interval:1];
	}
	return self;
}

-(NSString *) title
{
	return @"node sort same index";
}

-(NSString *) subtitle
{
	return @"tag order in console should be 2,1,3,4,5";
}

@end


@implementation SpriteBatchNodeReorderSameIndex

- (void) reorderSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	[batchNode reorderChild:sprite4 z:4];
	[batchNode reorderChild:sprite5 z:4];
	[batchNode reorderChild:sprite1 z:4];

	[batchNode sortAllChildren];
	CCSprite* child;
	CCARRAY_FOREACH(batchNode.descendants,child) NSLog(@"tag %i",(int)child.tag);

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		batchNode = [CCSpriteBatchNode batchNodeWithFile:@"piece.png" capacity:15];
		[self addChild:batchNode z:1 tag:0];

		sprite1 = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
		sprite1.position = CGPointMake(100,160);
		[batchNode addChild:sprite1 z:3 tag:1];

		sprite2= [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
		sprite2.position = CGPointMake(164,160);
		[batchNode addChild:sprite2 z:4 tag:2];

		sprite3 = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
		sprite3.position = CGPointMake(228,160);
		[batchNode addChild:sprite3 z:4 tag:3];

		sprite4 = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
		sprite4.position = CGPointMake(292,160);
		[batchNode addChild:sprite4 z:5 tag:4];

		sprite5 = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
		sprite5.position = CGPointMake(356,160);
		[batchNode addChild:sprite5 z:6 tag:5];


		[self schedule:@selector(reorderSprite:) interval:2];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNodeReorder same index";
}

-(NSString *) subtitle
{
	return @"tag order in console should be 2,3,4,5,1";
}

@end

#pragma mark -
#pragma mark SpriteBatchNodeReorderOneChild

@implementation SpriteBatchNodeReorderOneChild

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist"];

		CCSpriteBatchNode *aParent;
		CCSprite *l1, *l2a, *l2b, *l3a1, *l3a2, *l3b1, *l3b2;

		//
		// SpriteBatchNode: 3 levels of children
		//

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];

		batchNode_ = aParent;
		//[[aParent texture] generateMipmap];
		[self addChild:aParent];

		// parent
		l1 = [CCSprite spriteWithSpriteFrameName:@"father.gif"];
		l1.position = ccp( s.width/2, s.height/2);

		[aParent addChild:l1];
		CGSize l1Size = [l1 contentSize];

		// child left
		l2a = [CCSprite spriteWithSpriteFrameName:@"sister1.gif"];
		l2a.position = ccp( -10 + l1Size.width/2, 0 + l1Size.height/2);

		[l1 addChild:l2a z:1];
		CGSize l2aSize = [l2a contentSize];


		// child right
		l2b = [CCSprite spriteWithSpriteFrameName:@"sister2.gif"];
		l2b.position = ccp( +50 + l1Size.width/2, 0 + l1Size.height/2);

		[l1 addChild:l2b z:2];
		CGSize l2bSize = [l2a contentSize];


		// child left bottom
		l3a1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a1.scale = 0.45f;
		l3a1.position = ccp(0+l2aSize.width/2,-50+l2aSize.height/2);
		[l2a addChild:l3a1 z:1];

		// child left top
		l3a2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a2.scale = 0.45f;
		l3a2.position = ccp(0+l2aSize.width/2,+50+l2aSize.height/2);
		[l2a addChild:l3a2 z:2];

		reorderSprite_ = l2a;

		// child right bottom
		l3b1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b1.scale = 0.45f;
		l3b1.flipY = YES;
		l3b1.position = ccp(0+l2bSize.width/2,-50+l2bSize.height/2);
		[l2b addChild:l3b1];

		// child right top
		l3b2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b2.scale = 0.45f;
		l3b2.flipY = YES;
		l3b2.position = ccp(0+l2bSize.width/2,+50+l2bSize.height/2);
		[l2b addChild:l3b2];

		[self schedule:@selector(reorderSprite:) interval:2];

	}
	return self;
}


- (void) reorderSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	[reorderSprite_.parent reorderChild:reorderSprite_ z:-1];

	[batchNode_ sortAllChildren];
	//CCSprite* child;
	//CCARRAY_FOREACH(batchNode.descendants,child) NSLog(@"tag %i",child.tag);

}


-(NSString *) title
{
	return @"SpriteBatchNode reorder 1 child";
}
@end

@implementation SpriteBatchNodeReorderIssue766
-(CCSprite *)makeSpriteZ:(int)aZ
{
	CCSprite *sprite = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(128,0,64,64)];
	[batchNode addChild:sprite z:aZ+1 tag:0];

	//children
	CCSprite *spriteShadow = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(0,0,64,64)];
	spriteShadow.opacity = 128;
	[sprite addChild:spriteShadow z:aZ tag:3];

	CCSprite *spriteTop = [CCSprite spriteWithTexture:batchNode.texture rect:CGRectMake(64,0,64,64)];
	[sprite addChild:spriteTop z:aZ+2 tag:3];

	return sprite;
}

- (void) reorderSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	[batchNode reorderChild:sprite1 z:4];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		batchNode = [CCSpriteBatchNode batchNodeWithFile:@"piece.png" capacity:15];
		[self addChild:batchNode z:1 tag:0];

		sprite1 = [self makeSpriteZ:2];
		sprite1.position = CGPointMake(200,160);

		sprite2= [self makeSpriteZ:3];
		sprite2.position = CGPointMake(264,160);

		sprite3 = [self makeSpriteZ:4];
		sprite3.position = CGPointMake(328,160);

		[self schedule:@selector(reorderSprite:) interval:2];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNodeReorder";
}

-(NSString *) subtitle
{
	return @"In 2 seconds 1 sprite will be reordered";
}

@end



@implementation SpriteBatchNodeReorderIssue767

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist" textureFilename:@"animations/ghosts.png"];

		CCNode *aParent;
		CCSprite *l1, *l2a, *l2b, *l3a1, *l3a2, *l3b1, *l3b2;

		//
		// SpriteBatchNode: 3 levels of children
		//

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];
		[self addChild:aParent z:0 tag:kTagSprite1];

		// parent
		l1 = [CCSprite spriteWithSpriteFrameName:@"father.gif"];
		l1.position = ccp( s.width/2, s.height/2);
		[aParent addChild:l1 z:0 tag:kTagSprite2];
		CGSize l1Size = [l1 contentSize];

		// child left
		l2a = [CCSprite spriteWithSpriteFrameName:@"sister1.gif"];
		l2a.position = ccp( -25 + l1Size.width/2, 0 + l1Size.height/2);
		[l1 addChild:l2a z:-1 tag:kTagSpriteLeft];
		CGSize l2aSize = [l2a contentSize];


		// child right
		l2b = [CCSprite spriteWithSpriteFrameName:@"sister2.gif"];
		l2b.position = ccp( +25 + l1Size.width/2, 0 + l1Size.height/2);
		[l1 addChild:l2b z:1 tag:kTagSpriteRight];
		CGSize l2bSize = [l2a contentSize];


		// child left bottom
		l3a1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a1.scale = 0.65f;
		l3a1.position = ccp(0+l2aSize.width/2,-50+l2aSize.height/2);
		[l2a addChild:l3a1 z:-1];

		// child left top
		l3a2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a2.scale = 0.65f;
		l3a2.position = ccp(0+l2aSize.width/2,+50+l2aSize.height/2);
		[l2a addChild:l3a2 z:1];

		// child right bottom
		l3b1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b1.scale = 0.65f;
		l3b1.position = ccp(0+l2bSize.width/2,-50+l2bSize.height/2);
		[l2b addChild:l3b1 z:-1];

		// child right top
		l3b2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b2.scale = 0.65f;
		l3b2.position = ccp(0+l2bSize.width/2,+50+l2bSize.height/2);
		[l2b addChild:l3b2 z:1];

		[self schedule:@selector(reorderSprites:) interval:1];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode: reorder issue #767";
}

-(NSString *) subtitle
{
	return @"Should not crash";
}

-(void) reorderSprites:(ccTime)dt
{
	id spritebatch = [self getChildByTag:kTagSprite1];
	CCSprite *father = (CCSprite*)[spritebatch getChildByTag:kTagSprite2];
	CCSprite *left = (CCSprite*)[father getChildByTag:kTagSpriteLeft];
	CCSprite *right = (CCSprite*)[father getChildByTag:kTagSpriteRight];

	int newZLeft = 1;

	if( left.zOrder == 1 )
		newZLeft = -1;

	[father reorderChild:left z:newZLeft];
	[father reorderChild:right z:-newZLeft];
}
@end


#pragma mark -
#pragma mark Example SpriteZVertex

@implementation SpriteZVertex

-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
	[super onExit];
}

-(id) init
{
	if( (self=[super init]) ) {

		//
		// This test tests z-order
		// If you are going to use it is better to use a 3D projection
		//
		// WARNING:
		// The developer is resposible for ordering its sprites according to its Z if the sprite has
		// transparent parts.
		//

		//
		// Configure shader to mimic glAlphaTest
		//
		CCGLProgram *alphaTestShader = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
		GLint alphaValueLocation = glGetUniformLocation(alphaTestShader.program, kCCUniformAlphaTestValue_s);

		[alphaTestShader use];
		// set alpha test value
		// NOTE: alpha test shader is hard-coded to use the equivalent of a glAlphaFunc(GL_GREATER) comparison
		[alphaTestShader setUniformLocation:alphaValueLocation withF1:0.5f];

		dir = 1;
		time = 0;

		CGSize s = [[CCDirector sharedDirector] winSize];
		float step = s.width/12;

		CCNode *node = [CCNode node];
		// camera uses the center of the image as the pivoting point
		[node setContentSize:CGSizeMake(s.width,s.height)];
		[node setAnchorPoint:ccp(0.5f, 0.5f)];
		[node setPosition:ccp(s.width/2, s.height/2)];

		[self addChild:node z:0];

		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp((i+1)*step, s.height/2);
			sprite.vertexZ = 10 + i*40;
			sprite.shaderProgram = alphaTestShader;
			[node addChild:sprite z:0];
		}

		for(int i=5;i<11;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			sprite.vertexZ = 10 + (10-i)*40;
			sprite.shaderProgram = alphaTestShader;
			[node addChild:sprite z:0];
		}

		[node runAction:[CCOrbitCamera actionWithDuration:10 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0]];
	}
	return self;
}

-(NSString *) title
{
	return @"Sprite: openGL Z vertex";
}
@end

@implementation SpriteBatchNodeZVertex

-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
	[super onExit];
}

-(id) init
{
	if( (self=[super init]) ) {

		//
		// This test tests z-order
		// If you are going to use it is better to use a 3D projection
		//
		// WARNING:
		// The developer is resposible for ordering its sprites according to its Z if the sprite has
		// transparent parts.
		//

		//
		// Configure shader to mimic glAlphaTest
		//
		CCGLProgram *alphaTestShader = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
		GLint alphaValueLocation = glGetUniformLocation(alphaTestShader.program, kCCUniformAlphaTestValue_s);

		
		[alphaTestShader use];
		// set alpha test value
		// NOTE: alpha test shader is hard-coded to use the equivalent of a glAlphaFunc(GL_GREATER) comparison
		[alphaTestShader setUniformLocation:alphaValueLocation withF1:0.5f];


		CGSize s = [[CCDirector sharedDirector] winSize];
		float step = s.width/12;

		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:1];
		// camera uses the center of the image as the pivoting point
		[batch setContentSize:CGSizeMake(s.width,s.height)];
		[batch setAnchorPoint:ccp(0.5f, 0.5f)];
		[batch setPosition:ccp(s.width/2, s.height/2)];
		batch.shaderProgram = alphaTestShader;


		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			sprite.vertexZ = 10 + i*40;
			[batch addChild:sprite z:0];

		}

		for(int i=5;i<11;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);
			sprite.vertexZ = 10 + (10-i)*40;
			[batch addChild:sprite z:0];
		}

		[batch runAction:[CCOrbitCamera actionWithDuration:10 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0]];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode: openGL Z vertex";
}
@end


#pragma mark -
#pragma mark Example Sprite Anchor Point

@implementation SpriteAnchorPoint

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];


		id rotate = [CCRotateBy actionWithDuration:10 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];
		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*i, 121*1, 85, 121)];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:10];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			id copy = [[action copy] autorelease];
			[sprite runAction:copy];
			[self addChild:sprite z:i];
		}
	}
	return self;
}

-(NSString *) title
{
	return @"Sprite: anchor point";
}
@end

@implementation SpriteBatchNodeAnchorPoint
-(id) init
{
	if( (self=[super init]) ) {

		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CGSize s = [[CCDirector sharedDirector] winSize];


		id rotate = [CCRotateBy actionWithDuration:10 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];
		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*i, 121*1, 85, 121)];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			id copy = [[action copy] autorelease];
			[sprite runAction:copy];
			[batch addChild:sprite z:i];
		}
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode: anchor point";
}
@end

#pragma mark -
#pragma mark Example Sprite 6

@implementation Sprite6
-(id) init
{
	if( (self=[super init]) ) {

		// small capacity. Testing resizing
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];
		batch.ignoreAnchorPointForPosition = YES;

		CGSize s = [[CCDirector sharedDirector] winSize];

		batch.anchorPoint = ccp(0.5f, 0.5f);
		batch.contentSize = CGSizeMake(s.width, s.height);


		// SpriteBatchNode actions
		id rotate = [CCRotateBy actionWithDuration:5 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];

		// SpriteBatchNode actions
		id rotate_back = [rotate reverse];
		id rotate_seq = [CCSequence actions:rotate, rotate_back, nil];
		id rotate_forever = [CCRepeatForever actionWithAction:rotate_seq];

		id scale = [CCScaleBy actionWithDuration:5 scale:1.5f];
		id scale_back = [scale reverse];
		id scale_seq = [CCSequence actions: scale, scale_back, nil];
		id scale_forever = [CCRepeatForever actionWithAction:scale_seq];

		float step = s.width/4;

		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*i, 121*1, 85, 121)];
			sprite.position = ccp( (i+1)*step, s.height/2);

			[sprite runAction: [[action copy] autorelease]];
			[batch addChild:sprite z:i];
		}

		[batch runAction: scale_forever];
		[batch runAction: rotate_forever];
	}
	return self;
}
-(NSString*) title
{
	return @"SpriteBatchNode transformation";
}
@end

#pragma mark -
#pragma mark Example Sprite Flip

@implementation SpriteFlip
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite1 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[self addChild:sprite1 z:0 tag:kTagSprite1];

		CCSprite *sprite2 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[self addChild:sprite2 z:0 tag:kTagSprite2];

		[self schedule:@selector(flipSprites:) interval:1];
	}
	return self;
}
-(void) flipSprites:(ccTime)dt
{
	CCSprite *sprite1 = (CCSprite*)[self getChildByTag:kTagSprite1];
	CCSprite *sprite2 = (CCSprite*)[self getChildByTag:kTagSprite2];

	BOOL x = [sprite1 flipX];
	BOOL y = [sprite2 flipY];

	// testing bug #970
	NSLog(@"Pre: %f", sprite1.contentSize.height);
	[sprite1 setFlipX: !x];
	[sprite2 setFlipY: !y];
	NSLog(@"Post: %f", sprite1.contentSize.height);

}
-(NSString*) title
{
	return @"Sprite Flip X & Y";
}
@end

@implementation SpriteBatchNodeFlip
-(id) init
{
	if( (self=[super init]) ) {

		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:10];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite1 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[batch addChild:sprite1 z:0 tag:kTagSprite1];

		CCSprite *sprite2 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[batch addChild:sprite2 z:0 tag:kTagSprite2];

		[self schedule:@selector(flipSprites:) interval:1];
	}
	return self;
}
-(void) flipSprites:(ccTime)dt
{
	id batch = [self getChildByTag:kTagSpriteBatchNode];
	CCSprite *sprite1 = (CCSprite*)[batch getChildByTag:kTagSprite1];
	CCSprite *sprite2 = (CCSprite*)[batch getChildByTag:kTagSprite2];

	BOOL x = [sprite1 flipX];
	BOOL y = [sprite2 flipY];


	// testing bug #970
	NSLog(@"Pre: %f", sprite1.contentSize.height);
	[sprite1 setFlipX: !x];
	[sprite2 setFlipY: !y];
	NSLog(@"Post: %f", sprite1.contentSize.height);

}
-(NSString*) title
{
	return @"SpriteBatchNode Flip X & Y";
}
@end

#pragma mark -
#pragma mark Example Sprite Aliased

@implementation SpriteAliased
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite1 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[self addChild:sprite1 z:0 tag:kTagSprite1];

		CCSprite *sprite2 = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[self addChild:sprite2 z:0 tag:kTagSprite2];

		id scale = [CCScaleBy actionWithDuration:2 scale:5];
		id scale_back = [scale reverse];
		id seq = [CCSequence actions: scale, scale_back, nil];
		id repeat = [CCRepeatForever actionWithAction:seq];

		id repeat2 = [[repeat copy] autorelease];

		[sprite1 runAction:repeat];
		[sprite2 runAction:repeat2];

	}
	return self;
}
-(void) onEnter
{
	[super onEnter];

	//
	// IMPORTANT:
	// This change will affect every sprite that uses the same texture
	// So sprite1 and sprite2 will be affected by this change
	//
	CCSprite *sprite = (CCSprite*) [self getChildByTag:kTagSprite1];
	[sprite.texture setAliasTexParameters];
}

-(void) onExit
{
	// restore the tex parameter to AntiAliased.
	CCSprite *sprite = (CCSprite*) [self getChildByTag:kTagSprite1];
	[sprite.texture setAntiAliasTexParameters];
	[super onExit];
}

-(NSString*) title
{
	return @"Sprite Aliased";
}
@end

@implementation SpriteBatchNodeAliased
-(id) init
{
	if( (self=[super init]) ) {

		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:10];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite1 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[batch addChild:sprite1 z:0 tag:kTagSprite1];

		CCSprite *sprite2 = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[batch addChild:sprite2 z:0 tag:kTagSprite2];

		id scale = [CCScaleBy actionWithDuration:2 scale:5];
		id scale_back = [scale reverse];
		id seq = [CCSequence actions: scale, scale_back, nil];
		id repeat = [CCRepeatForever actionWithAction:seq];

		id repeat2 = [[repeat copy] autorelease];

		[sprite1 runAction:repeat];
		[sprite2 runAction:repeat2];

	}
	return self;
}
-(void) onEnter
{
	[super onEnter];
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagSpriteBatchNode];
	[batch.texture setAliasTexParameters];
}

-(void) onExit
{
	// restore the tex parameter to AntiAliased.
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagSpriteBatchNode];
	[batch.texture setAntiAliasTexParameters];
	[super onExit];
}

-(NSString*) title
{
	return @"SpriteBatchNode Aliased";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNode NewTexture

@implementation SpriteNewTexture

-(id) init
{
	if( (self=[super init]) ) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CCNode *node = [CCNode node];
		[self addChild:node z:0 tag:kTagSpriteBatchNode];

		texture1 = [[[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"] retain];
		texture2 = [[[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas-mono.png"] retain];

		usingTexture1 = YES;

		for(int i=0;i<30;i++)
			[self addNewSprite];

	}
	return self;
}

- (void) dealloc
{
	[texture1 release];
	[texture2 release];
	[super dealloc];
}

-(void) addNewSprite
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	CGPoint p = ccp( CCRANDOM_0_1() * s.width, CCRANDOM_0_1() * s.height);

	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;


	CCNode *node = [self getChildByTag:kTagSpriteBatchNode];
	CCSprite *sprite = [CCSprite spriteWithTexture:texture1 rect:CGRectMake(x,y,85,121)];
	[node addChild:sprite];

	sprite.position = ccp( p.x, p.y);

	id action;
	float rand = CCRANDOM_0_1();

	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];

	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
#endif
{

	CCNode *node = [self getChildByTag:kTagSpriteBatchNode];
	if( usingTexture1 ) {
		for( CCSprite* sprite in node.children)
			[sprite setTexture:texture2];
		usingTexture1 = NO;
	} else {
		for( CCSprite* sprite in node.children)
			[sprite setTexture:texture1];
		usingTexture1 = YES;
	}

#ifdef __CC_PLATFORM_IOS
#elif defined(__CC_PLATFORM_MAC)
	return YES;
#endif
}

-(NSString *) title
{
	return @"Sprite New texture (tap)";
}
@end

@implementation SpriteBatchNodeNewTexture
-(id) init
{
	if( (self=[super init]) ) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		texture1 = [[batch texture] retain];
		texture2 = [[[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas-mono.png"] retain];

		for(int i=0;i<30;i++)
			[self addNewSprite];

	}
	return self;
}

- (void) dealloc
{
	[texture1 release];
	[texture2 release];
	[super dealloc];
}

-(void) addNewSprite
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	CGPoint p = ccp( CCRANDOM_0_1() * s.width, CCRANDOM_0_1() * s.height);

	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagSpriteBatchNode];

	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;


	CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:CGRectMake(x,y,85,121)];
	[batch addChild:sprite];

	sprite.position = ccp( p.x, p.y);

	id action;
	float rand = CCRANDOM_0_1();

	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];

	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
#endif
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagSpriteBatchNode];

	if( [batch texture] == texture1 )
		[batch setTexture:texture2];
	else
		[batch setTexture:texture1];

#ifdef __CC_PLATFORM_IOS
#elif defined(__CC_PLATFORM_MAC)
	return YES;
#endif
}

-(NSString *) title
{
	return @"SpriteBatchNode new texture (tap)";
}
@end


#pragma mark -
#pragma mark Example Sprite vs SpriteBatchNode Animation

@implementation SpriteFrameTest

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// IMPORTANT:
		// The sprite frames will be cached AND RETAINED, and they won't be released unless you call
		//     [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
		//
		// CCSpriteFrameCache is a cache of CCSpriteFrames
		// CCSpriteFrames each contain a texture id and a rect (frame).

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		[cache addSpriteFramesWithFile:@"animations/grossini_blue.plist" textureFilename:@"animations/grossini_blue.png"];

		//
		// Animation using Sprite batch
		//
		// A CCSpriteBatchNode can reference one and only one texture (one .png file)
		// Sprites that are contained in that texture can be instantiatied as CCSprites and then added to the CCSpriteBatchNode
		// All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call
		// If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient
		//
		// When you animate a sprite, CCAnimation changes the frame of the sprite using setDisplayFrame: (this is why the animation must be in the same texture)
		// When setDisplayFrame: is used in the CCAnimation it changes the frame to one specified by the CCSpriteFrames that were added to the animation,
		// but texture id is still the same and so the sprite is still a child of the CCSpriteBatchNode,
		// and therefore all the animation sprites are also drawn as part of the CCSpriteBatchNode
		//

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		sprite1.position = ccp( s.width/2-80, s.height/2);

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[spritebatch addChild:sprite1];
		[self addChild:spritebatch];

		NSMutableArray *animFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {

			CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",i]];
			[animFrames addObject:frame];
		}

		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
		// 14 frames * 1sec = 14 seconds
		[sprite1 runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation] ]];

		// to test issue #732, uncomment the following line
		sprite1.flipX = NO;
		sprite1.flipY = NO;

		//
		// Animation using standard Sprite
		//
		//
		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		sprite2.position = ccp( s.width/2 + 80, s.height/2);
		[self addChild:sprite2];


		NSMutableArray *moreFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {

			CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_gray_%02d.png",i]];
			[moreFrames addObject:frame];
		}
		for( int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_blue_%02d.png",i]];
			[moreFrames addObject:frame];
		}

		// append frames from another batch
		[moreFrames addObjectsFromArray:animFrames];
		CCAnimation *animMixed = [CCAnimation animationWithSpriteFrames:moreFrames delay:0.3f];

		// 32 frames * 1 seconds = 32 seconds
		[sprite2 runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animMixed]]];

		// to test issue #732, uncomment the following line
		sprite2.flipX = NO;
		sprite2.flipY = NO;

		[self schedule:@selector(startIn05Secs:) interval:0.5f];

		counter = 0;

	}
	return self;
}

-(void) startIn05Secs:(ccTime)dt
{
	[self unschedule:_cmd];
	[self schedule:@selector(flipSprites:) interval:1];
}

-(void) flipSprites:(ccTime)dt
{
	counter ++;

	BOOL fx = NO;
	BOOL fy = NO;
	int i = counter % 4;

	switch ( i ) {
		case 0:
			fx = NO;
			fy = NO;
			break;
		case 1:
			fx = YES;
			fy = NO;
			break;
		case 2:
			fx = NO;
			fy = YES;
			break;
		case 3:
			fx = YES;
			fy = YES;
			break;
	}

	sprite1.flipX = sprite2.flipX = fx;
	sprite1.flipY = sprite2.flipY = fy;

	NSLog(@"flipX:%d, flipY:%d", fx, fy);
}

- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_blue.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite vs. SpriteBatchNode animation";
}

-(NSString*) subtitle
{
	return @"Testing issue #792";
}
@end

#pragma mark -
#pragma mark Example SpriteFrameAliasNameTest

@implementation SpriteFrameAliasNameTest

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// IMPORTANT:
		// The sprite frames will be cached AND RETAINED, and they won't be released unless you call
		//     [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
		//
		// CCSpriteFrameCache is a cache of CCSpriteFrames
		// CCSpriteFrames each contain a texture id and a rect (frame).

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini-aliases.plist" textureFilename:@"animations/grossini-aliases.png"];

		//
		// Animation using Sprite batch
		//
		// A CCSpriteBatchNode can reference one and only one texture (one .png file)
		// Sprites that are contained in that texture can be instantiatied as CCSprites and then added to the CCSpriteBatchNode
		// All CCSprites added to a CCSpriteBatchNode are drawn in one OpenGL ES draw call
		// If the CCSprites are not added to a CCSpriteBatchNode then an OpenGL ES draw call will be needed for each one, which is less efficient
		//
		// When you animate a sprite, CCAnimation changes the frame of the sprite using setDisplayFrame: (this is why the animation must be in the same texture)
		// When setDisplayFrame: is used in the CCAnimation it changes the frame to one specified by the CCSpriteFrames that were added to the animation,
		// but texture id is still the same and so the sprite is still a child of the CCSpriteBatchNode,
		// and therefore all the animation sprites are also drawn as part of the CCSpriteBatchNode
		//

		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		sprite.position = ccp(s.width * 0.5f, s.height * 0.5f);

		CCSpriteBatchNode *spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini-aliases.png"];
		[spriteBatch addChild:sprite];
		[self addChild:spriteBatch];

		NSMutableArray *animFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {

			// Obtain frames by alias name
			CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"dance_%02d",i]];
			[animFrames addObject:frame];
		}

		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
		// 14 frames * 1sec = 14 seconds
		[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]]];

	}
	return self;
}
- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"animations/grossini-aliases.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteFrame Alias Name";
}

-(NSString*) subtitle
{
	return @"SpriteFrames are obtained using the alias name";
}

@end


#pragma mark -
#pragma mark Example SpriteOffsetAnchorRotation

@implementation SpriteOffsetAnchorRotation

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		

		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]]];
			[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:10 angle:360]]];


			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite offset + anchor + rot";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorRotation

@implementation SpriteBatchNodeOffsetAnchorRotation

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
		
		for(int i=0;i<3;i++) {

			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]]];
			[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:10 angle:360]]];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode offset + anchor + rot";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchorScale

@implementation SpriteOffsetAnchorScale

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		
		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]]];

			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];

			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite offset + anchor + scale";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorScale

@implementation SpriteBatchNodeOffsetAnchorScale

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
		
		for(int i=0;i<3;i++) {

			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation] ]];

			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode offset + anchor + scale";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchorSkew

@implementation SpriteOffsetAnchorSkew

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation] ]];

			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite offset + anchor + skew";
}
@end


#pragma mark -
#pragma mark Example SpriteOffsetAnchorRotationalSkew

@implementation SpriteOffsetAnchorRotationalSkew

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
    
		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];
      
			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}
      
			point.position = sprite.position;
      
			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {
        
				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation] ]];
      
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite offset + anchor + rotational skew";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorSkew

@implementation SpriteBatchNodeOffsetAnchorSkew

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
		
		for(int i=0;i<3;i++) {

			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];

			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode offset + anchor + skew";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorRotationalSkew

@implementation SpriteBatchNodeOffsetAnchorRotationalSkew

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
    
		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
		
		for(int i=0;i<3;i++) {
      
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];
      
			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}
      
			point.position = sprite.position;
      
			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {
        
				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];
      
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode offset + anchor + rot skew";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchorSkewScale

@implementation SpriteOffsetAnchorSkewScale

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		
		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];

			// Skew
			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			// Scale
			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];


			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite anchor + skew + scale";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchorRotationalSkewScale

@implementation SpriteOffsetAnchorRotationalSkewScale

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		
		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];
      
			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}
      
			point.position = sprite.position;
      
			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {
        
				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];
      
			// Skew
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			// Scale
			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];
      
      
			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite anchor + rot skew + scale";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorSkewScale

@implementation SpriteBatchNodeOffsetAnchorSkewScale

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];

		for(int i=0;i<3;i++) {

			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;


			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];

			// Skew
			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			// Scale
			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode anchor + skew + scale";
}
@end


#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorRotationalSkewScale

@implementation SpriteBatchNodeOffsetAnchorRotationalSkewScale

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
    
		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
    
		for(int i=0;i<3;i++) {
      
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];
      
			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}
      
			point.position = sprite.position;
      
      
			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {
        
				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];
      
			// Skew
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			// Scale
			id scale = [CCScaleBy actionWithDuration:2 scale:2];
			id scale_back = [scale reverse];
			id seq_scale = [CCSequence actions:scale, scale_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_scale]];
      
			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode anchor + rot skew + scale";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchorFlip

@implementation SpriteOffsetAnchorFlip

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
		
		for(int i=0;i<3;i++) {
			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:1];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];

			id flip = [CCFlipY actionWithFlipY:YES];
			id flip_back = [CCFlipY actionWithFlipY:NO];
			id delay = [CCDelayTime actionWithDuration:1];
			id seq = [CCSequence actions:delay, flip, [[delay copy] autorelease], flip_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq]];

			[self addChild:sprite z:0];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite offset + anchor + flip";
}

-(NSString *) subtitle
{
	return @"issue #1078";
}

@end

#pragma mark -
#pragma mark Example SpriteBatchNodeOffsetAnchorFlip

@implementation SpriteBatchNodeOffsetAnchorFlip

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
		
		for(int i=0;i<3;i++) {

			//
			// Animation using Sprite batch
			//
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:200];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {

				CCSpriteFrame *frame = [cache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.3f];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation ]]];

			id flip = [CCFlipY actionWithFlipY:YES];
			id flip_back = [CCFlipY actionWithFlipY:NO];
			id delay = [CCDelayTime actionWithDuration:1];
			id seq = [CCSequence actions:delay, flip, [[delay copy] autorelease], flip_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq]];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}


- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode offset + anchor + flip";
}

-(NSString *) subtitle
{
	return @"issue #1078";
}

@end

#pragma mark -
#pragma mark Example Sprite: Animation Split

@implementation SpriteAnimationSplit

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"animations/dragon_animation.png"];

		// manually add frames to the frame cache
		CCSpriteFrame *frame0 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*0, 132, 132)];
		CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*0, 132, 132)];
		CCSpriteFrame *frame2 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*2, 132*0, 132, 132)];
		CCSpriteFrame *frame3 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*3, 132*0, 132, 132)];
		CCSpriteFrame *frame4 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*1, 132, 132)];
		CCSpriteFrame *frame5 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*1, 132, 132)];


		//
		// Animation using Sprite batch
		//
		CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frame0];
		sprite.position = ccp( s.width/2-80, s.height/2);
		[self addChild:sprite];

		NSMutableArray *animFrames = [NSMutableArray array];
		[animFrames addObject:frame0];
		[animFrames addObject:frame1];
		[animFrames addObject:frame2];
		[animFrames addObject:frame3];
		[animFrames addObject:frame4];
		[animFrames addObject:frame5];

		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.2f];
		CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
		CCSequence *seq = [CCSequence actions: animate,
						   [CCFlipX actionWithFlipX:YES],
						   [[animate copy] autorelease],
						   [CCFlipX actionWithFlipX:NO],
						   nil];

		[sprite runAction:[CCRepeatForever actionWithAction: seq ]];

	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite: Animation + flip";
}
@end

#pragma mark -
#pragma mark Sprite Hybrid

@implementation SpriteHybrid

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// parents
		CCNode *parent1 = [CCNode node];
		CCSpriteBatchNode *parent2 = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];

		[self addChild:parent1 z:0 tag:kTagNode];
		[self addChild:parent2 z:0 tag:kTagSpriteBatchNode];


		// IMPORTANT:
		// The sprite frames will be cached AND RETAINED, and they won't be released unless you call
		//     [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];


		// create 250 sprites
		// only show 80% of them
		for(int i = 0; i < 250; i++) {

			int spriteIdx = CCRANDOM_0_1() * 14;
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(spriteIdx+1)]];
			CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frame];
			[parent1 addChild:sprite z:i tag:i];

			float x=-1000;
			float y=-1000;
			if( CCRANDOM_0_1() < 0.2f ) {
				x = CCRANDOM_0_1() * s.width;
				y = CCRANDOM_0_1() * s.height;
			}
			sprite.position = ccp(x,y);

			id action = [CCRotateBy actionWithDuration:4 angle:360];
			[sprite runAction: [CCRepeatForever actionWithAction:action]];
		}

		usingSpriteBatchNode = NO;


		[self schedule:@selector(reparentSprite:) interval:2];
	}
	return self;
}

-(void) reparentSprite:(ccTime)dt
{
	CCNode *p1 = [self getChildByTag:kTagNode];
	CCNode *p2 = [self getChildByTag:kTagSpriteBatchNode];

	NSMutableArray *array = [NSMutableArray arrayWithCapacity:30];


	if( usingSpriteBatchNode )
		CC_SWAP(p1,p2);

	NSLog(@"New parent is: %@", p2);


	for( CCNode *node in p1.children) {
		[array addObject:node];
	}

	int i=0;
	[p1 removeAllChildrenWithCleanup:NO];

	for( CCNode *node in array ) {
		[p2 addChild:node z:i tag:i];
		i++;
	}

	usingSpriteBatchNode = ! usingSpriteBatchNode;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Hybrid Sprite Test";
}
@end

#pragma mark -
#pragma mark SpriteBatchNode Children

@implementation SpriteBatchNodeChildren

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// parents
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];

		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];

		CCSprite *sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/3, s.height/2)];

		CCSprite *sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(50,50)];

		CCSprite *sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-50,-50)];

		[batch addChild:sprite1];
		[sprite1 addChild:sprite2];
		[sprite1 addChild:sprite3];

		// BEGIN NEW CODE
		NSMutableArray *animFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {

			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",i]];
			[animFrames addObject:frame];
		}

		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.2f];
		[sprite1 runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]]];
		// END NEW CODE

		id action = [CCMoveBy actionWithDuration:2 position:ccp(200,0)];
		id action_back = [action reverse];
		id action_rot = [CCRotateBy actionWithDuration:2 angle:360];
		id action_s = [CCScaleBy actionWithDuration:2 scale:2];
		id action_s_back = [action_s reverse];

		id seq2 = [action_rot reverse];
		[sprite2 runAction: [CCRepeatForever actionWithAction:seq2]];

		[sprite1 runAction: [CCRepeatForever actionWithAction:action_rot]];
		[sprite1 runAction: [CCRepeatForever actionWithAction:[CCSequence actions:action, action_back, nil]]];
		[sprite1 runAction: [CCRepeatForever actionWithAction:[CCSequence actions:action_s, action_s_back, nil]]];

	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode Grand Children";
}
@end


#pragma mark -
#pragma mark SpriteBatchNode ChildrenZ

@implementation SpriteBatchNodeChildrenZ

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// parents
		CCSpriteBatchNode *batch;
		CCSprite *sprite1, *sprite2, *sprite3;


		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];


		// test 1
		batch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/3, s.height/2)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		[batch addChild:sprite1];
		[sprite1 addChild:sprite2 z:2];
		[sprite1 addChild:sprite3 z:-2];

		// test 2
		batch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( 2*s.width/3, s.height/2)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		[batch addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:2];

		// test 3
		batch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/2 - 90, s.height/4)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp( s.width/2 - 60,s.height/4)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp( s.width/2 - 30, s.height/4)];

		[batch addChild:sprite1 z:10];
		[batch addChild:sprite2 z:-10];
		[batch addChild:sprite3 z:-5];

		// test 4
		batch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		[self addChild:batch z:0 tag:kTagSpriteBatchNode];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/2 +30, s.height/4)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp( s.width/2 +60,s.height/4)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp( s.width/2 +90, s.height/4)];

		[batch addChild:sprite1 z:-10];
		[batch addChild:sprite2 z:-5];
		[batch addChild:sprite3 z:-2];


	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode Children Z";
}
@end

#pragma mark -
#pragma mark SpriteChildrenVisibility

@implementation SpriteChildrenVisibility

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];

		CCNode *aParent;
		CCSprite *sprite1, *sprite2, *sprite3;
		//
		// SpriteBatchNode
		//
		// parents
		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		aParent.position = ccp(s.width/3, s.height/2);
		[self addChild:aParent z:0];



		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		// test issue #665
//		sprite1.visible = NO;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:2];

		[sprite1 runAction:[CCBlink actionWithDuration:5 blinks:10]];

		//
		// Sprite
		//
		aParent = [CCNode node];
		aParent.position = ccp(2*s.width/3, s.height/2);
		[self addChild:aParent z:0];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		// test issue #665
//		sprite1.visible = NO;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:2];

		[sprite1 runAction:[CCBlink actionWithDuration:5 blinks:10]];

	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite & SpriteBatchNode Visibility";
}
@end

#pragma mark -
#pragma mark SpriteChildrenVisibilityIssue665

@implementation SpriteChildrenVisibilityIssue665

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];

		CCNode *aParent;
		CCSprite *sprite1, *sprite2, *sprite3;
		//
		// SpriteBatchNode
		//
		// parents
		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		aParent.position = ccp(s.width/3, s.height/2);
		[self addChild:aParent z:0];



		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		// test issue #665
		sprite1.visible = NO;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:2];

		//
		// Sprite
		//
		aParent = [CCNode node];
		aParent.position = ccp(2*s.width/3, s.height/2);
		[self addChild:aParent z:0];

		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		// test issue #665
		sprite1.visible = NO;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:2];

	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite & SpriteBatchNode Visibility";
}

-(NSString *) subtitle
{
	return @"No sprites should be visible";
}

@end

#pragma mark -
#pragma mark SpriteChildrenAnchorPoint

@implementation SpriteChildrenAnchorPoint

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];

		CCNode *aParent;
		CCSprite *sprite1, *sprite2, *sprite3, *sprite4, *point;
		//
		// SpriteBatchNode
		//
		// parents

		aParent = [CCNode node];
		[self addChild:aParent z:0];

		// anchor (0,0)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/4,s.height/2)];
		sprite1.anchorPoint = ccp(0,0);


		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;


		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];


		// anchor (0.5, 0.5)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/2,s.height/2)];
		sprite1.anchorPoint = ccp(0.5f, 0.5f);

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];


		// anchor (1,1)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/2+s.width/4,s.height/2)];
		sprite1.anchorPoint = ccp(1,1);


		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];
	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite: children + anchor";
}
@end

#pragma mark -
#pragma mark SpriteBatchNodeChildrenAnchorPoint

@implementation SpriteBatchNodeChildrenAnchorPoint

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];

		CCNode *aParent;
		CCSprite *sprite1, *sprite2, *sprite3, *sprite4, *point;
		//
		// SpriteBatchNode
		//
		// parents

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz" capacity:50];
		[self addChild:aParent z:0];

		// anchor (0,0)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/4,s.height/2)];
		sprite1.anchorPoint = ccp(0,0);

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];


		// anchor (0.5, 0.5)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/2,s.height/2)];
		sprite1.anchorPoint = ccp(0.5f, 0.5f);

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];


		// anchor (1,1)
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_08.png"];
		[sprite1 setPosition:ccp(s.width/2+s.width/4,s.height/2)];
		sprite1.anchorPoint = ccp(1,1);

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];

		sprite3 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];

		sprite4 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_04.png"];
		[sprite4 setPosition:ccp(0,0)];
		sprite4.scale = 0.5f;

		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2 z:-2];
		[sprite1 addChild:sprite3 z:-2];
		[sprite1 addChild:sprite4 z:3];

		point = [CCSprite spriteWithFile:@"r1.png"];
		point.scale = 0.25f;
		point.position = sprite1.position;
		[self addChild:point z:10];
	}
	return self;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode: children + anchor";
}
@end

#pragma mark -
#pragma mark SpriteBatchNodeChildrenScale

@implementation SpriteBatchNodeChildrenScale

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini_family.plist"];

		CCNode *aParent;
		CCSprite *sprite1, *sprite2;
		id rot = [CCRotateBy actionWithDuration:10 angle:360];
		id seq = [CCRepeatForever actionWithAction:rot];

		//
		// Children + Scale using Sprite
		// Test 1
		//
		aParent = [CCNode node];
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister1.png"];
		sprite1.position = ccp( s.width/4, s.height/4);
		sprite1.scaleX = -0.5f;
		sprite1.scaleY = 2.0f;
		[sprite1 runAction:seq];


		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister2.png"];
		sprite2.position = ccp( 50,0);

		[self addChild:aParent];
		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2];


		//
		// Children + Scale using SpriteBatchNode
		// Test 2
		//

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini_family.png"];
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister1.png"];
		sprite1.position = ccp( 3*s.width/4, s.height/4);
		sprite1.scaleX = -0.5f;
		sprite1.scaleY = 2.0f;
		[sprite1 runAction: [[seq copy] autorelease]];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister2.png"];
		sprite2.position = ccp( 50,0);

		[self addChild:aParent];
		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2];


		//
		// Children + Scale using Sprite
		// Test 3
		//

		aParent = [CCNode node];
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister1.png"];
		sprite1.position = ccp( s.width/4, 2*s.height/3);
		sprite1.scaleX = 1.5f;
		sprite1.scaleY = -0.5f;
		[sprite1 runAction: [[seq copy] autorelease]];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister2.png"];
		sprite2.position = ccp( 50,0);

		[self addChild:aParent];
		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2];

		//
		// Children + Scale using Sprite
		// Test 4
		//

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini_family.png"];
		sprite1 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister1.png"];
		sprite1.position = ccp( 3*s.width/4, 2*s.height/3);
		sprite1.scaleX = 1.5f;
		sprite1.scaleY = -0.5f;
		[sprite1 runAction: [[seq copy] autorelease]];

		sprite2 = [CCSprite spriteWithSpriteFrameName:@"grossinis_sister2.png"];
		sprite2.position = ccp( 50,0);

		[self addChild:aParent];
		[aParent addChild:sprite1];
		[sprite1 addChild:sprite2];

	}
	return self;
}

-(NSString *) title
{
	return @"Sprite/Batch + child + scale + rot";
}
@end

#pragma mark -
#pragma mark SpriteChildrenChildren

@implementation SpriteChildrenChildren

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist"];

		CCNode *aParent;
		CCSprite *l1, *l2a, *l2b, *l3a1, *l3a2, *l3b1, *l3b2;
		id rot = [CCRotateBy actionWithDuration:10 angle:360];
		id seq = [CCRepeatForever actionWithAction:rot];

		id rot_back = [rot reverse];
		id rot_back_fe = [CCRepeatForever actionWithAction:rot_back];

		//
		// SpriteBatchNode: 3 levels of children
		//

		aParent = [CCNode node];
		[self addChild:aParent];


		// parent
		l1 = [CCSprite spriteWithSpriteFrameName:@"father.gif"];
		l1.position = ccp( s.width/2, s.height/2);
		[l1 runAction: [[seq copy] autorelease]];
		[aParent addChild:l1];
		CGSize l1Size = [l1 contentSize];

		// child left
		l2a = [CCSprite spriteWithSpriteFrameName:@"sister1.gif"];
		l2a.position = ccp( -50 + l1Size.width/2, 0 + l1Size.height/2);
		[l2a runAction: [[rot_back_fe copy] autorelease]];
		[l1 addChild:l2a];
		CGSize l2aSize = [l2a contentSize];


		// child right
		l2b = [CCSprite spriteWithSpriteFrameName:@"sister2.gif"];
		l2b.position = ccp( +50 + l1Size.width/2, 0 + l1Size.height/2);
		[l2b runAction: [[rot_back_fe copy] autorelease]];
		[l1 addChild:l2b];
		CGSize l2bSize = [l2a contentSize];


		// child left bottom
		l3a1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a1.scale = 0.45f;
		l3a1.position = ccp(0+l2aSize.width/2,-100+l2aSize.height/2);
		[l2a addChild:l3a1];

		// child left top
		l3a2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a2.scale = 0.45f;
		l3a2.position = ccp(0+l2aSize.width/2,+100+l2aSize.height/2);
		[l2a addChild:l3a2];

		// child right bottom
		l3b1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b1.scale = 0.45f;
		l3b1.flipY = YES;
		l3b1.position = ccp(0+l2bSize.width/2,-100+l2bSize.height/2);
		[l2b addChild:l3b1];

		// child right top
		l3b2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b2.scale = 0.45f;
		l3b2.flipY = YES;
		l3b2.position = ccp(0+l2bSize.width/2,+100+l2bSize.height/2);
		[l2b addChild:l3b2];

	}
	return self;
}

-(NSString *) title
{
	return @"Sprite";
}

-(NSString *) subtitle
{
	return @"Multiple levels of children: Grandparent, parent and child";
}
@end

#pragma mark -
#pragma mark SpriteBatchNodeChildrenChildren

@implementation SpriteBatchNodeChildrenChildren

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist"];

		CCSpriteBatchNode *aParent;
		CCSprite *l1, *l2a, *l2b, *l3a1, *l3a2, *l3b1, *l3b2;
		id rot = [CCRotateBy actionWithDuration:10 angle:360];
		id seq = [CCRepeatForever actionWithAction:rot];

		id rot_back = [rot reverse];
		id rot_back_fe = [CCRepeatForever actionWithAction:rot_back];

		//
		// SpriteBatchNode: 3 levels of children
		//

		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];
		[[aParent texture] generateMipmap];
		[self addChild:aParent];

		// parent
		l1 = [CCSprite spriteWithSpriteFrameName:@"father.gif"];
		l1.position = ccp( s.width/2, s.height/2);
		[l1 runAction: [[seq copy] autorelease]];
		[aParent addChild:l1];
		CGSize l1Size = [l1 contentSize];

		// child left
		l2a = [CCSprite spriteWithSpriteFrameName:@"sister1.gif"];
		l2a.position = ccp( -50 + l1Size.width/2, 0 + l1Size.height/2);
		[l2a runAction: [[rot_back_fe copy] autorelease]];
		[l1 addChild:l2a];
		CGSize l2aSize = [l2a contentSize];


		// child right
		l2b = [CCSprite spriteWithSpriteFrameName:@"sister2.gif"];
		l2b.position = ccp( +50 + l1Size.width/2, 0 + l1Size.height/2);
		[l2b runAction: [[rot_back_fe copy] autorelease]];
		[l1 addChild:l2b];
		CGSize l2bSize = [l2a contentSize];


		// child left bottom
		l3a1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a1.scale = 0.45f;
		l3a1.position = ccp(0+l2aSize.width/2,-100+l2aSize.height/2);
		[l2a addChild:l3a1];

		// child left top
		l3a2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a2.scale = 0.45f;
		l3a2.position = ccp(0+l2aSize.width/2,+100+l2aSize.height/2);
		[l2a addChild:l3a2];

		// child right bottom
		l3b1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b1.scale = 0.45f;
		l3b1.flipY = YES;
		l3b1.position = ccp(0+l2bSize.width/2,-100+l2bSize.height/2);
		[l2b addChild:l3b1];

		// child right top
		l3b2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b2.scale = 0.45f;
		l3b2.flipY = YES;
		l3b2.position = ccp(0+l2bSize.width/2,+100+l2bSize.height/2);
		[l2b addChild:l3b2];

	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatchNode";
}

-(NSString *) subtitle
{
	return @"Multiple levels of children: Grandparent, parent and child";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeSkewNegativeScaleChildren

@implementation SpriteBatchNodeSkewNegativeScaleChildren

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];

		for(int i=0;i<2;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			// Skew
			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			if(i == 1)
			{
				[sprite setScale:-1.0f];
			}

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			CCSprite *child1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			[child1 setPosition: ccp(sprite.contentSize.width / 2.0f, sprite.contentSize.height / 2.0f)];

			[child1 setScale:0.8];

			[sprite addChild: child1];

			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}

- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode + children + skew";
}

-(NSString *) subtitle
{
	return @"SpriteBatchNode skew + negative scale with children";
}
@end

#pragma mark -
#pragma mark Example SpriteBatchNodeSkewNegativeScaleChildren

@implementation SpriteBatchNodeRotationalSkewNegativeScaleChildren

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
    
		CCSpriteBatchNode *spritebatch = [CCSpriteBatchNode batchNodeWithFile:@"animations/grossini.pvr.gz"];
		[self addChild:spritebatch];
    
		for(int i=0;i<2;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			// Skew
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			if(i == 1)
			{
				[sprite setScale:-1.0f];
			}
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			CCSprite *child1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			[child1 setPosition: ccp(sprite.contentSize.width / 2.0f, sprite.contentSize.height / 2.0f)];
      
			[child1 setScale:0.8];
      
			[sprite addChild: child1];
      
			[spritebatch addChild:sprite z:i];
		}
	}
	return self;
}

- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"SpriteBatchNode + children + rot skew";
}

-(NSString *) subtitle
{
	return @"SpriteBatchNode rot skew + negative scale with children";
}
@end

#pragma mark -
#pragma mark Example SpriteSkewNegativeScaleChildren

@implementation SpriteSkewNegativeScaleChildren

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];

		CCNode *parent = [CCNode node];
		[self addChild:parent];

		for(int i=0;i<2;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			// Skew
			id skewX = [CCSkewBy actionWithDuration:2 skewX:45 skewY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCSkewBy actionWithDuration:2 skewX:0 skewY:45];
			id skewY_back = [skewY reverse];

			if(i == 1)
			{
				[sprite setScale:-1.0f];
			}

			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];

			CCSprite *child1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			[child1 setPosition: ccp(sprite.contentSize.width / 2.0f, sprite.contentSize.height / 2.0f)];

			[sprite addChild: child1];

			[child1 setScale:0.8f];

			[parent addChild:sprite z:i];
		}
	}
	return self;
}

- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite + children + skew";
}

-(NSString *) subtitle
{
	return @"Sprite skew + negative scale with children";
}
@end


#pragma mark -
#pragma mark Example SpriteSkewNegativeScaleChildren

@implementation SpriteRotationalSkewNegativeScaleChildren

-(id) init
{
	if( (self=[super init]) ) {
    
		CGSize s = [[CCDirector sharedDirector] winSize];
    
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[cache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[cache addSpriteFramesWithFile:@"animations/grossini_gray.plist" textureFilename:@"animations/grossini_gray.png"];
    
		CCNode *parent = [CCNode node];
		[self addChild:parent];
    
		for(int i=0;i<2;i++) {
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);
      
			// Skew
			id skewX = [CCRotateBy actionWithDuration:2 angleX:45 angleY:0];
			id skewX_back = [skewX reverse];
			id skewY = [CCRotateBy actionWithDuration:2 angleX:0 angleY:45];
			id skewY_back = [skewY reverse];
      
			if(i == 1)
			{
				[sprite setScale:-1.0f];
			}
      
			id seq_skew = [CCSequence actions:skewX, skewX_back, skewY, skewY_back, nil];
			[sprite runAction:[CCRepeatForever actionWithAction:seq_skew]];
      
			CCSprite *child1 = [CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"];
			[child1 setPosition: ccp(sprite.contentSize.width / 2.0f, sprite.contentSize.height / 2.0f)];
      
			[sprite addChild: child1];
      
			[child1 setScale:0.8f];
      
			[parent addChild:sprite z:i];
		}
	}
	return self;
}

- (void) dealloc
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache removeSpriteFramesFromFile:@"animations/grossini.plist"];
	[cache removeSpriteFramesFromFile:@"animations/grossini_gray.plist"];
	[super dealloc];
}

-(NSString *) title
{
	return @"Sprite + children + rot skew";
}

-(NSString *) subtitle
{
	return @"Sprite rot skew + negative scale with children";
}
@end

#pragma mark -
#pragma mark SpriteNilTexture

@implementation SpriteNilTexture

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite = nil;

		// TEST: If no texture is given, then Opacity + Color should work.

		sprite = [CCSprite node];
		[sprite setTextureRect:CGRectMake(0, 0, 300,300)];
		[sprite setColor:ccRED];
		[sprite setOpacity:128];
		[sprite setPosition:ccp(3*s.width/4, s.height/2)];
		[self addChild:sprite z:100];

		sprite = [CCSprite node];
		[sprite setTextureRect:CGRectMake(0, 0, 300,300)];
		[sprite setColor:ccBLUE];
		[sprite setOpacity:128];
		[sprite setPosition:ccp(1*s.width/4, s.height/2)];
		[self addChild:sprite z:100];
	}
	return self;
}

-(NSString *) title
{
	return @"Sprite without texture";
}

-(NSString*) subtitle
{
	return @"opacity and color should work";
}
@end

#pragma mark -
#pragma mark SpriteSubclass

@interface MySprite1 : CCSprite
{
	int ivar1;
}
@end

@implementation MySprite1
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {
		ivar1 = 10;
	}

	return self;
}
@end


@interface MySprite2 : CCSprite
{
	int ivar1;
}
@end
@implementation MySprite2
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {
		ivar1 = 10;
	}

	return self;
}
@end

@implementation SpriteSubclass

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist"];

		CCSpriteBatchNode *aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];

		// MySprite1
		MySprite1 *sprite = [MySprite1 spriteWithSpriteFrameName:@"father.gif"];
		sprite.position = ccp( s.width/4*1, s.height/2);
		[aParent addChild:sprite];

		[self addChild:aParent];


		// MySprite2
		MySprite2 *sprite2 = [MySprite2 spriteWithFile:@"grossini.png"];
		[self addChild:sprite2];
		sprite2.position = ccp(s.width/4*3, s.height/2);

		NSLog(@"MySprite1: %@", sprite);
		NSLog(@"MySprite2: %@", sprite2);

	}
	return self;
}

-(NSString *) title
{
	return @"Sprite subclass";
}

-(NSString*) subtitle
{
	return @"Testing initWithTexture:rect method";
}
@end

#pragma mark -
#pragma mark SpriteSubclass

@interface DoubleSprite : CCSprite
{
	BOOL isHD_;
}
@end

@implementation DoubleSprite
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	if( (self=[super initWithTexture:texture rect:rect]) ) {

#ifdef __CC_PLATFORM_IOS
		ccResolutionType resolutionType = [texture resolutionType];
		isHD_ = ( resolutionType == kCCResolutioniPhoneRetinaDisplay || resolutionType == kCCResolutioniPadRetinaDisplay );
#endif
	}

	return self;
}

// Called everytime the vertex needs to be updated.
-(void) setContentSize:(CGSize)size
{
	// If Retina Display and Texture is in HD then scale the vertex rect
	if( CC_CONTENT_SCALE_FACTOR() == 2 && ! isHD_ ) {
		size.width *= 2;
		size.height *= 2;
	}

	[super setContentSize:size];
}

// rect used only for the vertex. Called everytime the vertex needs to be updated.
-(void) setVertexRect:(CGRect)rect
{
	// If Retina Display and Texture is in HD then scale the vertex rect
	if( CC_CONTENT_SCALE_FACTOR() == 2 && ! isHD_ ) {
		rect.size.width *= 2;
		rect.size.height *= 2;
	}

	[super setVertexRect:rect];
}
@end

@implementation SpriteDoubleResolution

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		//
		// LEFT: SD sprite
		//
		// there is no HD resolution file of grossini_dance_08.
		DoubleSprite *spriteSD = [DoubleSprite spriteWithFile:@"grossini_dance_08.png"];
		[self addChild:spriteSD];
		[spriteSD setPosition:ccp(s.width/4*1,s.height/2)];

		CCSprite *child1_left = [DoubleSprite spriteWithFile:@"grossini_dance_08.png"];
		[spriteSD addChild:child1_left];
		[child1_left setPosition:ccp(-30,0)];

		CCSprite *child1_right = [CCSprite spriteWithFile:@"grossini.png"];
		[spriteSD addChild:child1_right];
		[child1_left setPosition:ccp( spriteSD.contentSize.height, 0)];



		//
		// RIGHT: HD sprite
		//
		// there is an HD version of grossini.png
		CCSprite *spriteHD = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:spriteHD];
		[spriteHD setPosition:ccp(s.width/4*3,s.height/2)];

		CCSprite *child2_left = [DoubleSprite spriteWithFile:@"grossini_dance_08.png"];
		[spriteHD addChild:child2_left];
		[child2_left setPosition:ccp(-30,0)];

		CCSprite *child2_right = [CCSprite spriteWithFile:@"grossini.png"];
		[spriteHD addChild:child2_right];
		[child2_left setPosition:ccp( spriteHD.contentSize.height, 0)];



		// Actions
		id scale = [CCScaleBy actionWithDuration:2 scale:0.5];
		id scale_back = [scale reverse];
		id seq = [CCSequence actions:scale, scale_back, nil];

		id seq_copy = [[seq copy] autorelease];

		[spriteSD runAction:seq];
		[spriteHD runAction:seq_copy];


	}
	return self;
}

-(NSString *) title
{
	return @"Sprite Double resolution";
}

-(NSString*) subtitle
{
	return @"Retina Display. SD (left) should be equal to HD (right)";
}
@end


#pragma mark -
#pragma mark AnimationCache

@implementation AnimationCache


-(id) init
{
	if( (self=[super init]) ) {

		CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[frameCache addSpriteFramesWithFile:@"animations/grossini_gray.plist"];
		[frameCache addSpriteFramesWithFile:@"animations/grossini_blue.plist"];

		//
		// create animation "dance"
		//
		NSMutableArray *animFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {

			CCSpriteFrame *frame = [frameCache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",i]];
			[animFrames addObject:frame];
		}

		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.2f];

		// Add an animation to the Cache
		[[CCAnimationCache sharedAnimationCache] addAnimation:animation name:@"dance"];


		//
		// create animation "dance gray"
		//
		[animFrames removeAllObjects];

		for(int i = 1; i < 15; i++) {

			CCSpriteFrame *frame = [frameCache spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_gray_%02d.png",i]];
			[animFrames addObject:frame];
		}

		animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.2f];

		// Add an animation to the Cache
		[[CCAnimationCache sharedAnimationCache] addAnimation:animation name:@"dance_gray"];

		//
		// create animation "dance blue"
		//
		[animFrames removeAllObjects];

		for(int i = 1; i < 4; i++) {

			CCSpriteFrame *frame = [frameCache spriteFrameByName:[NSString stringWithFormat:@"grossini_blue_%02d.png",i]];
			[animFrames addObject:frame];
		}

		animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.2f];

		// Add an animation to the Cache
		[[CCAnimationCache sharedAnimationCache] addAnimation:animation name:@"dance_blue"];


		CCAnimationCache *animCache = [CCAnimationCache sharedAnimationCache];

		CCAnimation *normal = [animCache animationByName:@"dance"];
		normal.restoreOriginalFrame = YES;
		CCAnimation *dance_grey = [animCache animationByName:@"dance_gray"];
		dance_grey.restoreOriginalFrame = YES;
		CCAnimation *dance_blue = [animCache animationByName:@"dance_blue"];
		dance_blue.restoreOriginalFrame = YES;

		CCAnimate *animN = [CCAnimate actionWithAnimation:normal];
		CCAnimate *animG = [CCAnimate actionWithAnimation:dance_grey];
		CCAnimate *animB = [CCAnimate actionWithAnimation:dance_blue];

		CCSequence *seq = [CCSequence actions:animN, animG, animB, nil];

		// create an sprite without texture
		CCSprite *grossini = [CCSprite node];
		CCSpriteFrame *frame = [frameCache spriteFrameByName:@"grossini_dance_01.png"];
		[grossini setDisplayFrame:frame];

		CGSize winSize = [[CCDirector sharedDirector] winSize];

		grossini.position = ccp(winSize.width/2, winSize.height/2);

		[self addChild:grossini];


		// run the animation
		[grossini runAction:seq];

	}

	return self;

}

-(NSString *) title
{
	return @"AnimationCache";
}

-(NSString*) subtitle
{
	return @"Sprite should be animated";
}

@end

#pragma mark -
#pragma mark AnimationCacheFile

@implementation AnimationCacheFile


-(id) init
{
	if( (self=[super init]) ) {

		CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"animations/grossini.plist"];
		[frameCache addSpriteFramesWithFile:@"animations/grossini_gray.plist"];
		[frameCache addSpriteFramesWithFile:@"animations/grossini_blue.plist"];


		// Purge previously loaded animation
		[CCAnimationCache purgeSharedAnimationCache];

		CCAnimationCache *animCache = [CCAnimationCache sharedAnimationCache];

		// Add an animation to the Cache
		[animCache addAnimationsWithFile:@"animations/animations.plist"];


		CCAnimation *normal = [animCache animationByName:@"dance_1"];
		normal.restoreOriginalFrame = YES;
		CCAnimation *dance_grey = [animCache animationByName:@"dance_2"];
		dance_grey.restoreOriginalFrame = YES;
		CCAnimation *dance_blue = [animCache animationByName:@"dance_3"];
		dance_blue.restoreOriginalFrame = YES;

		CCAnimate *animN = [CCAnimate actionWithAnimation:normal];
		CCAnimate *animG = [CCAnimate actionWithAnimation:dance_grey];
		CCAnimate *animB = [CCAnimate actionWithAnimation:dance_blue];

		CCSequence *seq = [CCSequence actions:animN, animG, animB, nil];

		// create an sprite without texture
		CCSprite *grossini = [CCSprite node];

		CCSpriteFrame *frame = [frameCache spriteFrameByName:@"grossini_dance_01.png"];
		[grossini setDisplayFrame:frame];

		CGSize winSize = [[CCDirector sharedDirector] winSize];

		grossini.position = ccp(winSize.width/2, winSize.height/2);

		[self addChild:grossini];


		// run the animation
		[grossini runAction:seq];

	}

	return self;

}

-(NSString *) title
{
	return @"AnimationCache - Load file";
}

-(NSString*) subtitle
{
	return @"Sprite should be animated";
}

@end

#pragma mark - SpriteBatchBug1217

@implementation SpriteBatchBug1217
-(id) init
{
	if( (self=[super init]) ) {
		
		CCSpriteBatchNode *bn = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:15];
		
		CCSprite * s1 = [CCSprite spriteWithTexture:bn.texture rect:CGRectMake(0, 0, 57, 57)];
		CCSprite * s2 = [CCSprite spriteWithTexture:bn.texture rect:CGRectMake(0, 0, 57, 57)];
		CCSprite * s3 = [CCSprite spriteWithTexture:bn.texture rect:CGRectMake(0, 0, 57, 57)];
		
		s1.color = ccc3(255, 0, 0);
		s2.color = ccc3(0, 255, 0);
		s3.color = ccc3(0, 0, 255);
		
		s1.position = ccp(20,200);
		s2.position = ccp(100,0);
		s3.position = ccp(100,0);
		
		bn.position = ccp(0,0);
		
		//!!!!!
		[s1 addChild:s2];
		[s2 addChild:s3];
		[bn addChild:s1];
		
		[self addChild:bn];
	}
	return self;
}

-(NSString *) title
{
	return @"SpriteBatch - Bug 1217";
}

-(NSString*) subtitle
{
	return @"Adding big family to spritebatch. You shall see 3 heads";
}

@end


#pragma mark - AppDelegate - iOS

// CLASS IMPLEMENTATIONS

#ifdef __CC_PLATFORM_IOS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:4];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;
	// Display Milliseconds Per Frame
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];

	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene:scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ pushScene:scene];
	[director_ startAnimation];
}
@end
#endif
