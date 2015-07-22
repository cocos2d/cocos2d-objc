//
//  GameObject.h
//  cocos2d-demo
//
//  Created by Lars Birkemose on 22/07/15.
//  Copyright 2015 Cocos2D. All rights reserved.
//
// -----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------

@interface GameObject : CCSprite

// -----------------------------------------------------------------

@property (nonatomic, readonly) CGRect rect;

// -----------------------------------------------------------------

+ (instancetype)gameObjectWithImageNamed:(NSString *)imageName;

// -----------------------------------------------------------------

@end




