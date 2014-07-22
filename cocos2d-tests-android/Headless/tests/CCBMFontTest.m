//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextureCache.h"

static NSString *TEST_STRINGS[] = {
	@"ABCDEFGHIJKLM\nNOPQRSTUVWXYZ",
	@"abcdefghijklm\nnopqrstuvwxyz",
	@",.?!;:'\"",
	@"()[]{}<>\\|/\n",
	@"@#$%^&*+-=_",
	@" ab c de\n fg  hi j k",
};
static const int TEST_STRING_COUNT = sizeof(TEST_STRINGS)/sizeof(*TEST_STRINGS);

@interface CCBMFontTest : TestBase @end

@implementation CCBMFontTest

-(void)testFont:(NSString *)font
{
    self.subTitle = [NSString stringWithFormat:@"Test bitmap fonts. (%@)", font];
		
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:TEST_STRINGS[0] fntFile:font];
		label.positionType = CCPositionTypeNormalized;
		label.position = ccp(0.5, 0.5);
		[self.contentNode addChild:label];
		
		__block int i = 0;
		const CCTime delay = 1.0;
		[self scheduleBlock:^(CCTimer *timer) {
			i = (i + 1)%TEST_STRING_COUNT;
			label.string = TEST_STRINGS[i];
			
			[timer repeatOnceWithInterval:delay];
		} delay:delay];
}

-(void)setupBMFont01Test {[self testFont:@"din.fnt"];}
-(void)setupBMFont02Test {[self testFont:@"Fonts/arial-unicode-26.fnt"];}
-(void)setupBMFont03Test {[self testFont:@"Fonts/arial16.fnt"];}
-(void)setupBMFont04Test {[self testFont:@"Fonts/bitmapFontTest.fnt"];}
-(void)setupBMFont06Test {[self testFont:@"Fonts/bitmapFontTest3.fnt"];}
-(void)setupBMFont07Test {[self testFont:@"Fonts/bitmapFontTest4.fnt"];}
-(void)setupBMFont08Test {[self testFont:@"Fonts/bitmapFontTest5.fnt"];}
-(void)setupBMFont09Test {[self testFont:@"Fonts/boundsTestFont.fnt"];}
-(void)setupBMFont10Test {[self testFont:@"Fonts/font-issue1343.fnt"];}
-(void)setupBMFont11Test {[self testFont:@"Fonts/futura-48.fnt"];}
-(void)setupBMFont12Test {[self testFont:@"Fonts/konqa32.fnt"];}
-(void)setupBMFont14Test {[self testFont:@"Fonts/markerFelt.fnt"];}
-(void)setupBMFont15Test {[self testFont:@"Fonts/west_england-64.fnt"];}

@end
