#import "ccMacros.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

#import "CCDirectorView.h"

@interface CCMetalView : UIView<CCDirectorView>

@property(nonatomic, readonly) id<MTLDevice> device;
@property(nonatomic, readonly) id<MTLCommandBuffer> currentCommandBuffer;
@property(nonatomic, readonly) id<MTLTexture> currentFramebufferTexture;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

@end

#endif // __CC_PLATFORM_IOS
