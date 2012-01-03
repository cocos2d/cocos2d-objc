#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // Mac

@interface SpriteDemo: CCLayer
{
}

+(id) nodeWithInsideLayer: (CCLayer *) insideLayer;
-(id) initWithInsideLayer: (CCLayer *) insideLayer;

-(NSString*) title;
-(NSString*) subtitle;
-(CCLayer *) insideLayer;
@end


@interface Sprite1 : CCLayer 
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteBatchNode1 : CCLayer
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface SpriteColorOpacity : CCLayer
{}
@end

@interface SpriteBatchNodeColorOpacity : CCLayer
{}
@end

@interface SpriteZOrder : CCLayer
{
	int dir;
}
@end

@interface SpriteBatchNodeZOrder : CCLayer
{
	int dir;
}
@end

@interface SpriteBatchNodeReorder : CCLayer
{}
@end

@interface SpriteBatchNodeReorderIssue744 : CCLayer
{}
@end

@interface SpriteBatchNodeReorderIssue766 : CCLayer
{
	CCSpriteBatchNode *batchNode;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;	
}
@end

@interface NodeSort : CCLayer
{
	CCNode *node;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;	
	CCSprite *sprite4;	
	CCSprite *sprite5;		
}
@end

@interface SpriteBatchNodeReorderSameIndex : CCLayer
{
	CCSpriteBatchNode *batchNode;
	CCSprite *sprite1;
	CCSprite *sprite2;
	CCSprite *sprite3;	
	CCSprite *sprite4;	
	CCSprite *sprite5;		
}
@end

@interface SpriteBatchNodeReorderOneChild : CCLayer
{
	CCSpriteBatchNode *batchNode_;
	CCSprite *reorderSprite_;		
}
@end

@interface SpriteBatchNodeReorderIssue767 : CCLayer
{}
@end

@interface SpriteZVertex : CCLayer
{
	int dir;
	float	time;
}
@end

@interface SpriteBatchNodeZVertex : CCLayer
{
	int dir;
	float	time;
}
@end


@interface SpriteAnchorPoint : CCLayer
{}
@end

@interface SpriteBatchNodeAnchorPoint : CCLayer
{}
@end

@interface Sprite6 : CCLayer
{}
@end

@interface SpriteFlip : CCLayer
{}
@end

@interface SpriteBatchNodeFlip : CCLayer
{}
@end

@interface SpriteAliased : CCLayer
{}
@end

@interface SpriteBatchNodeAliased : CCLayer
{}
@end

@interface SpriteNewTexture : CCLayer
{
	BOOL	usingTexture1;
	CCTexture2D	*texture1;
	CCTexture2D	*texture2;
}
-(void) addNewSprite;
@end

@interface SpriteBatchNodeNewTexture : CCLayer
{
	CCTexture2D	*texture1;
	CCTexture2D	*texture2;
}
-(void) addNewSprite;
@end

@interface SpriteAnimationSplit : CCLayer
{}
@end

@interface SpriteFrameTest : CCLayer
{
	CCSprite *sprite1, *sprite2;
	int counter;
}
@end

@interface SpriteFrameAliasNameTest : CCLayer
{}
@end

@interface SpriteOffsetAnchorRotation : CCLayer
{}
@end

@interface SpriteBatchNodeOffsetAnchorRotation : CCLayer
{}
@end

@interface SpriteOffsetAnchorScale : CCLayer
{}
@end

@interface SpriteBatchNodeOffsetAnchorScale : CCLayer
{}
@end

@interface SpriteOffsetAnchorSkew : CCLayer
{}
@end

@interface SpriteBatchNodeOffsetAnchorSkew : CCLayer
{}
@end

@interface SpriteOffsetAnchorSkewScale : CCLayer
{}
@end

@interface SpriteBatchNodeOffsetAnchorSkewScale : CCLayer
{}
@end


@interface SpriteOffsetAnchorFlip : CCLayer
{}
@end

@interface SpriteBatchNodeOffsetAnchorFlip : CCLayer
{}
@end


@interface SpriteHybrid : CCLayer
{
	BOOL	usingSpriteBatchNode;
}
@end

@interface SpriteBatchNodeChildren : CCLayer
{}
@end

@interface SpriteBatchNodeChildren2 : CCLayer
{}
@end

@interface SpriteBatchNodeChildrenZ : CCLayer
{}
@end

@interface SpriteChildrenVisibility : CCLayer
{}
@end

@interface SpriteChildrenVisibilityIssue665 : CCLayer
{}
@end

@interface SpriteChildrenAnchorPoint : CCLayer
{}
@end

@interface SpriteBatchNodeChildrenAnchorPoint : CCLayer
{}
@end

@interface SpriteBatchNodeChildrenScale : CCLayer
{}
@end

@interface SpriteChildrenChildren: CCLayer
{}
@end

@interface SpriteBatchNodeChildrenChildren: CCLayer
{}
@end

@interface SpriteBatchNodeSkewNegativeScaleChildren : CCLayer
{}
@end

@interface SpriteSkewNegativeScaleChildren : CCLayer 
{}
@end

@interface SpriteNilTexture : CCLayer
{}
@end

@interface SpriteSubclass : CCLayer
{}
@end

@interface AnimationCache : CCLayer
{}
@end

@interface AnimationCacheFile : CCLayer
{}
@end


