/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
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

#import "TestbedSetup.h"
#import "MainMenu.h"
#import "TestBase.h"
#import "CCPackageConstants.h"

@implementation TestbedSetup

-(NSDictionary *)setupConfig
{
    return @{
        CCSetupDepthFormat: @GL_DEPTH24_STENCIL8,
        CCSetupTabletScale2X: @YES,
        CCSetupShowDebugStats: @(getenv("SHOW_DEBUG_STATS") != nil),
        CCMacDefaultWindowSize: [NSValue valueWithCGSize:CGSizeMake(960.0f, 640.0f)],
    };
}

- (void)setupApplication
{
    // TODO Hack to make the registerSpriteFramesFile: calls work until they are removed.
#if __CC_PLATFORM_MAC
    self.assetScale = 2;
#elif __CC_PLATFORM_IOS
    self.assetScale = [UIScreen mainScreen].scale*(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 1.0);
#endif
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Testbed needs special directory search paths:
    [CCFileLocator sharedFileLocator].searchPaths = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
        [[NSBundle mainBundle] resourcePath],
    ];

    [super setupApplication];
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

@end