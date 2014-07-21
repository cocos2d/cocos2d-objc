//
//  CCGLView.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/22/14.
//
//

#import "ccMacros.h"

#if __CC_PLATFORM_ANDROID

#import <BridgeKitV3/BridgeKit.h>
#import <android/native_window.h>
#import <bridge/runtime.h>
#import <BridgeKitV3/BridgeKit.h>

#import "../../Platforms/CCGL.h"

BRIDGE_CLASS("org.cocos2d.CCGLView")
@interface CCGLView : AndroidSurfaceView

- (id)initWithContext:(AndroidContext *)context;
- (id)initWithContext:(AndroidContext *)context scaleFactor:(float)scaleFactor;
- (BOOL)onTouchEvent:(AndroidMotionEvent *)event;

- (BOOL)setupView:(ANativeWindow*)window;
- (void)swapBuffers;

@property (nonatomic) CGFloat contentScaleFactor;
@property (nonatomic) CGRect bounds;
@property (nonatomic, readonly) EGLDisplay eglDisplay;
@property (nonatomic, readonly) EGLSurface eglSurface;
@property (nonatomic, readonly) EGLContext eglContext;
@property (nonatomic, readonly) EGLConfig eglConfiguration;

- (void)addGestureDetector:(AndroidGestureDetector *)detector;
- (void)removeGestureDetector:(AndroidGestureDetector *)detector;

@end
#endif // __CC_PLATFORM_ANDROID


