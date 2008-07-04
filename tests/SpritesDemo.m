//
// Sprites Demo
// a cocos2d example
//

// cocos2d imports
#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"

// local import
#import "SpritesDemo.h"

Class nextAction();

@implementation SpriteDemo
-(id) init
{
	[super init];

	isEventHandler = YES;

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

@implementation SpriteMove
-(void) onEnter
{
	[super onEnter];
	
	CGRect s = [[Director sharedDirector] winSize];

	
	id actionTo = [MoveTo actionWithDuration: 2 position:cpv(s.size.width-40, s.size.height-40)];
	id actionBy = [MoveBy actionWithDuration:2  position: cpv(80,80)];
	
	[tamara do: actionTo];
	[grossini do:actionBy];
}
-(NSString *) title
{
	return @"MoveTo / MoveBy";
}
@end

@implementation SpriteRotate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
		
	id actionTo = [RotateTo actionWithDuration: 2 angle:45];
	id actionBy = [RotateBy actionWithDuration:2  angle: 360];
	
	[tamara do: actionTo];
	[grossini do:actionBy];
}
-(NSString *) title
{
	return @"RotateTo / RotateBy";
}

@end

@implementation SpriteScale
-(void) onEnter
{
	[super onEnter];

	[self centerSprites];
	
	id actionTo = [ScaleTo actionWithDuration: 2 scale:0.5];
	id actionBy = [ScaleBy actionWithDuration:2  scale: 2];
	
	[tamara do: actionTo];
	[grossini do:actionBy];
}
-(NSString *) title
{
	return @"ScaleTo / ScaleBy";
}

@end

@implementation SpriteJump
-(void) onEnter
{
	[super onEnter];
		
	id actionTo = [JumpTo actionWithDuration:2 position:cpv(300,300) height:50 jumps:4];
	id actionBy = [JumpBy actionWithDuration:2 position:cpv(300,0) height:50 jumps:4];
	
	[tamara do: actionTo];
	[grossini do:actionBy];
}
-(NSString *) title
{
	return @"JumpTo / JumpBy";
}
@end

@implementation SpriteBlink
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	id action1 = [Blink actionWithDuration:2 blinks:10];
	id action2 = [Blink actionWithDuration:2 blinks:5];
	
	[tamara do: action1];
	[grossini do:action2];
}
-(NSString *) title
{
	return @"Blink";
}
@end

@implementation SpriteAnimate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	[tamara setVisible:NO];
	
	id animation = [[Animation alloc] initWithName:@"dance" delay:0.2];
	for( int i=1;i<15;i++)
		[animation addFrame: [NSString stringWithFormat:@"grossini_dance_%02d.png", i]];
	
	id action = [Animate actionWithAnimation: animation];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"Animatinon";
}
@end


@implementation SpriteSequence
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];

	id action = [Sequence actions:
				 [MoveBy actionWithDuration: 2 position:cpv(240,0)],
				 [RotateBy actionWithDuration: 2 angle: 540],
				 nil];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"Sequence: Move + Rotate";
}
@end

@implementation SpriteSpawn
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id action = [Spawn actions:
				 [JumpBy actionWithDuration:2 position:cpv(300,0) height:50 jumps:4],
				 [RotateBy actionWithDuration: 2 angle: 720],
				 nil];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"Spawn: Jump + Rotate";
}
@end

@implementation SpriteReverse
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id jump = [JumpBy actionWithDuration:2 position:cpv(300,0) height:50 jumps:4];
	id action = [Sequence actions: jump, [jump reverse], nil];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"Reverse an action";
}
@end

@implementation SpriteDelayTime
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id move = [MoveBy actionWithDuration:1 position:cpv(150,0)];
	id action = [Sequence actions: move, [DelayTime actionWithDuration:2], move, nil];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"DelayTime: m + delay + m";
}
@end

@implementation SpriteReverseSequence
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];

	id move1 = [MoveBy actionWithDuration:1 position:cpv(250,0)];
	id move2 = [MoveBy actionWithDuration:1 position:cpv(0,50)];
	id seq = [Sequence actions: move1, move2, [move1 reverse], nil];
	id action = [Sequence actions: seq, [seq reverse], nil];
	
	[grossini do:action];
}
-(NSString *) title
{
	return @"Reverse a sequence";
}
@end

@implementation SpriteRepeat
-(void) onEnter
{
	[super onEnter];
		
	id a1 = [MoveBy actionWithDuration:1 position:cpv(150,0)];
	id action1 = [Repeat actionWithAction:
						[Sequence actions: [Place actionWithPosition:cpv(60,60)], a1, nil]
									times:10];
	id action2 = [Repeat actionWithAction:
						[Sequence actions: a1, [a1 reverse], nil]
									times:5];
	
	[grossini do:action1];
	[tamara do:action2];
}
-(NSString *) title
{
	return @"Repeat actions";
}
@end

@implementation SpriteAccelerate
-(void) onEnter
{
	[super onEnter];
	
	id a1 = [MoveBy actionWithDuration:3 position:cpv(350,0)];
	id seq =[Sequence actions: [Place actionWithPosition:cpv(60,60)], a1, nil];
	id seq2 =[Sequence actions: [Place actionWithPosition:cpv(60,260)], a1, nil];
	id rep = [Repeat actionWithAction:seq times:10];
	id action = [Accelerate actionWithAction:seq2 rate:2];
	id rep2 = [Repeat actionWithAction:action times:10];
	

	[grossini do:rep];
	[tamara do:rep2];
}
-(NSString *) title
{
	return @"Accelerate actions";
}
@end

@implementation SpriteCallFunc
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id action = [Sequence actions:
				 [MoveBy actionWithDuration:2 position:cpv(200,0)],
				 [CallFunc actionWithTarget:self selector:@selector(callback)],
				nil];
	[grossini do:action];
}

-(void) callback
{
	[tamara setVisible:YES];
}

-(NSString *) title
{
	return @"Callback action: CallFunc";
}
@end


Class nextAction()
{
	static int i=0;
	
	NSArray *transitions = [[NSArray arrayWithObjects:
								@"SpriteMove",
								@"SpriteRotate",
								@"SpriteScale",
								@"SpriteJump",
								@"SpriteBlink",
								@"SpriteAnimate",
								@"SpriteSequence",
								@"SpriteSpawn",
								@"SpriteReverse",
								@"SpriteDelayTime",
								@"SpriteRepeat",
								@"SpriteReverseSequence",
								@"SpriteAccelerate",
								@"SpriteCallFunc",
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

	Scene *scene = [Scene node];
	[scene add: [nextAction() node]];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
