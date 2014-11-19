#import "TestBase.h"
#import "CCRenderer_Private.h"
#import "CCNode_Private.h"
#import "chipmunk/chipmunk.h"


@interface CCViewportNode : CCNode

@property(nonatomic, assign) CGPoint cameraPosition;
@property(nonatomic, assign) float cameraRotation;
@property(nonatomic, assign) float cameraZoom;

@property(nonatomic, assign) GLKMatrix4 projection;

// TODO
//@property(nonatomic, assign) CCRenderTexture *renderTarget;

@end


@implementation CCViewportNode {
}

-(instancetype)init
{
    if((self = [super init])){
        _cameraPosition = CGPointZero;
        _cameraRotation = 0.0f;
        _cameraZoom = 1.0f;
    }
    
    return self;
}

-(GLKMatrix4)projectionForSize:(CGSize)size
{
    float w = size.width;
    float h = size.height;
    
    // Lower left origin:
//    return GLKMatrix4MakeOrtho(0, w, 0, h, -1024, 1024);
    
    // Centered:
    return GLKMatrix4MakeOrtho(-w/2, w/2, -h/2, h/2, -1024, 1024);
}

-(void)setContentSize:(CGSize)size
{
    _projection = [self projectionForSize:size];
    
    [super setContentSize:size];
}

-(GLKMatrix4)cameraTransform
{
    float x = -_cameraPosition.x;
    float y = -_cameraPosition.y;
    
    float c = _cameraZoom*cosf(-CC_DEGREES_TO_RADIANS(_cameraRotation));
    float s = _cameraZoom*sinf(-CC_DEGREES_TO_RADIANS(_cameraRotation));
    
    return GLKMatrix4Make(
           c,   -s, 0.0f, 0.0f,
           s,    c, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
           x,    y, 0.0f, 1.0f
    );
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	if (!_visible) return;
    
    // Find the corners of the
    CGSize size = self.contentSizeInPoints;
    GLKMatrix4 viewportTransform = [super transform:parentTransform];
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
    GLKMatrix4 transform = GLKMatrix4Multiply(_projection, self.cameraTransform);
    
    // Render children.
	[self sortAllChildren];
	for(CCNode *child in _children){
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
}

- (void) setupViewPortTest
{
    _viewport = [[CCViewportNode alloc] init];
    _viewport.anchorPoint = ccp(0.5, 0.5);
    _viewport.positionType = CCPositionTypeNormalized;
    _viewport.position = ccp(0.5, 0.5);
    _viewport.contentSize = [CCDirector sharedDirector].viewSize;
    [self.contentNode addChild:_viewport];
    
    CCNodeColor *grey = [CCNodeColor nodeWithColor:[CCColor grayColor]];
    grey.contentSize = CGSizeMake(10000, 10000);
    grey.position = ccp(-5000, -5000);
    [_viewport addChild:grey z:-1000];
    
    for(int y=0; y<30; y++){
        for(int x=0; x<30; x++){
            CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
            sprite.vertexZ = -CCRANDOM_0_1();
            sprite.zOrder = sprite.vertexZ*100.0;
            
            CGSize size = sprite.contentSize;
            sprite.position = ccp((x - 15.0)*size.width, (y - 15.0)*size.height);
            
            [_viewport addChild:sprite];
        }
    }
    
    [self animateContentSize];
}

typedef void (^AnimationBlock)(CCTime t);

-(void)animationDuration:(CCTime)duration block:(AnimationBlock)block
{
    CCTime step = 1.0/60.0;
    NSUInteger repeats = duration/step;
    
    CCTimer *timer = [self scheduleBlock:^(CCTimer *timer) {
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
    
    CGSize size = _viewport.contentSize;
    float w = size.width, h = size.height;
    _viewport.projection = GLKMatrix4MakeOrtho(-w/2, w/2, -h/2, h/2, -1024, 1024);
    
    [self animationDuration:2.0 block:^(CCTime t) {
        float phase = 2*M_PI*(t + 0.25);
        _viewport.cameraPosition = ccp(30*cos(phase), 30*sin(2*phase));
        _viewport.cameraRotation = 10*sin(2*M_PI*t);
        _viewport.cameraZoom = pow(1.2, sin(4*M_PI*t));
        
        if(t == 1.0) [self animateAxonometric];
    }];
}

static GLKMatrix4
GLKMatrix4MakeAxonometric(CGSize size, CGPoint p)
{
    float w = size.width, h = size.height;
    
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

-(void)animateAxonometric
{
    self.subTitle = @"The viewport projection can be controlled for parallax effects.";
    
    CGSize size = _viewport.contentSize;
    
    [self animationDuration:2.0 block:^(CCTime t) {
        float phase = 2*M_PI*(t + 0.25);
        _viewport.cameraPosition = ccp(30*cos(phase), 30*sin(2*phase));
        _viewport.projection = GLKMatrix4MakeAxonometric(size, _viewport.cameraPosition);
        
        if(t == 1.0) [self animatePerspective];
    }];
}

-(void)animateProjectionTo:(GLKMatrix4)end after:(dispatch_block_t)after
{
    GLKMatrix4 begin = _viewport.projection;
    
    [self animationDuration:0.25 block:^(CCTime t) {
        GLKMatrix4 m = {};
        
        for(int i=0; i<16; i++){
            m.m[i] = (1.0f - t)*begin.m[i] + t*end.m[i];
        }
        
        _viewport.projection = m;
        
        if(t == 1.0) after();
    }];
}

-(void)animatePerspective
{
    self.subTitle = @"... or 3D perspective effects.";
    
    CGSize size = _viewport.contentSize;
    float w = size.width, h = size.height;
    
    float eye = 1;
    float near = eye;
    float far = eye + 1;
    float s = 2.0*eye/near;
    
    GLKMatrix4 projection = GLKMatrix4Multiply(
        GLKMatrix4MakeFrustum(-w/s, w/s, -h/s, h/s, near, far),
        GLKMatrix4MakeTranslation(0, 0, -eye)
    );
    
    [self animateProjectionTo:projection after:^{
        [self animationDuration:2.0 block:^(CCTime t) {
            float phase = 2*M_PI*(t + 0.25);
            _viewport.cameraPosition = ccp(30*cos(phase), 30*sin(2*phase));
            
            if(t == 1.0) [self animateReset];
        }];
    }];
}

-(void)animateReset
{
    self.subTitle = @"Viewport rect controlled by contentSize.";
    
    CGSize a = _viewport.contentSize;
    CGSize b = [CCDirector sharedDirector].viewSize;
    GLKMatrix4 projection = [_viewport projectionForSize:a];
    
    [self animateProjectionTo:projection after:^{
        [self animationDuration:0.5 block:^(CCTime t) {
            _viewport.contentSize = CGSizeMake(cpflerp(a.width, b.width, t), cpflerp(a.height, b.height, t));
            
            if(t == 1.0) [self animateContentSize];
        }];
    }];
}

@end
