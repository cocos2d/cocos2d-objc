//
//  CCEditText.m
//  cocos2d-ios
//
//  Created by Sergey Klimov on 8/5/14.
//
//

#import "CCEditText.h"

#import <AndroidKit/AndroidContext.h>
#import <AndroidKit/AndroidKeyEvent.h>

@implementation CCEditText {
    CCEditTextCompletionBlock _completionBlock;
}

- (BOOL)onKeyPreIme:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event {
    if (keyCode == AndroidKeyEventKeycodeBack || [event action] == AndroidKeyEventActionUp) {
        if (_completionBlock != nil) {
            _completionBlock();
        }
        
        return NO;
    }
    return [self dispatchKeyEvent:event];

}

- (void) setCompletionBlock:(CCEditTextCompletionBlock)completionBlock {
    _completionBlock = [completionBlock copy];
}

- (void)dealloc {
    [_completionBlock release];
    [super dealloc];
}
@end
