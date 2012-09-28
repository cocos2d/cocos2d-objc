//
//  SimpleSprite.h
//  cocos2d-ios
//
//  Created by Goffredo Marocchi on 9/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SimpleSprite : CCSprite {
    
    CCRenderTexture * rt;
}

@property (nonatomic, readwrite) BOOL disableFix;

@end
