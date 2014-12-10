#import "TestBase.h"
#import "CCRenderer_Private.h"
#import "CCNode_Private.h"
#import "chipmunk/chipmunk.h"
#import <objc/message.h>


@protocol CCProjectionDelegate
@property(nonatomic, readonly) GLKMatrix4 projection;
@end


@interface CCViewportNode : CCNode

// Node that controls the camera's transform (position/rotation/zoom)
@property(nonatomic, readonly) CCNode *camera;

// User assigninable node that holds the content that the viewport will show.
@property(nonatomic, strong) CCNode *contentNode;

// Create a viewport with the size of the screen and an empty contentNode;
-(instancetype)init;

// Create a viewport with the given size and content node.
// Uses a orthographic projection
-(instancetype)initWithSize:(CGSize)size contentNode:(CCNode *)contentNode;

// Convenience constructors to create screen sized viewports.
+(instancetype)centered:(CGSize)designSize;
+(instancetype)scaleToFill:(CGSize)designSize;
+(instancetype)scaleToFit:(CGSize)designSize;
+(instancetype)scaleToFitWidth:(CGSize)designSize;
+(instancetype)scaleToFitHeight:(CGSize)designSize;

// Power user functionality.

// Delegate that is responsible for calculating the projection each frame.
@property(nonatomic, strong) id<CCProjectionDelegate> projectionDelegate;

// Setting the projection explicitly is an error if the projectionDelegate is non-nil;
@property(nonatomic, assign) GLKMatrix4 projection;

@end


@interface CCAbstractProjection : NSObject @end
@implementation CCAbstractProjection {
    @protected
    __weak CCNode *_target;
}

-(instancetype)initWithTarget:(CCNode *)target
{
    if((self = [super init])){
        _target = target;
    }
    
    return self;
}

@end


@interface CCCentereredOrthoProjection : CCAbstractProjection<CCProjectionDelegate> @end
@implementation CCCentereredOrthoProjection

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    
    // TODO magic numbers
    return GLKMatrix4MakeOrtho(-w/2, w/2, -h/2, h/2, -1024, 1024);
}

@end


@interface CCParallaxProjection : CCAbstractProjection<CCProjectionDelegate> @end
@implementation CCParallaxProjection {
    SEL _cameraSelector;
}

-(instancetype)initWithTarget:(CCNode *)target cameraSelector:(SEL)cameraSelector
{
    if((self = [super initWithTarget:target])){
        _cameraSelector = cameraSelector;
    }
    
    return self;
}

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    
    typedef CCNode *(*Func)(id, SEL);
    CCNode *camera = ((Func)objc_msgSend)(_target, _cameraSelector);
    CGPoint p = camera.position;
    
    return GLKMatrix4Multiply(
        GLKMatrix4MakeOrtho(-w/2, w/2, -h/2, h/2, -1024, 1024),
        GLKMatrix4Make(
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            -p.x, -p.y, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
        )
    );
}

@end


@interface CCPerspectiveProjection : CCAbstractProjection<CCProjectionDelegate> @end
@implementation CCPerspectiveProjection

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    float w = size.width, h = size.height;
    
    // TODO magic numbers
    float eye = 1;
    float near = eye;
    float far = eye + 1;
    float s = 2.0*eye/near;
    
    return GLKMatrix4Multiply(
        GLKMatrix4MakeFrustum(-w/s, w/s, -h/s, h/s, near, far),
        GLKMatrix4MakeTranslation(0, 0, -eye)
    );
}

@end


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
    GLKMatrix4 viewportTransform = [super nodeToWorldMatrix];
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


@interface CCViewportNodeTest : TestBase @end
@implementation CCViewportNodeTest {
    CCTime _time;
    
    CCViewportNode *_viewport;
    id<CCProjectionDelegate> _orthoProjectionDelegate;
    id<CCProjectionDelegate> _parallaxProjectionDelegate;
    id<CCProjectionDelegate> _perspectiveProjectionDelegate;
}

- (void)setupViewPortTest
{
    _viewport = [[CCViewportNode alloc] init];
    _viewport.anchorPoint = ccp(0.5, 0.5);
    _viewport.positionType = CCPositionTypeNormalized;
    _viewport.position = ccp(0.5, 0.5);
    _viewport.contentSize = [CCDirector sharedDirector].viewSize;
    [self.contentNode addChild:_viewport];
    
    _orthoProjectionDelegate = [[CCCentereredOrthoProjection alloc] initWithTarget:_viewport];
    _parallaxProjectionDelegate = [[CCParallaxProjection alloc] initWithTarget:_viewport cameraSelector:@selector(camera)];
    _perspectiveProjectionDelegate = [[CCPerspectiveProjection alloc] initWithTarget:_viewport];
    _viewport.projectionDelegate = _orthoProjectionDelegate;
        
    CCNodeColor *grey = [CCNodeColor nodeWithColor:[CCColor grayColor]];
    grey.contentSize = CGSizeMake(10000, 10000);
    grey.position = ccp(-5000, -5000);
    grey.vertexZ = -1.0;
    [_viewport.contentNode addChild:grey z:-1000];
    
    for(int y=0; y<30; y++){
        for(int x=0; x<30; x++){
            CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
            sprite.vertexZ = -CCRANDOM_0_1();
            sprite.zOrder = sprite.vertexZ*100.0;
            
            CGSize size = sprite.contentSize;
            sprite.position = ccp((x - 15.0)*size.width, (y - 15.0)*size.height);
            
            [_viewport.contentNode addChild:sprite];
        }
    }
    
    [self animateContentSize];
}

typedef void (^AnimationBlock)(CCTime t);

-(void)animationDuration:(CCTime)duration block:(AnimationBlock)block
{
    CCTime step = 1.0/60.0;
    NSUInteger repeats = duration/step;
    
    CCTimer *timer = [_viewport scheduleBlock:^(CCTimer *timer) {
        CCTime t = (CCTime)(repeats - timer.repeatCount)/(CCTime)repeats;
        
        block(t);
    } delay:0.0];
    
    timer.repeatInterval = step;
    timer.repeatCount = repeats;
}

-(void)animateContentSize
{
    self.subTitle = @"Viewport rect controlled by contentSize.";
    
    CGSize a = [CCDirector sharedDirector].viewSize;
    CGSize b = CGSizeMake(0.75*a.width, 0.75*a.height);
    
    [self animationDuration:0.5 block:^(CCTime t) {
        _viewport.contentSize = CGSizeMake(cpflerp(a.width, b.width, t), cpflerp(a.height, b.height, t));
        
        if(t == 1.0) [self animatePositionScale];
    }];
}

-(void)animatePositionScale
{
    self.subTitle = @"Position/rotation/scale works like a regular node.";
    
    [self animationDuration:2.0 block:^(CCTime t) {
        float phase = 2*M_PI*(t + 0.25);
        _viewport.position = ccp(0.5 + 0.2*cos(phase), 0.5 + 0.2*sin(2*phase));
        _viewport.scale = pow(1.2, sin(4*M_PI*t));
        
        if(t == 1.0) [self animateCamera];
    }];
}

-(void)animateCamera
{
    self.subTitle = @"The viewport camera has a separate position/rotation/zoom.";
    
    _viewport.projectionDelegate = _orthoProjectionDelegate;
    
    [self animationDuration:2.0 block:^(CCTime t) {
        float phase = 2*M_PI*(t + 0.25);
        _viewport.camera.position = ccp(30*cos(phase), 30*sin(2*phase));
        _viewport.camera.rotation = 10*sin(2*M_PI*t);
        _viewport.camera.scale = pow(1.2, sin(4*M_PI*t));
        
        if(t == 1.0) [self animateAxonometric];
    }];
}

-(void)animateAxonometric
{
    self.subTitle = @"The viewport projection can be controlled for parallax effects.";
    
    _viewport.projectionDelegate = _parallaxProjectionDelegate;
    
    [self animationDuration:2.0 block:^(CCTime t) {
        float phase = 2*M_PI*(t + 0.25);
        _viewport.camera.position = ccp(30*cos(phase), 30*sin(2*phase));
        
        if(t == 1.0) [self animatePerspective];
    }];
}

-(void)animateProjectionTo:(id<CCProjectionDelegate>)delegate after:(dispatch_block_t)after
{
    GLKMatrix4 begin = _viewport.projection;
    GLKMatrix4 end = delegate.projection;
    
    _viewport.projectionDelegate = nil;
    _viewport.projection = begin;
    
    [self animationDuration:0.25 block:^(CCTime t) {
        GLKMatrix4 m = {};
        
        for(int i=0; i<16; i++){
            m.m[i] = (1.0f - t)*begin.m[i] + t*end.m[i];
        }
        
        _viewport.projection = m;
        
        if(t == 1.0){
            _viewport.projectionDelegate = delegate;
            after();
        }
    }];
}

-(void)animatePerspective
{
    self.subTitle = @"... or 3D perspective effects.";
    
    [self animateProjectionTo:_perspectiveProjectionDelegate after:^{
        [self animationDuration:2.0 block:^(CCTime t) {
            float phase = 2*M_PI*(t + 0.25);
            _viewport.camera.position = ccp(30*cos(phase), 30*sin(2*phase));
            
            if(t == 1.0) [self animateReset];
        }];
    }];
}

-(void)animateReset
{
    self.subTitle = @"Viewport rect controlled by contentSize.";
    
    CGSize a = _viewport.contentSize;
    CGSize b = [CCDirector sharedDirector].viewSize;
    
    [self animateProjectionTo:_orthoProjectionDelegate after:^{
        _viewport.projectionDelegate = _orthoProjectionDelegate;
        
        [self animationDuration:0.5 block:^(CCTime t) {
            _viewport.contentSize = CGSizeMake(cpflerp(a.width, b.width, t), cpflerp(a.height, b.height, t));
            
            if(t == 1.0) [self animateContentSize];
        }];
    }];
}

CGSize DesignSize = {300, 300};

-(void)setupCenteredTest
{
    self.subTitle = @"Centered";
    
    CCViewportNode *viewport = [CCViewportNode centered:DesignSize];
    [self.contentNode addChild:viewport];
    
    CCDrawNode *draw = [CCDrawNode node];
    [draw drawDot:ccp(DesignSize.width/2.0, DesignSize.height/2.0) radius:DesignSize.width/2.0 color:[CCColor redColor]];
    [viewport.contentNode addChild:draw];
}

-(void)setupScaleToFillTest
{
    self.subTitle = @"Scale to fill";
    
    CCViewportNode *viewport = [CCViewportNode scaleToFill:DesignSize];
    [self.contentNode addChild:viewport];
    
    CCDrawNode *draw = [CCDrawNode node];
    [draw drawDot:ccp(DesignSize.width/2.0, DesignSize.height/2.0) radius:DesignSize.width/2.0 color:[CCColor redColor]];
    [viewport.contentNode addChild:draw];
}

-(void)setupScaleToFitTest
{
    self.subTitle = @"Scale to fit";
    
    CCViewportNode *viewport = [CCViewportNode scaleToFit:DesignSize];
    [self.contentNode addChild:viewport];
    
    CCDrawNode *draw = [CCDrawNode node];
    [draw drawDot:ccp(DesignSize.width/2.0, DesignSize.height/2.0) radius:DesignSize.width/2.0 color:[CCColor redColor]];
    [viewport.contentNode addChild:draw];
}

-(void)setupScaleToFitWidthTest
{
    self.subTitle = @"Scale to fit width";
    
    CCViewportNode *viewport = [CCViewportNode scaleToFitWidth:DesignSize];
    [self.contentNode addChild:viewport];
    
    CCDrawNode *draw = [CCDrawNode node];
    [draw drawDot:ccp(DesignSize.width/2.0, DesignSize.height/2.0) radius:DesignSize.width/2.0 color:[CCColor redColor]];
    [viewport.contentNode addChild:draw];
}

-(void)setupScaleToFitHeightTest
{
    self.subTitle = @"Scale to fit height";
    
    CCViewportNode *viewport = [CCViewportNode scaleToFitHeight:DesignSize];
    [self.contentNode addChild:viewport];
    
    CCDrawNode *draw = [CCDrawNode node];
    [draw drawDot:ccp(DesignSize.width/2.0, DesignSize.height/2.0) radius:DesignSize.width/2.0 color:[CCColor redColor]];
    [viewport.contentNode addChild:draw];
}

@end
