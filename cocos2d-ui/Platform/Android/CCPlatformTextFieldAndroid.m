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
    CGPoint worldPos = [control convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    
    
    CGFloat scale = [[CCDirector sharedDirector] contentScaleFactor];
    
    viewPos.x *= scale;
    viewPos.y *= scale;
    
    CGSize size = control.contentSizeInPoints;
    size.width *= scale;
    size.height *= scale ;
    viewPos.y -=  size.height;
    
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    int nativePadding = (int)padding*scale;
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidViewGroupLayoutParams *oldParams = [_editText layoutParams];
        AndroidRelativeLayoutLayoutParams *params = [[AndroidRelativeLayoutLayoutParams alloc] initWithWidth:frame.size.width height:frame.size.height];
        [params setMargins:frame.origin.x top:frame.origin.y right:0 bottom:0];
        [_editText setPadding:nativePadding top:nativePadding right:nativePadding bottom:nativePadding];
        [_editText setLayoutParams:params];
        [_editText setImeOptions:AndroidEditorInfoIME_FLAG_NO_EXTRACT_UI];
        
        
        __weak id weakSelf = self;
        [_editText setCompletionBlock:^{
            if ([[weakSelf delegate] respondsToSelector:@selector(platformTextFieldDidFinishEditing:)]) {
                [[weakSelf delegate] platformTextFieldDidFinishEditing:weakSelf];
            }
            
        }];
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
