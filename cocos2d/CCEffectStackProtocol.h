//
//  CCEffectStackProtocol.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 6/19/14.
//
//

#import <Foundation/Foundation.h>

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@protocol CCEffectStackProtocol <NSObject>

- (void)passesDidChange:(id)sender;

@end
#endif
