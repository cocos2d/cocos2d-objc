//
//  CCTextField.m
//  cocos2d-ios
//
//  Created by Viktor on 10/22/13.
//
//

#import "CCTextField.h"
#import "CCControlSubclass.h"

@implementation CCTextField

- (id) init
{
    return [self initWithSpriteFrame:NULL];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)frame
{
    self = [super init];
    if (!self) return NULL;
    
    if (frame)
    {
        _background = [[CCSprite9Slice alloc] initWithSpriteFrame:frame];
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background];
    
#ifdef __CC_PLATFORM_IOS
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.delegate = self;
#endif
    
    _padding = 4;
    
    return self;
}

- (void) positionTextField
{
#ifdef __CC_PLATFORM_IOS
    CGPoint worldPos = [self convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += _padding;
    viewPos.y += _padding;
    
    CGSize size = self.contentSizeInPoints;
    viewPos.y -= size.height;
    size.width -= _padding * 2;
    size.height -= _padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    
    _textField.frame = frame;
#endif
}

- (void) addUITextView
{
#ifdef __CC_PLATFORM_IOS
    _textField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [[[CCDirector sharedDirector] view] addSubview:_textField];
    [self positionTextField];
#endif
}

- (void) removeUITextView
{
#ifdef __CC_PLATFORM_IOS
    if (_textField)
    {
        [_textField removeFromSuperview];
    }
#endif
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onEnterTransitionDidFinish
{
    [self addUITextView];
    [super onEnterTransitionDidFinish];
    [self scheduleUpdate];
    [self registerForKeyboardNotifications];
}

- (void) onExitTransitionDidStart
{
    [self removeUITextView];
    [super onExitTransitionDidStart];
    [self unscheduleUpdate];
    [self unregisterForKeyboardNotifications];
}

- (void) update:(ccTime)delta
{
    [self positionTextField];
}

- (void) layout
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    [_background setContentSize:sizeInPoints];
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    
    self.contentSize = [self convertContentSizeFromPoints: sizeInPoints type:self.contentSizeType];
    
    [super layout];
}

#pragma mark Text Field Delegate Methods

#ifdef __CC_PLATFORM_IOS
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
    [self triggerAction];
    
    return YES;
}

#endif

#pragma mark Keyboard Notifications

- (void)registerForKeyboardNotifications
{
#ifdef __CC_PLATFORM_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
#endif
}

- (void) unregisterForKeyboardNotifications
{
#ifdef __CC_PLATFORM_IOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

#ifdef __CC_PLATFORM_IOS
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
    
    if (_textField.isEditing)
    {
        [self focusOnTextField];
    }
}

- (void) keyboardWillBeHidden:(NSNotification*) notification
{
    _keyboardIsShown = NO;
}

#endif

#pragma mark Focusing on Text Field

#ifdef __CC_PLATFORM_IOS

- (void) focusOnTextField
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
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
    }
}

- (void) endFocusingOnTextField
{
    UIView* view = [[CCDirector sharedDirector] view];
    
    // Slide the main view back down
    [UIView beginAnimations: @"textFieldAnim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.2f];
    
    CGRect frame = view.frame;
    frame.origin = CGPointZero;
    view.frame = frame;
    
    [UIView commitAnimations];
}

#endif

#pragma mark Properties

#ifdef __CC_PLATFORM_IOS

- (void) setString:(NSString *)string
{
    _textField.text = string;
}

- (NSString*) string
{
    return _textField.text;
}

#endif

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    _background.spriteFrame = spriteFrame;
}

- (CCSpriteFrame*) backgroundSpriteFrame
{
    return _background.spriteFrame;
}

@end
