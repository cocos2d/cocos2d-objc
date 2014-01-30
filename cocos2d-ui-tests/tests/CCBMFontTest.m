//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextureCache.h"

@interface CCBMFontTest : TestBase @end

@implementation CCBMFontTest

- (void) setupSimpleAudioTest
{
    self.subTitle = @"Test bitmap fonts.";
    
		NSString *string =
			@"@Q&wyHDB4#qphdi\n"
			@"WYK>kgbE?97652f\n"
			@"MlXS<'U8Z{/usonec:\n"
			@"$}V0C%T3Lj1a)=~_\n"
			@"A!RGmPOJ\t]*-`\n"
			@"^;xv+NzF\"r[:(|l";
			
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:string fntFile:@"din.fnt"];
		label.positionType = CCPositionTypeNormalized;
		label.position = ccp(0.5, 0.5);
		[self.contentNode addChild:label];
}

@end
