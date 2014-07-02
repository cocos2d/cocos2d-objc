//
//  CCEffectStack_Private.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectStack.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@interface CCEffectStack ()
{
    NSMutableArray *_effects;
}

@property (nonatomic) BOOL passesDirty;

@end
#endif
