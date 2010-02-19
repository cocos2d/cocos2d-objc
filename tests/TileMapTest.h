#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TileDemo: CCLayer
{
    CCTextureAtlas *atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface TileMapTest : TileDemo
{
}
@end

@interface TileMapEditTest : TileDemo
{
}
@end


@interface TMXOrthoTest : TileDemo
{
}
@end

@interface TMXOrthoTest2 : TileDemo
{
}
@end

@interface TMXOrthoTest3 : TileDemo
{
}
@end

@interface TMXOrthoTest4 : TileDemo
{
}
@end

@interface TMXReadWriteTest : TileDemo
{
	unsigned int gid;
	unsigned int gid2;
}
@end

@interface TMXHexTest : TileDemo
{
}
@end

@interface TMXIsoTest : TileDemo
{
}
@end

@interface TMXIsoTest1 : TileDemo
{
}
@end

@interface TMXIsoTest2 : TileDemo
{
}
@end

@interface TMXUncompressedTest : TileDemo
{
}
@end


@interface TMXTilesetTest : TileDemo
{
}
@end

@interface TMXObjectsTest : TileDemo
{
}
@end

@interface TMXResizeTest : TileDemo
{
}
@end

@interface TMXIsoZorder : TileDemo
{
	CCSprite *tamara;
}
@end
