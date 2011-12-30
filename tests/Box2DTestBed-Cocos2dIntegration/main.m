//
//  main.m
//  Box2D
//
//  Created by Simon Oliver on 14/01/2009.
//  Copyright HandCircus 2009. All rights reserved.
//

//
// File modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"Box2DAppDelegate");
    [pool release];
    return retVal;
}
