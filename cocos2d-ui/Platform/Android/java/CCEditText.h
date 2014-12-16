//
//  CCEditText.h
//  cocos2d-ios
//
//  Created by Sergey Klimov on 8/5/14.
//
//

#import <AndroidKit/AndroidEditText.h>
#import <AndroidKit/AndroidContext.h>
#import <AndroidKit/AndroidKeyEvent.h>

typedef void (^CCEditTextCompletionBlock)(void);

BRIDGE_CLASS("org.cocos2d.EditText")
@interface CCEditText : AndroidEditText
- (id)initWithContext:(AndroidContext *)context;
- (BOOL)onKeyPreIme:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event;
- (void)setCompletionBlock:(CCEditTextCompletionBlock)completionBlock;
@end
