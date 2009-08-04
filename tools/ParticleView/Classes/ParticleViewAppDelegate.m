//
//  ParticleViewAppDelegate.m
//  ParticleView
//
//  Created by Stas Skuratov on 7/14/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "ParticleViewAppDelegate.h"
#import "Constants.h"

@implementation ParticleViewAppDelegate

@synthesize window;
@synthesize navController;
@synthesize settings1;
@synthesize settings2;
@synthesize settings3;
@synthesize settings4;
@synthesize settings5;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filePath1 = [documentDirectory stringByAppendingPathComponent:kFileName1];
	NSString *filePath2 = [documentDirectory stringByAppendingPathComponent:kFileName2];
	NSString *filePath3 = [documentDirectory stringByAppendingPathComponent:kFileName3];
	NSString *filePath4 = [documentDirectory stringByAppendingPathComponent:kFileName4];
	NSString *filePath5 = [documentDirectory stringByAppendingPathComponent:kFileName5];
	NSLog(filePath1);
	
	// Load saved settings
	settings1 = [[NSMutableArray alloc] initWithContentsOfFile:filePath1];
	settings2 = [[NSMutableArray alloc] initWithContentsOfFile:filePath2];
	settings3 = [[NSMutableArray alloc] initWithContentsOfFile:filePath3];
	settings4 = [[NSMutableArray alloc] initWithContentsOfFile:filePath4];
	settings5 = [[NSMutableArray alloc] initWithContentsOfFile:filePath5];

	// Fill with the deafult values if the file doesn't exist
	if ([settings1 count] == 0)
	{
		[settings1 release];
		settings1 = [[NSMutableArray alloc] init];
		[self initWithDefaultValues:settings1];
	}
	if ([settings2 count] == 0)
	{
		[settings2 release];
		settings2 = [[NSMutableArray alloc] init];
		[self initWithDefaultValues:settings2];
	}
	if ([settings3 count] == 0)
	{
		[settings3 release];
		settings3 = [[NSMutableArray alloc] init];
		[self initWithDefaultValues:settings3];
	}
	if ([settings4 count] == 0)
	{
		[settings4 release];
		settings4 = [[NSMutableArray alloc] init];
		[self initWithDefaultValues:settings4];
	}
	if ([settings5 count] == 0)
	{
		[settings5 release];
		settings5 = [[NSMutableArray alloc] init];
		[self initWithDefaultValues:settings5];
	}
	
	[window addSubview:navController.view];
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)dealloc 
{
	[settings1 release];
	[settings2 release];
	[settings3 release];
	[settings4 release];
	[settings5 release];
	[navController release];
    [window release];
    [super dealloc];
}

- (void) save
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filePath1 = [documentDirectory stringByAppendingPathComponent:kFileName1];
	NSString *filePath2 = [documentDirectory stringByAppendingPathComponent:kFileName2];
	NSString *filePath3 = [documentDirectory stringByAppendingPathComponent:kFileName3];
	NSString *filePath4 = [documentDirectory stringByAppendingPathComponent:kFileName4];
	NSString *filePath5 = [documentDirectory stringByAppendingPathComponent:kFileName5];

	[settings1 writeToFile:filePath1 atomically:YES];
	[settings2 writeToFile:filePath2 atomically:YES];
	[settings3 writeToFile:filePath3 atomically:YES];
	[settings4 writeToFile:filePath4 atomically:YES];
	[settings5 writeToFile:filePath5 atomically:YES];
}

- (void) initWithDefaultValues: (NSMutableArray *)array
{
	[array addObject:__enabled];
	[array addObject:__duration];
	[array addObject:__gravityX];
	[array addObject:__gravityY];
	[array addObject:__angle];
	[array addObject:__angleVar];
	[array addObject:__accel];
	[array addObject:__accelVar];
	[array addObject:__emitterPosX];
	[array addObject:__emitterPosY];
	[array addObject:__emitterPosVarX];
	[array addObject:__emitterPosVarY];
	[array addObject:__life];
	[array addObject:__lifeVar];
	[array addObject:__speed];
	[array addObject:__speedVar];
	[array addObject:__startSize];
	[array addObject:__startSizeVar];
	[array addObject:__endSize];
	[array addObject:__startR];
	[array addObject:__startG];
	[array addObject:__startB];
	[array addObject:__startA];
	[array addObject:__startRVar];
	[array addObject:__startGVar];
	[array addObject:__startBVar];
	[array addObject:__startAVar];
	[array addObject:__endR];
	[array addObject:__endG];
	[array addObject:__endB];
	[array addObject:__endA];
	[array addObject:__endRVar];
	[array addObject:__endGVar];
	[array addObject:__endBVar];
	[array addObject:__endAVar];
	[array addObject:__totalParticles];
	[array addObject:__textureNumber];
	[array addObject:__startSpin];
	[array addObject:__startSpinVar];
	[array addObject:__endSpin];
	[array addObject:__endSpinVar];
}

@end
