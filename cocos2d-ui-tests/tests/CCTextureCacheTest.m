//
//  CCTextureCacheTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/12/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextureCache.h"

@interface CCTextureCacheTest : TestBase
@property (nonatomic,strong) CCTexture* texture;
@end

@implementation CCTextureCacheTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupTextureCacheTest",
            nil];
}

- (void) setupTextureCacheTest
{
    self.subTitle = @"Tests the texture cache's retain count under ARC (check console).";
    
    CCButton* btnAdd = [CCButton buttonWithTitle:@"Add & Retain To Cache"];
    btnAdd.positionType = CCPositionTypeNormalized;
    btnAdd.position = ccp(0.5, 0.7);
    [btnAdd setTarget:self selector:@selector(testCacheAdd:)];
    [self.contentNode addChild:btnAdd];
    
    CCButton* btnClear = [CCButton buttonWithTitle:@"Clear Cache"];
    btnClear.positionType = CCPositionTypeNormalized;
    btnClear.position = ccp(0.5, 0.5);
    [btnClear setTarget:self selector:@selector(testCacheClear:)];
    [self.contentNode addChild:btnClear];
    
    CCButton* btnRelease = [CCButton buttonWithTitle:@"Release"];
    btnRelease.positionType = CCPositionTypeNormalized;
    btnRelease.position = ccp(0.5, 0.3);
    [btnRelease setTarget:self selector:@selector(testRelease:)];
    [self.contentNode addChild:btnRelease];
}

- (void) testCacheClear:(id)sender
{
    CCTextureCache* cache = [CCTextureCache sharedTextureCache];
    
    NSLog(@"BEFORE CLEAR texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
    
    [cache removeUnusedTextures];
    
    NSLog(@"AFTER  CLEAR texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
}

- (void) testCacheAdd:(id)sender
{
    CCTextureCache* cache = [CCTextureCache sharedTextureCache];
    
    NSLog(@"BEFORE ADD texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
    
    self.texture = [cache addImage:@"Sprites.png"];
    
    NSLog(@"AFTER  ADD texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
}

- (void) testRelease:(id)sender
{
    CCTextureCache* cache = [CCTextureCache sharedTextureCache];
    
    NSLog(@"BEFORE RELEASE texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
    
    self.texture = NULL;
    
    NSLog(@"AFTER  RELEASE texture: %@", [cache textureForKey:@"Sprites.png"]);
    if ([cache textureForKey:@"Sprites.png"]) NSLog(@" - retain count: %d", (int)CFGetRetainCount((__bridge CFTypeRef)[cache textureForKey:@"Sprites.png"]));
}

@end
