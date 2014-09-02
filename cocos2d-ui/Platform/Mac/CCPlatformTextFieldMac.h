//
//  CCPlatformTextFieldMac.h
//  cocos2d-osx
//
//  Created by Sergey Klimov on 7/1/14.
//
//

#import "CCMacros.h"

#if __CC_PLATFORM_MAC

#import <AppKit/AppKit.h>
#import "CCPlatformTextField.h"

@interface CCPlatformTextFieldMac : CCPlatformTextField <NSTextFieldDelegate>

@end

#endif
