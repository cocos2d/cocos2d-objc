//
// Atlas Demo
// a cocos2d example
//

// cocos import
#import "cocos2d.h"

// local import
#import "TestParallax.h"
static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Parallax1",
			@"Parallax2",
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


@implementation ParallaxDemo
-(id) init
{
	[super init];


	CGRect s = [[Director sharedDirector] winSize];
		
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label z:1];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.position = cpvzero;
	item1.position = cpv( s.size.width/2 - 100,30);
	item2.position = cpv( s.size.width/2, 30);
	item3.position = cpv( s.size.width/2 + 100,30);
	[self add: menu z:1];	

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example Parallax 1

@implementation Parallax1
-(id) init
{
	if( ![super init] )
		return nil;
	
	
	TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
	
	tilemap.transformAnchor = cpv(0, 0);
	tilemap.position = cpv(0,-200);

	Sprite *background = [Sprite spriteWithFile:@"background.png"];
	background.scale = 1.5;
	background.transformAnchor = cpv(0,0);

	Sprite *cocosImage = [Sprite spriteWithFile:@"powered.png"];
	cocosImage.scale = 2.5;
	cocosImage.transformAnchor = cpv(0,0);
	cocosImage.position = cpv(200,1000);
	
	
	CocosNode *voidNode = [CocosNode node];
	
	[voidNode add:background z:-1 parallaxRatio:cpv(0.4,0.5)];
	[voidNode add:tilemap z:1 parallaxRatio:cpv(2.2,1.0)];
	[voidNode add:cocosImage z:2 parallaxRatio:cpv(3.0,2.5)];
	
	id goUp = [MoveBy actionWithDuration:4 position:cpv(0,-500)];
	id goDown = [goUp reverse];
	id go = [MoveBy actionWithDuration:8 position:cpv(-1000,0)];
	id goBack = [go reverse];
	id seq = [Sequence actions:
			  goUp,
			  go,
			  goDown,
			  goBack,
			  nil];	
	[voidNode do: [RepeatForEver actionWithAction:seq ] ];
	
	[self add:voidNode];
	
	return self;
	
}

-(NSString *) title
{
	return @"Parallax: parent and 3 children";
}
@end

#pragma mark Example Parallax 2

@implementation Parallax2
-(id) init
{
	if( ![super init] )
		return nil;
	
	
	TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
	
	tilemap.transformAnchor = cpv(0, 0);
	tilemap.position = cpv(0,-200);
	
	Sprite *background = [Sprite spriteWithFile:@"background.png"];
	background.scale = 1.5;
	background.transformAnchor = cpv(0,0);
	
	
	[tilemap add:background z:-1 parallaxRatio:cpv(0.4,0.5)];
	
	id goUp = [MoveBy actionWithDuration:2 position:cpv(-1000,-500)];
	id goDown = [goUp reverse];
	id seq = [Sequence actions:
			  goUp,
			  goDown,
			  nil];	
	[tilemap do: [RepeatForEver actionWithAction:seq ] ];
	
	[self add:tilemap];
	
	return self;
	
}

-(NSString *) title
{
	return @"Parallax: parent & child";
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	Scene *scene = [Scene node];
	[scene add: [nextAction() node]];
			 
	[[Director sharedDirector] runScene: scene];
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

@end
