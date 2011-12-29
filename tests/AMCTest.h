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

@interface AMCDemo: CCLayer
{
    CCTextureAtlas	*atlas;
}

// Creates layer first time, that we will save/load after.
-(CCLayer *) insideLayer;

-(NSString*) title;
-(NSString*) subtitle;
@end

#pragma mark - Actual AMC Tests

#pragma mark Node + Children

/** @class RectNode Simple CCNode that draws a rectangle around it's bounds. */
@interface RectNode : CCNode
@end

/** @class NodeAMC Visual test for CCNode save/load with hierarchy,tag, zOrder 
 * & all transformations.
 * Uses RectNode for all nodes.
 */
@interface NodeAMC : AMCDemo
@end

#pragma mark Sprite + SpriteFrame + Texture
@interface SpriteAMC1 : AMCDemo
{}
-(CCSprite *) spriteWithCoords:(CGPoint)p;
@end

@interface LayersAMC : AMCDemo {

}
@end




