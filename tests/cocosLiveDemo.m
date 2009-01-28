//
// cocos live demo
// a cocos2d example
//

#import <UIKit/UIKit.h>
#include <sys/time.h>

// cocos import
#import "cocoslive.h"

// local import
#import "cocosLiveDemo.h"

#define RANDOM_FLOAT() (((float)random() / (float)0x7fffffff))

@interface AppController (Private)
-(void) testRequest;
-(void) testPost;
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

-(void) initRandom {
	struct timeval t;
	gettimeofday(&t, nil);
	unsigned int i;
	i = t.tv_sec;
	i += t.tv_usec;
	srandom(i);	
}

-(int) getRandomWithMax:(int)max 
{
	return RANDOM_FLOAT() * max;
}

-(void) testPost
{
	ScoreServerPost *server = [[ScoreServerPost alloc] initWithGameName:@"DemoGame" gameKey:@"e8e0765de336f46b17a39ad652ee4d39" delegate:nil];

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	// usr_ are fields that can be modified.
	// set score
	[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:20000] ] forKey:@"cc_score"];
	// set speed
	[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:2000] ] forKey:@"usr_speed"];
	// set angle
	[dict setObject: [NSNumber numberWithInt:[self getRandomWithMax:360] ] forKey:@"usr_angle"];
	// set playername
	[dict setObject: @"Tito" forKey:@"usr_playername"];
	// set player type
	[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:2] ] forKey:@"usr_playertype"];

	// cc_ are fields that cannot be modified. cocos fields
	// set category... it can be "easy", "medium", whatever you want.
	int r = [self getRandomWithMax:3];
	NSString *category;
	switch(r) {
		case 0:
			category = @"easy";
			break;
		case 1:
			category = @"medium";
			break;
		case 2:
		default:
			category = @"hard";
			break;
	}
	
	[dict setObject:category forKey:@"cc_category"];
	
	[server sendScore:dict];
	[server release];
}

-(void) testRequest
{
	ScoreServerRequest *request = [[ScoreServerRequest alloc] initWithGameName:@"DemoGame" delegate:self];
//	[request requestScores:kQueryAllTime limit:25 offset:0 flags:kQueryFlagIgnore category:@"easy"];

	// Only ask for the scores from certain country... in this case, from "your" country
	[request requestScores:kQueryAllTime limit:25 offset:0 flags:kQueryFlagByCountry category:@"easy"];

}

-(void) scoreRequestOk: (id) sender
{
	NSLog(@"score request OK");
	
	NSArray *scores = [sender parseScores];	
	NSLog(@"%@", scores);
	[sender release];

}

-(void) scoreRequestFail: (id) sender
{
#if DEBUG
	NSLog(@"score request fail");
#endif
	[sender release];
}


-(void) applicationDidFinishLaunching:(UIApplication*)application
{
	[self initRandom];
	for( int i=0; i< 15;i++)
		[self testPost];
	[self testRequest];
}
@end
