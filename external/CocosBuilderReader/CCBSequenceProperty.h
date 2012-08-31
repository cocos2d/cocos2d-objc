//
//  CCBSequenceProperty.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBSequenceProperty : NSObject
{
    NSString* name;
    int type;
    NSMutableArray* keyframes;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,assign) int type;
@property (nonatomic,readonly) NSMutableArray* keyframes;

@end
