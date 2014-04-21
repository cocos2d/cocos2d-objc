//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 11/15/13.
//

#import "cocos2d.h"
#import "TestBase.h"

@interface TilemapTest : TestBase @end
@implementation TilemapTest {
	CCNode *map;
}

-(void) setupTilemap1Test
{
	self.userInteractionEnabled = YES;
	map = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-test1.tmx"];
	[self.contentNode addChild:map];
}

-(void) setupTilemap2Test
{
	self.userInteractionEnabled = YES;
	map = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-desert-test-with-flips.tmx"];
	[self.contentNode addChild:map];
}

-(void) setupTilemap3Test
{
	self.userInteractionEnabled = YES;
	map = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-testLarge.tmx"];
	[self.contentNode addChild:map];
}

-(void) setupTilemap4Test
{
	self.userInteractionEnabled = YES;
	map = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-desert-obscenely-large.tmx"];
	[self.contentNode addChild:map];
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
	

	CGPoint currentPos = [map position];
	[map setPosition: ccpAdd(currentPos, diff)];
}

#else

- (void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint currentPos = [parallaxNode position];
	[parallaxNode setPosition: ccpAdd(currentPos, CGPointMake( theEvent.deltaX, -theEvent.deltaY) )];
}
#endif


@end
