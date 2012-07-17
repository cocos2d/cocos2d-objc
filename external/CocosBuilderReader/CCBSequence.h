//
//  CCBSequence.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCBSequenceProperty;

@interface CCBSequence : NSObject
{
    float duration;
    NSString* name;
    int sequenceId;
    int chainedSequenceId;
    
}

@property (nonatomic,assign) float duration;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) int sequenceId;
@property (nonatomic,assign) int chainedSequenceId;

@end
