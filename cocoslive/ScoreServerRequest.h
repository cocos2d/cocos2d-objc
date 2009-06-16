/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <UIKit/UIKit.h>

// cocoslive definitions
#import "cocoslive.h"

// Server URL
#if USE_LOCAL_SERVER
#define SCORE_SERVER_REQUEST_URL @"http://localhost:8080/api/get-scores"
#else
#define SCORE_SERVER_REQUEST_URL @"http://www.cocoslive.net/api/get-scores"
#endif

/** Type of predefined Query */
typedef enum {
	kQueryIgnore = 0,
	kQueryDay = 1,
	kQueryWeek = 2,
	kQueryMonth = 3,
	kQueryAllTime = 4,
} tQueryType;

/** Flags that can be added to the query */
typedef enum {
	kQueryFlagIgnore = 0,
	kQueryFlagByCountry = 1 << 0,
	kQueryFlagByDevice = 1 << 1,
} tQueryFlags;

/**
 * Handles the Request Scores to the cocos live server
 */
@interface ScoreServerRequest : NSObject {
	
	/// game name, used as a login name.
	NSString	*gameName;

	/// delegate instance of fetch score
	id			delegate;

	// data received
	NSMutableData *receivedData;
}

/** creates a ScoreServerRequest server with a game name*/
+(id) serverWithGameName:(NSString*) name delegate:(id)delegate;

/** initializes a ScoreServerRequest with a game name*/
-(id) initWithGameName:(NSString*) name delegate:(id)delegate;

/** request scores from server using a predefined query. This is an asyncronous request.
 * limit: how many scores are being requested. Maximun is 100
 * flags: can be kQueryFlagByCountry (fetches only scores from country)
 * category: an NSString. For example: 'easy', 'medium', 'type1'... When requesting scores, they can be filtered by this field.
 */
-(BOOL) requestScores: (tQueryType) type limit:(int)limit offset:(int)offset flags:(tQueryFlags)flags category:(NSString*)category;

/** request scores from server using a predefined query. This is an asyncronous request.
 * limit: how many scores are being requested. Maximun is 100
 * flags: can be kQueryFlagByCountry (fetches only scores from country)
 */
-(BOOL) requestScores: (tQueryType) type limit:(int)limit offset:(int)offset flags:(tQueryFlags)flags;

/** parse the received JSON scores and convert it to objective-c objects */
-(NSArray*) parseScores;
@end

/** CocosLiveRequest protocol */
@protocol CocosLiveRequestDelegate <NSObject>
-(void) scoreRequestOk:(id) sender;
-(void) scoreRequestFail:(id) sender;
@end
