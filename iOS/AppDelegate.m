/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
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

#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "AppController.h"
#import "CCDirector_Private.h"
#import "MainMenu.h"
#import "CCPackageConstants.h"

@implementation AppDelegate
{
    UIWindow *_window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    CCViewiOSGL *view = [[CCViewiOSGL alloc] initWithFrame:_window.bounds pixelFormat:kEAGLColorFormatRGBA8 depthFormat:GL_DEPTH24_STENCIL8_OES preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
    CCDirectorIOS *director = (CCDirectorIOS *)view.director;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        director.contentScaleFactor *= 2;
        director.UIScaleFactor *= 0.5;
    }
    
    CCFileLocator *locator = [CCFileLocator sharedFileLocator];
    locator.untaggedContentScale = 4;
    locator.deviceContentScale = director.contentScaleFactor;
    
    locator.searchPaths = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
        [[NSBundle mainBundle] resourcePath],
    ];

    // Register spritesheets.
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Interface.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Sprites.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"TilesAtlassed.plist"];
    
    [CCDirector pushCurrentDirector:director];
    [director presentScene:[MainMenu scene]];
    [CCDirector popCurrentDirector];
    
    _window.rootViewController = director;
    [_window makeKeyAndVisible];
    
    [director startRunLoop];
    
    return YES;
}

@end
