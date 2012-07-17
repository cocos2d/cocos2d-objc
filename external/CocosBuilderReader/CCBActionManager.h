//
//  CCBActionManager.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCBSequence;

#pragma mark Delegate

@protocol CCBActionManagerDelegate <NSObject>

- (void) completedAnimationSequenceNamed:(NSString*)name;

@end

#pragma mark Action Manager

@interface CCBActionManager : NSObject
{
    NSMutableArray* sequences;
    NSMutableDictionary* nodeSequences;
    NSMutableDictionary* baseValues;
    int autoPlaySequenceId;
    
    CCNode* rootNode;
    CGSize rootContainerSize;
    
    NSObject<CCBActionManagerDelegate>* delegate;
    CCBSequence* runningSequence;
}
@property (nonatomic,readonly) NSMutableArray* sequences;
@property (nonatomic,assign) int autoPlaySequenceId;
@property (nonatomic,retain) CCNode* rootNode;
@property (nonatomic,assign) CGSize rootContainerSize;
@property (nonatomic,retain) NSObject<CCBActionManagerDelegate>* delegate;
@property (nonatomic,readonly) NSString* runningSequenceName;

- (CGSize) containerSize:(CCNode*)node;

- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq;
- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName;

- (void) runActionsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration;
- (void) runActionsForSequenceNamed:(NSString*)name;
- (void) runActionsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration;

- (void) debug;

@end

#pragma mark Custom Animation Actions

@interface CCBSetSpriteFrame : CCActionInstant <NSCopying>
{
	CCSpriteFrame* spriteFrame;
}
/** creates a Place action with a position */
+(id) actionWithSpriteFrame: (CCSpriteFrame*) sf;
/** Initializes a Place action with a position */
-(id) initWithSpriteFrame: (CCSpriteFrame*) sf;
@end
