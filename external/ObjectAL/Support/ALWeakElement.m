//
//  ALWeakElement.m
//  cocos2d-ios
//
//  Created by Philippe Hausler on 7/1/14.
//
//

#import "ALWeakElement.h"

@implementation ALWeakElement

- (NSUInteger)hash
{
    return [self.object hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[ALWeakElement class]])
    {
        return [self.object isEqual:[(ALWeakElement *)object object]];
    }
    else
    {
        return [self.object isEqual:object];
    }
}

@end
