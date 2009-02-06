//
// Ease Demo
// a cocos2d example
//

// local import
#import "cocos2d.h"
#import "EaseDemo.h"


static int sceneIdx=-1;
static NSString *transitions[] = {
						 @"SpriteEaseCubic",
						 @"SpriteEaseCubicInOut",
						 @"SpriteEaseQuad",
						 @"SpriteEaseQuadInOut",
						 @"SpriteEaseExponential",
						 @"SpriteEaseExponentialInOut",
						 @"SpriteEaseSine",
						 @"SpriteEaseSineInOut",
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
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
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
	[super init];

	// Example:
	// You can create a sprite using a Texture2D
	Texture2D *tex = [ [Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"grossini.png" ofType:nil] ] ];
	grossini = [[Sprite spriteWithTexture:tex] retain];
	[tex release];
	
	// Example:
	// Or you can create an sprite using a filename. PNG and BMP files are supported. Probably TIFF too
	tamara = [[Sprite spriteWithFile:@"grossinis_sister1.png"] retain];
	kathia = [[Sprite spriteWithFile:@"grossinis_sister2.png"] retain];
	
	[self add: grossini z:3];
	[self add: kathia z:2];
	[self add: tamara z:1];

	CGSize s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(60, 50)];
	[kathia setPosition: cpv(60, 150)];
	[tamara setPosition: cpv(60, 250)];
	
	Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.width/2, s.height-50)];

	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	menu.position = cpvzero;
	item1.position = cpv(480/2-100,30);
	item2.position = cpv(480/2, 30);
	item3.position = cpv(480/2+100,30);
	[self add: menu z:1];

	return self;
}

-(void) dealloc
{
	[grossini release];
	[tamara release];
	[kathia release];
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


-(void) positionForTwo
{	
	grossini.position = cpv( 60, 120 );
	tamara.position = cpv( 60, 220);
	kathia.visible = NO;
}
-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark Ease Actions

@implementation SpriteEaseCubic
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseCubicIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];

	id move_ease_out = [EaseCubicOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];

	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	
	
	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
	[kathia do: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseCubicIn - EaseCubicOut";
}
@end

@implementation SpriteEaseCubicInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseCubicInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];
	
	[self positionForTwo];
	
	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseCubicInOut action";
}
@end


@implementation SpriteEaseSine
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseSineIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseSineOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	
	
	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
	[kathia do: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseSineIn - EaseSineOut";
}
@end

@implementation SpriteEaseSineInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseSineInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];

	[self positionForTwo];

	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseSineInOut action";
}
@end

@implementation SpriteEaseQuad
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseQuadIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseQuadOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	
	
	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
	[kathia do: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseQuadIn - EaseQuadOut";
}
@end

@implementation SpriteEaseQuadInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseQuadInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];

	[self positionForTwo];

	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseQuadInOut action";
}
@end

@implementation SpriteEaseExponential
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseExponentialIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseExponentialOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	

	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
	[kathia do: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"ExpIn - ExpOut actions";
}
@end

@implementation SpriteEaseExponentialInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseExponentialInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];
	
	[self positionForTwo];
	
	[grossini do: [RepeatForever actionWithAction:seq1]];
	[tamara do: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseExponentialInOut action";
}
@end


#pragma mark -
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
	[scene add: [nextAction() node]];	
	
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
