//
//  CCLabelTextFormatter.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 17.11.13.
//
//

#import "CCLabelTextFormatter.h"

@implementation CCLabelTextFormatter
+ (BOOL) multilineText:(id<CCLabelTextFormatProtocol>)label
{
    return NO;
}

+ (BOOL) alignText:(id<CCLabelTextFormatProtocol>)label
{
    return NO;
}

+ (BOOL) makeStringSprites:(id<CCLabelTextFormatProtocol>)label
{
    return NO;
}


@end
