//
//  CCEffectStack_Private.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectStack.h"

@interface CCEffectStack ()
{
    NSMutableArray *_effects;
}

@property (nonatomic) BOOL passesDirty;

@end

