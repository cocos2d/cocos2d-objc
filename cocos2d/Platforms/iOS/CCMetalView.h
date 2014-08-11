#import "ccMacros.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

#import "../../ccMacros.h"

@interface CCMetalView : UIView

@property(nonatomic, readonly) id<MTLDevice> device;
@property(nonatomic, readonly) id<MTLCommandBuffer> currentCommandBuffer;
@property(nonatomic, readonly) id<MTLTexture> currentFramebufferTexture;

///** pixel format: it could be RGBA8 (32-bit) or RGB565 (16-bit) */
//@property(nonatomic,readonly) NSString* pixelFormat;
//
///** depth format of the render buffer: 0, 16 or 24 bits*/
//@property(nonatomic,readonly) GLuint depthFormat;

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

-(void)beginFrame;
-(void) presentFrame;

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point;
- (CGRect) convertRectFromViewToSurface:(CGRect)rect;
@end

#endif // __CC_PLATFORM_IOS
