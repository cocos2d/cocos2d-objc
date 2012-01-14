//
// CCGLViewTest
// http://www.cocos2d-iphone.org
//

#import <UIKit/UIKit.h>

//CLASS INTERFACE
@interface EAGLViewTestDelegate : NSObject <UIApplicationDelegate>
{
	IBOutlet UIWindow				*window_;
	IBOutlet CCGLView				*glView_;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CCGLView *glView;

@end
