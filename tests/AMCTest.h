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

/** @class RectNode Simple CCNode that draws a rectangle around it's bounds. */
@interface RectNode : CCNode
@end

/** @class NodeAMC Visual test for CCNode save/load with hierarchy,tag, zOrder 
 * & all transformations.
 * Uses RectNode for all nodes.
 */
@interface NodeAMC : AMCDemo
@end

/** @class LayersAMC Visual test for CCLayer, CCLayerColor, CCLayerGradient & 
 * CCLayerMultiplex.
 * Added to AMCTest target, cause there was no tests for Layers before.
 */
@interface LayersAMC : AMCDemo {

}
@end

/** @class ParallaxAMC Visual test for CCParallaxNode.
 * Added to AMCTest target, cause ParallaxTest isn't compatible with AMC
 * due to depreceted (=> not-AMC-Supported) class use (CCTileMapAtlas).
 */
@interface ParallaxAMC : AMCDemo {
}
@end

/** @class ProgessTimerAMC Visual test for CCProgressTimer.
 * Added to AMCTest target, cause there was no test for CCProgressTimer before.
 */
@interface ProgessTimerAMC : AMCDemo {
}
@end

/** @class SceneAMC Visual test for saving/loading whole CCScene.
 *
 */
@interface SceneAMC : AMCDemo {
}
@end




