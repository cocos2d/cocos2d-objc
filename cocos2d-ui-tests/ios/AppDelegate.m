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

#import "AppDelegate.h"
#import "MainMenu.h"
#import "TestBase.h"
#import "CCPackageConstants.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureCocos2d];

    return YES;
}

- (void)configureCocos2d
{
#if CC_CCBREADER
    // Configure the file utils to work with SpriteBuilder, but use a custom resource path (Resources-shared instead of Published-iOS)
    [CCBReader configureCCFileUtils];
#else 
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    
    // Setup file utils for use with SpriteBuilder
    [sharedFileUtils setEnableiPhoneResourcesOniPad:NO];
    
    sharedFileUtils.directoriesDict =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"resources-tablet", CCFileUtilsSuffixiPad,
     @"resources-tablethd", CCFileUtilsSuffixiPadHD,
     @"resources-phone", CCFileUtilsSuffixiPhone,
     @"resources-phonehd", CCFileUtilsSuffixiPhoneHD,
     @"resources-phone", CCFileUtilsSuffixiPhone5,
     @"resources-phonehd", CCFileUtilsSuffixiPhone5HD,
     @"resources-phone", CCFileUtilsSuffixMac,
     @"resources-phonehd", CCFileUtilsSuffixMacHD,
     @"", CCFileUtilsSuffixDefault,
     nil];

    sharedFileUtils.searchPath =
    [NSArray arrayWithObjects:
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"],
     [[NSBundle mainBundle] resourcePath],
     nil];
    
    sharedFileUtils.enableiPhoneResourcesOniPad = YES;
    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [sharedFileUtils buildSearchResolutionsOrder];
    
    [sharedFileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFrameLookupDictionaryFromFile:@"spriteFrameFileList.plist"];
#endif

    [self configureFileUtilsSearchPathAndRegisterSpriteSheets];

    [self setupCocos2dWithOptions:@{
			CCSetupDepthFormat: @GL_DEPTH24_STENCIL8,
//			CCSetupScreenMode: CCScreenModeFixed,
//			CCSetupScreenOrientation: CCScreenOrientationPortrait,
			CCSetupTabletScale2X: @YES,
			CCSetupShowDebugStats: @(getenv("SHOW_DEBUG_STATS") != nil),
		}];
    
    [[CCDirector sharedDirector] runWithScene:[MainMenu scene]];
}

- (void)configureFileUtilsSearchPathAndRegisterSpriteSheets
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CCFileUtils* sharedFileUtils = [CCFileUtils sharedFileUtils];

    sharedFileUtils.searchPath =
    [NSArray arrayWithObjects:
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
     [[NSBundle mainBundle] resourcePath],
     nil];

    // Register spritesheets.
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Interface.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Sprites.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"TilesAtlassed.plist"];
}

/*- (CCScene*) startScene
{
    const char *testName = getenv("Test");
    
    if(testName){
        return [TestBase sceneWithTestName:[NSString stringWithCString:testName encoding:NSUTF8StringEncoding]];
    } else {
        return [MainMenu scene];
    }
}*/

//// I'm going to leave this in for testing the fixed size screen mode in the future.
//- (CCScene*) startScene
//{
////    return [MainMenu scene];
//	CCScene *scene = [CCScene node];
//	
////	// Landscape
////	{
////		// iPad
////		CCNode *node = [CCNodeColor nodeWithColor:[CCColor greenColor] width:512 height:384];
////		node.position = ccp(28, 0);
////		[scene addChild:node];
////	}{
////		// iPhone5
////		CCNode *node = [CCNodeColor nodeWithColor:[CCColor redColor] width:568 height:320];
////		node.position = ccp(0, 32);
////		[scene addChild:node];
////	}{
////		// iPhone
////		CCNode *node = [CCNodeColor nodeWithColor:[CCColor blueColor] width:480 height:320];
////		node.position = ccp(44, 32);
////		[scene addChild:node];
////	}
//	
//	// Portrait
//	{
//		// iPad
//		CCNode *node = [CCNodeColor nodeWithColor:[CCColor greenColor] width:384 height:512];
//		node.position = ccp(0, 28);
//		[scene addChild:node];
//	}{
//		// iPhone5
//		CCNode *node = [CCNodeColor nodeWithColor:[CCColor redColor] width:320 height:568];
//		node.position = ccp(32, 0);
//		[scene addChild:node];
//	}{
//		// iPhone
//		CCNode *node = [CCNodeColor nodeWithColor:[CCColor blueColor] width:320 height:480];
//		node.position = ccp(32, 44);
//		[scene addChild:node];
//	}
//	
//	return scene;
//}

@end