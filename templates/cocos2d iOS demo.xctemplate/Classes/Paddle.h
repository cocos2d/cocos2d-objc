//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameTypes.h"

// -----------------------------------------------------------------

typedef NS_ENUM(NSUInteger, PaddleSide)
{
    PaddleSideLeft,
    PaddleSideRight,
    PaddleSideInvalid
};

// -----------------------------------------------------------------

@interface Paddle : CCSprite

// -----------------------------------------------------------------

@property (nonatomic, readonly) PaddleSide side;
// we are not allowed to retain touches, iOS does that for us, so keep any reference weak
@property (nonatomic, weak) UITouch *touch;
@property (nonatomic, assign) float destination;

// -----------------------------------------------------------------

+ (instancetype)paddleWithSide:(PaddleSide)side;

- (BOOL)validTouchPosition:(CGPoint)position;

// -----------------------------------------------------------------

@end




