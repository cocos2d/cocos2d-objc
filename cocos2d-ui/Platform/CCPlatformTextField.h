//
//  CCPlatformTextField.h
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import <Foundation/Foundation.h>

@class CCControl;

@interface CCPlatformTextField : NSObject
- (void) positionInControl:(CCControl *)control padding:(float)padding;
- (void) onEnterTransitionDidFinish;
- (void) onExitTransitionDidStart;
- (void) setFontSize:(float)fontSize;
@property (nonatomic) NSString * text;
@property (nonatomic) BOOL hidden;
@property (nonatomic, readonly) id nativeTextField;
@end
