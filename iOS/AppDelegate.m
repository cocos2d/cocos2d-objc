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

#import "TestbedSetup.h"
#import "CCDirector_Private.h"
#import "MainMenu.h"
#import "CCPackageConstants.h"


@interface AppDelegate : NSObject
@end


@implementation AppDelegate
{
    UIWindow *_window;
    CC_VIEW<CCView> *_view;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if 0
    [[TestbedSetup sharedSetup] setupApplication];
    _window = [TestbedSetup sharedSetup].window;
    _view = [TestbedSetup sharedSetup].view;
#else
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [CCSetup createCustomSetup];
    [CCSetup sharedSetup].contentScale = [UIScreen mainScreen].scale;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [CCSetup sharedSetup].contentScale *= 2;
        [CCSetup sharedSetup].UIScale *= 0.5;
    }
    
    [CCSetup sharedSetup].assetScale = [CCSetup sharedSetup].contentScale;
    
    CCFileLocator *locator = [CCFileLocator sharedFileLocator];
    locator.untaggedContentScale = 4;
    
    locator.searchPaths = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
        [[NSBundle mainBundle] resourcePath],
    ];

    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _view = [[CCViewiOSGL alloc] initWithFrame:_window.bounds pixelFormat:kEAGLColorFormatRGBA8 depthFormat:GL_DEPTH24_STENCIL8_OES preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = _view;
    viewController.wantsFullScreenLayout = YES;
    _window.rootViewController = viewController;
    
    // Need to force the window to be visible to set the initial view size on iOS < 8
    [_window makeKeyAndVisible];
    
    CCDirector *director = _view.director;
    [CCDirector pushCurrentDirector:director];
    [director presentScene:[MainMenu scene]];
    [CCDirector popCurrentDirector];
    
    [director startRunLoop];
#endif
    
    return YES;
}

@end
