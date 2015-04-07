//
//  CCBAnimationManager+FrameAnimation.m
//  cocos2d-ios
//
//  Created by Martin Walsh on 14/04/2014.
//
//

#import "CCAnimationManager+FrameAnimation.h"
#import "CCAnimationManager_Private.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache_Private.h"
#import "CCFileLocator.h"
#import "CCFile.h"

@implementation CCAnimationManager (FrameAnimation)

- (void)animationWithSpriteFrames:animFrames delay:(float)delay name:(NSString*)name node:(CCNode*)node loop:(BOOL)loop{
    
    float nextTime = 0.0f;
    NSMutableArray *keyFrames = [[NSMutableArray alloc] init];
    
    for(NSString* frame in animFrames) {
        // Create Frame(s)
        NSDictionary* frameDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   frame, @"value",
                                   [NSNumber numberWithFloat:nextTime], @"time",
                                   nil];
        
        [keyFrames addObject:frameDict];
        nextTime+=delay;
    }
    
    // Return to first frame
    NSDictionary* frameDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [animFrames firstObject], @"value",
                               [NSNumber numberWithFloat:(nextTime)], @"time",
                               nil];
    
    [keyFrames addObject:frameDict];
    
    // Add Animation Sequence
    [self addKeyFramesForSequenceNamed:name propertyType:CCBSequencePropertyTypeSpriteFrame frameArray:keyFrames node:node loop:loop];
}

#pragma mark Legacy Animation Support
- (void)parseVersion1:(NSDictionary*)animations node:(CCNode*)node {
    
	NSArray* animationNames = [animations allKeys];
    NSMutableArray* animFrames = [[NSMutableArray alloc] init];
    
	for( NSString *name in animationNames ) {
        
        [animFrames removeAllObjects];
        
		NSDictionary* animationDict = [animations objectForKey:name];
		NSArray *frameNames = [animationDict objectForKey:@"frames"];
        
		float delay = [[animationDict objectForKey:@"delay"] floatValue];

		if ( frameNames == nil ) {
			CCLOG(@"Animation '%@' found in dictionary without any frames - Skipping", name);
			continue;
		}

		for( NSString *frameName in frameNames ) {
			CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithImageNamed:frameName];
			
			if ( !spriteFrame ) {
				CCLOG(@"Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache.  This frame will not be added to the animation - Skipping", name, frameName);
				continue;
			}
            
            [animFrames addObject:frameName];
		}
        
        [self animationWithSpriteFrames:animFrames delay:delay name:name node:node loop:YES];
	}
}

- (void)parseVersion2:(NSDictionary*)animations node:(CCNode*)node {
    
	NSArray* animationNames = [animations allKeys];
    NSMutableArray* animFrames = [[NSMutableArray alloc] init];
	
	for( NSString *name in animationNames ) {
        
        [animFrames removeAllObjects];
		NSDictionary* animationDict = [animations objectForKey:name];
        
		//int loops = [[animationDict objectForKey:@"loops"] intValue];
		//BOOL restoreOriginalFrame = [[animationDict objectForKey:@"restoreOriginalFrame"] boolValue];
        
		NSArray *frameArray = [animationDict objectForKey:@"frames"];
		
		if ( frameArray == nil ) {
			CCLOG(@"Animation '%@' found in dictionary without any frames - Skipping", name);
			continue;
		}
        
		for( NSDictionary *entry in frameArray ) {
			NSString *spriteFrameName = [entry objectForKey:@"spriteframe"];
			CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithImageNamed:spriteFrameName];
			
			if ( !spriteFrame ) {
				CCLOG(@"Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache.  This frame will not be added to the animation - Skipping", name, spriteFrameName);
				continue;
			}
            
            [animFrames addObject:spriteFrameName];
            
			//float delayUnits = [[entry objectForKey:@"delayUnits"] floatValue];
			//NSDictionary *userInfo = [entry objectForKey:@"notification"];
		}
		
		float delayPerUnit = [[animationDict objectForKey:@"delayPerUnit"] floatValue];

        [self animationWithSpriteFrames:animFrames delay:delayPerUnit name:name node:node loop:YES];
	}
}

- (void)addAnimationsWithDictionary:(NSDictionary *)dictionary node:(CCNode*)node {
	NSDictionary *animations = [dictionary objectForKey:@"animations"];
    
	if ( animations == nil ) {
		CCLOG(@"No animations were found in dictionary.");
		return;
	}
	
	NSUInteger version = 1;
	NSDictionary *properties = [dictionary objectForKey:@"properties"];
	if( properties ) {
		version = [[properties objectForKey:@"format"] intValue];
    }
	
	NSArray *spritesheets = [properties objectForKey:@"spritesheets"];
    
    #warning TODO uses old spriteframe cache API
    // Ensure Sheets Loaded
	for( NSString *name in spritesheets ) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:name];
    }
    
	switch (version) {
		case 1:
			[self parseVersion1:animations node:node];
			break;
		case 2:
			[self parseVersion2:animations node:node];
			break;
		default:
			NSAssert(NO, @"Invalid animation format.");
	}
}


- (void)addAnimationsWithFile:(NSString *)plistFile node:(CCNode*)node {
    NSError *err = nil;
    
    CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:plistFile error:&err];
    NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
    
    NSDictionary *dict = [file loadPlist:&err];
    NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);
    
	[self addAnimationsWithDictionary:dict node:node];
}

@end
