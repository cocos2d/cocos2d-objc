//
//  CCPlatformTextField.h
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class CCControl;

@interface CCPlatformTextField : NSObject
- (void) positionInControl:(CCControl *)control padding:(CGFloat)padding;
- (void) onEnterTransitionDidFinish;
- (void) onExitTransitionDidStart;
- (void) setFontSize:(float)fontSize;
@property (nonatomic) NSString * text;
@property (nonatomic) BOOL hidden;
@property (nonatomic, readonly) id nativeTextField;
@end
