//
// Texture2D Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// local import
#import "cocos2d.h"
#import "Texture2dTest.h"


static int sceneIdx=-1;
static NSString *transitions[] = {
						@"TextureLabel",
						@"TextureLabel2",
						@"TextureAlias",
						@"TexturePVRMipMap",
						@"TexturePVR",
						@"TexturePVRRaw",
						@"TexturePNG",
						@"TextureBMP",
						@"TextureJPEG",
						@"TextureTIFF",
						@"TextureGIF",
};

#pragma mark Callbacks

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

#pragma mark Demo examples start here

@implementation TextureDemo
-(id) init
{
	if( (self = [super initWithColor:0x202020FF]) ) {

		CGSize s = [[Director sharedDirector] winSize];	
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];

		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
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

#pragma mark -
#pragma mark Examples

@implementation TextureLabel
-(void) onEnter
{
	[super onEnter];
	
	Label *left = [Label labelWithString:@"alignment left" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:32];
	Label *center = [Label labelWithString:@"alignment center" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:32];
	Label *right = [Label labelWithString:@"alignment right" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:32];

	left.position = ccp(240,200);
	center.position = ccp(240,150);
	right.position = ccp(240,100);

	[[[self addChild:left z:0]
			addChild:right z:0]
			addChild:center z:0];
	
//	id s = [Sprite spriteWithFile:@"grossini_indexed.png"];
//	id s2 = [Sprite spriteWithFile:@"grossini_indexed.gif"];
//	[self addChild:s];
//	[self addChild:s2];
}

-(NSString *) title
{
	return @"Label Alignments";
}
@end

@implementation TextureLabel2
-(void) onEnter
{
	[super onEnter];
	
	Label *center1 = [Label labelWithString:@"Marker Felt 32" fontName:@"Marker Felt" fontSize:32];
	Label *center2 = [Label labelWithString:@"Times New Roman 48" fontName:@"Times New Roman" fontSize:48];
	Label *center3 = [Label labelWithString:@"Courier 64" fontName:@"Courier" fontSize:64];
	
	center1.position = ccp(240,200);
	center2.position = ccp(240,150);
	center3.position = ccp(240,100);
	
	[[[self addChild:center1 z:0]
			addChild:center2 z:0]
			addChild:center3 z:0];
}

-(NSString *) title
{
	return @"Label Dynamic Size";
}
@end

@implementation TexturePNG
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];

	Sprite *img = [Sprite spriteWithFile:@"test_image.png"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PNG Test";
}
@end

@implementation TextureJPEG
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.jpeg"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"JPEG Test";
}
@end

@implementation TextureBMP
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.bmp"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"BMP Test";
}
@end

@implementation TextureTIFF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.tiff"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"TIFF Test";
}
@end

@implementation TextureGIF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.gif"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"GIF Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRMipMap
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];

	Sprite *imgMipMap = [Sprite spriteWithFile:@"logo-mipmap.pvr"];
	imgMipMap.position = ccp( s.width/2.0f-100, s.height/2.0f);
	[self addChild:imgMipMap];

	// support mipmap filtering
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[imgMipMap.texture setTexParameters:&texParams];
	Sprite *img = [Sprite spriteWithFile:@"logo-nomipmap.pvr"];
	img.position = ccp( s.width/2.0f+100, s.height/2.0f);
	[self addChild:img];
	
	id scale1 = [EaseOut actionWithAction: [ScaleBy actionWithDuration:4 scale:0.01f] rate:3];
	id sc_back = [scale1 reverse];
	
	id scale2 = [[scale1 copy] autorelease];
	id sc_back2 = [scale2 reverse];
	
	[imgMipMap runAction: [RepeatForever actionWithAction: [Sequence actions: scale1, sc_back, nil]]];
	[img runAction: [RepeatForever actionWithAction: [Sequence actions: scale2, sc_back2, nil]]];
}

-(NSString *) title
{
	return @"PVR MipMap Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVR
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PVR Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRRaw
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addPVRTCImage:@"test_image.pvrraw" bpp:4 hasAlpha:YES width:128];
	Sprite *img = [Sprite spriteWithTexture:tex];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PVR Raw Test";
}
@end

@implementation TextureAlias
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	//
	// Sprite 1: GL_LINEAR
	//
	// Default filter is GL_LINEAR
	
	Sprite *sprite = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	sprite.position = ccp( s.width/3.0f, s.height/2.0f);
	[self addChild:sprite];
	
	// this is the default filterting
	[sprite.texture setAntiAliasTexParameters];
	
	//
	// Sprite 1: GL_NEAREST
	//	
	
	Sprite *sprite2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	sprite2.position = ccp( 2*s.width/3.0f, s.height/2.0f);
	[self addChild:sprite2];
	
	// Use Nearest in this one
	[sprite2.texture setAliasTexParameters];

		
	// scale them to show
	id sc = [ScaleBy actionWithDuration:3 scale:8.0f];
	id sc_back = [sc reverse];
	id scaleforever = [RepeatForever actionWithAction: [Sequence actions: sc, sc_back, nil]];
	
	[sprite2 runAction:scaleforever];
	[sprite runAction: [[scaleforever copy] autorelease]];
}

-(NSString *) title
{
	return @"AntiAlias / Alias textures";
}
@end



#pragma mark -
#pragma mark AppController - Main


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
