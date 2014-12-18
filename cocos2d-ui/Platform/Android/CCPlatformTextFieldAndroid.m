//
//  CCPlatformTextFieldAndroid.m
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import "CCPlatformTextFieldAndroid.h"
#import "CCActivity.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CCControl.h"
#import "CCDirector.h"
#import "CCEditText.h"

#import <AndroidKit/AndroidColorDrawable.h>
#import <AndroidKit/AndroidColor.h>
#import <AndroidKit/AndroidEditorInfo.h>

#import <AndroidKit/AndroidAbsoluteLayout.h>
#import <AndroidKit/AndroidAbsoluteLayoutLayoutParams.h>

@implementation CCPlatformTextFieldAndroid {
    CCEditText *_editText;
}

- (id) init {
    if (self=[super init]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _editText = [[CCEditText alloc] initWithContext:[CCActivity currentActivity]];
            [_editText setBackground:[[AndroidColorDrawable alloc] initWithColor:AndroidColorTransparent]];
            [_editText setTextColorByColor:AndroidColorBlack];
        });
        
    }
    return self;
}

- (void)dealloc
{
    _editText = nil;
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
    CGPoint viewPos = [control convertToWorldSpace:CGPointZero];
    CGSize screenSize = [[CCDirector sharedDirector] viewSizeInPixels];
    CGFloat scale = [[CCDirector sharedDirector] contentScaleFactor];
    CGSize size = control.contentSizeInPoints;

    size.width *= scale;
    size.height *= scale;

    viewPos.x *= scale;
    viewPos.y *= scale;
    viewPos.y = screenSize.height - viewPos.y - size.height;

    int nativePadding = (int)padding*scale;
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidAbsoluteLayoutLayoutParams *params = [[AndroidAbsoluteLayoutLayoutParams alloc] initWithWidth:size.width height:size.height x:viewPos.x y:viewPos.y];
        [_editText setPadding:nativePadding top:nativePadding right:nativePadding bottom:nativePadding];
        [_editText setLayoutParams:params];
        [_editText setImeOptions:AndroidEditorInfoImeFlagNoExtractUi];
    });
}

-(void)addEditText {
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidAbsoluteLayout *layout = [[CCActivity currentActivity] layout];
        [layout addView:_editText];
        __weak id weakSelf = self;
        [_editText setCompletionBlock:^{
            if ([[weakSelf delegate] respondsToSelector:@selector(platformTextFieldDidFinishEditing:)]) {
                [[weakSelf delegate] platformTextFieldDidFinishEditing:weakSelf];
            }
        }];
    });
}

- (void)removeEditText {
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidAbsoluteLayout *layout = [[CCActivity currentActivity] layout];
        [layout removeView:_editText];
    });
}

- (void)setFontSize:(float)fontSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_editText setTextSize:fontSize];
    });
}

- (void)setString:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_editText setText:string];
    });
}

- (NSString *)string {
    NSString *str = [_editText.text description];
    return str;
}


@end
