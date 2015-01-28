//
//  CCPlatformTextField.h
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//


#import "ccTypes.h"


@class CCControl;

@class CCPlatformTextField;

@protocol CCPlatformTextFieldDelegate <NSObject>

- (void) platformTextFieldDidFinishEditing:(CCPlatformTextField *) platformTextField;

@end

@interface CCPlatformTextField : NSObject
- (void) positionInControl:(CCControl *)control padding:(CGFloat)padding;
- (void) onEnterTransitionDidFinish;
- (void) onExitTransitionDidStart;
- (void) setFontSize:(float)fontSize;
@property (nonatomic, weak) id<CCPlatformTextFieldDelegate> delegate;
@property (nonatomic, copy) NSString * string;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, readonly) id nativeTextField;
@end
