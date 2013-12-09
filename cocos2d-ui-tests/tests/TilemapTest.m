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

-(void) setupTilemapTest
{
	CCTiledMap *tmap = [CCTiledMap tiledMapWithFile:@"TileMaps/orthogonal-test1.tmx"];
	
	[self.contentNode addChild:tmap];
}

@end
