//
//  CCTouchEvent.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CCTouchEvent : NSObject

@property(nonatomic) NSTimeInterval timestamp;
@property(nonatomic, readonly) NSMutableDictionary* allTouches;
@property(nonatomic, readonly) NSMutableSet* currentTouches; // CCTouches

- (id)init;

- (void)updateTouchesBegan:(NSSet*)touches;
- (void)updateTouchesMoved:(NSSet*)touches;
- (void)updateTouchesEnded:(NSSet*)touches;
- (void)updateTouchesCancelled:(NSSet*)touches;

@end
