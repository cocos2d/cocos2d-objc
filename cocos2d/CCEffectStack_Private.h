//
//  CCEffectStack_Private.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectStack.h"
#import "CCEffectStackProtocol.h"


@interface CCEffectStack () <CCEffectStackProtocol>

@property (nonatomic) BOOL passesDirty;
@property (nonatomic) BOOL stitchingEnabled;
@property (nonatomic) NSMutableArray *effects;

@end
