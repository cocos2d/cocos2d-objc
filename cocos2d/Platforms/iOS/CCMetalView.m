#import "CCMetalView.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

#import "CCMetalView.h"
#import "../../CCDirector.h"
#import "../../ccMacros.h"
#import "../../CCConfiguration.h"
#import "CCScene.h"

#import "CCMetalSupport_Private.h"


#define CC_METAL_MAX_QUEUED_FRAMES 3


@implementation CCMetalView {
	CCMetalContext *_context;
	id<MTLDrawable> _currentDrawable;
	
	dispatch_semaphore_t _queuedFramesSemaphore;
	
	BOOL _layerSizeDidUpdate;
}

+ (Class) layerClass
{
	return NSClassFromString(@"CAMetalLayer");
}

- (id) initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame]))
	{
		_context = [[CCMetalContext alloc] init];
		
		//TODO Move into CCRenderDispatch to support threaded rendering with Metal?
		[CCMetalContext setCurrentContext:_context];
		
		_queuedFramesSemaphore = dispatch_semaphore_create(CC_METAL_MAX_QUEUED_FRAMES);
		
		CAMetalLayer *layer = self.metalLayer;
		layer.opaque = YES;
		layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
		layer.framebufferOnly = YES;
		
    layer.device = _context.device;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
		
		self.opaque = YES;
		self.backgroundColor = nil;
		self.contentScaleFactor = [UIScreen mainScreen].scale;
		
		self.multipleTouchEnabled = YES;
	}

	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
}

-(CAMetalLayer *)metalLayer
{
	return (CAMetalLayer *)self.layer;
}

- (void) layoutSubviews
{
	_layerSizeDidUpdate = YES;

	_surfaceSize = CC_SIZE_SCALE(self.bounds.size, self.contentScaleFactor);
	[[CCDirector sharedDirector] reshapeProjection:_surfaceSize];
}

-(void)beginFrame
{
	dispatch_semaphore_wait(_queuedFramesSemaphore, DISPATCH_TIME_FOREVER);
	
    @autoreleasepool {
        if(_layerSizeDidUpdate){
            self.metalLayer.drawableSize = _surfaceSize;
            _layerSizeDidUpdate = NO;
        }
        
        id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
        if (drawable == nil) {
            NSLog(@"Metal drawable pool exhausted. You may be rendering too much in a frame.");
        }
        
        _currentDrawable    = drawable;
        _destinationTexture = drawable.texture;
    }
}

- (void)presentFrame
{
    [_context.currentCommandBuffer presentDrawable:_currentDrawable];
    
	// Prevent the block from retaining self via the ivar.
	dispatch_semaphore_t sema = _queuedFramesSemaphore;
	[_context.currentCommandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer){
		dispatch_semaphore_signal(sema);
	}];
	
	[_context flushCommandBuffer];
	
	_currentDrawable = nil;
    _destinationTexture = nil;
}

-(void)addFrameCompletionHandler:(dispatch_block_t)handler
{
	[_context.currentCommandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {handler();}];
}

#pragma mark CCMetalView - Point conversion

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point
{
	CGRect bounds = [self bounds];

	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _surfaceSize.width, (point.y - bounds.origin.y) / bounds.size.height * _surfaceSize.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect
{
	CGRect bounds = [self bounds];

	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * _surfaceSize.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * _surfaceSize.height, rect.size.width / bounds.size.width * _surfaceSize.width, rect.size.height / bounds.size.height * _surfaceSize.height);
}

#pragma mark CCMetalView - Touch Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dispatch touch to responder manager
    [[CCDirector sharedDirector].responderManager touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dispatch touch to responder manager
    [[CCDirector sharedDirector].responderManager touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dispatch touch to responder manager
    [[CCDirector sharedDirector].responderManager touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dispatch touch to responder manager
    [[CCDirector sharedDirector].responderManager touchesCancelled:touches withEvent:event];
}
 
@end


#endif // __CC_PLATFORM_IOS
