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

@property (nonatomic, assign) BOOL passesDirty;
@property (nonatomic, assign) BOOL stitchingEnabled;
@property (nonatomic, strong) NSMutableArray *effects;

@end
