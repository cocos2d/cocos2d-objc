//
//  CCBSequence.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBSequence.h"

@implementation CCBSequence

@synthesize duration;
@synthesize name;
@synthesize sequenceId;
@synthesize chainedSequenceId;


- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    return self;
}

- (void) dealloc
{
    self.name = NULL;
    [super dealloc];
}

@end
