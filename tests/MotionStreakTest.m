//
// MotionStreak Demo
// a cocos2d example
//
// Example by Jason Booth (slipster216)

// cocos import
#import "cocos2d.h"
#import "MotionStreakTest.h"
#import "BaseAppController.h"

enum {
	kTagLabel = 1,
	kTagSprite1 = 2,
	kTagSprite2 = 3,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"Test1",
	@"Test2",
};

#pragma mark Callbacks

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

@implementation MotionStreakTest
-(id) init
{
	if( (self = [super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];	
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:0 tag:kTagLabel];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];
		
		
		CCMenuItemToggle *itemMode = [CCMenuItemToggle itemWithTarget:self
														  selector:@selector(modeCallback:)
															 items: [CCMenuItemFont itemWithString: @"Fast"], [CCMenuItemFont itemWithString: @"Slow"], nil];
		
		CCMenu *menuMode = [CCMenu menuWithItems:itemMode, nil];
		[self addChild:menuMode];
		
		[menuMode setPosition:ccp(30,65)];
		
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) modeCallback: (id) sender
{
	BOOL fastMode = [streak_ isFastMode];
	[streak_ setFastMode: ! fastMode];
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


#pragma mark Test1

@implementation Test1
-(NSString*) title
{
	return @"MotionStreak test 1";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
  
	// the root object just rotates around
	root = [CCSprite spriteWithFile:@"r1.png"];
	[self addChild: root z:1];
	[root setPosition: ccp(s.width/2, s.height/2)];
  
	// the target object is offset from root, and the streak is moved to follow it
	target = [CCSprite spriteWithFile:@"r1.png"];
	[root addChild:target];
	[target setPosition:ccp(100,0)];

	// create the streak object and add it to the scene
	streak = [CCMotionStreak streakWithFade:2 minSeg:3 width:32 color:ccGREEN textureFilename:@"streak.png"];
	[self addChild:streak];
	
	// schedule an update on each frame so we can syncronize the streak with the target
	[self schedule:@selector(onUpdate:)];
  
	id a1 = [CCRotateBy actionWithDuration:2 angle:360];

	id action1 = [CCRepeatForever actionWithAction:a1];
	id motion = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
	[root runAction:[CCRepeatForever actionWithAction:[CCSequence actions:motion, [motion reverse], nil]]];
	[root runAction:action1];
    
    
    CCActionInterval *colorAction = [CCRepeatForever actionWithAction:[CCSequence actions:
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:0 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:255],nil
                                                                  ]
                                ];
    [streak runAction:colorAction];
	
	
	// weak ref
	streak_ = streak;
}

-(void)onUpdate:(ccTime)delta
{
	[streak setPosition:[target convertToWorldSpace:CGPointZero]];
}
@end

#pragma mark Test2

@implementation Test2
-(NSString*) title
{
	return @"MotionStreak test (tap screen)";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	
	self.isTouchEnabled = YES;

	CGSize s = [[CCDirector sharedDirector] winSize];
		
	// create the streak object and add it to the scene
	streak = [CCMotionStreak streakWithFade:3 minSeg:3 width:64 color:ccWHITE textureFilename:@"streak.png"];
	[self addChild:streak];
	
	streak.position = ccp(s.width/2, s.height/2);
	
	
	// weak ref
	streak_ = streak;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	[streak setPosition:touchLocation];
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
	// Turn on display FPS
	[director_ setDisplayStats:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director_ pushScene: scene];
	
	return  YES;
}

- (void) dealloc
{
	[super dealloc];
}
@end
