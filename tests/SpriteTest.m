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
			@"SpriteSheet1",
			@"SpriteFrameTest",
			@"SpriteOffsetAnchor",
			@"SpriteSheetOffsetAnchor",
			@"SpriteAnimationSplit",
			@"SpriteColorOpacity",
			@"SpriteSheetColorOpacity",
			@"SpriteZOrder",
			@"SpriteSheetZOrder",
			@"SpriteZVertex",
			@"SpriteSheetZVertex",
			@"SpriteAnchorPoint",
			@"SpriteSheetAnchorPoint",
			@"Sprite6",
			@"SpriteFlip",
			@"SpriteSheetFlip",
			@"SpriteAliased",
			@"SpriteSheetAliased",
			@"SpriteNewTexture",
			@"SpriteSheetNewTexture",
			@"SpriteHybrid",
			@"SpriteSheetChildren",
			@"SpriteSheetChildren2",
			@"SpriteSheetChildrenZ",
			@"SpriteChildrenVisibility",
};

enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagNode = 2,
	kTagAnimation1 = 1,
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


@implementation SpriteDemo
-(id) init
{
	if( (self = [super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];
			
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
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
@end

#pragma mark -
#pragma mark Example Sprite 1


@implementation Sprite1

-(id) init
{
	if( (self=[super init]) ) {
		
		self.isTouchEnabled = YES;
		
		
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

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteWithCoords: location];
	}
	return kEventHandled;
}

-(NSString *) title
{
	return @"Sprite (tap screen)";
}
@end

@implementation SpriteSheet1

-(id) init
{
	if( (self=[super init]) ) {
		
		self.isTouchEnabled = YES;

		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:50];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		[self addNewSpriteWithCoords:ccp(s.width/2, s.height/2)];
		
	}	
	return self;
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;
	

	CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(x,y,85,121)];
	[sheet addChild:sprite];

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

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteWithCoords: location];
	}
	return kEventHandled;
}

-(NSString *) title
{
	return @"SpriteSheet (tap screen)";
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

@implementation SpriteSheetColorOpacity

-(id) init
{
	if( (self=[super init]) ) {
		
		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];		
		
		CCSprite *sprite1 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite2 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite3 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite4 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*3, 121*1, 85, 121)];
		
		CCSprite *sprite5 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
		CCSprite *sprite6 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		CCSprite *sprite7 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*2, 121*1, 85, 121)];
		CCSprite *sprite8 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*3, 121*1, 85, 121)];
		
		
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
		[sheet addChild:sprite1 z:0 tag:kTagSprite1];
		[sheet addChild:sprite2 z:0 tag:kTagSprite2];
		[sheet addChild:sprite3 z:0 tag:kTagSprite3];
		[sheet addChild:sprite4 z:0 tag:kTagSprite4];
		[sheet addChild:sprite5 z:0 tag:kTagSprite5];
		[sheet addChild:sprite6 z:0 tag:kTagSprite6];
		[sheet addChild:sprite7 z:0 tag:kTagSprite7];
		[sheet addChild:sprite8 z:0 tag:kTagSprite8];
		
		
		[self schedule:@selector(removeAndAddSprite:) interval:2];
		
	}	
	return self;
}

// this function test if remove and add works as expected:
//   color array and vertex array should be reindexed
-(void) removeAndAddSprite:(ccTime) dt
{
	id sheet = [self getChildByTag:kTagSpriteSheet];
	id sprite = [sheet getChildByTag:kTagSprite5];
	
	[sprite retain];

	[sheet removeChild:sprite cleanup:NO];
	[sheet addChild:sprite z:0 tag:kTagSprite5];
	
	[sprite release];
}

-(NSString *) title
{
	return @"SpriteSheet: Color & Opacity";
}
@end

#pragma mark -
#pragma mark Example Sprite Z Order

@implementation SpriteZOrder

-(id) init
{
	if( (self=[super init]) ) {
		
		dir = 1;
				
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			[self addChild:sprite z:i];
		}
		
		for(int i=5;i<10;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
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
	
	int z = [sprite zOrder];
	
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

@implementation SpriteSheetZOrder

-(id) init
{
	if( (self=[super init]) ) {
		
		dir = 1;
		
		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];		
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			[sheet addChild:sprite z:i];
		}
		
		for(int i=5;i<10;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			[sheet addChild:sprite z:14-i];
		}
		
		CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*3, 121*0, 85, 121)];
		[sheet addChild:sprite z:-1 tag:kTagSprite1];
		sprite.position = ccp(s.width/2, s.height/2 - 20);
		sprite.scaleX = 6;
		[sprite setColor:ccRED];
		
		[self schedule:@selector(reorderSprite:) interval:1];		
	}	
	return self;
}

-(void) reorderSprite:(ccTime) dt
{
	id sheet = [self getChildByTag:kTagSpriteSheet];
	id sprite = [sheet getChildByTag:kTagSprite1];
	
	int z = [sprite zOrder];
	
	if( z < -1 )
		dir = 1;
	if( z > 10 )
		dir = -1;
	
	z += dir * 3;

	[sheet reorderChild:sprite z:z];
	
}

-(NSString *) title
{
	return @"SpriteSheet: Z order";
}
@end

#pragma mark -
#pragma mark Example SpriteZVertex

@implementation SpriteZVertex

-(id) init
{
	if( (self=[super init]) ) {
		
		//
		// This test tests z-order
		// If you are going to use it is better to use a 2D projection
		//
		// WARNING:
		// The developer is resposible for ordering it's sprites according to it's Z if the sprite has
		// transparent parts.
		//
		
		dir = 1;
		time = 0;

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCNode *node = [CCNode node];
		[self addChild:node z:0];

		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			sprite.vertexZ = 10 + i*40;
			[node addChild:sprite z:0];
			
		}
		
		for(int i=5;i<11;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			sprite.vertexZ = 10 + (10-i)*40;
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

@implementation SpriteSheetZVertex

-(id) init
{
	if( (self=[super init]) ) {
		
		//
		// This test tests z-order
		// If you are going to use it is better to use a 2D projection
		//
		// WARNING:
		// The developer is resposible for ordering it's sprites according to it's Z if the sprite has
		// transparent parts.
		//
		
		dir = 1;
		time = 0;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];		
		
		for(int i=0;i<5;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*0, 121*1, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			sprite.vertexZ = 10 + i*40;
			[sheet addChild:sprite z:0];
			
		}
		
		for(int i=5;i<11;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*0, 85, 121)];
			sprite.position = ccp( 50 + i*40, s.height/2);
			sprite.vertexZ = 10 + (10-i)*40;
			[sheet addChild:sprite z:0];
		}
		
		[sheet runAction:[CCOrbitCamera actionWithDuration:10 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0]];
	}	
	return self;
}

-(NSString *) title
{
	return @"SpriteSheet: openGL Z vertex";
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
			sprite.position = ccp( 90 + i*150, s.height/2);
			
			
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

@implementation SpriteSheetAnchorPoint
-(id) init
{
	if( (self=[super init]) ) {

		// small capacity. Testing resizing.
		// Don't use capacity=1 in your real game. It is expensive to resize the capacity
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		
		id rotate = [CCRotateBy actionWithDuration:10 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];
		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*i, 121*1, 85, 121)];
			sprite.position = ccp( 90 + i*150, s.height/2);

			
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
			[sheet addChild:sprite z:i];
		}		
	}	
	return self;
}

-(NSString *) title
{
	return @"SpriteSheet: anchor point";
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
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:1];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];

		CGSize s = [[CCDirector sharedDirector] winSize];

		sheet.relativeAnchorPoint = NO;
		sheet.anchorPoint = ccp(0.5f, 0.5f);
		sheet.contentSize = CGSizeMake(s.width, s.height);
		
		
		// SpriteSheet actions
		id rotate = [CCRotateBy actionWithDuration:5 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];

		// SpriteSheet actions
		id rotate_back = [rotate reverse];
		id rotate_seq = [CCSequence actions:rotate, rotate_back, nil];
		id rotate_forever = [CCRepeatForever actionWithAction:rotate_seq];
		
		id scale = [CCScaleBy actionWithDuration:5 scale:1.5f];
		id scale_back = [scale reverse];
		id scale_seq = [CCSequence actions: scale, scale_back, nil];
		id scale_forever = [CCRepeatForever actionWithAction:scale_seq];


		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*i, 121*1, 85, 121)];
			sprite.position = ccp( 90 + i*150, s.height/2);

			[sprite runAction: [[action copy] autorelease]];
			[sheet addChild:sprite z:i];
		}
		
		[sheet runAction: scale_forever];
		[sheet runAction: rotate_forever];
	}	
	return self;
}
-(NSString*) title
{
	return @"SpriteSheet transformation";
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
	id sprite1 = [self getChildByTag:kTagSprite1];
	id sprite2 = [self getChildByTag:kTagSprite2];
	
	BOOL x = [sprite1 flipX];
	BOOL y = [sprite2 flipY];
	
	[sprite1 setFlipX: !x];
	[sprite2 setFlipY: !y];
}
-(NSString*) title
{
	return @"Sprite Flip X & Y";
}
@end

@implementation SpriteSheetFlip
-(id) init
{
	if( (self=[super init]) ) {
		
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:10];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *sprite1 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[sheet addChild:sprite1 z:0 tag:kTagSprite1];
		
		CCSprite *sprite2 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[sheet addChild:sprite2 z:0 tag:kTagSprite2];
		
		[self schedule:@selector(flipSprites:) interval:1];
	}	
	return self;
}
-(void) flipSprites:(ccTime)dt
{
	id sheet = [self getChildByTag:kTagSpriteSheet];
	id sprite1 = [sheet getChildByTag:kTagSprite1];
	id sprite2 = [sheet getChildByTag:kTagSprite2];
	
	BOOL x = [sprite1 flipX];
	BOOL y = [sprite2 flipY];
	
	[sprite1 setFlipX: !x];
	[sprite2 setFlipY: !y];
}
-(NSString*) title
{
	return @"SpriteSheet Flip X & Y";
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

@implementation SpriteSheetAliased
-(id) init
{
	if( (self=[super init]) ) {
		
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:10];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
	
		CCSprite *sprite1 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite1.position = ccp( s.width/2 - 100, s.height/2 );
		[sheet addChild:sprite1 z:0 tag:kTagSprite1];
		
		CCSprite *sprite2 = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(85*1, 121*1, 85, 121)];
		sprite2.position = ccp( s.width/2 + 100, s.height/2 );
		[sheet addChild:sprite2 z:0 tag:kTagSprite2];
		
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
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	[sheet.texture setAliasTexParameters];
}

-(void) onExit
{
	// restore the tex parameter to AntiAliased.
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	[sheet.texture setAntiAliasTexParameters];
	[super onExit];
}

-(NSString*) title
{
	return @"SpriteSheet Aliased";
}
@end

#pragma mark -
#pragma mark Example SpriteSheet NewTexture

@implementation SpriteNewTexture

-(id) init
{
	if( (self=[super init]) ) {
		
		isTouchEnabled = YES;
		
		CCNode *node = [CCNode node];
		[self addChild:node z:0 tag:kTagSpriteSheet];

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
	
	
	CCNode *node = [self getChildByTag:kTagSpriteSheet];
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

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

	CCNode *node = [self getChildByTag:kTagSpriteSheet];
	if( usingTexture1 ) {
		for( CCSprite* sprite in node.children)
			[sprite setTexture:texture2];
		usingTexture1 = NO;
	} else {
		for( CCSprite* sprite in node.children)
			[sprite setTexture:texture1];
		usingTexture1 = YES;
	}

	return kEventHandled;
}

-(NSString *) title
{
	return @"Sprite New texture (tap)";
}
@end

@implementation SpriteSheetNewTexture
-(id) init
{
	if( (self=[super init]) ) {
		
		isTouchEnabled = YES;
		
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"grossini_dance_atlas.png" capacity:50];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		texture1 = [[sheet texture] retain];
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
	
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;
	
	
	CCSprite *sprite = [CCSprite spriteWithTexture:sheet.texture rect:CGRectMake(x,y,85,121)];
	[sheet addChild:sprite];
	
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

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	
	if( [sheet texture] == texture1 )
		[sheet setTexture:texture2];
	else
		[sheet setTexture:texture1];
	
	return kEventHandled;
}

-(NSString *) title
{
	return @"SpriteSheet new texture (tap)";
}
@end


#pragma mark -
#pragma mark Example SpriteSheet - SpriteFrame

@implementation SpriteFrameTest

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// IMPORTANT:
		// The sprite frames will be cached AND RETAINED, and they won't be released unless you call
		//     [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini_gray.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini_blue.plist"];

		//
		// Animation using Sprite Sheet
		//
		CCSprite *sprite = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		sprite.position = ccp( s.width/2-80, s.height/2);
		
		CCSpriteSheet *spritesheet = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png"];
		[spritesheet addChild:sprite];
		[self addChild:spritesheet];

		NSMutableArray *animFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {
			
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",i]];
			[animFrames addObject:frame];
		}

		CCAnimation *animation = [CCAnimation animationWithName:@"dance" delay:0.2f frames:animFrames];
		[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO] ]];


		//
		// Animation using standard Sprite
		//
		CCSprite *sprite2 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		sprite2.position = ccp( s.width/2 + 80, s.height/2);
		[self addChild:sprite2];
		

		NSMutableArray *moreFrames = [NSMutableArray array];
		for(int i = 1; i < 15; i++) {
			
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_gray_%02d.png",i]];
			[moreFrames addObject:frame];
		}
		for( int i = 1; i < 5; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_blue_%02d.png",i]];
			[moreFrames addObject:frame];
		}
		
		// append frames from another sheet
		[moreFrames addObjectsFromArray:animFrames];
		CCAnimation *animMixed = [CCAnimation animationWithName:@"dance" delay:0.2f frames:moreFrames];
		
		[sprite2 runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animMixed restoreOriginalFrame:NO]]];
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
	return @"Sprite vs. SpriteSheet animation";
}
@end

#pragma mark -
#pragma mark Example SpriteOffsetAnchor

@implementation SpriteOffsetAnchor

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];		
		
		for(int i=0;i<3;i++) {
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini_gray.plist"];
			
			//
			// Animation using Sprite Sheet
			//
			CCSprite *sprite = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( 90 + i*150, s.height/2);			
			
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
				
				CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithName:@"dance" delay:0.2f frames:animFrames];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO] ]];			
			[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:10 angle:360]]];

			
			[self addChild:sprite z:0];
		}		
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
	return @"Sprite offset + anchor";
}
@end

#pragma mark -
#pragma mark Example SpriteSheetOffsetAnchor

@implementation SpriteSheetOffsetAnchor

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];		
		
		for(int i=0;i<3;i++) {
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini_gray.plist"];
			
			//
			// Animation using Sprite Sheet
			//
			CCSprite *sprite = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
			sprite.position = ccp( 90 + i*150, s.height/2);			
			
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
			
			CCSpriteSheet *spritesheet = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png"];
			[self addChild:spritesheet];
			
			NSMutableArray *animFrames = [NSMutableArray array];
			for(int i = 0; i < 14; i++) {
				
				CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",(i+1)]];
				[animFrames addObject:frame];
			}
			CCAnimation *animation = [CCAnimation animationWithName:@"dance" delay:0.2f frames:animFrames];
			[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO] ]];
			[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:10 angle:360]]];
			
			[spritesheet addChild:sprite z:i];
		}		
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
	return @"SpriteSheet offset + anchor";
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
		CCSpriteFrame *frame0 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*0, 132, 132) offset:CGPointZero];
		CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*0, 132, 132) offset:CGPointZero];
		CCSpriteFrame *frame2 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*2, 132*0, 132, 132) offset:CGPointZero];
		CCSpriteFrame *frame3 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*3, 132*0, 132, 132) offset:CGPointZero];
		CCSpriteFrame *frame4 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*1, 132, 132) offset:CGPointZero];
		CCSpriteFrame *frame5 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*1, 132, 132) offset:CGPointZero];

		CCSpriteFrame *frameFlip0 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*0, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		CCSpriteFrame *frameFlip1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*0, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		CCSpriteFrame *frameFlip2 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*2, 132*0, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		CCSpriteFrame *frameFlip3 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*3, 132*0, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		CCSpriteFrame *frameFlip4 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*0, 132*1, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		CCSpriteFrame *frameFlip5 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(132*1, 132*1, 132, 132) offset:CGPointZero flipX:YES flipY:NO];
		
		
		//
		// Animation using Sprite Sheet
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
		[animFrames addObject:frameFlip0];
		[animFrames addObject:frameFlip1];
		[animFrames addObject:frameFlip2];
		[animFrames addObject:frameFlip3];
		[animFrames addObject:frameFlip4];
		[animFrames addObject:frameFlip5];
		
		CCAnimation *animation = [CCAnimation animationWithName:@"fly" delay:0.2f frames:animFrames];
		[sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO] ]];
		
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
		CCSpriteSheet *parent2 = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png" capacity:50];
		
		[self addChild:parent1 z:0 tag:kTagNode];
		[self addChild:parent2 z:0 tag:kTagSpriteSheet];
		
		
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
		
		usingSpriteSheet = NO;
		
		
		[self schedule:@selector(reparentSprite:) interval:2];
	}	
	return self;
}

-(void) reparentSprite:(ccTime)dt
{
	CCNode *p1 = [self getChildByTag:kTagNode];
	CCNode *p2 = [self getChildByTag:kTagSpriteSheet];
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:30];
	

	if( usingSpriteSheet )
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
	
	usingSpriteSheet = ! usingSpriteSheet;
}

- (void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

-(NSString *) title
{
	return @"Hybrid Sprite Test";
}
@end

#pragma mark -
#pragma mark SpriteSheet Children

@implementation SpriteSheetChildren

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// parents
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png" capacity:50];
		
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
				
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
		

		CCSprite *sprite1 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/3, s.height/2)];

		CCSprite *sprite2 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(50,50)];

		CCSprite *sprite3 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-50,-50)];
		
		[sheet addChild:sprite1];
		[sprite1 addChild:sprite2];
		[sprite1 addChild:sprite3];
		
		
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
	return @"SpriteSheet Grand Children";
}
@end

#pragma mark -
#pragma mark SpriteSheet Children2

@implementation SpriteSheetChildren2

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// parents
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png" capacity:50];
		[sheet.texture generateMipmap];
		
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
		
		
		CCSprite *sprite11 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite11 setPosition:ccp( s.width/3, s.height/2)];

		CCSprite *sprite12 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite12 setPosition:ccp(20,30)];
		sprite12.scale = 0.2f;

		CCSprite *sprite13 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite13 setPosition:ccp(-20,30)];
		sprite13.scale = 0.2f;
		
		[sheet addChild:sprite11];
		[sprite11 addChild:sprite12 z:-2];
		[sprite11 addChild:sprite13 z:2];

		// don't rotate with it's parent
		sprite12.honorParentTransform &= ~CC_HONOR_PARENT_TRANSFORM_ROTATE;

		// don't scale and rotate with it's parent
		sprite13.honorParentTransform &= ~(CC_HONOR_PARENT_TRANSFORM_SCALE | CC_HONOR_PARENT_TRANSFORM_ROTATE);
		
		id action = [CCMoveBy actionWithDuration:2 position:ccp(200,0)];
		id action_back = [action reverse];
		id action_rot = [CCRotateBy actionWithDuration:2 angle:360];
		id action_s = [CCScaleBy actionWithDuration:2 scale:2];
		id action_s_back = [action_s reverse];

		[sprite11 runAction: [CCRepeatForever actionWithAction:action_rot]];
		[sprite11 runAction: [CCRepeatForever actionWithAction:[CCSequence actions:action, action_back, nil]]];
		[sprite11 runAction: [CCRepeatForever actionWithAction:[CCSequence actions:action_s, action_s_back, nil]]];
		
		//
		// another set of parent / children
		//
		
		CCSprite *sprite21 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite21 setPosition:ccp( 2*s.width/3, s.height/2-50)];
		
		CCSprite *sprite22 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite22 setPosition:ccp(20,30)];
		sprite22.scale = 0.8f;
		
		CCSprite *sprite23 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite23 setPosition:ccp(-20,30)];
		sprite23.scale = 0.8f;
		
		[sheet addChild:sprite21];
		[sprite21 addChild:sprite22 z:-2];
		[sprite21 addChild:sprite23 z:2];
		
		// don't rotate with it's parent
		sprite22.honorParentTransform &= ~CC_HONOR_PARENT_TRANSFORM_TRANSLATE;
		
		// don't scale and rotate with it's parent
		sprite23.honorParentTransform &= ~CC_HONOR_PARENT_TRANSFORM_SCALE;
		
		[sprite21 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:360]]];
		[sprite21 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5f scale:5.0f],[CCScaleTo	actionWithDuration:0.5f scale:1],nil]]];
		
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
	return @"SpriteSheet HonorTransform";
}
@end


#pragma mark -
#pragma mark SpriteSheet ChildrenZ

@implementation SpriteSheetChildrenZ

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// parents
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png" capacity:50];
		
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/grossini.plist"];
		
		
		CCSprite *sprite1 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp( s.width/3, s.height/2)];
		
		CCSprite *sprite2 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];
		
		CCSprite *sprite3 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];
		
		[sheet addChild:sprite1];
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
	return @"SpriteSheet Children Z";
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
		// SpriteSheet
		//
		// parents
		aParent = [CCSpriteSheet spriteSheetWithFile:@"animations/grossini.png" capacity:50];
		aParent.position = ccp(s.width/3, s.height/2);
		[self addChild:aParent z:0];
		
		
		
		sprite1 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];
		
		sprite2 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];
		
		sprite3 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];
		
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

		sprite1 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_01.png"];
		[sprite1 setPosition:ccp(0,0)];
		
//		sprite1.relativeAnchorPoint = NO;
		
		sprite2 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_02.png"];
		[sprite2 setPosition:ccp(20,30)];
		
		sprite3 = [[CCSpriteFrameCache sharedSpriteFrameCache] createSpriteWithFrameName:@"grossini_dance_03.png"];
		[sprite3 setPosition:ccp(-20,30)];
		
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
	return @"Sprite & SpriteSheet Visibility";
}
@end


#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];

	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];

	// Use this pixel format to have transparent buffers
	[[CCDirector sharedDirector] setPixelFormat:kRGBA8];
	
	// Create a depth buffer of 24 bits
	// These means that openGL z-order will be taken into account
	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer24];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
			 
	[[CCDirector sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
