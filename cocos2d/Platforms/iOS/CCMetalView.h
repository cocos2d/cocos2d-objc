#import "ccMacros.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

#import "CCDirectorView.h"

@interface CCMetalView : UIView<CCDirectorView>

@property(nonatomic, readonly, strong) id<MTLTexture> destinationTexture;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

@end

#endif // __CC_PLATFORM_IOS
