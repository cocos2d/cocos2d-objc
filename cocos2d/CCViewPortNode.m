//
//  CCViewPortNode.m
//  cocos2d-ios
//
//  Created by Andy Korth on 12/10/14.

#import "CCViewPortNode.h"
#import "CCNode_Private.h"
#import "CCDirector.h"
#import "ccUtils.h"

@implementation CCViewportNode {
    GLKMatrix4 _projection;
}

-(instancetype)init
{
    return [self initWithSize:[CCDirector sharedDirector].viewSize contentNode:[CCNode node]];
}

-(instancetype)initWithSize:(CGSize)size contentNode:(CCNode *)contentNode;
{
    if((self = [super init])){
        self.contentSize = size;
        
        _camera = [CCNode node];
        [self addChild:_camera];
        
        _contentNode = contentNode;
        [_camera addChild:_contentNode];
        
        _projection = GLKMatrix4MakeOrtho(0, size.width, 0, size.height, -1024, 1024);
    }
    
    return self;
}

+(instancetype)centered:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    viewport.projection = GLKMatrix4MakeOrtho(-size.width/2.0, size.width/2.0, -size.height/2.0, size.height/2.0, -1024, 1024);
    
    return viewport;
}

+(instancetype)scaleToFill:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = MIN(designSize.width/size.width, designSize.height/size.height)/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, -1024, 1024);
    
    return viewport;
}

+(instancetype)scaleToFit:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = MAX(designSize.width/size.width, designSize.height/size.height)/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, -1024, 1024);
    
    return viewport;
}

+(instancetype)scaleToFitWidth:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = designSize.width/size.width/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, -1024, 1024);
    
    return viewport;
}

+(instancetype)scaleToFitHeight:(CGSize)designSize;
{
    CCViewportNode *viewport = [[self alloc] init];
    viewport.camera.position = ccp(designSize.width/2.0, designSize.height/2.0);
    
    CGSize size = viewport.contentSize;
    float scale = designSize.height/size.height/2.0;
    viewport.projection = GLKMatrix4MakeOrtho(-scale*size.width, scale*size.width, -scale*size.height, scale*size.height, -1024, 1024);
    
    return viewport;
}

-(GLKMatrix4)projection
{
    return (_projectionDelegate ? _projectionDelegate.projection : _projection);
}

-(void)setProjection:(GLKMatrix4)projection
{
    NSAssert(_projectionDelegate == nil, @"Cannot set the projection explicitly when a projection delegate is set.");
    _projection = projection;
}

-(GLKMatrix4)cameraTransform
{
    CGPoint p = _camera.position;
    
    float radians = -CC_DEGREES_TO_RADIANS(_camera.rotation);
    float c = _camera.scaleX*cosf(radians);
    float s = _camera.scaleY*sinf(radians);
    
    return GLKMatrix4Make(
                          c,   -s, 0.0f, 0.0f,
                          s,    c, 0.0f, 0.0f,
                          0.0f, 0.0f, 1.0f, 0.0f,
                          -p.x, -p.y, 0.0f, 1.0f
                          );
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    
    if (!self.visible) return;
    
    // Find the corners of the
    CGSize size = self.contentSizeInPoints;
    GLKMatrix4 viewportTransform = GLKMatrix4Multiply(*parentTransform, [super nodeToParentMatrix]);
    GLKVector3 v0 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(      0.0f,        0.0f, 0.0f));
    GLKVector3 v1 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(size.width,        0.0f, 0.0f));
    GLKVector3 v2 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(size.width, size.height, 0.0f));
    GLKVector3 v3 = GLKMatrix4MultiplyAndProjectVector3(viewportTransform, GLKVector3Make(      0.0f, size.height, 0.0f));
    
    // Find the viewport rectangle in framebuffer pixels.
    CGSize framebufferSize = [CCDirector sharedDirector].viewSizeInPixels;
    float hw = framebufferSize.width/2.0;
    float hh = framebufferSize.height/2.0;
    
    int minx = floorf(hw + hw*MIN(MIN(v0.x, v1.x), MIN(v2.x, v3.x)));
    int maxx = floorf(hw + hw*MAX(MAX(v0.x, v1.x), MAX(v2.x, v3.x)));
    int miny = floorf(hh + hh*MIN(MIN(v0.y, v1.y), MIN(v2.y, v3.y)));
    int maxy = floorf(hh + hh*MAX(MAX(v0.y, v1.y), MAX(v2.y, v3.y)));
    
    // Set the viewport.
    [renderer pushGroup];
    [renderer enqueueBlock:^{glViewport(minx, miny, maxx - minx, maxy - miny);} globalSortOrder:NSIntegerMin debugLabel:@"CCViewportNode: Set viewport" threadSafe:YES];
    
    // TODO Need to do something to fix rotations when using clipping mode.
    GLKMatrix4 transform = GLKMatrix4Multiply(self.projection, self.cameraTransform);
    
    // Render children.
    [self sortAllChildren];
    for(CCNode *child in _camera.children){
        [child visit:renderer parentTransform:&transform];
    }
    
    // Reset the viewport.
    [renderer enqueueBlock:^{glViewport(0, 0, framebufferSize.width, framebufferSize.height);} globalSortOrder:NSIntegerMax debugLabel:@"CCViewportNode: Reset viewport" threadSafe:YES];
    [renderer popGroupWithDebugLabel:@"CCViewportNode" globalSortOrder:0];
}

@end
