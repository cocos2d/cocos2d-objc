//
//  CCPlatformTextFieldMac.m
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import "CCPlatformTextFieldMac.h"

#if __CC_PLATFORM_MAC

#import "CCDirector.h"
#import "CCControl.h"

@implementation CCPlatformTextFieldMac {
    NSTextField *_textField;
}
- (id) init {
    if (self = [super init]) {
        // Create NSTextField and set it up
        _textField = [[NSTextField alloc] initWithFrame: NSMakeRect(10, 10, 300, 40)];
        _textField.delegate = self;
        
        [_textField setFont:[NSFont fontWithName:@"Helvetica" size:17]];
        [_textField setBezeled:NO];
        [_textField setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
        [_textField setWantsLayer:YES];
        
    }
    return self;
}

- (void) positionInControl:(CCControl *)control padding:(CGFloat)padding {
    CGPoint worldPos = [control convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += padding;
    viewPos.y += padding;
    
    CGSize size = control.contentSizeInPoints;
    //viewPos.y -= size.height;
    size.width -= padding * 2;
    size.height -= padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    
    _textField.frame = frame;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{

    if ([[self delegate] respondsToSelector:@selector(platformTextFieldDidFinishEditing:)]) {
        [[self delegate]platformTextFieldDidFinishEditing:self];
    }
    return YES;
}

- (void)setFontSize:(float)fontSize {
    NSFont* font = _textField.font;
    _textField.font = [NSFont fontWithName:font.fontName size:fontSize];

    
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self addUITextView];
    
}
- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
    [self removeUITextView];
}

- (void) addUITextView
{
    [[[CCDirector sharedDirector] view] addSubview:_textField];
}

- (void) removeUITextView
{
    [_textField removeFromSuperview];
}


- (void) setString:(NSString *)string
{
    _textField.stringValue = string;
}

- (NSString*) string
{
    return _textField.stringValue;
}
@end

#endif
