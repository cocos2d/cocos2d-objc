//
//  CCTouchEvent.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/13/14.
//
//

#import "CCTouchEvent.h"
#import "CCDirector.h"
#import "ccMacros.h"

#if __CC_PLATFORM_IOS
#import "Platforms/iOS/CCTouchIOS.h"
#define CCTouch CCTouchIOS

#elif __CC_PLATFORM_ANDROID
#import "Platforms/Android/CCTouchAndroid.h"
#define CCTouch CCTouchAndroid

#endif

#ifndef __CC_TOUCH_MAX
#define __CC_TOUCH_MAX 10
#endif


@implementation CCTouchEvent {
    NSMutableSet* _deadTouches;
}

- (id)init
{
    if((self = [super init]))
    {
        _deadTouches = [[NSMutableSet alloc] init];
        for(int i = 0; i < 10; i++)
        {
            [_deadTouches addObject:[CCTouch touchWithPlatformTouch:nil]];
        }
        
        _allTouches = [[NSMutableDictionary alloc] init];
        _currentTouches = [[NSMutableSet alloc] init];
        return self;
    }
    
    return self;
}

- (void)updateTouchesBegan:(NSSet*)touches
{
    [_currentTouches removeAllObjects];

    // Began touches - move touches from dead pool to allTouches
    for(PlatformTouch* touch in touches)
    {
        CCTouch* ccTouch = [_deadTouches anyObject];
        ccTouch.uiTouch = touch;
        
        [_allTouches setObject:ccTouch forKey:[NSValue valueWithNonretainedObject:touch]];
        
        [_deadTouches removeObject:ccTouch];
    }
    
    // Set currentTouches
    for(PlatformTouch* touch in touches)
    {
        CCTouch* ccTouch = [_allTouches objectForKey:[NSValue valueWithNonretainedObject:touch]];
        if(ccTouch)
        {
            ccTouch.view = (CCGLView*)[CCDirector sharedDirector].view;
            ccTouch.uiTouch = touch;
            [_currentTouches addObject:ccTouch];
        }
    }
}

- (void)updateTouchesMoved:(NSSet*)touches
{
    [_currentTouches removeAllObjects];
    
    // Set currentTouches
    for(PlatformTouch* touch in touches)
    {
        CCTouch* ccTouch = [_allTouches objectForKey:[NSValue valueWithNonretainedObject:touch]];
        if(ccTouch)
        {
            ccTouch.view = (CCGLView*)[CCDirector sharedDirector].view;
            ccTouch.uiTouch = touch;
            [_currentTouches addObject:ccTouch];
        }
    }
}

- (void)updateTouchesEnded:(NSSet*)touches
{
    [_currentTouches removeAllObjects];
    
    NSMutableArray* keys = [[NSMutableArray alloc] init];
    
    // Set currentTouches
    for(PlatformTouch* touch in touches)
    {
        CCTouch* ccTouch = [_allTouches objectForKey:[NSValue valueWithNonretainedObject:touch]];
        if(ccTouch)
        {
            ccTouch.view = (CCGLView*)[CCDirector sharedDirector].view;
            ccTouch.uiTouch = touch;
            [_currentTouches addObject:ccTouch];
        }
        
        [keys addObject:[NSValue valueWithNonretainedObject:touch]];
    }
    
    
    // Ended touches - remove touches from allTouches and place them back into the deadpool
    NSArray* deadTouches = [_allTouches objectsForKeys:keys notFoundMarker:[CCTouch touchWithPlatformTouch:nil]];
    [_deadTouches addObjectsFromArray:deadTouches];
    [_allTouches removeObjectsForKeys:keys];
}

- (void)updateTouchesCancelled:(NSSet*)touches
{
    [_currentTouches removeAllObjects];
    
    NSMutableArray* keys = [[NSMutableArray alloc] init];
    
    // Set currentTouches
    for(PlatformTouch* touch in touches)
    {
        CCTouch* ccTouch = [_allTouches objectForKey:[NSValue valueWithNonretainedObject:touch]];
        if(ccTouch)
        {
            ccTouch.view = (CCGLView*)[CCDirector sharedDirector].view;
            ccTouch.uiTouch = touch;
            [_currentTouches addObject:ccTouch];
        }
        
        [keys addObject:[NSValue valueWithNonretainedObject:touch]];
    }
    
    
    // Ended touches - remove touches from allTouches and place them back into the deadpool
    NSArray* deadTouches = [_allTouches objectsForKeys:keys notFoundMarker:[CCTouch touchWithPlatformTouch:nil]];
    [_deadTouches addObjectsFromArray:deadTouches];
    [_allTouches removeObjectsForKeys:keys];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p allTouches: %@ currentTouches: %@>", [self class], self, _allTouches, _currentTouches];
}

@end



