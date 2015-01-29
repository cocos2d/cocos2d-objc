//
//  CCViewportNode.m
//  cocos2d-ios
//
//  Created by Andy Korth on 12/10/14.

#import "CCViewportNode.h"
#import "CCNode_Private.h"
#import "CCMetalSupport_Private.h"

#import "CCDirector.h"
#import "ccUtils.h"
#import "CCDeviceInfo.h"

#define NEAR_Z -1024
#define FAR_Z 1024

@interface CCCamera : CCNode

@property(nonatomic, weak) CCViewportNode *viewport;

- (id) initWithViewport:(CCViewportNode*)viewportNode;
- (GLKMatrix4)cameraMatrix;

@end

@implementation CCCamera {

}

- (CGSize)contentSize {
    return self.parent.contentSize;
}

- (CCSizeType)contentSizeType {
    return self.parent.contentSizeType;
}

- (CGSize)contentSizeInPoints {
    return self.parent.contentSizeInPoints;
}

// Designated initializer
- (instancetype) initWithViewport:(CCViewportNode*)viewportNode
{
    if( (self=[super init]) ) {
        self.viewport = viewportNode;
        self.userInteractionEnabled = true;
    }
    return self;
}

// Override nodeToParentMatrix so input (like touches) in the viewport can be transformed into the node space of the content of the viewport.
- (GLKMatrix4)nodeToParentMatrix
{
    CGSize cs = _viewport.contentSizeInPoints;
    float hw = cs.width / 2.0f;
    float hh = cs.height / 2.0f;
    
    // Scale and translate matrix to convert from clip coordiates to viewport internal coordinates
    GLKMatrix4 toProj = GLKMatrix4Make(
            hw,   0.0f, 0.0f, 0.0f,
            0.0f, hh,   0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            hw,   hh,   0.0f, 1.0f);

    return GLKMatrix4Multiply(toProj, self.cameraMatrix);
}

// Camera matrix is used for drawing the contents of the viewport, relative to the camera.
- (GLKMatrix4)cameraMatrix
{
    bool isInvertable;
    
    GLKMatrix4 cameraTransform = GLKMatrix4Invert([super nodeToParentMatrix], &isInvertable);
    NSAssert(isInvertable, @"Couldn't invert camera matrix.");
    
    return GLKMatrix4Multiply(_viewport.projection, cameraTransform);
}

@end


@implementation CCViewportNode {
    GLKMatrix4 _projection;
}

-(instancetype)init
{
    return [self initWithContentNode:[CCNode node]];
}

-(instancetype)initWithContentNode:(CCNode *)contentNode;
{
    if((self = [super init])){
        self.contentSize = [CCDirector currentDirector].viewSize;
        self.clipsInput = true;
        
        _camera = [[CCCamera alloc]initWithViewport:self];
        [self addChild:_camera];
        [_camera addChild:contentNode];
        
        // Reasonable default:
        CGSize sizeInPoints = self.contentSizeInPoints;
        _projection = GLKMatrix4MakeOrtho(0, sizeInPoints.width, 0, sizeInPoints.height, NEAR_Z, FAR_Z);
    }
    
    return self;
}

// TODO: subscribe to transform changes and update projection when that happens.

+(instancetype)centered:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    viewport.projection = GLKMatrix4MakeOrtho(-size.width/2.0, size.width/2.0, -size.height/2.0, size.height/2.0, NEAR_Z, FAR_Z);
    
    return viewport;
}

+(instancetype)scaleToFill:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = MIN(designSize.width/size.width, designSize.height/size.height)/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, NEAR_Z, FAR_Z);
    
    return viewport;
}

+(instancetype)scaleToFit:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = MAX(designSize.width/size.width, designSize.height/size.height)/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, NEAR_Z, FAR_Z);
    
    return viewport;
}

+(instancetype)scaleToFitWidth:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = designSize.width/size.width/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, NEAR_Z, FAR_Z);
    
    return viewport;
}

+(instancetype)scaleToFitHeight:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = designSize.height/size.height/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, NEAR_Z, FAR_Z);
    
    return viewport;
}

-(GLKMatrix4)projection
{
    return (_projectionDelegate ? _projectionDelegate.projection : _projection);
}

-(void)setProjection:(GLKMatrix4)projection
{
    NSLog(@"Set projection");
    NSAssert(_projectionDelegate == nil, @"Cannot set the projection explicitly when a projection delegate is set.");
    _projection = projection;
}

- (void) setContentNode:(CCNode *)contentNode
{
    [_camera removeChild:self.contentNode];
    [_camera addChild: contentNode];
}

- (CCNode *) contentNode{
    return _camera.children[0];
}

static void
SetViewport(int minx, int miny, int maxx, int maxy)
{
    switch([CCDeviceInfo graphicsAPI]){
        case CCGraphicsAPIGL: {
            glViewport((GLint)minx, (GLint)miny, (GLint)(maxx - minx), (GLint)(maxy - miny));
            break;
        } case CCGraphicsAPIMetal: {
#if __CC_METAL_SUPPORTED_AND_ENABLED
            // Grab the context and framebuffer info.
            CCMetalContext *context = [CCMetalContext currentContext];
            id<MTLTexture> dst = context.destinationTexture;
            int dstw = (int)dst.width;
            int dsth = (int)dst.height;
            
            // Clamp the viewport.
            minx = MAX(0, minx); maxx = MIN(maxx, dstw);
            miny = MAX(0, miny); maxy = MIN(maxy, dsth);
            
            // This is so much easier in GL...
            MTLViewport viewport = {minx, dsth - maxy, maxx - minx, maxy - miny, 0.0, 1.0};
            [context.currentRenderCommandEncoder setViewport:viewport];
            break;
#endif
        } case CCGraphicsAPIInvalid: {
            break;
        }
    }
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    
    if (!self.visible) return;
    
    // Find the corners of the content rect, in viewport coordinates.
    CGSize size = self.contentSizeInPoints;
    GLKMatrix4 viewportTransform = GLKMatrix4Multiply(*parentTransform, [super nodeToParentMatrix]);
    GLKVector3 v0 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(      0.0f,        0.0f, 0.0f));
    GLKVector3 v1 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(size.width,        0.0f, 0.0f));
    GLKVector3 v2 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(size.width, size.height, 0.0f));
    GLKVector3 v3 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(      0.0f, size.height, 0.0f));
    
    // Find the viewport rectangle in framebuffer pixels.
    CGSize framebufferSize = [CCDirector currentDirector].viewSizeInPixels;
    float hw = framebufferSize.width/2.0;
    float hh = framebufferSize.height/2.0;
    
    int minx = floorf(hw + hw*MIN(MIN(v0.x, v1.x), MIN(v2.x, v3.x)));
    int maxx = floorf(hw + hw*MAX(MAX(v0.x, v1.x), MAX(v2.x, v3.x)));
    int miny = floorf(hh + hh*MIN(MIN(v0.y, v1.y), MIN(v2.y, v3.y)));
    int maxy = floorf(hh + hh*MAX(MAX(v0.y, v1.y), MAX(v2.y, v3.y)));
    
    // Set the viewport to ensure we're drawing to the correct area.
    [renderer pushGroup];
    [renderer enqueueBlock:^{SetViewport(minx, miny, maxx, maxy);} globalSortOrder:NSIntegerMin debugLabel:@"CCViewportNode: Set viewport" threadSafe:YES];
    
    // TODO Need to do something to fix rotations when using clipping mode.
    GLKMatrix4 transform = [(CCCamera*)_camera cameraMatrix];
    
    // Render children.
    [self sortAllChildren];
    for(CCNode *child in _camera.children){
        [child visit:renderer parentTransform:&transform];
    }
    
    // Reset the viewport.
    [renderer enqueueBlock:^{SetViewport(0, 0, framebufferSize.width, framebufferSize.height);} globalSortOrder:NSIntegerMax debugLabel:@"CCViewportNode: Reset viewport" threadSafe:YES];
    [renderer popGroupWithDebugLabel:@"CCViewportNode" globalSortOrder:0];
}

@end
