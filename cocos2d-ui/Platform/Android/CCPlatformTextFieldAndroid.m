//
//  CCPlatformTextFieldAndroid.m
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import "CCPlatformTextFieldAndroid.h"
#import "CCActivity.h"
#import <BridgeKitV3/BridgeKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCControl.h"
#import "CCDirector.h"
#import "CCEditText.h"

extern void objc_retain(id);


typedef void (^CCPlatformTextFieldAndroidTextViewOnEditorActionListenerCompletionBlock)(void);


BRIDGE_CLASS("org.cocos2d.CCPlatformTextFieldAndroidTextViewOnEditorActionListener")
@interface CCPlatformTextFieldAndroidTextViewOnEditorActionListener : JavaObject<AndroidTextViewOnEditorActionListener>
- (BOOL)onEditorAction:(AndroidTextView *)v actionId:(int32_t)actionId keyEvent:(AndroidKeyEvent *)event;

@end
@implementation CCPlatformTextFieldAndroidTextViewOnEditorActionListener {
    CCPlatformTextFieldAndroidTextViewOnEditorActionListenerCompletionBlock _completionBlock;
}

- (id) initWithCompletionBlock:(CCPlatformTextFieldAndroidTextViewOnEditorActionListenerCompletionBlock)completionBlock {
    if (self = [super init]) {
        _completionBlock = [completionBlock copy];
    }
    return self;
    
}

@bridge(callback) onEditorAction:actionId:keyEvent: = onEditorAction;
- (BOOL)onEditorAction:(AndroidTextView *)v actionId:(int32_t)actionId keyEvent:(AndroidKeyEvent *)event {
    if (actionId == AndroidEditorInfoIME_ACTION_SEARCH ||
       actionId == AndroidEditorInfoIME_ACTION_DONE
//        || [event action] == KeyEvent.ACTION_DOWN && [event keyCode] == ANDROID_KEYCODE_ENTER
        ) {
        _completionBlock();
    } else {
        NSLog(@"nothing");
    }
    return NO;
}

@end
 
@implementation CCPlatformTextFieldAndroid {
    CCEditText *_editText;
}

- (id) init {
    if (self=[super init]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _editText = [[CCEditText alloc] initWithContext:[CCActivity currentActivity]];
            [_editText setBackground:[[AndroidColorDrawable alloc] initWithColor:AndroidColorTRANSPARENT]];
            [_editText setTextColorByColor:AndroidColorBLACK];
        });
        
    }
    return self;
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self addEditText];
}
- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
    [self removeEditText];
}

- (void) positionInControl:(CCControl *)control padding:(float)padding {
    CGPoint worldPos = [control convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += padding;
//    viewPos.y += padding;
    
    CGFloat scale = [[CCDirector sharedDirector] contentScaleFactor];
    
    viewPos.x *= scale;
    viewPos.y *= scale;
    
    CGSize size = control.contentSizeInPoints;
    size.width -= padding * 2;
    size.height -= padding * 2;
    size.width *= scale;
    size.height *= scale ;
    viewPos.y -= size.height + padding *scale;

    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidViewGroupLayoutParams *oldParams = [_editText layoutParams];
        AndroidRelativeLayoutLayoutParams *params = [[AndroidRelativeLayoutLayoutParams alloc] initWithWidth:frame.size.width height:frame.size.height];
        [params setMargins:frame.origin.x top:frame.origin.y right:0 bottom:0];
        [_editText setLayoutParams:params];
        
        [_editText setOnEditorActionListener:[[CCPlatformTextFieldAndroidTextViewOnEditorActionListener alloc] initWithCompletionBlock:^{
            if ([[self delegate] respondsToSelector:@selector(platformTextFieldDidFinishEditing:)]) {
                [[self delegate] platformTextFieldDidFinishEditing:self];
            }

        }]];
    });
}

-(void)addEditText {
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidRelativeLayout *layout = [[CCActivity currentActivity] layout];
        [layout addView:_editText];
    });
}


- (void)removeEditText {
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidRelativeLayout *layout = [[CCActivity currentActivity] layout];
        [layout removeView:_editText];
    });
}

- (void)setFontSize:(float)fontSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        // AndroidDisplayMetrics *metrics = [[AndroidDisplayMetrics alloc] init];
        // [[CCActivity currentActivity].windowManager.defaultDisplay getMetrics:metrics];

        [_editText setTextSizeDouble:fontSize];

    });


}

- (void)setString:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_editText setText:string];
    });
}


- (NSString *)string {
    return _editText.text;
}
@end
