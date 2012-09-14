#import <Cocoa/Cocoa.h>
#import "ThoMoClientStub.h"

@class SMLTextView;
@class MGSFragaria;

@interface AppDelegate : NSObject <NSApplicationDelegate, ThoMoClientDelegateProtocol>
{
    NSWindow * mJavaScriptConsoleWindow;
    NSView * mJavaScriptConsoleInputView;
    SMLTextView * mJavaScriptConsoleInputTextView;
    NSView * mJavaScriptConsoleOutputView;
    SMLTextView * mJavaScriptConsoleOutputTextView;
    MGSFragaria * mJavaScriptConsoleInputViewFragaria;
    MGSFragaria * mJavaScriptConsoleOutputViewFragaria;
    ThoMoClientStub * mThoMoClient;
}

@property (nonatomic, assign) IBOutlet NSWindow * javaScriptConsoleWindow;
@property (nonatomic, assign) IBOutlet NSView * javaScriptConsoleInputView;
@property (nonatomic, assign) IBOutlet NSView * javaScriptConsoleOutputView;
@property (nonatomic, assign) SMLTextView * javaScriptConsoleInputTextView;
@property (nonatomic, assign) SMLTextView * javaScriptConsoleOutputTextView;

- (IBAction)sendJavaScriptCode:(id)sender;

- (void)initThoMoClient;

@end
