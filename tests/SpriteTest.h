#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface SpriteDemo: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface Sprite1 : SpriteDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteBatchNode1 : SpriteDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteColorOpacity : SpriteDemo
{}
@end

@interface SpriteBatchNodeColorOpacity : SpriteDemo
{}
@end

@interface SpriteZOrder : SpriteDemo
{
	int dir;
}
@end

@interface SpriteBatchNodeZOrder : SpriteDemo
{
	int dir;
}
@end

@interface SpriteBatchNodeReorder : SpriteDemo
{}
@end

@interface SpriteBatchNodeReorderIssue744 : SpriteDemo
{}
@end

@interface SpriteBatchNodeReorderIssue767 : SpriteDemo
{}
@end

@interface SpriteZVertex : SpriteDemo
{
	int dir;
	float	time;
}
@end

@interface SpriteBatchNodeZVertex : SpriteDemo
{
	int dir;
	float	time;
}
@end


@interface SpriteAnchorPoint : SpriteDemo
{}
@end

@interface SpriteBatchNodeAnchorPoint : SpriteDemo
{}
@end

@interface Sprite6 : SpriteDemo
{}
@end

@interface SpriteFlip : SpriteDemo
{}
@end

@interface SpriteBatchNodeFlip : SpriteDemo
{}
@end

@interface SpriteAliased : SpriteDemo
{}
@end

@interface SpriteBatchNodeAliased : SpriteDemo
{}
@end

@interface SpriteNewTexture : SpriteDemo
{
	BOOL	usingTexture1;
	CCTexture2D	*texture1;
	CCTexture2D	*texture2;
}
-(void) addNewSprite;
@end

@interface SpriteBatchNodeNewTexture : SpriteDemo
{
	CCTexture2D	*texture1;
	CCTexture2D	*texture2;
}
-(void) addNewSprite;
@end

@interface SpriteAnimationSplit : SpriteDemo
{}
@end

@interface SpriteFrameTest : SpriteDemo
{
	CCSprite *sprite1, *sprite2;
	int counter;
}
@end

@interface SpriteOffsetAnchorRotation : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorRotation : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorScale : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorScale : SpriteDemo
{}
@end

@interface SpriteHybrid : SpriteDemo
{
	BOOL	usingSpriteBatchNode;
}
@end

@interface SpriteBatchNodeChildren : SpriteDemo
{}
@end

@interface SpriteBatchNodeChildren2 : SpriteDemo
{}
@end

@interface SpriteBatchNodeChildrenZ : SpriteDemo
{}
@end

@interface SpriteChildrenVisibility : SpriteDemo
{}
@end

@interface SpriteChildrenAnchorPoint : SpriteDemo
{}
@end

@interface SpriteBatchNodeChildrenAnchorPoint : SpriteDemo
{}
@end

@interface SpriteBatchNodeChildrenScale : SpriteDemo
{}
@end

@interface SpriteChildrenChildren: SpriteDemo
{}
@end

@interface SpriteBatchNodeChildrenChildren: SpriteDemo
{}
@end

@interface SpriteNilTexture : SpriteDemo
{}
@end

@interface SpriteSubclass : SpriteDemo
{}
@end


