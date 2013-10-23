//
//  CCTextField.h
//  cocos2d-ios
//
//  Created by Viktor on 10/22/13.
//
//

#import "cocos2d.h"
#import "CCControl.h"

@interface CCTextField : CCControl <UITextFieldDelegate>
{
    BOOL _keyboardIsShown;
    float _keyboardHeight;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)frame;

@property (nonatomic,readonly) UITextField* textField;
@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,assign) float padding;
@property (nonatomic,strong) NSString* string;

@end
