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
@end


@interface Sprite1 : SpriteDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteSheet1 : SpriteDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteColorOpacity : SpriteDemo
{}
@end

@interface SpriteSheetColorOpacity : SpriteDemo
{}
@end

@interface SpriteZOrder : SpriteDemo
{
	int dir;
}
@end

@interface SpriteSheetZOrder : SpriteDemo
{
	int dir;
}
@end


@interface SpriteZVertex : SpriteDemo
{
	int dir;
	float	time;
}
@end

@interface SpriteSheetZVertex : SpriteDemo
{
	int dir;
	float	time;
}
@end


@interface SpriteAnchorPoint : SpriteDemo
{}
@end

@interface SpriteSheetAnchorPoint : SpriteDemo
{}
@end

@interface Sprite6 : SpriteDemo
{}
@end

@interface SpriteFlip : SpriteDemo
{}
@end

@interface SpriteSheetFlip : SpriteDemo
{}
@end

@interface SpriteAliased : SpriteDemo
{}
@end

@interface SpriteSheetAliased : SpriteDemo
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

@interface SpriteSheetNewTexture : SpriteDemo
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
{}
@end

@interface SpriteOffsetAnchorRotation : SpriteDemo
{}
@end

@interface SpriteSheetOffsetAnchorRotation : SpriteDemo
{}
@end

@interface SpriteOffsetAnchorScale : SpriteDemo
{}
@end

@interface SpriteSheetOffsetAnchorScale : SpriteDemo
{}
@end

@interface SpriteHybrid : SpriteDemo
{
	BOOL	usingSpriteSheet;
}
@end

@interface SpriteSheetChildren : SpriteDemo
{}
@end

@interface SpriteSheetChildren2 : SpriteDemo
{}
@end

@interface SpriteSheetChildrenZ : SpriteDemo
{}
@end

@interface SpriteChildrenVisibility : SpriteDemo
{}
@end

@interface SpriteChildrenAnchorPoint : SpriteDemo
{}
@end

@interface SpriteSheetChildrenAnchorPoint : SpriteDemo
{}
@end

@interface SpriteSheetChildrenScale : SpriteDemo
{}
@end

@interface SpriteChildrenChildren: SpriteDemo
{}
@end

@interface SpriteSheetChildrenChildren: SpriteDemo
{}
@end

@interface SpriteSheetReorder : SpriteDemo
{}
@end

@interface SpriteNilTexture : SpriteDemo
{}
@end


