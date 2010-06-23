//
// EAGLViewTest
// http://www.cocos2d-iphone.org
//

#import <UIKit/UIKit.h>

//CLASS INTERFACE
@interface EAGLViewTestDelegate : NSObject <UIApplicationDelegate>
{
	IBOutlet UIWindow				*window_;
	IBOutlet EAGLView				*glView_;	
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) EAGLView *glView;

@end
