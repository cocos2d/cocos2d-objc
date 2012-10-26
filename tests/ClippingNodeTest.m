//
// Clipping Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
// by Pierre-David Bélanger
//

#import "cocos2d.h"

#import "ClippingNodeTest.h"

#if COCOS2D_DEBUG > 1
#import "CCGL.h"
#import "CCDrawingPrimitives.h"
#endif

enum {
	kTagTitleLabel = 1,
	kTagSubtitleLabel = 2,
	kTagStencilNode = 100,
	kTagClipperNode = 101,
	kTagContentNode = 102,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
    @"ScrollViewDemo",
    @"HoleDemo",
	@"ShapeTest",
	@"ShapeInvertedTest",
	@"SpriteTest",
    @"SpriteNoAlphaTest",
	@"SpriteInvertedTest",
    @"NestedTest",
#if COCOS2D_DEBUG > 1
	@"RawStencilBufferTest",
    @"RawStencilBufferTest2",
    @"RawStencilBufferTest3",
    @"RawStencilBufferTest4",
    @"RawStencilBufferTest5",
#endif
};

#pragma mark Callbacks

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	sceneIdx++;
	sceneIdx = sceneIdx % (sizeof(transitions) / sizeof(transitions[0]));
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	if (sceneIdx < 0)
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) - 1;
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark Demo examples start here

@implementation BaseClippingNodeTest

- (id)init
{
	if (self = [super init]) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background z:-1];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:1 tag:kTagTitleLabel];
		[label setPosition: ccp(s.width / 2, s.height - 50)];
		
		NSString *subtitleText = [self subtitle];
		if (subtitleText) {
			CCLabelTTF *subtitle = [CCLabelTTF labelWithString:subtitleText fontName:@"Thonburi" fontSize:16];
			[self addChild:subtitle z:1 tag:kTagSubtitleLabel];
			[subtitle setPosition:ccp(s.width / 2, s.height - 80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png"
                                                               target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png"
                                                               target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png"
                                                               target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(s.width / 2 - item2.contentSize.width * 2, item2.contentSize.height / 2);
		item2.position = ccp(s.width / 2, item2.contentSize.height / 2);
		item3.position = ccp(s.width / 2 + item2.contentSize.width * 2, item2.contentSize.height / 2);
		[self addChild: menu z:1];
        
        [self setup];
        
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(NSString*) title
{
	return @"Clipping Demo";
}

-(NSString*) subtitle
{
	return @"";
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[restartAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[nextAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild:[backAction() node]];
	[[CCDirector sharedDirector] replaceScene:s];
}

- (void)setup
{
}

@end

#pragma mark - BasicTest

@implementation BasicTest

-(NSString*) title
{
	return @"Basic Test";
}

-(NSString*) subtitle
{
	return @"";
}

- (void)setup
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CCNode *stencil = [self stencil];
    stencil.tag = kTagStencilNode;
    stencil.position = ccp(50, 50);
    
    CCClippingNode *clipper = [self clipper];
    clipper.tag = kTagClipperNode;
    clipper.anchorPoint = ccp(0.5, 0.5);
    clipper.position = ccp(s.width / 2 - 50, s.height / 2 - 50);
    clipper.stencil = stencil;
    [self addChild:clipper];
    
    CCNode *content = [self content];
    content.position = ccp(50, 50);
    [clipper addChild:content];
}

- (CCAction *)actionRotate
{
    return [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:90]];
}

- (CCAction *)actionScale
{
    CCScaleBy *scale = [CCScaleBy actionWithDuration:1.33 scale:1.5];
    return [CCRepeatForever actionWithAction:[CCSequence actions:scale, [scale reverse], nil]];
}

- (CCDrawNode *)shape
{
    CCDrawNode *shape = [CCDrawNode node];
    static CGPoint triangle[] = {{-100, -100}, {100, -100}, {0, 100}};
    static ccColor4F green = {0, 1, 0, 1};
    [shape drawPolyWithVerts:triangle count:3 fillColor:green borderWidth:0 borderColor:green];
    return shape;
}

- (CCSprite *)grossini
{
    CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
    grossini.scale = 1.5;
    return grossini;
}

- (CCNode *)stencil
{
    return nil;
}

- (CCClippingNode *)clipper
{
    return [CCClippingNode clippingNode];
}

- (CCNode *)content
{
    return nil;
}

@end

#pragma mark - ShapeTest

@implementation ShapeTest

-(NSString*) title
{
	return @"Shape Basic Test";
}

-(NSString*) subtitle
{
	return @"A DrawNode as stencil and Sprite as content";
}

- (CCNode *)stencil
{
    CCNode *node = [self shape];
    [node runAction:[self actionRotate]];
    return node;
}

- (CCNode *)content
{
    CCNode *node = [self grossini];
    [node runAction:[self actionScale]];
    return node;
}

@end

#pragma mark - ShapeInvertedTest

@implementation ShapeInvertedTest

-(NSString*) title
{
	return @"Shape Inverted Basic Test";
}

-(NSString*) subtitle
{
	return @"A DrawNode as stencil and Sprite as content, inverted";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.inverted = YES;
    return clipper;
}

@end

#pragma mark - SpriteTest

@implementation SpriteTest

-(NSString*) title
{
	return @"Sprite Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content";
}

- (CCNode *)stencil
{
    CCNode *node = [self grossini];
    [node runAction:[self actionRotate]];
    return node;
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.alphaThreshold = 0.05;
    return clipper;
}

- (CCNode *)content
{
    CCNode *node = [self shape];
    [node runAction:[self actionScale]];
    return node;
}

@end

#pragma mark - SpriteNoAlphaTest

@implementation SpriteNoAlphaTest

-(NSString*) title
{
	return @"Sprite No Alpha Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content, no alpha";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.alphaThreshold = 1;
    return clipper;
}

@end

#pragma mark - SpriteInvertedTest

@implementation SpriteInvertedTest

-(NSString*) title
{
	return @"Sprite Inverted Basic Test";
}

-(NSString*) subtitle
{
	return @"A Sprite as stencil and DrawNode as content, inverted";
}

- (CCClippingNode *)clipper
{
    CCClippingNode *clipper = [super clipper];
    clipper.alphaThreshold = 0.05;
    clipper.inverted = YES;
    return clipper;
}

@end

#pragma mark - NestedTest

@implementation NestedTest

-(NSString*) title
{
	return @"Nested Test";
}

-(NSString*) subtitle
{
	return @"Nest 9 Clipping Nodes, max is usually 8";
}

- (void)setup
{
 
    static int depth = 9;
    
    CCNode *parent = self;
    
    for (int i = 0; i < depth; i++) {
                
        int size = 225 - i * (225 / (depth * 2));

        CCClippingNode *clipper = [CCClippingNode clippingNode];
        clipper.contentSize = CGSizeMake(size, size);
        clipper.anchorPoint = ccp(0.5, 0.5);
        clipper.position = ccp(parent.contentSize.width / 2, parent.contentSize.height / 2);
        clipper.alphaThreshold = 0.05;
        [clipper runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:i % 3 ? 1.33 : 1.66 angle:i % 2 ? 90 : -90]]];
        [parent addChild:clipper];
        
        CCNode *stencil = [CCSprite spriteWithFile:@"grossini.png"];
        stencil.scale = 2.5 - (i * (2.5 / depth));
        stencil.anchorPoint = ccp(0.5, 0.5);
        stencil.position = ccp(clipper.contentSize.width / 2, clipper.contentSize.height / 2);
        stencil.visible = NO;
        [stencil runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:i] two:[CCShow action]]];
        clipper.stencil = stencil;

        [clipper addChild:stencil];
        
        parent = clipper;
        
    }

}

@end

#pragma mark - HoleDemo

@interface HoleDemo ()
{
    /*
    BOOL scrolling_;
    CGPoint lastPoint_;
    */
    CCClippingNode *outerClipper_;
    CCNode *holes_;
    CCNode *holesStencil_;
}
@end

@implementation HoleDemo

- (void) dealloc
{
    [outerClipper_ release];
    [holes_ release];
    [holesStencil_ release];
    [super dealloc];
}

-(NSString*) title
{
	return @"Hole Demo";
}

-(NSString*) subtitle
{
	return @"Touch/click to poke holes";
}

- (void)setup
{
    CCSprite *target = [CCSprite spriteWithFile:@"blocks.png"];
    target.anchorPoint = CGPointZero;
    target.scale = 3;
    
    outerClipper_ = [[CCClippingNode clippingNode] retain];
    outerClipper_.contentSize = CGSizeApplyAffineTransform(target.contentSize, CGAffineTransformMakeScale(target.scale, target.scale));
    outerClipper_.anchorPoint = ccp(0.5, 0.5);
    outerClipper_.position = ccpMult(ccpFromSize(self.contentSize), 0.5);
    [outerClipper_ runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:45]]];
    
    outerClipper_.stencil = target;
    
    CCClippingNode *holesClipper = [CCClippingNode clippingNode];
    holesClipper.inverted = YES;
    holesClipper.alphaThreshold = 0.05;
    
    [holesClipper addChild:target];
    
    holes_ = [[CCNode node] retain];
    
    [holesClipper addChild:holes_];
    
    holesStencil_ = [[CCNode node] retain];
    
    holesClipper.stencil = holesStencil_;
    
    [outerClipper_ addChild:holesClipper];
    
    [self addChild:outerClipper_];
        
#ifdef __CC_PLATFORM_IOS
    self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
    self.mouseEnabled = YES;
#endif
}

- (void)pokeHoleAtPoint:(CGPoint)point
{
    float scale = CCRANDOM_0_1() * 0.2 + 0.9;
    float rotation = CCRANDOM_0_1() * 360;
    
    CCSprite *hole = [CCSprite spriteWithFile:@"hole_effect.png"];
    hole.position = point;
    hole.rotation = rotation;
    hole.scale = scale;
    
    [holes_ addChild:hole];
    
    CCSprite *holeStencil = [CCSprite spriteWithFile:@"hole_stencil.png"];
    holeStencil.position = point;
    holeStencil.rotation = rotation;
    holeStencil.scale = scale;
    
    [holesStencil_ addChild:holeStencil];

    [outerClipper_ runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:0.05 scale:0.95]
                                               two:[CCScaleTo actionWithDuration:0.125 scale:1]]];
}

#ifdef __CC_PLATFORM_IOS

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [outerClipper_ convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]]];
    if (!CGRectContainsPoint(CGRectMake(0, 0, outerClipper_.contentSize.width, outerClipper_.contentSize.height), point)) return;
    [self pokeHoleAtPoint:point];
}

#elif defined(__CC_PLATFORM_MAC)

- (BOOL)ccMouseDown:(NSEvent*)event
{
    CGPoint point = [outerClipper_ convertToNodeSpace:[[CCDirector sharedDirector] convertEventToGL:event]];
    if (!CGRectContainsPoint(CGRectMake(0, 0, outerClipper_.contentSize.width, outerClipper_.contentSize.height), point)) return NO;
    [self pokeHoleAtPoint:point];
    return YES;
}

#endif

@end

#pragma mark - ScrollViewDemo

@interface ScrollViewDemo ()
{
    BOOL scrolling_;
    CGPoint lastPoint_;
}
@end

@implementation ScrollViewDemo

-(NSString*) title
{
	return @"Scroll View Demo";
}

-(NSString*) subtitle
{
	return @"Move/drag to scroll the content";
}

- (void)setup
{
    CCClippingNode *clipper = [CCClippingNode clippingNode];
    clipper.tag = kTagClipperNode;
    clipper.contentSize = CGSizeMake(200, 200);
    clipper.anchorPoint = ccp(0.5, 0.5);
    clipper.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
    [clipper runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:45]]];
    [self addChild:clipper];

    CCDrawNode *stencil = [CCDrawNode node];
    CGPoint rectangle[] = {{0, 0}, {clipper.contentSize.width, 0}, {clipper.contentSize.width, clipper.contentSize.height}, {0, clipper.contentSize.height}};
    ccColor4F white = {1, 1, 1, 1};
    [stencil drawPolyWithVerts:rectangle count:4 fillColor:white borderWidth:1 borderColor:white];
    clipper.stencil = stencil;

    CCSprite *content = [CCSprite spriteWithFile:@"background2.jpg"];
    content.tag = kTagContentNode;
    content.anchorPoint = ccp(0.5, 0.5);
    content.position = ccp(clipper.contentSize.width / 2, clipper.contentSize.height / 2);
    [clipper addChild:content];
    
    scrolling_ = NO;
#ifdef __CC_PLATFORM_IOS
    self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
    self.mouseEnabled = YES;
#endif
}

#ifdef __CC_PLATFORM_IOS

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CCNode *clipper = [self getChildByTag:kTagClipperNode];
	CGPoint point = [clipper convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]]];
    scrolling_ = CGRectContainsPoint(CGRectMake(0, 0, clipper.contentSize.width, clipper.contentSize.height), point);
    lastPoint_ = point;
}

-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    if (!scrolling_) return;
	UITouch *touch = [touches anyObject];
    CCNode *clipper = [self getChildByTag:kTagClipperNode];
    CGPoint point = [clipper convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]]];
	CGPoint diff = ccpSub(point, lastPoint_);
    CCNode *content = [clipper getChildByTag:kTagContentNode];
    content.position = ccpAdd(content.position, diff);
    lastPoint_ = point;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!scrolling_) return;
    scrolling_ = NO;
}

#elif defined(__CC_PLATFORM_MAC)

- (BOOL)ccMouseDown:(NSEvent*)event
{
    CCNode *clipper = [self getChildByTag:kTagClipperNode];
    CGPoint point = [clipper convertToNodeSpace:[[CCDirector sharedDirector] convertEventToGL:event]];
    scrolling_ = CGRectContainsPoint(CGRectMake(0, 0, clipper.contentSize.width, clipper.contentSize.height), point);
    lastPoint_ = point;
    return scrolling_;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (!scrolling_) return NO;
    CCNode *clipper = [self getChildByTag:kTagClipperNode];
    CGPoint point = [clipper convertToNodeSpace:[[CCDirector sharedDirector] convertEventToGL:event]];
	CGPoint diff = ccpSub(point, lastPoint_);
    CCNode *content = [clipper getChildByTag:kTagContentNode];
    content.position = ccpAdd(content.position, diff);
    lastPoint_ = point;
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent*)event
{
    if (!scrolling_) return NO;
    scrolling_ = NO;
    return YES;
}

#endif

@end

#pragma mark - RawStencilBufferTests

#if COCOS2D_DEBUG > 1

static GLint _stencilBits = -1;

static const GLfloat _alphaThreshold = 0.05;

static const int _planeCount = 8;
static const ccColor4F _planeColor[] = {
    {0, 0, 0, 0.65},
    {0.7, 0, 0, 0.6},
    {0, 0.7, 0, 0.55},
    {0, 0, 0.7, 0.5},
    {0.7, 0.7, 0, 0.45},
    {0, 0.7, 0.7, 0.4},
    {0.7, 0, 0.7, 0.35},
    {0.7, 0.7, 0.7, 0.3},
};

@implementation RawStencilBufferTest

- (void)dealloc
{
    [sprite_ release];
    [super dealloc];
}

-(NSString*) title
{
	return @"Raw Stencil Tests";
}

-(NSString*) subtitle
{
	return @"1:Default";
}

- (void)setup
{
    glGetIntegerv(GL_STENCIL_BITS, &_stencilBits);
    if (_stencilBits < 3) {
        CCLOGWARN(@"Stencil must be enabled for the current CCGLView.");
    }
    sprite_ = [[CCSprite spriteWithFile:@"grossini.png"] retain];
    sprite_.anchorPoint = ccp(0.5, 0);
    sprite_.scale = 2.5;
    [[CCDirector sharedDirector] setAlphaBlending:YES];
}

- (void)draw
{    
    CGPoint winPoint = ccpFromSize([[CCDirector sharedDirector] winSize]);
    
    CGPoint planeSize = ccpMult(winPoint, 1.0 / _planeCount);
    
    glEnable(GL_STENCIL_TEST);
    CHECK_GL_ERROR_DEBUG();
        
    for (int i = 0; i < _planeCount; i++) {
        
        CGPoint stencilPoint = ccpMult(planeSize, _planeCount - i);
        stencilPoint.x = winPoint.x;
        
        CGPoint spritePoint = ccpMult(planeSize, i);
        spritePoint.x += planeSize.x / 2;
        spritePoint.y = 0;
        sprite_.position = spritePoint;

        [self setupStencilForClippingOnPlane:i];
        CHECK_GL_ERROR_DEBUG();

        ccDrawSolidRect(CGPointZero, stencilPoint, (ccColor4F){1, 1, 1, 1});
        
        kmGLPushMatrix();
        [self transform];
        [sprite_ visit];
        kmGLPopMatrix();
        
        [self setupStencilForDrawingOnPlane:i];
        CHECK_GL_ERROR_DEBUG();
        
        ccDrawSolidRect(CGPointZero, winPoint, _planeColor[i]);
        
        kmGLPushMatrix();
        [self transform];
        [sprite_ visit];
        kmGLPopMatrix();
    }
    
    glDisable(GL_STENCIL_TEST);
    CHECK_GL_ERROR_DEBUG();
}

- (void)setupStencilForClippingOnPlane:(GLint)plane
{
    GLint planeMask = 0x1 << plane;
    glStencilMask(planeMask);
    glClearStencil(0x0);
    glClear(GL_STENCIL_BUFFER_BIT);
    glStencilFunc(GL_NEVER, planeMask, planeMask);
    glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
}

- (void)setupStencilForDrawingOnPlane:(GLint)plane
{
    GLint planeMask = 0x1 << plane;
    GLint equalOrLessPlanesMask = planeMask | (planeMask - 1);
    glStencilFunc(GL_EQUAL, equalOrLessPlanesMask, equalOrLessPlanesMask);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
}

@end

@implementation RawStencilBufferTest2

-(NSString*) subtitle
{
	return @"2:DepthMask:FALSE";
}

- (void)setupStencilForClippingOnPlane:(GLint)plane
{
    [super setupStencilForClippingOnPlane:plane];
    glDepthMask(GL_FALSE);
}

- (void)setupStencilForDrawingOnPlane:(GLint)plane
{
    glDepthMask(GL_TRUE);
    [super setupStencilForDrawingOnPlane:plane];
}

@end

@implementation RawStencilBufferTest3

-(NSString*) subtitle
{
	return @"3:DepthTest:DISABLE,DepthMask:FALSE";
}

- (void)setupStencilForClippingOnPlane:(GLint)plane
{
    [super setupStencilForClippingOnPlane:plane];
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
}

- (void)setupStencilForDrawingOnPlane:(GLint)plane
{
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    [super setupStencilForDrawingOnPlane:plane];
}

@end

@implementation RawStencilBufferTest4

-(NSString*) subtitle
{
	return @"4:DepthMask:FALSE,AlphaTest:ENABLE";
}

- (void)setupStencilForClippingOnPlane:(GLint)plane
{
    [super setupStencilForClippingOnPlane:plane];
    glDepthMask(GL_FALSE);
#if defined(__CC_PLATFORM_IOS)
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
    GLint alphaValueLocation = glGetUniformLocation(program->program_, kCCUniformAlphaTestValue);
    [program setUniformLocation:alphaValueLocation withF1:_alphaThreshold];
    sprite_.shaderProgram = program;
#elif defined(__CC_PLATFORM_MAC)
    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, _alphaThreshold);
#endif
}

- (void)setupStencilForDrawingOnPlane:(GLint)plane
{
#if defined(__CC_PLATFORM_MAC)
    glDisable(GL_ALPHA_TEST);
#endif
    glDepthMask(GL_TRUE);
    [super setupStencilForDrawingOnPlane:plane];
}

@end

@implementation RawStencilBufferTest5

-(NSString*) subtitle
{
	return @"5:DepthTest:DISABLE,DepthMask:FALSE,AlphaTest:ENABLE";
}

- (void)setupStencilForClippingOnPlane:(GLint)plane
{
    [super setupStencilForClippingOnPlane:plane];
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
#if defined(__CC_PLATFORM_IOS)
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
    GLint alphaValueLocation = glGetUniformLocation(program->program_, kCCUniformAlphaTestValue);
    [program setUniformLocation:alphaValueLocation withF1:_alphaThreshold];
    sprite_.shaderProgram = program;
#elif defined(__CC_PLATFORM_MAC)
    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, _alphaThreshold);
#endif
}

- (void)setupStencilForDrawingOnPlane:(GLint)plane
{
#if defined(__CC_PLATFORM_MAC)
    glDisable(GL_ALPHA_TEST);
#endif
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    [super setupStencilForDrawingOnPlane:plane];
}

@end

#endif // COCOS2D_DEBUG > 1

#pragma mark - AppDelegate

#if defined(__CC_PLATFORM_IOS)

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Main Window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// GL View
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:GL_DEPTH24_STENCIL8_OES
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0];
    
	// Director
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:YES];
	[director_ setAnimationInterval:1.0 / 60];
	director_.wantsFullScreenLayout = YES;
    [director_ setDelegate:self];    
	// Turn on display FPS
	[director_ setDisplayStats:YES];

	[director_ setView:__glView];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used

	// Navigation Controller
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	// set it as the root VC
	[window_ setRootViewController:navController_];
    
	[window_ makeKeyAndVisible];
    
	return  YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    window_ = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 480, 320)
                                           styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                                             backing:NSBackingStoreBuffered
                                               defer:NO] retain];
    
    NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAStencilSize, 8,
		0
    };
    NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
    
    glView_ = [[[CCGLView alloc] initWithFrame:window_.frame pixelFormat:pixelFormat] retain];
    
    window_.contentView = glView_;
    
	director_ = (CCDirectorMac*) [CCDirector sharedDirector];
    
	[director_ setDisplayStats:YES];
    
	[director_ setView:glView_];
    
	// Center window
	[self.window center];
	    
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
    
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_NoScale]; // kCCDirectorResize_AutoScale
    
    [window_ makeKeyAndOrderFront:self];
    
	CCScene *scene = [CCScene node];
	[scene addChild:[nextAction() node]];
	
	[director_ runWithScene:scene];
}
@end
#endif

