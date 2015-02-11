#import "AppDelegate.h"
#import "CCPackageManager.h"
#import "CCDirector_Private.h"
#import "AppController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet CC_VIEW<CCView> *glView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AppController *controller = [AppController sharedController];
    controller.window = _window;
    controller.glView = _glView;
    [controller setupApplication];
    return;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[CCPackageManager sharedManager] savePackages];
}

@end
