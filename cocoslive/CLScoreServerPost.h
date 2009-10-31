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


#import <UIKit/UIKit.h>

// for MD5 signing
#import <CommonCrypto/CommonDigest.h>

// cocoslive definitions
#import "cocoslive.h"

// Score Server protocol version
#define SCORE_SERVER_PROTOCOL_VERSION @"1.1"

// Server URL
#ifdef USE_LOCAL_SERVER
#define SCORE_SERVER_SEND_URL @"http://localhost:8080/api/post-score"
#define SCORE_SERVER_UPDATE_URL @"http://localhost:8080/api/update-score"
#else
#define SCORE_SERVER_SEND_URL @"http://www.cocoslive.net/api/post-score"
#define SCORE_SERVER_UPDATE_URL @"http://www.cocoslive.net/api/update-score"
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

enum {
	//! Invalid Ranking. Valid rankins are from 1 to ...
	kServerPostInvalidRanking = 0,
};

/**
 * Handles the Score Post to the cocos live server
 */
@interface CLScoreServerPost : NSObject {
	/// game key. secret shared with the server.
	/// used to sign the values to prevent spoofing.
	NSString	*gameKey;
	
	/// game name, used as a login name.
	NSString	*gameName;

	/// delegate instance of fetch score
	id			delegate;
	
	/// ranking
	NSUInteger	ranking_;
	
	/// score was updated
	BOOL		scoreDidUpdate_;

	/// data received
	NSMutableData *receivedData;
	
	/// values to send in the POST
	NSMutableArray *bodyValues;
	
	/// status of the request
	tPostStatus		postStatus_;
	
	/// mdt context
	CC_MD5_CTX		md5Ctx;
}

/** status from the score post */ 
@property (nonatomic,readonly) tPostStatus postStatus;
 
/** ranking of your score
 @since v0.7.3
 */
@property (nonatomic,readonly) NSUInteger ranking;

/** whether or not the score was updated
 @since v0.7.3
 */
@property (nonatomic,readonly) BOOL scoreDidUpdate;

/** creates a cocos server with a game name and a game key */
+(id) serverWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id)delegate;

/** initializes a cocos server with a game name and a game key */
-(id) initWithGameName:(NSString*) name gameKey:(NSString*) key delegate:(id)delegate;

/** send the scores to the server. A new entre will be created on the server */
-(BOOL) sendScore: (NSDictionary*) dict;

/** 
 * Sends a score dictionary to the server for updating an existing entry by playername and device id, or creating a new one.
 * The passed dictionary must contain a cc_playername key, otherwise it will raise and exception.
 * @since v0.7.1
 */
-(BOOL) updateScore: (NSDictionary*) dict;

@end

/** CocosLivePost protocol */
@protocol CLPostDelegate <NSObject>
/** callback method that will be called if the post is successful */
-(void) scorePostOk:(id) sender;
/** callback method that will be called if the post fails */
-(void) scorePostFail:(id) sender;
@end
