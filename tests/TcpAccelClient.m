//
// TcpAccelClient Demo
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
#import "TcpAccelClient.h"

#define HOST @"192.168.1.83"
#define PORT 0xAC3d

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
	
	[grossini setPosition: CGPointMake(60, s.size.height/3)];
	[tamara setPosition: CGPointMake(60, 2*s.size.height/3)];
	
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: CGPointMake(s.size.width/2, s.size.height-50)];

	return self;
}

-(void) dealloc
{
	[grossini release];
	[tamara release];
	[super dealloc];
}

-(void) centerSprites
{
	CGRect s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: CGPointMake(s.size.width/3, s.size.height/2)];
	[tamara setPosition: CGPointMake(2*s.size.width/3, s.size.height/2)];
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

	id actionTo = [MoveTo actionWithDuration: 2 position:CGPointMake(s.size.width-40, s.size.height-40)];
	id actionBy = [MoveBy actionWithDuration:2  delta: CGPointMake(80,80)];
	
	[tamara do: actionTo];
	[grossini do:actionBy];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	Scene *s = [Scene node];
//	[s add: [nextAction() node]];
//	[[Director sharedDirector] replaceScene: s];
	if (iStream == nil) {
        [self setupSocket];
    }
}

- (void) setupSocket
{
    NSHost *host = [NSHost hostWithAddress:HOST];
    [NSStream getStreamsToHost:host port:PORT inputStream:&iStream outputStream:&oStream];
    [iStream retain];
    [oStream retain];
    [iStream setDelegate:self];	
    [oStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
					   forMode:NSDefaultRunLoopMode];
    [iStream open];
    [oStream open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	if (eventCode == NSStreamEventHasBytesAvailable)
	{
		float buffer[3];
		[iStream read:(uint8_t*)&buffer maxLength:sizeof(buffer)];

		float xx = buffer[0];
		float yy = buffer[1];
		float angle = atan2(yy, xx);
		angle += 3.14159;
		angle *= -180.0/3.14159;
		
		[grossini setRotation:angle];
	}
}
	
-(NSString *) title
{
	return @"MoveTo / MoveBy";
}
@end

Class nextAction()
{
	static int i=0;
	
	NSArray *transitions = [[NSArray arrayWithObjects:
								@"SpriteMove",
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
