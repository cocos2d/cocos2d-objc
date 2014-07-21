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

@implementation CCPlatformTextFieldAndroid {
    AndroidEditText *_editText;
}

- (id) init {
    if (self=[super init]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _editText = [[AndroidEditText alloc] initWithContext:[CCActivity currentActivity]];
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

- (void) positionInControl:(CCControl *)control padding:(CGFloat)padding {
    CGPoint worldPos = [control convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += padding;
    viewPos.y += padding;
    
    CGSize size = control.contentSizeInPoints;
//    size.width *= _scaleMultiplier;
//    size.height *= _scaleMultiplier;
    
    viewPos.y -= size.height;
    size.width -= padding * 2;
    size.height -= padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    dispatch_async(dispatch_get_main_queue(), ^{
        AndroidViewGroupLayoutParams *oldParams = [_editText layoutParams];
        float yoffset = 20;
        float heightoffset = 20;
        AndroidRelativeLayoutLayoutParams *params = [[AndroidRelativeLayoutLayoutParams alloc] initWithWidth:frame.size.width height:frame.size.height+yoffset+heightoffset];
        [params setMargins:frame.origin.x top:frame.origin.y-yoffset right:0 bottom:0];
        [_editText setLayoutParams:params];
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
//    NSLog(@"Set font size %f", fontSize);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_editText setTextSize:0  size:fontSize];
//    });

}

@end
