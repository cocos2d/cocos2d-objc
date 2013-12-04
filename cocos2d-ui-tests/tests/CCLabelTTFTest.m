//
//  CCLabelTTFTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Andy Korth on November 25th, 2013.
//

#import "CCLabelTTFTest.h"
#import "CCSlider.h"

@implementation CCLabelTTFTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupAlignedTTFs",
            nil];
}

static int fontIdx=0;
static NSString *fontList[] =
{
	@"American Typewriter",
	@"Marker Felt",
	@"A Damn Mess",
	@"Abberancy",
	@"Abduction",
	@"Paint Boy",
	@"Schwarzwald",
	@"Scissor Cuts",
};
static int fontCount = sizeof(fontList) / sizeof(*fontList);

static int vAlignIdx = 0;
static CCVerticalTextAlignment verticalAlignment[] =
{
  CCVerticalTextAlignmentTop,
  CCVerticalTextAlignmentCenter,
  CCVerticalTextAlignmentBottom,
};
static int vAlignCount = sizeof(verticalAlignment) / sizeof(*verticalAlignment);

- (void) pressedNext:(id) sender
{
	vAlignIdx += 1;
  if(vAlignIdx >= vAlignCount) {
    vAlignIdx = 0;
    fontIdx = (fontIdx + 1) % fontCount;
  }
	[self showFont: fontList[fontIdx]];
}

- (void) pressedPrev:(id) sender
{
	vAlignIdx -= 1;
	if( vAlignIdx < 0 ) {
    vAlignIdx = vAlignCount - 1;
    vAlignIdx--;
    if(fontIdx < 0)
      fontIdx = fontCount - 1;
  }
	[self showFont: fontList[fontIdx]];
}

- (void) pressedReset:(id)sender
{
	[self showFont: fontList[fontIdx]];
}

- (void) setupAlignedTTFs{
  [self pressedReset:nil];
}

- (void)showFont:(NSString *)aFont
{
  self.subTitle = @"Test alignment and fonts (click next a bunch of times)";
  
  CGSize s = [[CCDirector sharedDirector] viewSize];
  CGSize blockSize = CGSizeMake(s.width/3, 150);
  CGFloat fontSize = 13;
  
  [self.contentNode removeAllChildren ];
  
  CCLabelTTF *top = [CCLabelTTF labelWithString:aFont fontName:aFont fontSize:24];
	CCLabelTTF *left = [CCLabelTTF labelWithString:@"alignment left" fontName:aFont fontSize:fontSize dimensions:blockSize];
	CCLabelTTF *center = [CCLabelTTF labelWithString:@"alignment center" fontName:aFont fontSize:fontSize dimensions:blockSize];
	CCLabelTTF *right = [CCLabelTTF labelWithString:@"alignment right" fontName:aFont fontSize:fontSize dimensions:blockSize];
  
  [left setHorizontalAlignment:CCTextAlignmentLeft];
  [center setHorizontalAlignment:CCTextAlignmentCenter];
  [right setHorizontalAlignment:CCTextAlignmentRight];
  
  [left setVerticalAlignment:verticalAlignment[vAlignIdx]];
  [center setVerticalAlignment:verticalAlignment[vAlignIdx]];
  [right setVerticalAlignment:verticalAlignment[vAlignIdx]];
  
  CCNodeColor *leftColor = [CCNodeColor nodeWithColor:ccc4(100, 100, 100, 255) width:blockSize.width height:blockSize.height];
  CCNodeColor *centerColor = [CCNodeColor nodeWithColor:ccc4(200, 100, 100, 255) width:blockSize.width height:blockSize.height];
  CCNodeColor *rightColor = [CCNodeColor nodeWithColor:ccc4(100, 100, 200, 255) width:blockSize.width height:blockSize.height];
  
  top.anchorPoint = ccp(0.5, 1);
  left.anchorPoint = leftColor.anchorPoint = ccp(0,0.5);
  center.anchorPoint = centerColor.anchorPoint = ccp(0,0.5);
  right.anchorPoint = rightColor.anchorPoint = ccp(0,0.5);
  
	top.position = ccp(s.width/2,s.height-60);
	left.position = leftColor.position = ccp(0,s.height/3);
	center.position = centerColor.position = ccp(blockSize.width, s.height/3);
	right.position = rightColor.position = ccp(blockSize.width*2, s.height/3);
  
  [self.contentNode addChild:leftColor z:-1];
	[self.contentNode addChild:left z:0];
  [self.contentNode addChild:rightColor z:-1];
	[self.contentNode addChild:right z:0];
	[self.contentNode addChild:centerColor z:-1];
	[self.contentNode addChild:center z:0];
	[self.contentNode addChild:top z:0 ];

}


@end
