//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 11/15/13.
//

#import "cocos2d.h"
#import "TestBase.h"

#import "CCTextureCache.h"

@interface TextureTest : TestBase @end

@implementation TextureTest

- (CCSprite *) loadAndDisplayImageNamed:(NSString*) fileName withTitle:(NSString*) title{
	[self.contentNode removeAllChildren];
	self.subTitle = title;
	
	CGSize s = [[CCDirector sharedDirector] viewSize];
	[[CCFileUtils sharedFileUtils] setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
	
	CCSprite *img = [CCSprite spriteWithImageNamed:fileName];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self.contentNode addChild:img];
	[CCTextureCache purgeSharedTextureCache];
	return img;
}

-(void) setupPNGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (has alpha)"];
}

-(void) setupPNGLoadingRedoverlayTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (With red color overlay)"];
	[img setColor:[UIColor redColor]];
}

-(void) setupBMPLoadingTest
{
	[self loadAndDisplayImageNamed:	@"test_image.bmp" withTitle: @"BMP loading example (no alpha)"];
}

-(void) setupJPEGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.jpeg" withTitle: @"JPEG loading example (no alpha, white spots)"];
}

-(void) setupPVRLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.pvr" withTitle: @"PVR loading example (no alpha)"];
}

-(void) setupTIFFLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.tiff" withTitle: @"TIFF loading example (has alpha)"];
}

-(void) setupPVRa8LoadingTest
{
	// Doesn't seem to work?
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8.pvr" withTitle: @"8 bit PVR, alpha only. (With red color overlay)"];
	[img setColor:[UIColor redColor]];
}

-(void) setupPVRa8v3LoadingTest
{
	// Doesn't seem to work?
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8_v3.pvr" withTitle: @"8 bit PVR v3, alpha only. (With red color overlay)"];
	[img setColor:[UIColor redColor]];
}

-(void) setupPVRa88LoadingTest
{
	// alpha fails to load?
	[self loadAndDisplayImageNamed: @"test_image_ai88.pvr" withTitle: @"8+8 bit PVR, alpha + greyscale."];

}
-(void) setupPVRa88v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_ai88_v3.pvr" withTitle: @"8+8 bit PVR v3, alpha  + greyscale."];
}

-(void) setup-pvrtc2bpp_v3-LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc2bpp_v3.pvr" withTitle: @"pvrtc2bpp_v3 "];
}


@end
