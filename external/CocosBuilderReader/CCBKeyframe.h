//
//  CCBKeyframe.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBKeyframe : NSObject
{
    id value;
    float time;
    int easingType;
    float easingOpt;
}

@property (nonatomic,retain) id value;
@property (nonatomic,assign) float time;
@property (nonatomic,assign) int easingType;
@property (nonatomic,assign) float easingOpt;

@end
