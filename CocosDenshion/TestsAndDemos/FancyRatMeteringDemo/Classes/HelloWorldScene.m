//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "AudioVisualization.h"
#import "SimpleAudioEngine.h"
#import "SimpleAudioEngine.h"
#import "DebugAudioVis.h"

enum {
	kTagBg,
	kTagHead,
};

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];

	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];


		// add the label as a child to this Layer
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Cyber Advance!.mp3" loop:YES];
		CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
		// position the label on the center of the screen
		sprite.position =  ccp( size.width /2 , size.height/2 );
		sprite.tag = kTagBg;
		[self addChild: sprite];

		sprite = [CCSprite spriteWithFile:@"head.png"];
		// position the label on the center of the screen
		sprite.position =  ccp( size.width /2 , 192.f );
		sprite.anchorPoint = ccp(.5f,0.f);
		sprite.tag = kTagHead;
		[self addChild: sprite];

		[self addChild:[DebugAudioVis node]];

		//	Now let's setup audio visualization
		//	We should always call AudioVisualization AFTER we load the background music
		//	We add a delegate callback for each audio channel, there's 2
		//	As the metering of our audio runs it returns a level value form 0..1
		[[AudioVisualization sharedAV] addDelegate:self forChannel:0];
	}
	return self;
}

///
//	The callback when the avg power level changes it gives you a level amount from 0..1
///
- (void) avAvgPowerLevelDidChange:(float) level channel:(ushort) theChannel
{
	//	Just change the cocos2d logo scale for one channel
		[self getChildByTag:kTagHead].scale = 1 + level*.5f;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
