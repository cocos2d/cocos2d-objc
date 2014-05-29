//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 11/15/13.
//

#import "cocos2d.h"
#import "TestBase.h"
#import "CCTiledMapLayer_Private.h"

@interface TilemapTest : TestBase @end
@implementation TilemapTest {
	CCTiledMap *_map;
	CCNode *_content;
	CCScrollView *_scroll;
	
	CCDrawNode *_tileOrigin;
	CCDrawNode *_dot;
	
	CCTime _time;
}

-(void)testForMapNamed:(NSString *)mapName
{
	self.subTitle = mapName;
	
	_map = [CCTiledMap tiledMapWithFile:mapName];
	
	_content = [CCNode node];
	_content.contentSize = _map.contentSize;
	[_content addChild:_map];
	
	_scroll = [[CCScrollView alloc] initWithContentNode:_content];
	_scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:_scroll];
	
	if([_map layerNamed:@"Layer 0"].layerOrientation == CCTiledMapOrientationIso){
		_scroll.scrollPosition = ccp(_map.contentSizeInPoints.width/2 - _scroll.contentSizeInPoints.width/2, 0);
	}
	
	_tileOrigin = [CCDrawNode node];
	[_map addChild:_tileOrigin];
	
	CCDrawNode *draw = [CCDrawNode node];
	[draw drawDot:CGPointZero radius:5.0f color:[CCColor redColor]];
	
	draw.positionType = CCPositionTypeNormalized;
	draw.position = ccp(0.5, 0.5);
	[self.contentNode addChild:draw];
	_dot = draw;
}

-(void)update:(CCTime)delta
{
	_time += delta;
	
	CCTiledMapLayer *layer0 = [_map layerNamed:@"Layer 0"];
	
	CGPoint worldCenter = [_dot convertToWorldSpace:CGPointZero];
	CGPoint tileCenter = [layer0 convertToNodeSpace:worldCenter];
	CGPoint tile = [layer0 tileCoordinateAt:tileCenter];
	
	[_tileOrigin clear];
	[_tileOrigin drawDot:[layer0 positionAt:tile] radius:5.0 color:[CCColor blueColor]];
	
	layer0.animationBlock = ^(NSUInteger tileX, NSUInteger tileY, uint32_t *gid, uint32_t *flags, GLKVector4 *color){
		if(tile.x == tileX && tile.y == tileY){
			*color = GLKVector4Make(1, 0.5, 0.5, 1);
		}
	};
}

-(void) setupTilemap1Test
{
	[self testForMapNamed:@"TileMaps/orthogonal-test1.tmx"];
}

-(void) setupTilemap2Test
{
	[self testForMapNamed:@"TileMaps/orthogonal-desert-test-with-flips.tmx"];
}

-(void) setupTilemap3Test
{
	[self testForMapNamed:@"TileMaps/orthogonal-testLarge.tmx"];
}

-(void) setupTilemap4Test
{
	[self testForMapNamed:@"TileMaps/orthogonal-desert-obscenely-large.tmx"];
}

-(void) setupTilemap5Test
{
	[self testForMapNamed:@"TileMaps/orthogonal-desert-test-with-flips.tmx"];
	
	_map.anchorPoint = ccp(0.5, 0.5);
	_map.position = _map.anchorPointInPoints;
	[_map runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:10.0 angle:90]]];
}

-(void) setupTilemap6Test
{
	[self testForMapNamed:@"TileMaps/iso-test-bug787.tmx"];
}

-(void) setupTilemap7Test
{
	// These files are in the SB directories.
	self.subTitle = @"TileMaps/orthogonal_resolution.tmx";
	
	CCNode *map = [CCTiledMap tiledMapWithFile:self.subTitle];
	CCScrollView *scroll = [[CCScrollView alloc] initWithContentNode:map];
	scroll.flipYCoordinates = NO;
	
	[self.contentNode addChild:scroll];
	scroll.scrollPosition = ccp(map.contentSizeInPoints.width/2 - scroll.contentSizeInPoints.width/2, 0);
}

@end
