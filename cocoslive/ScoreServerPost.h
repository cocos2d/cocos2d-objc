/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

// for MD5 signing
#import <CommonCrypto/CommonDigest.h>

// cocoslive definitions
#import "cocoslive.h"

// Score Server protocol version
#define SCORE_SERVER_PROTOCOL_VERSION @"1.0"

// Server URL
#ifdef USE_LOCAL_SERVER
#define SCORE_SERVER_SEND_URL @"http://localhost:8080/api/post-score"
#else
#define SCORE_SERVER_SEND_URL @"http://www.cocoslive.net/api/post-score"
#endif

/// Type of errors from the Post Score request
typedef enum {
	/// post request successful
	kPostStatusOK = 0,
	/// post request failed to establish a connection. wi-fi isn't enabled.
	/// Don't retry when this option is preset
	kPostStatusConnectionFailed = 1,
	/// post request failed to post the score. Server might be busy.
	/// Retry is suggested
	kPostStatusPostFailed = 2,
} tPostStatus;

/**
 * Handles the Score Post to the cocos live server
 */
@interface ScoreServerPost : NSObject {
	/// game key. secret shared with the server.
	/// used to sign the values to prevent spoofing.
	NSString	*gameKey;
	
	/// game name, used as a login name.
	NSString	*gameName;

	/// delegate instance of fetch score
	id			delegate;

	/// data received
	NSMutableData *receivedData;
	
	/// values to send in the POST
	NSMutableArray *bodyValues;
	
	/// status of the request
	tPostStatus		postStatus;
	
	/// mdt context
	CC_MD5_CTX		md5Ctx;
}

@property (readonly) tPostStatus postStatus;

/** creates a cocos server with a game name and a game key */
+(id) serverWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id)delegate;

/** initializes a cocos server with a game name and a game key */
-(id) initWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id)delegate;

/** send the scores to the server */
-(BOOL) sendScore: (NSDictionary*) dict;

@end

/** CocosLivePost protocol */
@protocol CocosLivePostDelegate
-(void) scorePostOk:(id) sender;
-(void) scorePostFail:(id) sender;
@end
