//
// Color Tests
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 12/12/13.
//

#import "cocos2d.h"
#import "TestBase.h"

@interface ColorTest : TestBase @end

@implementation ColorTest

- (void) setUp
{
	[[CCFileUtils sharedFileUtils] setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
}

- (CCSprite *) loadAndDisplayImageNamed:(NSString*) fileName withTitle:(NSString*) title{

	self.subTitle = title;
	
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	CCSprite *img = [CCSprite spriteWithImageNamed:fileName];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self.contentNode addChild:img];
	return img;
}

-(void) setupTintRedTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @"Tint image red"];
	[img setColor:[CCColor redColor]];
}


-(void) setupNormalColorTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @"Image should be normal colored"];
	
	// Crazy color values should be correctly clamped unless using custom shaders.
	[img setColor:[CCColor colorWithRed:1.1f green:10.0f blue:100.0f alpha:1.1f]];
}

-(void) setupSetColorDoesNotChangeAlphaTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @"Image should not be transparent. setColor ignores alpha"];
	[img setColor:[CCColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
}


-(void) setupSetColorRGBASetsAlphaTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @"50% alpha, via setColorRGBA"];
	[img setColorRGBA:[CCColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
}

-(void) setupHalfTransparentViaOpacityTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @"50% alpha, via SetOpacity"];
	[img setOpacity:0.5f];
}

-(void) setupDoNotCascadeColorTest
{
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	// add parent with two children sprites.
	CCSprite *parent = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @""];
	[parent setPosition:ccp(s.width/2, s.height/3*2)];
	
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(-parent.contentSize.width, -100)];
	
	sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(2* parent.contentSize.width, -100)];
	
	parent.cascadeColorEnabled = NO;
	[parent setColor:[CCColor redColor]];
	
	self.subTitle = @"Parent should be red, children normal. (Color cascade off)";
}

-(void) setupCascadeColorTest
{
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	// add parent with two children sprites.
	CCSprite *parent = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @""];
	parent.name = @"Parent node";
	[parent setPosition:ccp(s.width/2, s.height/3*2)];
	
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(-parent.contentSize.width, -100)];
	
	sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(2* parent.contentSize.width, -100)];
	
	parent.cascadeColorEnabled = YES;
	[parent setColor:[CCColor redColor]];
	
	self.subTitle = @"Parent and 2 children sprites should all be red. (Color cascade)";
}

-(void) setupFadeChildrenTest
{
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	// add parent with two children sprites.
	CCSprite *parent = [self loadAndDisplayImageNamed: @"powered.png" withTitle: @""];
	parent.name = @"Parent node";
	[parent setPosition:ccp(s.width/2, s.height/3*2)];
	
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(-parent.contentSize.width, -100)];
	[sprite setColor:[CCColor redColor]];
	
	sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
	[parent addChild:sprite];
	[sprite setPosition:ccp(2* parent.contentSize.width, -100)];
	[sprite setColor:[CCColor greenColor]];
	
	parent.cascadeOpacityEnabled = YES;
	
	id seq = [CCActionSequence actions:
						[CCActionFadeOut actionWithDuration:0.5f],
						[CCActionFadeIn actionWithDuration:0.2f],
						nil];
	[parent runAction: [CCActionRepeatForever actionWithAction:seq ] ];

	
	self.subTitle = @"Parent and red/green child should all fade in and out together.";
}

-(void) setupCCNodeColorTest
{
	CCNodeColor *colorNode = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.3f blue:0.5f alpha:1.0f]];
	[self.contentNode addChild:colorNode];
		
	self.subTitle = @"A pretty blue background.";
}

-(void) setupCCNodeGradientColorTest
{
	CGSize s = [[CCDirector sharedDirector] viewSize];

	CCNodeGradient *colorNode = [CCNodeGradient nodeWithColor:[CCColor blueColor]
													fadingTo:[CCColor redColor]
													alongVector:ccp(1, 1)];
	colorNode.contentSize = CGSizeMake(200, 200);
	colorNode.position = ccp( s.width/2.0f - 100, s.height/2.0f - 100);
	[self.contentNode addChild:colorNode];
	
	self.subTitle = @"Blue bottom left, red top right";
}


-(void) unfinishedsetupBMFontColorCascadeTest
{
	CCNodeColor *colorNode = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
	[colorNode setCascadeColorEnabled:YES];
	[self.contentNode addChild:colorNode];

	CCLabelBMFont* bmFont = [CCLabelBMFont labelWithString:@"CCLabelBMFont" fntFile:@"font_menu.fnt"];
	[colorNode addChild:bmFont]; // This will be white (font bitmap is white)

	[bmFont setColor:[CCColor whiteColor]]; // Oh now it turns red :-)
	
	
	self.subTitle = @"Text color should be red.";
}
	
@end
