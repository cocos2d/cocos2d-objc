//
//  main.m
//  MyFirstGame
//
//  Created by Ricardo Quesada on 17/07/09.
//  Copyright Sapus Media 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"MyFirstGameAppDelegate");
    [pool release];
    return retVal;
}
