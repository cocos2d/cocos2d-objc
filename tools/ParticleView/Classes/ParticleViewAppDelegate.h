//
//  ParticleViewAppDelegate.h
//  ParticleView
//
//  Created by Stas Skuratov on 7/14/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticleViewAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navController;
	NSMutableArray *settings1;
	NSMutableArray *settings2;
	NSMutableArray *settings3;
	NSMutableArray *settings4;
	NSMutableArray *settings5;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) NSMutableArray *settings1;
@property (nonatomic, retain) NSMutableArray *settings2;
@property (nonatomic, retain) NSMutableArray *settings3;
@property (nonatomic, retain) NSMutableArray *settings4;
@property (nonatomic, retain) NSMutableArray *settings5;

- (void) save;
- (void) initWithDefaultValues: (NSMutableArray *)array;

@end

