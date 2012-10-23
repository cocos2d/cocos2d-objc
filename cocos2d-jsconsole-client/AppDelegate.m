#import "AppDelegate.h"
#import "MGSFragaria.h"

@implementation AppDelegate

@synthesize javaScriptConsoleWindow = mJavaScriptConsoleWindow;
@synthesize javaScriptConsoleInputView = mJavaScriptConsoleInputView;
@synthesize javaScriptConsoleOutputView = mJavaScriptConsoleOutputView;
@synthesize javaScriptConsoleInputTextView = mJavaScriptConsoleInputTextView;
@synthesize javaScriptConsoleOutputTextView = mJavaScriptConsoleOutputTextView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /* Input View. */
    {
        mJavaScriptConsoleInputViewFragaria = [[MGSFragaria alloc] init];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];
        
        [mJavaScriptConsoleInputViewFragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
        [mJavaScriptConsoleInputViewFragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
        
        [mJavaScriptConsoleInputViewFragaria setObject:self forKey:MGSFODelegate];
        
        // define our syntax definition
        [mJavaScriptConsoleInputViewFragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
        [mJavaScriptConsoleInputViewFragaria embedInView:mJavaScriptConsoleInputView];
        
        // access the NSTextView
        mJavaScriptConsoleInputTextView = [mJavaScriptConsoleInputViewFragaria objectForKey:ro_MGSFOTextView];
        [mJavaScriptConsoleInputTextView setString:@"var director = cc.Director.getInstance();\nvar runningScene = director.getRunningScene();\n\nvar sprite = cc.Sprite.create(\"grossini.png\");\nrunningScene.addChild(sprite);"];
    }
    /* Output View. */
    {
        mJavaScriptConsoleOutputViewFragaria = [[MGSFragaria alloc] init];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];
        
        [mJavaScriptConsoleOutputViewFragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
        [mJavaScriptConsoleOutputViewFragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
        
        [mJavaScriptConsoleOutputViewFragaria setObject:self forKey:MGSFODelegate];
        
        // define our syntax definition
        [mJavaScriptConsoleOutputViewFragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
        [mJavaScriptConsoleOutputViewFragaria embedInView:mJavaScriptConsoleOutputView];
        
        // access the NSTextView
        mJavaScriptConsoleOutputTextView = [mJavaScriptConsoleOutputViewFragaria objectForKey:ro_MGSFOTextView];
        [mJavaScriptConsoleOutputTextView setSelectable:NO];
    }
    
    [self initThoMoClient];
}

- (void)dealloc {
    [mThoMoClient stop];
    [mThoMoClient release];
    
    [super dealloc];
}

- (void) initThoMoClient {
    mThoMoClient = [[ThoMoClientStub alloc] initWithProtocolIdentifier:@"JSConsole"];
    [mThoMoClient setDelegate:self];
    [mThoMoClient start];
}

-(void)client:(ThoMoClientStub *)theClient didConnectToServer:(NSString *)aServerIdString {
        NSLog(@"Connected to: %@", aServerIdString);
}

-(void)client:(ThoMoClientStub *)theClient didReceiveData:(id)theData fromServer:(NSString *)aServerIdString {
    NSString * result = (NSString *)theData;

    [mJavaScriptConsoleOutputTextView appendString:result];

    /* Scroll to bottom. */
    NSRange range = NSMakeRange ([[mJavaScriptConsoleOutputTextView string] length], 0);
    [mJavaScriptConsoleOutputTextView scrollRangeToVisible: range];
}

-(void)sendJavaScriptCode:(id)sender {
    NSString * script = [[mJavaScriptConsoleInputTextView textStorage] string];
    [mThoMoClient sendToAllServers:script];
}

@end
