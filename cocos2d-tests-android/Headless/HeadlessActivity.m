//
//  HeadlessActivity.m
//  Headless
//
//  Created by Philippe Hausler on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "HeadlessActivity.h"
#import "MainMenu.h"
#import "TestbedSetup.h"

@implementation HeadlessActivity

-(void)run
{
	[super run];
	
	[[TestbedSetup sharedSetup] setupApplication];
}

//- (BOOL)onKeyUp:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
//{
//    if ([[CCDirector currentDirector] runningScene] == [self startScene])
//    {
//        return NO;
//    }
//    
//    [self runOnGameThread:^{
//        CCTransition* transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionRight duration:0.3];
//        [[CCDirector currentDirector] presentScene:[MainMenu scene] withTransition:transition];
//    }];
//    
//    return YES;
//}

@end
