#import "CCPackageManager.h"
#import "CCDirector_Private.h"
#import "TestbedSetup.h"
#import "MainMenu.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@end

@implementation AppDelegate
{
    IBOutlet NSWindow *_window;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if 1
    [[TestbedSetup sharedSetup] setupApplication];
#else
    CGRect rect = CGRectMake(0, 0, 1024, 768);
    NSUInteger styleMask = NSClosableWindowMask | NSResizableWindowMask | NSTitledWindowMask;
    _window = [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
    
    NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute[]) {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 32,
        0
    }];

    CCViewMacGL *view = [[CCViewMacGL alloc] initWithFrame:CGRectZero pixelFormat:pixelFormat];
    view.wantsBestResolutionOpenGLSurface = YES;
    _window.contentView = view;
    
    [_window center];
    [_window makeFirstResponder:view];
    [_window makeKeyAndOrderFront:self];
    _window.acceptsMouseMovedEvents = YES;
    
    // TODO hack
    [view awakeFromNib];
    
    CCDirector *director = view.director;
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
#endif
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
