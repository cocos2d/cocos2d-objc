//
//  CCBKeyframe.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBKeyframe.h"

@implementation CCBKeyframe

@synthesize value;
@synthesize time;
@synthesize easingType;
@synthesize easingOpt;

- (void) dealloc
{
    self.value = NULL;
    [super dealloc];
}

@end
