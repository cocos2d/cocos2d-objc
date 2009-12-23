/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// 3rd party imports
#import "CJSONDeserializer.h"

// local imports
#import "CLScoreServerPost.h"
#import "CLScoreServerRequest.h"
#import "ccMacros.h"

@implementation CLScoreServerRequest
+(id) serverWithGameName:(NSString*) name delegate:(id)delegate
{
	return [[[self alloc] initWithGameName:name delegate:delegate] autorelease];
}

-(id) initWithGameName:(NSString*) name delegate:(id)aDelegate
{	
	self = [super init];
	if( self ) {
		gameName = [[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
		delegate = [aDelegate retain];
		receivedData = [[NSMutableData data] retain];
	}	
	return self;
}

-(void) dealloc
{
	CCLOG( @"deallocing %@", self);
	
	[delegate release];
	[gameName release];
	[receivedData release];
	[super dealloc];
}

-(BOOL) requestScores:(tQueryType)type
				limit:(int)limit
			   offset:(int)offset
				flags:(tQueryFlags)flags
			 category:(NSString*)category
{
	// create the request	
	[receivedData setLength:0];
	
	// it's not a call for rank
	reqRankOnly = NO;
	
	NSString *device = @"";
	if( flags & kQueryFlagByDevice )
		device = [[UIDevice currentDevice] uniqueIdentifier];
	
	// arguments:
	//  query: type of query
	//  limit: how many scores are being requested. Default is 25. Maximun is 100
	//  offset: offset of the scores
	//  flags: bring only country scores, world scores, etc.
	//  category: string user defined string used to filter
	NSString *url= [NSString stringWithFormat:@"%@?gamename=%@&querytype=%d&offset=%d&limit=%d&flags=%d&category=%@&device=%@",
					SCORE_SERVER_REQUEST_URL,
					gameName,
					type,
					offset,
					limit,
					flags,
					[category stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
					device
					];
	
	//	NSLog(@"%@", url);
	
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
									   timeoutInterval:10.0];
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (! theConnection)
		return NO;
	
	// XXX: Don't release 'theConnection' here
	// XXX: It will be released by the delegate
	
	return YES;
}

-(BOOL) requestScores:(tQueryType)type
				limit:(int)limit
			   offset:(int)offset
				flags:(tQueryFlags)flags
{
	// create the request	
	[receivedData setLength:0];
	
	// arguments:
	//  query: type of query
	//  limit: how many scores are being requested. Maximun is 100
	//  offset: offset of the scores
	//  flags: bring only country scores, world scores, etc.
	return [self requestScores:type limit:limit offset:offset flags:flags category:@""];
}

-(NSArray*) parseScores
{	
	NSArray *array = nil;
	NSError *error = nil;
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:&error];
	
//	NSLog(@"r: %@", dictionary);
	if( ! error ) {
		array = [dictionary objectForKey:@"scores"];
	} else {
		CCLOG(@"Error parsing scores: %@", error);
	}
	return array;
}

#pragma mark Request rank for score

-(BOOL) requestRankForScore:(int)score andCategory:(NSString*)category {
	// create the request	
	[receivedData setLength:0];
	
	reqRankOnly = YES;
	
	// arguments:
	//  score: score for which you need rank
	//  category: user defined string used to filter
	NSString *url= [NSString stringWithFormat:@"%@?gamename=%@&category=%@&score=%d",
					SCORE_SERVER_GETRANK_URL,
					gameName,
					[category stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
					score
					];
	
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
									   timeoutInterval:10.0];
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (! theConnection)
		return NO;
	
	// XXX: Don't release 'theConnection' here
	// XXX: It will be released by the delegate
	
	return YES;
}

-(int) parseRank {
//	NSString *rankStr = [NSString stringWithCString:[receivedData bytes] length: [receivedData length]];
	NSString *rankStr = [NSString stringWithCString:[receivedData bytes] encoding: NSASCIIStringEncoding];
	
	// creating trimmed string by trimming everything that's not numbers from the receivedData
	NSString *trimmedStr = [rankStr stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	
	int scoreInt = [trimmedStr intValue];
	
	return scoreInt;
}


#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// release the connection, and the data object
    [connection release];
	
	CCLOG(@"Error getting scores: %@", error);
	
	if( [delegate respondsToSelector:@selector(scoreRequestFail:) ] )
		[delegate scoreRequestFail:self];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// release the connection, and the data object
    [connection release];
	
	if(reqRankOnly) {		
		// because it's request for rank, different delegate method is called scoreRequestRankOk:
		// if connection failed the same delegate method is used as for standard scores - scoreRequestFail:
		if( [delegate respondsToSelector:@selector(scoreRequestRankOk:) ] ) {
			[delegate scoreRequestRankOk:self];	
		}
	} else {
		if( [delegate respondsToSelector:@selector(scoreRequestOk:) ] ) {
			[delegate scoreRequestOk:self];	
		}
		
	}
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
			willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{	
    NSURLRequest *newRequest=request;
    if (redirectResponse) {
        newRequest=nil;
    }
    return newRequest;
}

@end
