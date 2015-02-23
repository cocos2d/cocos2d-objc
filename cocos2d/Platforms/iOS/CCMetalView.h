#import "ccMacros.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

#import "CCDirectorView.h"

/** Metal renderer, can be used in place of CCGLView on devices that support Metal rendering.
 
 @note Currently the `CC_ENABLE_METAL_RENDERING` preprocessor macro defined in ccConfig.h must be set to 1 to enable Metal rendering.
 */
@interface CCMetalView : UIView<CCDirectorView>

/** @name Properties */

@property(nonatomic, readonly, strong) id<MTLTexture> destinationTexture;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

@end

#endif // __CC_PLATFORM_IOS
