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
		
		CGSize s = [[CCDirector sharedDirector] winSize];	
		CCLabel* label = [CCLabel labelWithString:@"Render Texture Test" fontName:@"Arial" fontSize:32];
		[self addChild:label z:0];
		[label setPosition: ccp(s.width/2, s.height-50)];

		// create a render texture, this is what we're going to draw into
		target = [[CCRenderTexture renderTextureWithWidth:s.width height:s.height] retain];
		[target setPosition:ccp(s.width/2, s.height/2)];

		// note that the render texture is a cocosnode, and contains a sprite of it's texture for convience,
		// so we can just parent it to the scene like any other cocos node
		[self addChild:target z:1];

		// create a brush image to draw into the texture with
		brush = [[CCSprite spriteWithFile:@"stars.png"] retain];
		[brush setBlendFunc: (ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA }];  
		[brush setOpacity:20];
		self.isTouchEnabled = YES;
		
		// Save Image menu
		[CCMenuItemFont setFontSize:16];
		CCMenuItem *item = [CCMenuItemFont itemFromString:@"Save Image" target:self selector:@selector(saveImage:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		[menu setPosition:ccp(s.width-80, s.height-80)];
	}
	return self;
}

-(void) saveImage:(id)sender
{
	static int counter=0;

	NSString *str = [NSString stringWithFormat:@"image-%d.png", counter];
	[target saveBuffer:str format:kImageFormatPNG];
	NSLog(@"Image saved: %@", str);
	
	counter++;
}

-(void) dealloc
{
	[brush release];
	[target release];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
	
}


-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];	
	start = [[CCDirector sharedDirector] convertToGL: start];
	CGPoint end = [touch previousLocationInView:[touch view]];
	end = [[CCDirector sharedDirector] convertToGL:end];

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
  
	[CCDirector setDirectorType:CCDirectorTypeDisplayLink];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
  
	// create an openGL view inside a window
	[director attachInView:window];	
	[window makeKeyAndVisible];		
  
	CCScene *scene = [CCScene node];
	[scene addChild: [RenderTextureTest node]];
	
	[director runWithScene: scene];
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
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
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
