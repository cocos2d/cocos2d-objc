//
// cocos node tests
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// cocos import
#import "cocos2d.h"

// local import
#import "cocosnodeTest.h"

enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
	kTagSprite3 = 3,
};


static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Test1",
			@"Test2",
			@"Test3",
			@"Test4",
			@"Test5",
			@"Test6",
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


@implementation TestDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[Director sharedDirector] winSize];
	
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: cpv(s.width/2, s.height-50)];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
		menu.position = cpvzero;
		item1.position = cpv( s.width/2 - 100,30);
		item2.position = cpv( s.width/2, 30);
		item3.position = cpv( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

@implementation Test1
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = cpv(100, s.height /2 );
	sp2.position = cpv(380, s.height /2 );
	
	[self addChild: sp1];
	[self addChild: sp2];
	

	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];

	id action1 = [RepeatForever actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [RepeatForever actionWithAction:
				  [Sequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	sp2.transformAnchor = cpvzero;
	
	[sp1 runAction: action1];
	[sp2 runAction:action2];
}
-(NSString *) title
{
	return @"transformAnchor";
}
@end

@implementation Test2
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	Sprite *sp3 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp4 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = cpv(100, s.height /2 );
	sp2.position = cpv(380, s.height /2 );
	[self addChild: sp1];
	[self addChild: sp2];
	
	sp3.scale = 0.25f;
	sp4.scale = 0.25f;
	
	[sp1 addChild:sp3];
	[sp2 addChild:sp4];
	
	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];
	
	id action1 = [RepeatForever actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [RepeatForever actionWithAction:
				  [Sequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	sp2.transformAnchor = cpvzero;
	
	[sp1 runAction:action1];
	[sp2 runAction:action2];	
}
-(NSString *) title
{
	return @"transformAnchor and children";
}
@end

@implementation Test3
-(void) onEnter
{
	[super onEnter];

	
	CGSize s = [[Director sharedDirector] winSize];

	Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	Sprite *sp3 = [Sprite spriteWithFile:@"grossini.png"];
	
	sp1.position = cpv(20,80);
	sp2.position = cpv(70,50);
	sp3.position = cpv(s.width/2, s.height/2);
	
	// these tags belong to sp3 (kTagSprite1, kTagSprite2)
	[sp3 addChild:sp1 z:-1 tag:kTagSprite1];
	[sp3 addChild:sp2 z:1 tag:kTagSprite2];
	
	// this tag belong to Test3 (kTagSprite1)
	[self addChild:sp3 z:0 tag:kTagSprite1];
	
	id a1 = [RotateBy actionWithDuration:4 angle:360];
	id action1 = [RepeatForever actionWithAction:a1];
	[sp3 runAction:action1];	
	
	[self schedule:@selector(changeZOrder:) interval:2.0f];
}

-(void) changeZOrder:(ccTime) dt
{
	CocosNode *grossini = [self getChildByTag:kTagSprite1];

	CocosNode *sprite1 = [grossini getChildByTag:kTagSprite1];
	CocosNode *sprite2 = [grossini getChildByTag:kTagSprite2];
	
	int zt = sprite1.zOrder;
	[grossini reorderChild:sprite1 z:sprite2.zOrder];
	[grossini reorderChild:sprite2 z:zt];
}

-(NSString *) title
{
	return @"z order";
}
@end

@implementation Test4
-(id) init
{
	if( !( self=[super init]) )
		return nil;
		
	Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = cpv(100,160);
	sp2.position = cpv(380,160);
	
	[self addChild:sp1 z:0 tag:2];
	[self addChild:sp2 z:0 tag:3];
	
	[self schedule:@selector(delay2:) interval:2.0f];
	[self schedule:@selector(delay4:) interval:4.0f];
	
	return self;
}

-(void) delay2:(ccTime) dt
{
	id node = [self getChildByTag:2];
	id action1 = [RotateBy actionWithDuration:1 angle:360];
	[node runAction:action1];
}

-(void) delay4:(ccTime) dt
{
	[self unschedule:_cmd];
	[self removeChildByTag:3 cleanup:NO];
}


-(NSString *) title
{
	return @"tags";
}
@end

@implementation Test5
-(id) init
{
	if( ( self=[super init]) ) {

		Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
		Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = cpv(100,160);
		sp2.position = cpv(380,160);

		id rot = [RotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever = [RepeatForever actionWithAction:
						[Sequence actions:rot, rot_back, nil]];
		id forever2 = [[forever copy] autorelease];
													  
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[self addChild:sp2 z:0 tag:kTagSprite2];
		
		[sp1 runAction:forever];
		[sp2 runAction:forever2];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CocosNode *sp1 = [self getChildByTag:kTagSprite1];
	CocosNode *sp2 = [self getChildByTag:kTagSprite2];

	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];

}


-(NSString *) title
{
	return @"remove and cleanup";
}
@end

@implementation Test6
-(id) init
{
	if( ( self=[super init]) ) {
		
		Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
		Sprite *sp11 = [Sprite spriteWithFile:@"grossinis_sister1.png"];

		Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
		Sprite *sp21 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = cpv(100,160);
		sp2.position = cpv(380,160);
		
		
		id rot = [RotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever1 = [RepeatForever actionWithAction:
					  [Sequence actions:rot, rot_back, nil]];
		id forever11 = [[forever1 copy] autorelease];

		id forever2 = [[forever1 copy] autorelease];
		id forever21 = [[forever1 copy] autorelease];
		
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[sp1 addChild:sp11];
		[self addChild:sp2 z:0 tag:kTagSprite2];
		[sp2 addChild:sp21];
		
		[sp1 runAction:forever1];
		[sp11 runAction:forever11];
		[sp2 runAction:forever2];
		[sp21 runAction:forever21];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CocosNode *sp1 = [self getChildByTag:kTagSprite1];
	CocosNode *sp2 = [self getChildByTag:kTagSprite2];
	
	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];
}


-(NSString *) title
{
	return @"remove/cleanup with children";
}
@end


#pragma mark AppController

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
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
			 
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
