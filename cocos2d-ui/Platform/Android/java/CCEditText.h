//
//  CCEditText.h
//  cocos2d-ios
//
//  Created by Sergey Klimov on 8/5/14.
//
//

#import <BridgeKitV3/BridgeKit.h>


typedef void (^CCEditTextCompletionBlock)(void);

BRIDGE_CLASS("org.cocos2d.CCEditText")
@interface CCEditText : AndroidEditText
- (id)initWithContext:(AndroidContext *)context;
- (BOOL)onKeyPreIme:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event;
- (void)setTextSizeDouble:(double)textSize;
- (void) setCompletionBlock:(CCEditTextCompletionBlock)completionBlock;
@end
