//
// Anchor Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// cocos import
#import "cocos2d.h"

enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
};

// local import
#import "TestAnchor.h"
static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Anchor1",
			@"Anchor2",
			@"Anchor3",
			@"Anchor4",
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


@implementation AnchorDemo
-(id) init
{
	[super init];

	grossini = [[Sprite spriteWithFile:@"grossini.png"] retain];
	tamara = [[Sprite spriteWithFile:@"grossinis_sister1.png"] retain];
	
	[self addChild: grossini z:1];
	[self addChild: tamara z:2];

	CGSize s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(60, s.height/3)];
	[tamara setPosition: cpv(60, 2*s.height/3)];
	
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

	return self;
}

-(void) dealloc
{
	[grossini release];
	[tamara release];
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

-(void) centerSprites
{
	CGSize s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(s.width/3, s.height/2)];
	[tamara setPosition: cpv(2*s.width/3, s.height/2)];
}
-(NSString*) title
{
	return @"No title";
}
@end

@implementation Anchor1
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];

	id action1 = [RepeatForever actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [RepeatForever actionWithAction:
				  [Sequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	tamara.transformAnchor = cpvzero;
	
	[tamara runAction: action1];
	[grossini runAction:action2];
}
-(NSString *) title
{
	return @"transformAnchor";
}
@end

@implementation Anchor2
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];

	Sprite *sp1 = [Sprite spriteWithFile:@"grossini.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	
	sp1.scale = 0.25f;
	sp2.scale = 0.25f;
	
	[tamara addChild:sp1];
	[grossini addChild:sp2];
	
	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];
	
	id action1 = [RepeatForever actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [RepeatForever actionWithAction:
				  [Sequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	tamara.transformAnchor = cpvzero;
	
	[tamara runAction: action1];
	[grossini runAction:action2];	
}
-(NSString *) title
{
	return @"transformAnchor and children";
}
@end

@implementation Anchor3
-(void) onEnter
{
	[super onEnter];

	tamara.visible = NO;

	[self centerSprites];
	
	Sprite *sp1 = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	Sprite *sp2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = cpv(20,80);
	sp2.position = cpv(70,50);
	
	[grossini addChild:sp1 z:-1 tag:kTagSprite1];
	[grossini addChild:sp2 z:1 tag:kTagSprite2];
	
	id a1 = [RotateBy actionWithDuration:4 angle:360];
	id action1 = [RepeatForever actionWithAction:a1];
	[grossini runAction:action1];	
	
	[self schedule:@selector(changeZOrder:) interval:2.0f];
}

-(void) changeZOrder:(ccTime) dt
{
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

@implementation Anchor4
-(id) init
{
	if( !( self=[super init]) )
		return nil;
	
	// ignore these lines
	// they are not part of the tag test
	grossini.visible = NO;
	tamara.visible = NO;
	
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
	[self removeByTag:3];
}


-(NSString *) title
{
	return @"tags";
}
@end


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
