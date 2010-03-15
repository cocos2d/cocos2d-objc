//
// attach demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import <UIKit/UIKit.h>
#include <sys/time.h>

// cocos2d import
#import "cocos2d.h"

// local import
#import "attachDemo.h"


enum {
	kStateRun,
	kStateEnd,
	kStateAttach,
	kStateDetach,
};

enum {
	kTagSprite = 1,
};

@interface LayerExample : CCLayer
{}
@end

@implementation LayerExample
-(id) init
{
	if( (self=[super init] ) )
	{
		self.isTouchEnabled = YES;
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
		CCLabel *label = [CCLabel labelWithString:[NSString stringWithFormat:@"%dx%d",(int)s.width, (int)s.height] fontName:@"Marker Felt" fontSize:28];
		
		[self addChild:label];
		[self addChild:grossini z:0 tag:kTagSprite];
		
		grossini.position = ccp( s.width/2, s.height/2);
		label.position = ccp( s.width/2, s.height-40);
		
		id sc = [CCScaleBy actionWithDuration:2 scale:1.5f];
		id sc_back = [sc reverse];
		[grossini runAction: [CCRepeatForever actionWithAction:
					   [CCSequence actions: sc, sc_back, nil]]];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	
	CCNode *s = [self getChildByTag:kTagSprite];
	[s stopAllActions];
	[s runAction: [CCMoveTo actionWithDuration:1 position:ccp(convertedLocation.x, convertedLocation.y)]];
	float o = convertedLocation.x - [s position].x;
	float a = convertedLocation.y - [s position].y;
	float at = (float) CC_RADIANS_TO_DEGREES( atanf( o/a) );
	
	if( a < 0 ) {
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);	
	}
	
	[s runAction: [CCRotateTo actionWithDuration:1 angle: at]];	
}
@end


@interface AppController (Private)
-(void) attachView;
-(void) detachView;
-(void) runCocos2d;
-(void) endCocos2d;
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window, mainView;

enum {
	kTagAttach = 1,
	kTagDettach = 2,
};

//
// Use runWithScene / end
// to remove /add the cocos2d view
// This is the recommended way since it removes the Scenes from memory
//
-(void) runCocos2d
{
	if( state == kStateEnd ) {
		[[CCDirector sharedDirector] attachInView:mainView withFrame:CGRectMake(0, 0, 250,350)];
		
		CCScene *scene = [CCScene node];
		id node = [LayerExample node];
		[scene addChild: node];
		
		[[CCDirector sharedDirector] runWithScene:scene];
		
		state = kStateRun;
	}
	else {
		NSLog(@"End the view before running it");
	}
}

-(void) endCocos2d
{
	if( state == kStateRun || state == kStateAttach) {
		// Director end releases the "inner" objects from memory
		[[CCDirector sharedDirector] end];
		state = kStateEnd;
	}
	else
		NSLog(@"Run or Attach the view before calling end");
}

//
// Use attach / detach
// To hide / unhide the cocos2d view.
// If you want to remove them, use runWithScene / end
// IMPORTANT: Memory is not released if you use attach / detach
//
-(void) attachView
{
	if( state == kStateDetach ) {
		[[CCDirector sharedDirector] attachInView:mainView withFrame:CGRectMake(0, 0, 250,350)];
		[[CCDirector sharedDirector] startAnimation];

		state = kStateAttach;
	}
	else
		NSLog(@"Dettach the view before attaching it");
}

-(void) detachView
{
	if( state == kStateRun || state == kStateAttach ) {
		[[CCDirector sharedDirector] detach];
		[[CCDirector sharedDirector] stopAnimation];
		state = kStateDetach;
	} else {
		NSLog(@"Run or Attach the view before calling detach");
	}
}

#pragma mark -
#pragma mark Segment Delegate
- (void)segmentAction:(id)sender
{	
	int idx = [sender selectedSegmentIndex];
	// category 
	if( [sender tag] == 0 ) {	// attach / detach
		if( idx == 0)
			[self attachView];
		else if( idx == 1 )
			[self detachView];
	} else if( [sender tag] == 1 ) { // run / end
		if( idx == 0 )
			[self runCocos2d];
		else if(idx == 1)
			[self endCocos2d];
	}
}

#pragma mark -
#pragma mark Application Delegate

-(void) applicationDidFinishLaunching:(UIApplication*)application
{	
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];

	[[CCDirector sharedDirector] setDisplayFPS:YES];
	[[CCDirector sharedDirector] setAnimationInterval:1/240.0f];


	[window makeKeyAndVisible];	
	
	state = kStateEnd;

	[self runCocos2d];
}

#pragma mark -
#pragma mark Init
-(void) dealloc
{
	[mainView release];
	[window release];
	[super dealloc];
}
@end
