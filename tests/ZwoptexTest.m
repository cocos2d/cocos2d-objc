//
// Zwoptex support test
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ZwoptexTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"ZwoptexGenericTest",
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
#pragma mark ZwoptexTest

@implementation ZwoptexTest
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
#pragma mark ZwoptexGenericTest

@implementation ZwoptexGenericTest

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"zwoptex/grossini.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"zwoptex/grossini-generic.plist"];

		CCLayerColor *layer1 = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:85 height:121];
		layer1.position = ccp(s.width/2-80 - (85.0f * 0.5f), s.height/2 - (121.0f * 0.5f));
		[self addChild:layer1];

		sprite1 = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"grossini_dance_01.png"]];
		sprite1.position = ccp( s.width/2-80, s.height/2);
		[self addChild:sprite1];

		sprite1.flipX = NO;
		sprite1.flipY = NO;

		CCLayerColor *layer2 = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:85 height:121];
		layer2.position = ccp(s.width/2+80 - (85.0f * 0.5f), s.height/2 - (121.0f * 0.5f));
		[self addChild:layer2];

		sprite2 = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"grossini_dance_generic_01.png"]];
		sprite2.position = ccp( s.width/2 + 80, s.height/2);
		[self addChild:sprite2];

		sprite2.flipX = NO;
		sprite2.flipY = NO;

		[self schedule:@selector(startIn05Secs:) interval:1.0f];

		[sprite1 retain];
		[sprite2 retain];

		counter = 0;

	}
	return self;
}

-(void) startIn05Secs:(ccTime)dt
{
	[self unschedule:_cmd];
	[self schedule:@selector(flipSprites:) interval:0.5f];
}

static int spriteFrameIndex = 0;
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

	if(++spriteFrameIndex > 14) {
		spriteFrameIndex = 1;
	}
	[sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_%02d.png",spriteFrameIndex]]];
	NSLog(@"Sprite 1 Displayed Frame: %@", [sprite1 displayFrame]);

	[sprite2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"grossini_dance_generic_%02d.png",spriteFrameIndex]]];
	NSLog(@"Sprite 2 Displayed Frame: %@", [sprite2 displayFrame]);

}

- (void) dealloc
{
	[sprite1 release];
	[sprite2 release];
	[super dealloc];
}

-(NSString *) title
{
	return @"Zwoptex Tests";
}

-(NSString*) subtitle
{
	return @"Coordinate Formats, Rotation, Trimming, flipX/Y";
}
@end

#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// Display FPS: yes
	[director_ setDisplayStats:YES];


	// 2D projection
//	[director_ setProjection:kCCDirectorProjection2D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// create the main scene
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	// and run it!
	[director_ pushScene: scene];

	return YES;
}

@end
