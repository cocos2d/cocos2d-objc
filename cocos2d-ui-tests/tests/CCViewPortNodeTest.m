#import "TestBase.h"
#import "CCRenderer_Private.h"
#import "CCNode_Private.h"
#import "chipmunk/chipmunk.h"
#import <objc/message.h>
#import "CCViewPortNode.h"

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
