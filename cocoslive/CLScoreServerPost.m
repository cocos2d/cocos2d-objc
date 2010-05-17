/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CLScoreServerPost.h"
#import "ccMacros.h"

// free function used to sort
NSInteger alphabeticSort(id string1, id string2, void *reverse)
{
    if ((NSInteger *)reverse == NO)
        return [string2 localizedCaseInsensitiveCompare:string1];
    return [string1 localizedCaseInsensitiveCompare:string2];
}


@interface CLScoreServerPost (Private)
-(void) addValue:(NSString*)value key:(NSString*)key;
-(void) calculateHashAndAddValue:(id)value key:(NSString*)key;
-(NSString*) getHashForData;
-(NSData*) getBodyValues;
-(NSString*) encodeData:(NSString*)data;
-(NSMutableURLRequest *) scoreServerRequestWithURLString:(NSString *)url;
-(BOOL) submitScore:(NSDictionary*)dict forUpdate:(BOOL)isUpdate;
@end


@implementation CLScoreServerPost

@synthesize postStatus = postStatus_;
@synthesize ranking = ranking_;
@synthesize scoreDidUpdate = scoreDidUpdate_;
@synthesize connection = connection_;

+(id) serverWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id) delegate
{
	return [[[self alloc] initWithGameName:name gameKey:key delegate:delegate] autorelease];
}

-(id) initWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id)aDelegate
{
	self = [super init];
	if( self ) {
		gameKey = [key retain];
		gameName = [name retain];
		bodyValues = [[NSMutableArray arrayWithCapacity:5] retain];
		delegate = [aDelegate retain];
		receivedData = [[NSMutableData data] retain];
		
		ranking_ = kServerPostInvalidRanking;
	}
	
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"deallocing %@", self);
	[delegate release];
	[gameKey release];
	[gameName release];
	[bodyValues release];
	[receivedData release];
	[connection_ release];
	[super dealloc];
}


#pragma mark ScoreServer send scores
-(BOOL) sendScore: (NSDictionary*) dict 
{
    return [self submitScore:dict forUpdate:NO];
}

-(BOOL) updateScore: (NSDictionary*) dict
{	
    if (![dict objectForKey:@"cc_playername"]) {
		// fail. cc_playername + cc_device_id are needed to update an score
		[NSException raise:@"cocosLive:updateScore" format:@"cc_playername not found"]; 
	}
    return [self submitScore:dict forUpdate:YES];
}

-(BOOL) submitScore: (NSDictionary*)dict forUpdate:(BOOL)isUpdate
{	
    [receivedData setLength:0];
	[bodyValues removeAllObjects];
	
	// reset status
	postStatus_ = kPostStatusOK;
		
	// create the request
	NSMutableURLRequest *post = [self scoreServerRequestWithURLString:(isUpdate ? SCORE_SERVER_UPDATE_URL : SCORE_SERVER_SEND_URL)];
	
	CC_MD5_Init( &md5Ctx);

    // hash SHALL be calculated in certain order
	NSArray *keys = [dict allKeys];
	int reverseSort = NO;
	NSArray *sortedKeys = [keys sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	for( id key in sortedKeys )
		[self calculateHashAndAddValue:[dict objectForKey:key] key:key];    

    // device id is hashed to prevent spoofing this same score from different devices
	// one way to prevent a replay attack is to send cc_id & cc_time and use it as primary keys
    
	[self addValue:[[UIDevice currentDevice] uniqueIdentifier] key:@"cc_device_id"];
	[self addValue:gameName key:@"cc_gamename"];
	[self addValue:[self getHashForData] key:@"cc_hash"];
	[self addValue:SCORE_SERVER_PROTOCOL_VERSION key:@"cc_prot_ver"];
    
	[post setHTTPBody: [self getBodyValues] ];
	
	// create the connection with the request
	// and start loading the data
	self.connection=[[NSURLConnection alloc] initWithRequest:post delegate:self];
	
	if ( ! connection_)
		return NO;
	
	return YES;
}

-(NSMutableURLRequest *) scoreServerRequestWithURLString:(NSString *)url {
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:10.0];
	
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    return request;
}

-(void) calculateHashAndAddValue:(id) value key:(NSString*) key
{
	NSString *val;
	// value shall be a string or nsnumber
	if( [value respondsToSelector:@selector(stringValue)] )
		val = [value stringValue];
	else if( [value isKindOfClass:[NSString class]] )
		val = value;
	else
		[NSException raise:@"Invalid format for value" format:@"Invalid format for value. addValue"];

	[self addValue:val key:key];
	
	const char * data = [val UTF8String];
	CC_MD5_Update( &md5Ctx, data, strlen(data) );
}

-(void) addValue:(NSString*)value key:(NSString*) key
{

	NSString *encodedValue = [self encodeData:value];
	NSString *encodedKey = [self encodeData:key];
		
	[bodyValues addObject: [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue] ];
}

-(NSData*) getBodyValues {
	NSMutableData *data = [[NSMutableData alloc] init];
	
	BOOL first=YES;
	for( NSString *s in bodyValues ) {
		if( !first)
			[data appendBytes:"&" length:1];
		
		[data appendBytes:[s UTF8String] length:[s length]];
		first = NO;
	}
	
	return [data autorelease];
}

-(NSString*) getHashForData
{
	NSString *ret;
	unsigned char  pTempKey[16];
	
	// update the hash with the secret key
	const char *data = [gameKey UTF8String];
	CC_MD5_Update(&md5Ctx, data, strlen(data));
	
	// then get the hash
	CC_MD5_Final( pTempKey, &md5Ctx);

//	NSData *nsdata = [NSData dataWithBytes:pTempKey length:16];
	ret = [NSString stringWithString:@""];
	for( int i=0;i<16;i++) {
		ret = [NSString stringWithFormat:@"%@%02x", ret, pTempKey[i] ];
	}

	return ret;
}

-(NSString*) encodeData:(NSString*) data
{
	NSString *newData;
	
	newData = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	// '&' and '=' should be encoded manually
	newData = [newData stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	newData = [newData stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];

	return newData;
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
	
//	NSString *dataString = [NSString stringWithCString:[data bytes] length: [data length]];
//	CCLOG( @"data: %@", dataString);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	CCLOG(@"Connection failed");

	// wifi problems ?
	postStatus_ = kPostStatusConnectionFailed;

    // release the connection
	self.connection = nil;
	
	if( [delegate respondsToSelector:@selector(scorePostFail:) ] )
		[delegate scorePostFail:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	// release the connection
	self.connection = nil;
	
//	NSString *dataString = [NSString stringWithCString:[receivedData bytes] length: [receivedData length]];
	NSString *dataString = [NSString stringWithCString:[receivedData bytes] encoding: NSASCIIStringEncoding];
	if( [dataString isEqual: @"OK"] ) {
		
		// Ok
		postStatus_ = kPostStatusOK;

		if( [delegate respondsToSelector:@selector(scorePostOk:) ] )
			[delegate scorePostOk:self];

	} else if( [dataString hasPrefix:@"OK:"] ) {
		// parse ranking and other possible answers
		NSArray *values = [dataString componentsSeparatedByString:@":"];
		NSArray *answer = [ [values objectAtIndex:1] componentsSeparatedByString:@","];
		NSEnumerator *nse = [answer objectEnumerator];
		
		// Create a holder for each line we are going to work with
		NSString *line;
		
		// Loop through all the lines in the lines array processing each one
		while( (line = [nse nextObject]) ) {
			NSArray *keyvalue = [line componentsSeparatedByString:@"="];
//			NSLog(@"%@",keyvalue);
			if( [[keyvalue objectAtIndex:0] isEqual:@"ranking"] ) {
				ranking_ = [[keyvalue objectAtIndex:1] intValue];
			} else if( [[keyvalue objectAtIndex:0] isEqual:@"score_updated"] ) {
				scoreDidUpdate_ = [[keyvalue objectAtIndex:1] boolValue];
			}
			
		}
		if( [delegate respondsToSelector:@selector(scorePostOk:) ] )
			[delegate scorePostOk:self];
		
	} else {
		
		CCLOG(@"Post Score failed. Reason: %@", dataString);

		// Error parsing answer
		postStatus_ = kPostStatusPostFailed;

		if( [delegate respondsToSelector:@selector(scorePostFail:) ] )
			[delegate scorePostFail:self];
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
