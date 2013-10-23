//
//  CCTextField.h
//  cocos2d-ios
//
//  Created by Viktor on 10/22/13.
//
//

#import "cocos2d.h"
#import "CCControl.h"

#ifdef __CC_PLATFORM_IOS
@interface CCTextField : CCControl <UITextFieldDelegate>
#elif defined(__CC_PLATFORM_MAC)
@interface CCTextField : CCControl
#endif
{
    BOOL _keyboardIsShown;
    float _keyboardHeight;
}


- (id) initWithSpriteFrame:(CCSpriteFrame*)frame;

#ifdef __CC_PLATFORM_IOS
@property (nonatomic,readonly) UITextField* textField;
#endif

@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,assign) float padding;
@property (nonatomic,strong) NSString* string;

@end
