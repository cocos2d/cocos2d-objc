//
// TouchTest demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "TouchTest.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

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
		MainLayer * mainLayer =[MainLayer node];
		[scene addChild: mainLayer];
		[director runWithScene:scene];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

#pragma mark - AppController - Mac

#else

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	CCScene *scene = [CCScene node];
	
	MainLayer * mainLayer =[MainLayer node];
	
	[scene addChild: mainLayer];
		
	[director_ runWithScene:scene];
}
@end

#endif

// -----------------------------------------------------------------

@implementation TouchSprite

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    MainLayer* layer = (MainLayer *)self.parent;
    [layer nextStep];
}

#else

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (void)mouseUp:(NSEvent *)theEvent
{
    MainLayer* layer = (MainLayer *)self.parent;
    [layer nextStep];
}

#endif

@end

// -----------------------------------------------------------------

@implementation SlideSprite

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.scale = 1.2;
    [self runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    MainLayer* layer = (MainLayer *)self.parent;
    [layer nextStep];
}

#else

- (void)mouseDown:(NSEvent *)theEvent
{
    self.scale = 1.2;
    [self runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    MainLayer* layer = (MainLayer *)self.parent;
    [layer nextStep];
}

#endif

@end

// -----------------------------------------------------------------

@implementation CrashSprite

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSAssert(NO, @"Error in touch handler");
}

#else

- (void)mouseDown:(NSEvent *)theEvent
{
    NSAssert(NO, @"Error in touch handler");
}

#endif

@end

// -----------------------------------------------------------------

@implementation MainLayer
{
    int             _step;
}

- (id)init
{
    self = [super init];
    _step = -1;
    [self nextStep];
    return(self);
}

- (void)nextStep
{
    CCSprite *sprite;
    CGPoint win = ccp([CCDirector sharedDirector].winSize.width, [CCDirector sharedDirector].winSize.height);
    
    _step ++;
    [self removeAllChildren];
    CCLabelTTF *label = [ CCLabelTTF labelWithString:@"there really is no step" fontName:@"Arial" fontSize:20];
    label.position = ccp(win.x * 0.5, win.y * 0.9);
    [self addChild:label];
    
    switch (_step)
    {
        case 0:
            // check that simple click works
            label.string = @"#1 Click on Grossini (2x touch area)";
            sprite = [self newTouchSprite:@"grossini.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:0 user:YES];
            sprite.hitAreaExpansion = 2.0;
            break;
            
        case 1:
            // check that sorted nodes are clicked correctly
            label.string = @"#2 Click on Grossoni's sister";
            sprite = [self newTouchSprite:@"grossinis_sister1.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:1 user:YES];
            [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:-360]]];
            [self newCrashSprite:@"grossini.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:0 user:NO];
            break;
            
        case 2:
            // check that touch goes to responders only
            label.string = @"#3 Click on Grossoni behind his sister";
            sprite = [self newCrashSprite:@"grossinis_sister1.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:1 user:NO];
            [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
            [self newTouchSprite:@"grossini.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:0 user:YES];
            break;
            
        case 3:
            // check that invisible strites arent clicked
            label.string = @"#4 Click on Grossoni's sister";
            sprite = [self newTouchSprite:@"grossinis_sister1.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:0 user:YES];
            [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:360]]];
            sprite = [self newCrashSprite:@"grossini.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:1 user:YES];
            sprite.visible = NO;
            break;
            
        case 4:
            // check userInteractionClaimed
            label.string = @"#5 Slide over Grossini and his sisters (1.5x touch area)";
            sprite = [self newSlideSprite:@"grossini.png" pos:ccp(win.x * 0.25, win.y * 0.5) z:0 user:YES];
            sprite = [self newSlideSprite:@"grossinis_sister1.png" pos:ccp(win.x * 0.5, win.y * 0.5) z:0 user:YES];
            sprite = [self newSlideSprite:@"grossinis_sister2.png" pos:ccp(win.x * 0.75, win.y * 0.5) z:0 user:YES];
            break;
            
        default:
            _step = -1;
            [self nextStep];
            break;
    }
}

- (TouchSprite *)newTouchSprite:(NSString *)file pos:(CGPoint)pos z:(float)z user:(BOOL)user
{
    TouchSprite *sprite = [TouchSprite spriteWithFile:file];
    sprite.position = pos;
    [self addChild:sprite z:z];
    sprite.userInteractionEnabled = user;
    return(sprite);
}

- (CrashSprite *)newCrashSprite:(NSString *)file pos:(CGPoint)pos z:(float)z user:(BOOL)user
{
    CrashSprite *sprite = [CrashSprite spriteWithFile:file];
    sprite.position = pos;
    [self addChild:sprite z:z];
    sprite.userInteractionEnabled = user;
    return(sprite);
}

- (SlideSprite *)newSlideSprite:(NSString *)file pos:(CGPoint)pos z:(float)z user:(BOOL)user
{
    SlideSprite *sprite = [SlideSprite spriteWithFile:file];
    sprite.position = pos;
    [self addChild:sprite z:z];
    sprite.userInteractionEnabled = user;
    sprite.userInteractionClaimed = NO;
    sprite.hitAreaExpansion = 1.5;
    return(sprite);
}

@end

