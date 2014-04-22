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
@implementation TilemapTest

-(void) setupTilemap1Test
{
	self.subTitle = @"TileMaps/orthogonal-test1.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:map];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
}

-(void) setupTilemap2Test
{
	self.subTitle = @"TileMaps/orthogonal-desert-test-with-flips.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:map];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
}

-(void) setupTilemap3Test
{
	self.subTitle = @"TileMaps/orthogonal-testLarge.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:map];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
}

-(void) setupTilemap4Test
{
	self.subTitle = @"TileMaps/orthogonal-desert-obscenely-large.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:map];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
}

-(void) setupTilemap5Test
{
	self.subTitle = @"TileMaps/orthogonal-desert-test-with-flips.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	map.anchorPoint = ccp(0.5, 0.5);
	map.position = map.anchorPointInPoints;
	[map runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:10.0 angle:90]]];
	
	CCNode *content = [CCNode node];
	content.contentSize = map.contentSize;
	[content addChild:map];
	
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:content];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
}

@end
