//
//  CCEditText.h
//  cocos2d-ios
//
//  Created by Sergey Klimov on 8/5/14.
//
//

#import <GLActivityKit/GLEditText.h>

@class AndroidContext;
@class AndroidKeyEvent;

typedef void (^CCEditTextCompletionBlock)(void);

BRIDGE_CLASS("com.apportable.GLEditText")
@interface CCEditText : GLEditText
- (id)initWithContext:(AndroidContext *)context;
- (BOOL)onKeyPreIme:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event;
- (void)setCompletionBlock:(CCEditTextCompletionBlock)completionBlock;
@end
