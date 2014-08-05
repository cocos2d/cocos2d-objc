//
//  CCEditText.h
//  cocos2d-ios
//
//  Created by Sergey Klimov on 8/5/14.
//
//

#import <BridgeKitV3/BridgeKit.h>
BRIDGE_CLASS("org.cocos2d.CCEditText")
@interface CCEditText : AndroidEditText
- (id)initWithContext:(AndroidContext *)context;

- (void)setTextSizeDouble:(double)textSize;
@end
