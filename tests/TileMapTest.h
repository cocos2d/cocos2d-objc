#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface TileDemo: CCLayer
{
    CCTextureAtlas *atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface TileMapTest : TileDemo
{}
@end

@interface TileMapEditTest : TileDemo
{}
@end


@interface TMXOrthoTest : TileDemo
{}
@end

@interface TMXOrthoTest2 : TileDemo
{}
@end

@interface TMXOrthoTest3 : TileDemo
{}
@end

@interface TMXOrthoTest4 : TileDemo
{}
@end

@interface TMXReadWriteTest : TileDemo
{
	unsigned int gid;
	unsigned int gid2;
}
@end

@interface TMXHexTest : TileDemo
{}
@end

@interface TMXIsoTest : TileDemo
{}
@end

@interface TMXIsoTest1 : TileDemo
{}
@end

@interface TMXIsoTest2 : TileDemo
{}
@end

@interface TMXUncompressedTest : TileDemo
{}
@end

@interface TMXTilesetTest : TileDemo
{}
@end

@interface TMXOrthoObjectsTest : TileDemo
{}
@end

@interface TMXIsoObjectsTest : TileDemo
{}
@end

@interface TMXGIDObjectsTest : TileDemo
{}
@end

@interface TMXResizeTest : TileDemo
{}
@end

@interface TMXIsoZorder : TileDemo
{
	CCSprite *tamara;
}
@end

@interface TMXOrthoZorder : TileDemo
{
	CCSprite *tamara;
}
@end

@interface TMXIsoVertexZ : TileDemo
{
	CCSprite *tamara;
}
@end

@interface TMXOrthoVertexZ : TileDemo
{
	CCSprite *tamara;
}
@end

@interface TMXIsoMoveLayer : TileDemo
{}
@end

@interface TMXOrthoMoveLayer : TileDemo
{}
@end

@interface TMXTilePropertyTest : TileDemo
{}
@end

@interface TMXOrthoFlipTest : TileDemo
{}
@end

@interface TMXOrthoFlipRunTimeTest : TileDemo
{}
@end

@interface TMXOrthoFromXMLTest : TileDemo 
{}
@end

@interface TMXBug987 : TileDemo
{}
@end

@interface TMXBug787 : TileDemo
{}
@end

