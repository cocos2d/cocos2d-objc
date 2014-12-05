//
//  CCTouchEvent.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import <Foundation/Foundation.h>

/** Thin wrapper around platform-specific touch event objects.
  @note You should never create instances of CCTouchEvent.
 */
@interface CCTouchEvent : NSObject

/** Timestamp for this event. */
@property(nonatomic) NSTimeInterval timestamp;
/** A dictionary containing the current touches. The keys are `PlatformTouch` pointers (UITouch on iOS, CCTouchAndroid on Android, NSObject on Mac)
 and the values are CCTouch objects. 
 @see CCTouch */
@property(nonatomic, readonly) NSMutableDictionary* allTouches;
/** The list of touches for this particular event. Items are CCTouch instances.
 @see CCTouch */
@property(nonatomic, readonly) NSMutableSet* currentTouches; // CCTouches

// purposefully undocumented: following methods are for internal use only
- (id)init;

- (void)updateTouchesBegan:(NSSet*)touches;
- (void)updateTouchesMoved:(NSSet*)touches;
- (void)updateTouchesEnded:(NSSet*)touches;
- (void)updateTouchesCancelled:(NSSet*)touches;

@end
