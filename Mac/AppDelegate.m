#import "CCPackageManager.h"
#import "CCDirector_Private.h"
#import "TestbedSetup.h"
#import "MainMenu.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@end

@implementation AppDelegate
{
    IBOutlet NSWindow *_window;
    IBOutlet CCViewMacGL *_view;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_window center];
    [_window makeFirstResponder:_view];
    [_window makeKeyAndOrderFront:self];
    _window.acceptsMouseMovedEvents = YES;
    
    CCDirector *director = _view.director;
    director.contentScaleFactor *= 2;
    director.UIScaleFactor *= 0.5;
    
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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[CCPackageManager sharedManager] savePackages];
}

//MARK: Window delegate methods:

-(void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}

@end
