//
//  CCResponder__Private.h
//  cocos2d-ios
//
//  Created by Benjamin Encz on 05/12/13.
//
//

#import "CCResponder.h"

@interface CCResponder ()

/* Stores queued & grouped touches for the touchesBegan event. Touches will be queued & grouped if multitouch is enabled on a CCResponder and multiple touches occur.
 @since v3.0
 */
@property (nonatomic, strong) NSMutableSet* queuedTouchesBegan;

/* Stores queued & grouped touches for the touchesMoved event. Touches will be queued & grouped if multitouch is enabled on a CCResponder and multiple touches occur.
 @since v3.0
 */
@property (nonatomic, strong) NSMutableSet* queuedTouchesMoved;

/* Stores queued & grouped touches for the touchesCancelled event. Touches will be queued & grouped if multitouch is enabled on a CCResponder and multiple touches occur.
 @since v3.0
 */
@property (nonatomic, strong) NSMutableSet* queuedTouchesCancelled;

/* Stores queued & grouped touches for the touchesEnded event. Touches will be queued & grouped if multitouch is enabled on a CCResponder and multiple touches occur.
 @since v3.0
 */
@property (nonatomic, strong) NSMutableSet* queuedTouchesEnded;

/* Performs all queued touch events. When this method is called the touch event methods (touchesMoved, etc.) will be called on the CCResponder.
 @since v3.0
 */
- (void)performQueuedTouchesWithEvent:(UIEvent*)event;

@end
