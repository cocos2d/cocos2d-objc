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
    @"foo\nbar",
    @"0123456789",
    @"ABCDEFGHIJKLM\nNOPQRSTUVWXYZ",
    @"abcdefghijklm\nnopqrstuvwxyz",
    @"first line\u2028second line",
    @",.?!;:'\"",
    @"()[]{}<>\\|/\n",
    @"@#$%^&*+-=_",
    @" ab c de\n fg  hi j k",
    @"Supercalifragilisticexpialidocious even if the sound of it is something quite atrocious",
};
static const int TEST_STRING_COUNT = sizeof(TEST_STRINGS)/sizeof(*TEST_STRINGS);

@interface CCBMFontTest : TestBase @end

@implementation CCBMFontTest
{
    CCTime (^_updateBlock)(void);
    CCTime _testLoopTimer;
    BOOL _runTestLoop;
}

-(void)testFont:(NSString *)font
{
    self.subTitle = [NSString stringWithFormat:@"Test bitmap fonts. (%@)", font];
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:TEST_STRINGS[0] fntFile:font];
    label.positionType = CCPositionTypeNormalized;
    label.position = ccp(0.5, 0.5);
    [self.contentNode addChild:label];

    NSLog(@"Running test for %@", font);
    
    __block int i = 0;
    
    const CCTime delay = 2.0;
    
    _runTestLoop = YES;
    _testLoopTimer = delay;
    _updateBlock = ^(void) {
        i = (i + 1)%TEST_STRING_COUNT;
        label.string = TEST_STRINGS[i];
        return delay;
    };
}

- (void)update:(CCTime)delta
{
    if (_runTestLoop)
    {
        _testLoopTimer -= delta;
        if (_testLoopTimer < 0.0f)
        {
            CCTime delay = _updateBlock();
            _testLoopTimer = delay;
        }
    }
}

- (void)pressedNext:(id)sender
{
    // stop running the block and release it
    _runTestLoop = NO;
    _updateBlock = nil;
    [super pressedNext:sender];
}

-(void)setupBMFont01Test {[self testFont:@"din.fnt"];}
-(void)setupBMFont02Test {[self testFont:@"arial-unicode-26.fnt"];}
-(void)setupBMFont03Test {[self testFont:@"arial16.fnt"];}
-(void)setupBMFont04Test {[self testFont:@"bitmapFontTest.fnt"];}
-(void)setupBMFont06Test {[self testFont:@"bitmapFontTest3.fnt"];}
-(void)setupBMFont07Test {[self testFont:@"bitmapFontTest4.fnt"];}
-(void)setupBMFont08Test {[self testFont:@"bitmapFontTest5.fnt"];}
-(void)setupBMFont09Test {[self testFont:@"boundsTestFont.fnt"];}
-(void)setupBMFont10Test {[self testFont:@"font-issue1343.fnt"];}
-(void)setupBMFont11Test {[self testFont:@"futura-48.fnt"];}
-(void)setupBMFont12Test {[self testFont:@"konqa32.fnt"];}
-(void)setupBMFont14Test {[self testFont:@"markerFelt.fnt"];}
-(void)setupBMFont15Test {[self testFont:@"west_england-64.fnt"];}

NSDictionary *testConfigSet(int config)
{
    static NSArray *testConfigs = nil;
    static NSUInteger testConfigsCount = 0;
    if (testConfigs == nil)
    {
        testConfigs = @[
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @9 },
           
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @0 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @1 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:1.0], @"Font" : @"arial-unicode-26.fnt", @"String" : @2 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @3 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @4 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:0.5], @"Font" : @"markerFelt.fnt", @"String" : @5 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentLeft], @"Explainer" : @"Left",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @6 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentCenter], @"Explainer" : @"Center",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @7 },
           @{ @"Alignment" : [NSNumber numberWithUnsignedInteger:CCTextAlignmentRight], @"Explainer" : @"Right",
              @"Width" : [NSNumber numberWithFloat:1.5], @"Font" : @"arial-unicode-26.fnt", @"String" : @8 },
           ];
        testConfigsCount = [testConfigs count];
    }
    return testConfigs[config % testConfigsCount];
}

- (void)testFontWrapping:(NSDictionary *)testConfig
{
    CGSize screenSize = [[CCDirector currentDirector] viewSize];
    float baseWidth = screenSize.width / 2.0f;
    float currentWidth = baseWidth * [testConfig[@"Width"] floatValue];
    CCTextAlignment align = [testConfig[@"Alignment"] unsignedIntegerValue];

    NSUInteger ix = [testConfig[ @"String" ] unsignedIntegerValue];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:TEST_STRINGS[ix] fntFile:testConfig[@"Font"] width:currentWidth alignment:align];
    [label setPositionType:CCPositionTypeNormalized];
    [label setPosition:ccp(0.5f, 0.5f)];
    [[self contentNode] addChild:label];
    NSString *explanation = [NSString stringWithFormat:@"%@ - Align:%@ - Width:%0.2f", testConfig[@"Font"],
                             testConfig[ @"Explainer" ], currentWidth];

    // To see debug frames around the label and font characters, uncomment
    // the following lines.  This is helpful when working on font rendering.
    //    explanation = [explanation stringByAppendingString:@"\ndebugDraw - GREEN: content rect - RED: width property"];
    //    [label setEnableDebugDrawing:YES];
    
    [self setSubTitle:explanation];
}

- (void)setupBMFontWrap00Test { [self testFontWrapping:testConfigSet(0)]; }
- (void)setupBMFontWrap01Test { [self testFontWrapping:testConfigSet(1)]; }
- (void)setupBMFontWrap02Test { [self testFontWrapping:testConfigSet(2)]; }
- (void)setupBMFontWrap03Test { [self testFontWrapping:testConfigSet(3)]; }
- (void)setupBMFontWrap04Test { [self testFontWrapping:testConfigSet(4)]; }
- (void)setupBMFontWrap05Test { [self testFontWrapping:testConfigSet(5)]; }
- (void)setupBMFontWrap06Test { [self testFontWrapping:testConfigSet(6)]; }
- (void)setupBMFontWrap07Test { [self testFontWrapping:testConfigSet(7)]; }
- (void)setupBMFontWrap08Test { [self testFontWrapping:testConfigSet(8)]; }
- (void)setupBMFontWrap09Test { [self testFontWrapping:testConfigSet(9)]; }
- (void)setupBMFontWrap10Test { [self testFontWrapping:testConfigSet(10)]; }
- (void)setupBMFontWrap11Test { [self testFontWrapping:testConfigSet(11)]; }
- (void)setupBMFontWrap12Test { [self testFontWrapping:testConfigSet(12)]; }
- (void)setupBMFontWrap13Test { [self testFontWrapping:testConfigSet(13)]; }
- (void)setupBMFontWrap14Test { [self testFontWrapping:testConfigSet(14)]; }
- (void)setupBMFontWrap15Test { [self testFontWrapping:testConfigSet(15)]; }
- (void)setupBMFontWrap16Test { [self testFontWrapping:testConfigSet(16)]; }
- (void)setupBMFontWrap17Test { [self testFontWrapping:testConfigSet(17)]; }

- (void)setupBMFontStylingTest
{
    CGSize screenSize = [[CCDirector currentDirector] viewSize];
    float currentWidth = screenSize.width / 2.0f;
    
    NSString *highlightString = @"even if the sound";
    NSString *testString = @"Supercalifragilisticexpialidocious even if the sound of it is something quite atrocious";
    NSRange highlightRange = [testString rangeOfString:highlightString];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:testString fntFile:@"arial16.fnt" width:currentWidth alignment:CCTextAlignmentLeft];
    [label setColor:[CCColor whiteColor]];
    NSArray *highlightChars = [label characterSpritesForRange:highlightRange];
    for (CCSprite *fontSprite in highlightChars)
    {
        [fontSprite setColor:[CCColor cyanColor]];
    }
    [label setPositionType:CCPositionTypeNormalized];
    [label setPosition:ccp(0.5f, 0.5f)];
    [[self contentNode] addChild:label];
    NSString *explanation = @"Styling font characters - color";
    
    // To see debug frames around the label and font characters, uncomment
    // the following lines.  This is helpful when working on font rendering.
    //    explanation = [explanation stringByAppendingString:@"\ndebugDraw - GREEN: content rect - RED: width property"];
    //    [label setEnableDebugDrawing:YES];
    
    [self setSubTitle:explanation];
}

- (void)setupBMFontStyling2Test
{
    CGSize screenSize = [[CCDirector currentDirector] viewSize];
    float currentWidth = screenSize.width / 2.0f;
    
    NSString *boldString = @"boldly go";
    NSString *italicString = @"new civilizations";
    NSString *testString = @"to seek out new life and new civilizations, to boldly go where no man has gone before.";
    NSRange boldRange = [testString rangeOfString:boldString];
    NSRange italicRange = [testString rangeOfString:italicString];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:testString fntFile:@"arial16.fnt" width:currentWidth alignment:CCTextAlignmentLeft];
    [label setColor:[CCColor whiteColor]];
    {
        NSArray *highlightChars = [label characterSpritesForRange:boldRange];
        CCEffectBloom *boldEffect = [CCEffectBloom effectWithBlurRadius:1 intensity:0.5 luminanceThreshold:0.1];
        for (CCSprite *fontSprite in highlightChars)
        {
            [fontSprite setEffect:boldEffect];
        }
    }
    {
        NSArray *highlightChars = [label characterSpritesForRange:italicRange];
        for (CCSprite *fontSprite in highlightChars)
        {
            [fontSprite setSkewX:20.0f];
        }
    }
    [label setPositionType:CCPositionTypeNormalized];
    [label setPosition:ccp(0.5f, 0.5f)];
    [[self contentNode] addChild:label];
    NSString *explanation = @"Styling font characters - bold/italic";
    
    // To see debug frames around the label and font characters, uncomment
    // the following lines.  This is helpful when working on font rendering.
    //    explanation = [explanation stringByAppendingString:@"\ndebugDraw - GREEN: content rect - RED: width property"];
    //    [label setEnableDebugDrawing:YES];
    
    [self setSubTitle:explanation];
}


@end
