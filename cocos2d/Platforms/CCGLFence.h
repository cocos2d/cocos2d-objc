//
//  CCGLFence.h
//  cocos2d
//
//  Created by Oleg Osin on 1/12/15.
//
//

#import <Foundation/Foundation.h>

@interface CCGLFence : NSObject

/// Is the fence ready to be inserted?
@property(nonatomic, readonly) BOOL isReady;
@property(nonatomic, readonly) BOOL isCompleted;

/// List of completion handlers to be called when the fence completes.
@property(nonatomic, readonly, strong) NSMutableArray *handlers;

-(void)insertFence;

@end

