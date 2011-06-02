//
// cocos live demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

//
// To view these scores online, go here:
// http://www.cocoslive.net/game-scores?gamename=DemoGame%203
//

//
// CocosLive client can be used within cocos2d
// or without it.
// This example shows how to use it without cocos2d
//
// To use cocos live in your game you need to link against these
// static libraries (or include the these sources in your game):
//   * cocosLive
//   * TouchJSON


#import <UIKit/UIKit.h>
#include <sys/time.h>


// cocos live import
//   This is the only import you need to use "pure" cocosLive
#import "cocoslive.h"

// CCLOG and CCRANDOM_0_1
#import "ccMacros.h"

// local import
#import "cocosLiveDemo.h"

@interface AppController (Private)
-(void) testRequest;
-(void) testPost;
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window, mainView;
@synthesize globalScores;

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
	return CCRANDOM_0_1() * max;
}

-(void) requestRank
{
	
	CLScoreServerRequest *request = [[CLScoreServerRequest alloc] initWithGameName:@"DemoGame 3" delegate:self];
	
	NSString *cat = @"easy2";

	int score = CCRANDOM_0_1() * 20000;
	int category_idx = CCRANDOM_0_1() * 3;
	switch( category_idx ) {
		case 0:
			cat = @"easy2";
			break;
		case 1:
			cat = @"medium";
			break;
		case 2:
			cat = @"hard";
			break;
	}
	
	NSLog(@"Requesting Rank for Score %d in category %@", score, cat);

	// Request Ranking for a given score and category
	[request requestRankForScore:score andCategory:cat];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[request release];	
}

-(void) requestScore
{
	NSLog(@"Requesting scores...");

	CLScoreServerRequest *request = [[CLScoreServerRequest alloc] initWithGameName:@"DemoGame 3" delegate:self];
	
	NSString *cat = @"easy2";
	
	switch( category ) {
		case kCategoryEasy:
			cat = @"easy2";
			break;
		case kCategoryMedium:
			cat = @"medium";
			break;
		case kCategoryHard:
			cat = @"hard";
			break;
	}

	// The only supported flags as of v0.2 is kQueryFlagByCountry and kQueryFlagByDevice
	tQueryFlags flags = kQueryFlagIgnore;
	if( world == kCountry )
		flags = kQueryFlagByCountry;
	else if(world == kDevice )
		flags = kQueryFlagByDevice;

	// request All time Scores: the only supported version as of v0.2
	// request best 15 scores (limit:15, offset:0)
	[request requestScores:kQueryAllTime limit:15 offset:0 flags:flags category:cat];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[request release];
}

-(void) postScore:(NSInteger)cate
{
	NSLog(@"Posting Score");

	// Create que "post" object for the game "DemoGame 3"
	// The gameKey is the secret key that is generated when you create you game in cocos live.
	// This secret key is used to prevent spoofing the high scores
	CLScoreServerPost *server = [[CLScoreServerPost alloc] initWithGameName:@"DemoGame 3" gameKey:@"f35a4350b63afcb4e87c88b01ecc64b6" delegate:self];

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];

	// Name at random
	NSArray *names = [NSArray arrayWithObjects:@"いすの上に猫がいる", @"Carrière", @"Iñaqui", @"Clemensstraße München ", @"有一只猫在椅子上", nil];
	NSString *name = [names objectAtIndex: CCRANDOM_0_1() * 5];

	// cc_ files are predefined cocoslive fields.
	// set score
	[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:20000] ] forKey:@"cc_score"];

	// set playername
	[dict setObject:name forKey:@"cc_playername"];

	// usr_ are fields that can be modified.
	// set speed
	[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:2000] ] forKey:@"usr_speed"];
	// set angle
	[dict setObject: [NSNumber numberWithInt:[self getRandomWithMax:360] ] forKey:@"usr_angle"];


	// cc_ are fields that cannot be modified. cocos fields
	// set category... it can be "easy", "medium", whatever you want.
	NSString *cat = @"easy2";
	switch(cate) {
		case 0:
			cat = @"easy2";
			break;
		case 1:
			cat = @"medium";
			break;
		case 2:
		default:
			cat = @"hard";
			break;
	}
	
	[dict setObject:cat forKey:@"cc_category"];
	
	NSLog(@"Sending data: %@", dict);

	// You can add a new score to the database
//	[server sendScore:dict];
	
	// Or you can "update" your score instead of adding a new one.
	// The score will be udpated only if it is better than the previous one
	// 
	// "update score" is the recommend way since it can be treated like a profile
	// and it has some benefits like: "tell me if my score was beaten", etc.
	// It also supports "world ranking". eg: "What's my ranking ?"
	[server updateScore:dict];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[server release];
	
	
	// Test for 
}

#pragma mark -
#pragma mark ScorePost Delegate

-(void) scorePostOk: (id) sender
{
	NSLog(@"score post OK");
	if( [sender ranking] != kServerPostInvalidRanking && [sender scoreDidUpdate]) {
		NSString *message = [NSString stringWithFormat:@"World ranking: %d", [sender ranking]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Ok." message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];	
		alert.tag = 2;
		[alert show];
		[alert release];		
		
	}
}

-(void) scorePostFail: (id) sender
{
	NSString *message = nil;
	tPostStatus status = [sender postStatus];
	if( status == kPostStatusPostFailed )
		message = @"Cannot post the score to the server. Retry";
	else if( status == kPostStatusConnectionFailed )
		message = @"Internet connection not available. Enable wi-fi / 3g to post your scores to the server";
	
	NSLog(@"%@", message);

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Score Post Failed" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];	
	alert.tag = 0;
	[alert show];
	[alert release];		
}

#pragma mark -
#pragma mark ScoreRequest Delegate

-(void) scoreRequestRankOk: (id) sender
{
	NSLog(@"score request Rank OK");	
	int rank = [sender parseRank];
	NSLog(@"Ranking: %d", rank);
}

-(void) scoreRequestOk: (id) sender
{
	NSLog(@"score request OK");	
	NSArray *scores = [sender parseScores];	
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:scores];
	
	// use the property (retain is needed)
	self.globalScores = mutable;
		
	[myTableView reloadData];
	
	// Test Rank
	[self requestRank];
}

-(void) scoreRequestFail: (id) sender
{
	NSLog(@"score request fail");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Score Request Failed" message:@"Internet connection not available, cannot view world scores" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];	
	alert.tag = 0;
	[alert show];
	[alert release];	
}


#pragma mark -
#pragma mark Button Delegate
-(void) buttonCallback:(id) sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Score" message:@"A random score will be posted. Select category"
												   delegate:self cancelButtonTitle:nil otherButtonTitles:@"easy", @"medium", @"hard", nil];
	alert.tag = 1;
	[alert show];
	[alert release];	
}

#pragma mark -
#pragma mark Segment Delegate
- (void)segmentAction:(id)sender
{	
	int idx = [sender selectedSegmentIndex];
	// category 
	if( [sender tag] == 0 ) {
		// 0: easy
		// 1: med
		// 2: hard
		category = idx;
	} else if( [sender tag] == 1 ) {
		// 0 = scores world wide
		// 1 = scores by country
		world = idx;
	}

	[self requestScore];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)view clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [view tag] == 1 )
		[self postScore:buttonIndex];
}

#pragma mark -
#pragma mark Application Delegate

-(void) applicationDidFinishLaunching:(UIApplication*)application
{
//	[self initRandom];
//	for( int i=0; i< 15;i++)
//		[self testPost];
//	[self testRequest];


//	[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];

	globalScores = [[NSMutableArray alloc] initWithCapacity:50];
	category = kCategoryEasy;
	world = kAll;
	
	[self initRandom];

	[window makeKeyAndVisible];
	
	[self requestScore];
}

#pragma mark -
#pragma mark Init
-(void) dealloc
{
	[globalScores release];
	[mainView release];
	[window release];
	[super dealloc];
}
@end
