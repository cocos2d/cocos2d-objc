//
// Anchor Demo
// a cocos2d example
//

// cocos import
#import "cocos2d.h"

// local import
#import "TestAnchor.h"

Class nextAction();

@implementation AnchorDemo
-(id) init
{
	[super init];

	isTouchEnabled = YES;

	grossini = [[Sprite spriteFromFile:@"grossini.png"] retain];
	tamara = [[Sprite spriteFromFile:@"grossinis_sister1.png"] retain];
	
	[self add: grossini z:1];
	[self add: tamara z:2];

	CGRect s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(60, s.size.height/3)];
	[tamara setPosition: cpv(60, 2*s.size.height/3)];
	
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];

	return self;
}

-(void) dealloc
{
	[grossini release];
	[tamara release];
	[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) centerSprites
{
	CGRect s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(s.size.width/3, s.size.height/2)];
	[tamara setPosition: cpv(2*s.size.width/3, s.size.height/2)];
}
-(NSString*) title
{
	return @"No title";
}
@end

@implementation Anchor1
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];

	id action1 = [Repeat actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									times:-1];
	id action2 = [Repeat actionWithAction:
				  [Sequence actions: [a1 copy], [a2 copy], [a2 reverse], nil]
									times:-1];
	
	tamara.transformAnchor = cpvzero;
	
	[tamara do: action1];
	[grossini do:action2];
}
-(NSString *) title
{
	return @"transformAnchor";
}
@end

@implementation Anchor2
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];

	Sprite *sp1 = [Sprite spriteFromFile:@"grossini.png"];
	Sprite *sp2 = [Sprite spriteFromFile:@"grossinis_sister1.png"];
	
	sp1.scale = 0.25;
	sp2.scale = 0.25;
	
	[tamara add:sp1];
	[grossini add:sp2];
	
	id a1 = [RotateBy actionWithDuration:2 angle:360];
	id a2 = [ScaleBy actionWithDuration:2 scale:2];
	
	id action1 = [Repeat actionWithAction:
				  [Sequence actions: a1, a2, [a2 reverse], nil]
									times:-1];
	id action2 = [Repeat actionWithAction:
				  [Sequence actions: [a1 copy], [a2 copy], [a2 reverse], nil]
									times:-1];
	
	tamara.transformAnchor = cpvzero;
	
	[tamara do: action1];
	[grossini do:action2];	
}
-(NSString *) title
{
	return @"transformAnchor and children";
}

@end

Class nextAction()
{
	static int i=0;
	
	NSArray *transitions = [[NSArray arrayWithObjects:
								@"Anchor1",
								@"Anchor2",
									nil ] retain];
	
	
	NSString *r = [transitions objectAtIndex:i++];
	i = i % [transitions count];
	Class c = NSClassFromString(r);
	return c;
}


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

@end
