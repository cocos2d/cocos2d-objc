#import "CCMetalView.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

#import "CCMetalView.h"
#import "../../CCDirector.h"
#import "../../ccMacros.h"
#import "../../CCConfiguration.h"
#import "CCScene.h"

#import "CCDirector_Private.h"
#import "CCMetalSupport_Private.h"


#define CC_METAL_MAX_QUEUED_FRAMES 3


@implementation CCMetalView {
	CCMetalContext *_context;
//	id<MTLCommandQueue> _queue;
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

//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//	if( (self = [super initWithCoder:aDecoder]) ) {
//		CAMetalLayer *layer = (CAMetalLayer *)self.layer;
//		
//		_pixelformat = kEAGLColorFormatRGB565;
//		_depthFormat = 0;
//		_multiSampling= NO;
//		_requestedSamples = 0;
//		_surfaceSize = [layer bounds].size;
//		
//		if(![self setupSurfaceWithSharegroup:nil]){
//			return nil;
//		}
//	}
//	
//	return self;
//}

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

//- (MTLRenderPassDescriptor *)renderPassDescriptorForTexture:(id <MTLTexture>)texture
//{
//	MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
//	
//	MTLRenderPassColorAttachmentDescriptor *colorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
//	colorAttachment.texture = texture;
//	colorAttachment.loadAction = MTLLoadActionClear;
//	colorAttachment.clearColor = MTLClearColorMake(0, 0, 0, 0);
//	colorAttachment.storeAction = MTLStoreActionStore;
//	
//	descriptor.colorAttachments[0] = colorAttachment;
//	
//	return descriptor;
//    
////    if (!_depthTex || (_depthTex && (_depthTex.width != texture.width || _depthTex.height != texture.height)))
////    {
////        //  If we need a depth texture and don't have one, or if the depth texture we have is the wrong size
////        //  Then allocate one of the proper size
////        
////        MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: MTLPixelFormatDepth32Float width: texture.width height: texture.height mipmapped: NO];
////        _depthTex = [_device newTextureWithDescriptor: desc];
////        _depthTex.label = @"Depth";
////        
////        MTLRenderPassAttachmentDescriptor *depthAttachment = [MTLRenderPassAttachmentDescriptor new];
////        depthAttachment.texture = _depthTex;
////        [depthAttachment setLoadAction:MTLLoadActionClear];
////        [depthAttachment setClearValue:MTLClearValueMakeDepth(1.0)];
////        [depthAttachment setStoreAction: MTLStoreActionDontCare];
////        
////        _renderPassDescriptor.depthAttachment = depthAttachment;
////    }
//}

-(void)beginFrame
{
	if(_layerSizeDidUpdate){
		self.metalLayer.drawableSize = _surfaceSize;
		_layerSizeDidUpdate = NO;
	}
	
//	id<CAMetalDrawable> drawable = nil;
//	while(drawable == nil){
//		drawable = [self.metalLayer nextDrawable];
//		
//		if(drawable == nil) NSLog(@"nil drawable? (Why does this happen?)");
//	}
	
	id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
	[_context.currentCommandBuffer presentDrawable:drawable];
	
	_currentDrawable = drawable;
	_destinationTexture = drawable.texture;
}

- (void)presentFrame
{
	// Prevent the block from retaining self via the ivar.
	dispatch_semaphore_t sema = _queuedFramesSemaphore;
	[_context.currentCommandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer){
		dispatch_semaphore_signal(sema);
	}];
	
	[_context flushCommandBuffer];
	
	[_currentDrawable present];
	_currentDrawable = nil;
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
