//
//  TestBase.h
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 9/17/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface TestBase : CCNode
{
    CCLabelTTF* _lblTitle;
}

@property (nonatomic,strong) CCNode* contentNode;

+ (CCScene *) sceneWithTestName:(NSString*)testName;

@end
