//
//  GameObject.m
//  cocos2d-demo
//
//  Created by Lars Birkemose on 22/07/15.
//  Copyright 2015 Cocos2D. All rights reserved.
//
// -----------------------------------------------------------------

#import "GameObject.h"

// -----------------------------------------------------------------

@implementation GameObject

// -----------------------------------------------------------------

+ (instancetype)gameObjectWithImageNamed:(NSString *)imageName
{
    return [[self alloc] initWithImageNamed:imageName];
}

// -----------------------------------------------------------------

- (CGRect)rect
{
    CGRect result;
    
    result.origin = ccpSub(self.position, (CGPoint){self.contentSize.width * 0.5, self.contentSize.height * 0.5});
    result.size = self.contentSize;

    return result;
}

// -----------------------------------------------------------------

@end





