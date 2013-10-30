//
//  CCDirector_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCDirector.h"

@interface CCDirector ()

/** Whether or not the replaced scene will receive the cleanup message.
 If the new scene is pushed, then the old scene won't receive the "cleanup" message.
 If the new scene replaces the old one, the it will receive the "cleanup" message.
 @since v0.99.0
 */
@property (nonatomic, readonly) BOOL sendCleanupToScene;

/** This object will be visited after the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 @since v0.99.5
 */
@property (nonatomic, readwrite, strong) id	notificationNode;

/** CCScheduler associated with this director
 @since v2.0
 */
@property (nonatomic,readwrite,strong) CCScheduler *scheduler;

/** CCActionManager associated with this director
 @since v2.0
 */
@property (nonatomic,readwrite,strong) CCActionManager *actionManager;

/** Sets the glViewport*/
-(void) setViewport;

/// XXX: missing description
-(float) getZEye;

/** Pops out all scenes from the queue until it reaches `level`.
 If level is 0, it will end the director.
 If level is 1, it will pop all scenes until it reaches to root scene.
 If level is <= than the current stack level, it won't do anything.
 */
-(void) popToSceneStackLevel:(NSUInteger)level;

/** Draw the scene.
 This method is called every frame. Don't call it manually.
 */
-(void) drawScene;

// helper
/** creates the Stats labels */
-(void) createStatsLabel;

@end

// optimization. Should only be used to read it. Never to write it.
extern NSUInteger __ccNumberOfDraws;
