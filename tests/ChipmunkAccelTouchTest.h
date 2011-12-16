//
// cocos2d
//

#import "cocos2d.h"
#import "chipmunk.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;				// weak ref
	UINavigationController *navigationController_;	// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;

@end

@interface MainLayer : CCLayer
{
	CCTexture2D *spriteTexture_; // weak ref
	
	cpSpace *space_; // strong ref
	
	cpShape *walls_[4];
}
@end
	

@interface PhysicsSprite : CCSprite
{
	cpBody *body_;	// strong ref
}

-(void) setPhysicsBody:(cpBody*)body;

@end