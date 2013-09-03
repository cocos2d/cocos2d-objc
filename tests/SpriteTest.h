
#import "BaseAppController.h"
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
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

@interface SpriteBatchNodeReorderIssue766 : SpriteDemo
{
	CCSpriteBatchNode *batchNode;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;
}
@end

@interface NodeSort : SpriteDemo
{
	CCNode *node;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;
	CCSprite *sprite4;
	CCSprite *sprite5;
}
@end

@interface SpriteBatchNodeReorderSameIndex : SpriteDemo
{
	CCSpriteBatchNode *batchNode;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;
	CCSprite *sprite4;
	CCSprite *sprite5;
}
@end

@interface SpriteBatchNodeReorderOneChild : SpriteDemo
{
	CCSpriteBatchNode *batchNode_;
	CCSprite *reorderSprite_;
}
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

@interface SpriteFrameAliasNameTest : SpriteDemo
{}
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

@interface SpriteOffsetAnchorSkew : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorRotationalSkew : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorSkew : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorRotationalSkew : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorSkewScale : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorRotationalSkewScale : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorSkewScale : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorRotationalSkewScale : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorFlip : SpriteDemo
{}
@end

@interface SpriteBatchNodeOffsetAnchorFlip : SpriteDemo
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

@interface SpriteBatchNodeChildrenZ : SpriteDemo
{}
@end

@interface SpriteChildrenVisibility : SpriteDemo
{}
@end

@interface SpriteChildrenVisibilityIssue665 : SpriteDemo
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

@interface SpriteBatchNodeSkewNegativeScaleChildren : SpriteDemo
{}
@end

@interface SpriteBatchNodeRotationalSkewNegativeScaleChildren : SpriteDemo
{}
@end

@interface SpriteSkewNegativeScaleChildren : SpriteDemo
{}
@end

@interface SpriteRotationalSkewNegativeScaleChildren : SpriteDemo
{}
@end

@interface SpriteNilTexture : SpriteDemo
{}
@end

@interface SpriteSubclass : SpriteDemo
{}
@end

@interface SpriteDoubleResolution : SpriteDemo
{}
@end


@interface AnimationCache : SpriteDemo
{}
@end

@interface AnimationCacheFile : SpriteDemo
{}
@end

@interface SpriteBatchBug1217 : SpriteDemo
{}
@end

@interface Sprite9Slice : SpriteDemo

@end

