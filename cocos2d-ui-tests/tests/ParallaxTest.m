//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 11/15/13.
//

#import "cocos2d.h"

// local import
#import "TestBase.h"

@interface ParallaxTest : TestBase @end

@implementation ParallaxTest

CCParallaxNode *parallaxNode;

- (NSArray*) testConstructors
{
  return [NSArray arrayWithObjects:
          @"setupParallaxTest1",
          @"setupParallaxTest2",
          nil];
}


-(void) setupParallaxTest1
{
    self.subTitle = @"Parallax: parent and 3 children";
    self.userInteractionEnabled = NO;
		
    // Top Layer, a simple image
		CCSprite *cocosImage = [CCSprite spriteWithImageNamed:@"Images/powered.png"];
		// scale the image (optional)
		cocosImage.scale = 1.0f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);


		// Middle layer: a Tile map atlas
		CCTiledMap *tilemap = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-test1.tmx" ];

		// change the transform anchor to 0,0 (optional)
		tilemap.anchorPoint = ccp(0, 0);

		// background layer: another image
		CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/background.png"];
		// scale the image (optional)
		background.scale = 1.5f;
		// change the transform anchor point (optional)
		background.anchorPoint = ccp(0,0);

		// create a void node, a parent node
		CCParallaxNode *voidNode = [CCParallaxNode node];

		// NOW add the 3 layers to the 'void' node

		// background image is moved at a ratio of 0.4x, 0.5y
		[voidNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];

		// tiles are moved at a ratio of 2.2x, 1.0y
		[voidNode addChild:tilemap z:1 parallaxRatio:ccp(2.2f,1.0f) positionOffset:ccp(0,0)];

		// top image is moved at a ratio of 3.0x, 2.5y
		[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(300,200)];


		// now create some actions that will move the 'void' node
		// and the children of the 'void' node will move at different
		// speed, thus, simulation the 3D environment
		id goUp = [CCActionMoveBy actionWithDuration:4 position:ccp(0,-200)];
		id goDown = [goUp reverse];
		id go = [CCActionMoveBy actionWithDuration:8 position:ccp(-150,0)];
		id goBack = [go reverse];
		id seq = [CCActionSequence actions:
				  goUp,
				  go,
				  goDown,
				  goBack,
				  nil];
		[voidNode runAction: [CCActionRepeatForever actionWithAction:seq ] ];

		[self.contentNode addChild:voidNode];

}

#pragma mark Example Parallax 2

-(void) setupParallaxTest2
{
    self.userInteractionEnabled = YES;
  
    // Make the node fill the entire area. Required for user interaction.
    self.contentSizeType = CCSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    self.subTitle = @"Parallax: drag screen";
  
		// Top Layer, a simple image
		CCSprite *cocosImage = [CCSprite spriteWithImageNamed:@"Images/powered.png"];
		// scale the image (optional)
		cocosImage.scale = 2.5f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);


		// Middle layer: a Tile map atlas
		CCTiledMap *tilemap = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-test5.tmx" ];


		// change the transform anchor to 0,0 (optional)
		tilemap.anchorPoint = ccp(0, 0);

		// background layer: another image
		CCSprite *background = [CCSprite spriteWithImageNamed:@"Images/background.png"];
		// scale the image (optional)
		background.scale = 1.5f;
		// change the transform anchor point (optional)
		background.anchorPoint = ccp(0,0);


		// create a void node, a parent node
		parallaxNode = [CCParallaxNode node];

		// NOW add the 3 layers to the 'void' node

		// background image is moved at a ratio of 0.4x, 0.5y
		[parallaxNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];

		// tiles are moved at a ratio of 1.0, 1.0y
		[parallaxNode addChild:tilemap z:1 parallaxRatio:ccp(1.0f,1.0f) positionOffset:ccp(0,-200)];

		// top image is moved at a ratio of 3.0x, 2.5y
		[parallaxNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,1000)];
  
    [self.contentNode addChild:parallaxNode z:0];

}

#if ( TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR )

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self touchEnded:touch withEvent:event];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self touchEnded:touch withEvent:event];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];
  
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
  
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	

	CGPoint currentPos = [parallaxNode position];
	[parallaxNode setPosition: ccpAdd(currentPos, diff)];
}

#else

- (void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint currentPos = [parallaxNode position];
	[parallaxNode setPosition: ccpAdd(currentPos, CGPointMake( theEvent.deltaX, -theEvent.deltaY) )];
}
#endif

@end


