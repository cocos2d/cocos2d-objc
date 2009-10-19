//
// RenderTexture Demo
// a cocos2d example
//
// Example by Jason Booth (slipster216)

// cocos import
#import "RenderTextureTest.h"


@implementation RenderTextureTest
-(id) init
{
	if( (self = [super init]) ) {
		
		CGSize s = [[Director sharedDirector] winSize];	
		Label* label = [Label labelWithString:@"Render Texture Test" fontName:@"Arial" fontSize:32];
		[self addChild:label z:0];
		[label setPosition: ccp(s.width/2, s.height-50)];
		// create a render texture, this is what we're going to draw into
		target = [RenderTexture renderTextureWithWidth:s.width height:s.height];
		[target setPosition:ccp(s.width/2, s.height/2)];
		// note that the render texture is a cocosnode, and contains a sprite of it's texture for convience,
		// so we can just parent it to the scene like any other cocos node
		[self addChild:target z:1];
		// create a brush image to draw into the texture with
		brush = [[Sprite spriteWithFile:@"stars.png"] retain];
		[brush setBlendFunc: (ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA }];  
		[brush setOpacity:20];
		isTouchEnabled = YES;		
	}
	return self;
}

-(void) dealloc
{
	[brush release];
	[target release];
	[[TextureMgr sharedTextureMgr] removeUnusedTextures];
	[super dealloc];
	
}


-(BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];	
	start = [[Director sharedDirector] convertToGL: start];
	CGPoint end = [touch previousLocationInView:[touch view]];
	end = [[Director sharedDirector] convertToGL:end];

	// begin drawing to the render texture
	[target begin];

	// for extra points, we'll draw this smoothly from the last position and vary the sprite's
	// scale/rotation/offset
	float distance = ccpDistance(start, end);
	if (distance > 1)
	{
		int d = (int)distance;
		for (int i = 0; i < d; i++)
		{
			float difx = end.x - start.x;
			float dify = end.y - start.y;
			float delta = (float)i / distance;
			[brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
			[brush setRotation:rand()%360];
			float r = ((float)(rand()%50)/50.f) + 0.25f;
			[brush setScale:r];
			// Call visit to draw the brush, don't call draw..
			[brush visit];
		}
	}
	// finish drawing and return context back to the screen
	[target end];

	return YES;
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
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use Threaded director
	if( ! [Director setDirectorType:CCDirectorTypeDisplayLink] )
		[Director setDirectorType:CCDirectorTypeDefault];	
  
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
  
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
  
	Scene *scene = [Scene node];
	[scene addChild: [RenderTextureTest node]];
	
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
