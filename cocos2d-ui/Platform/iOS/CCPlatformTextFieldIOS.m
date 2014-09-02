   //
//  CCPlatformTextFieldIOS.m
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import "CCPlatformTextFieldIOS.h"
#import "CCDirector.h"
#import "CCControl.h"
#import <UIKit/UIKit.h>

@implementation CCPlatformTextFieldIOS {
    UITextField *_textField;
    CGFloat _scaleMultiplier;
    BOOL _keyboardIsShown;
    float _keyboardHeight;
}
- (id) init {
    if (self=[super init]) {
        // Create UITextField and set it up
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.delegate = self;
        _textField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
        // UIKit might not be running in the same scale as us.
        _scaleMultiplier = [CCDirector sharedDirector].contentScaleFactor/[UIScreen mainScreen].scale;
        
    }
    return self;
}

- (void) positionInControl:(CCControl *)control padding:(CGFloat)padding {
    CGPoint worldPos = [control convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += padding;
    viewPos.y += padding;
    
    CGSize size = control.contentSizeInPoints;
    size.width *= _scaleMultiplier;
    size.height *= _scaleMultiplier;
    
    viewPos.y -= size.height;
    size.width -= padding * 2;
    size.height -= padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    
    _textField.frame = frame;
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self addUITextView];
    [self registerForKeyboardNotifications];

}
- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
    [self removeUITextView];
    [self unregisterForKeyboardNotifications];
}
- (void) setString:(NSString *)string
{
    _textField.text = string;
}

- (NSString*) string
{
    return _textField.text;
}

- (void)setFontSize:(float)fontSize {
    UIFont *font = _textField.font;
    _textField.font = [font fontWithSize:fontSize*_scaleMultiplier];

}

- (BOOL)hidden {
    return _textField.hidden;
}

- (void) setHidden:(BOOL)hidden {
    _textField.hidden = hidden;
}

- (void) addUITextView
{
    [[[CCDirector sharedDirector] view] addSubview:_textField];
}

- (void) removeUITextView
{
    [_textField removeFromSuperview];
}

#pragma mark Text Field Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    if (_keyboardIsShown)
    {
        [self focusOnTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

    [self endFocusingOnTextField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([[self delegate] respondsToSelector:@selector(platformTextFieldDidFinishEditing:)]) {
        [[self delegate]platformTextFieldDidFinishEditing:self];
    }

    
    return YES;
}




#pragma mark Keyboard Notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    _keyboardIsShown = YES;
    
    UIView* view = [[CCDirector sharedDirector] view];
    
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [value CGRectValue];
    frame = [view.window convertRect:frame toView:view];
    
    CGSize kbSize = frame.size;
    
    _keyboardHeight = kbSize.height;
    
    BOOL focusOnTextField = _textField.isEditing;
    
#if __CC_PLATFORM_ANDROID
    focusOnTextField = _textFieldIsEditing;
#endif
    
    if (focusOnTextField)
    {
        [self focusOnTextField];
    }
}

- (void) keyboardWillBeHidden:(NSNotification*) notification
{
    _keyboardIsShown = NO;
}


#pragma mark Focusing on Text Field


- (void) focusOnTextField
{
#if __CC_PLATFORM_ANDROID
    // Ensure that all textfields have actually been positioned before checkings textField.frame property,
    // it's possible for the apportable keyboard notification to be fired before the mainloop has had a chance to kick of a scheduler update
    CCDirector *director = [CCDirector sharedDirector];
    [director.scheduler update:0.0];
#endif
    
    CGSize windowSize = [[CCDirector sharedDirector] viewSize];
    
    // Find the location of the textField
    float fieldCenterY = _textField.frame.origin.y - (_textField.frame.size.height/2);
    
    // Upper third part of the screen
    float upperThirdHeight = windowSize.height / 3;
    
    if (fieldCenterY > upperThirdHeight)
    {
        // Slide the main view up
        
        // Calculate offset
        float dstYLocation = windowSize.height / 4;
        float offset = -(fieldCenterY - dstYLocation);
        
        if (offset < -_keyboardHeight) offset = -_keyboardHeight;
        
#if __CC_PLATFORM_ANDROID
        // Apportable does not support changing the openglview position, so we will just change the current scenes position instead
        CCScene *runningScene = [[CCDirector sharedDirector] runningScene];
        CGPoint newPosition = runningScene.position;
        newPosition.y = (offset * -1);
        runningScene.position = newPosition;
#else
        // Calcualte target frame
        UIView* view = [[CCDirector sharedDirector] view];
        CGRect frame = view.frame;
        frame.origin.y = offset;
        
        // Do animation
        [UIView beginAnimations: @"textFieldAnim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.2f];
        
        view.frame = frame;
        [UIView commitAnimations];
#endif
    }
}

- (void) endFocusingOnTextField
{
    // Slide the main view back down
    
#if __CC_PLATFORM_ANDROID
    // Apportable does not support changing the openglview position, so we will just change the current scenes position instead
    CCScene *runningScene = [[CCDirector sharedDirector] runningScene];
    CGPoint newPosition = CGPointZero;
    newPosition.y = 0.0f;
    runningScene.position = newPosition;
#else
    UIView* view = [[CCDirector sharedDirector] view];
    [UIView beginAnimations: @"textFieldAnim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.2f];
    
    CGRect frame = view.frame;
    frame.origin = CGPointZero;
    view.frame = frame;
    
    [UIView commitAnimations];
#endif
    
}



@end
