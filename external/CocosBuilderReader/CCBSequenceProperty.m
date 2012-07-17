//
//  CCBSequenceProperty.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBSequenceProperty.h"

@implementation CCBSequenceProperty

@synthesize name;
@synthesize type;
@synthesize keyframes;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    keyframes = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc
{
    [keyframes release];
    self.name = NULL;
    
    [super dealloc];
}

@end
