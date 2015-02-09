/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"

#import "AppController.h"
#import "MainMenu.h"
#import "TestBase.h"
#import "CCPackageConstants.h"

@implementation AppController


- (void)setupApplication
{
    [self configureFileUtilsSearchPathAndRegisterSpriteSheets];
    [super setupApplication];
}

- (NSDictionary*)iosConfig
{
    return @{
             CCSetupDepthFormat: @GL_DEPTH24_STENCIL8,
             CCSetupTabletScale2X: @YES,
             CCSetupShowDebugStats: @(getenv("SHOW_DEBUG_STATS") != nil),
             };
}

- (NSDictionary*)macConfig
{
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    config[CCMacDefaultWindowSize] = [NSValue valueWithCGSize:[self defaultWindowSize]];
    config[CCSetupDepthFormat] = @GL_DEPTH24_STENCIL8;
    config[CCSetupTabletScale2X] = @YES;
    config[CCSetupShowDebugStats] = @(getenv("SHOW_DEBUG_STATS") != nil);
    
    return config;
}

- (void)configureFileUtilsSearchPathAndRegisterSpriteSheets
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // The testbed uses a different directory dictionary than is created by the default CCFileUtils constructor- it uses the file utils one
    [CCBReader configureCCFileUtils];
    CCFileUtils* sharedFileUtils = [CCFileUtils sharedFileUtils];

    // Testbed needs special directory search paths:
    sharedFileUtils.searchPath = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
        [[NSBundle mainBundle] resourcePath],
    ];

    // Register spritesheets.
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Interface.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Sprites.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"TilesAtlassed.plist"];
}

- (CCScene*) createFirstScene
{
    const char *testName = getenv("Test");
    
    if(testName){
        return [TestBase sceneWithTestName:[NSString stringWithCString:testName encoding:NSUTF8StringEncoding]];
    } else {
        return [MainMenu scene];
    }
}


#pragma mark Android

#if __CC_PLATFORM_ANDROID

/*
 Add any android specific overrides here
 */

#endif


#pragma mark Mac

#if __CC_PLATFORM_MAC

/*
 Add any Mac specific overrides here
 */
-(CGSize)defaultWindowSize
{
    return CGSizeMake(960.0f, 640.0f);
}

#endif

#pragma mark Singleton Methods

static AppController *__sharedController;

/*
 These methods are used in the framework to reference this controller.
 */
+ (AppController*)sharedController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      __sharedController = [[AppController alloc] init];
                  });
    
    return __sharedController;
}

+ (void)setupApplication
{
    static dispatch_once_t setupToken;
    dispatch_once(&setupToken, ^
                  {
                      [[AppController sharedController] setupApplication];
                  });
}


@end