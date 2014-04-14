//
//  CCBAnimationManager+FrameAnimation.m
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCBAnimationManager+FrameAnimation.h"

@implementation CCBAnimationManager (FrameAnimation)

- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop{
    
    float nextTime = 0.0f;
    NSMutableArray *keyFrames = [[NSMutableArray alloc] init];
    
    for(NSString* frame in animFrames) {
        // Create Frame(s)
        NSDictionary* frameDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   frame, @"value",
                                   [NSNumber numberWithFloat:nextTime], @"time",
                                   nil];
        
        [keyFrames addObject:frameDict];
        nextTime+=delay;
    }
    
    // Return to first frame
    NSDictionary* frameDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [animFrames firstObject], @"value",
                               [NSNumber numberWithFloat:(nextTime+delay)], @"time",
                               nil];
    
    [keyFrames addObject:frameDict];
    
    // Add Animation Sequence
    [self addKeyFramesForSequenceNamed:name propertyType:CCBSequencePropertyTypeSpriteFrame frameArray:keyFrames node:node loop:loop];
}

@end
