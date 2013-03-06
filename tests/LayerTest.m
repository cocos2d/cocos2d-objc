//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "LayerTest.h"

enum {
	kTagLayer = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"LayerTestCascadingOpacityA",
	@"LayerTestCascadingOpacityB",
	@"LayerTestCascadingOpacityC",
	@"LayerTestCascadingColorA",
	@"LayerTestCascadingColorB",
	@"LayerTestCascadingColorC",
	@"LayerTest1",
	@"LayerTest2",
	@"LayerTestBlend",
	@"LayerGradient",
	@"LayerIgnoreAnchorPointPos",
	@"LayerIgnoreAnchorPointRot",
	@"LayerIgnoreAnchorPointScale",
    @"LayerExtendedBlendOpacityTest",

};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;

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

#pragma mark - Cascading support extensions

@interface CCNode (cascading)
@end
@implementation CCNode (cascading)
-(void) setEnableRecursiveCascading:(BOOL)enable
{
	if( [self conformsToProtocol:@protocol(CCRGBAProtocol)] ) {
		[(id<CCRGBAProtocol>)self setCascadeColorEnabled:enable];
		[(id<CCRGBAProtocol>)self setCascadeOpacityEnabled:enable];
		
	}
	for( CCNode* child in self.children)
		[child setEnableRecursiveCascading:enable];
}
@end

#pragma mark - Example LayerTestCascadingOpacity

@implementation LayerTestCascadingOpacityA
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerRGBA* layer1 = [CCLayerRGBA node];
 
		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];

		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];

		sister1.position = ccp( s.width*1/3, s.height/2);
		sister2.position = ccp( s.width*2/3, s.height/2);
		label.position = ccp( s.width/2, s.height/2);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:4 opacity:0],
           [CCFadeTo actionWithDuration:4 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];


		// Enable cascading in scene
		[self setEnableRecursiveCascading:YES];
    }
	return self;
}

-(NSString *) title
{
	return @"LayerRGBA: cascading opacity";
}
@end

@implementation LayerTestCascadingOpacityB
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor:ccc4(192, 0, 0, 255) width:s.width height:s.height/2];
        layer1.cascadeColorEnabled = NO;

        layer1.position = ccp(0, s.height/2);

		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];
		
		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];
		
		sister1.position = ccp( s.width*1/3, 0);
		sister2.position = ccp( s.width*2/3, 0);
		label.position = ccp( s.width/2, 0);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:4 opacity:0],
           [CCFadeTo actionWithDuration:4 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];
		
		// Enable cascading in scene
		[self setEnableRecursiveCascading:YES];
	}
	return self;
}

-(NSString *) title
{
	return @"CCLayerColor: cascading opacity";
}
@end

@implementation LayerTestCascadingOpacityC
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor:ccc4(192, 0, 0, 255) width:s.width height:s.height/2];
        layer1.cascadeColorEnabled = NO;
        layer1.cascadeOpacityEnabled = NO;

        layer1.position = ccp(0, s.height/2);

		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];
		
		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];
		
		sister1.position = ccp( s.width*1/3, 0);
		sister2.position = ccp( s.width*2/3, 0);
		label.position = ccp( s.width/2, 0);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:4 opacity:0],
           [CCFadeTo actionWithDuration:4 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCFadeTo actionWithDuration:2 opacity:0],
           [CCFadeTo actionWithDuration:2 opacity:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];
	}
	return self;
}

-(NSString *) title
{
	return @"CCLayerColor: non-cascading opacity";
}
@end

#pragma mark -
#pragma mark Example LayerTestCascadingColor

@implementation LayerTestCascadingColorA
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerRGBA* layer1 = [CCLayerRGBA node];

		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];
		
		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];
		
		sister1.position = ccp( s.width*1/3, s.height/2);
		sister2.position = ccp( s.width*2/3, s.height/2);
		label.position = ccp( s.width/2, s.height/2);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:6 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:6 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:0],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:0 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

		// Enable cascading in scene
		[self setEnableRecursiveCascading:YES];

    }
	return self;
}

-(NSString *) title
{
	return @"LayerRGBA: cascading color";
}
@end

@implementation LayerTestCascadingColorB
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) width:s.width height:s.height/2];

        layer1.position = ccp(0, s.height/2);

		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];
		
		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];
		
		sister1.position = ccp( s.width*1/3, 0);
		sister2.position = ccp( s.width*2/3, 0);
		label.position = ccp( s.width/2, 0);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:6 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:6 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:0],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:0 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];
		
		// Enable cascading in scene
		[self setEnableRecursiveCascading:YES];
	}
	return self;
}

-(NSString *) title
{
	return @"CCLayerColor: cascading color";
}
@end

@implementation LayerTestCascadingColorC
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255) width:s.width height:s.height/2];
        layer1.cascadeColorEnabled = NO;
        layer1.position = ccp(0, s.height/2);

		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest.fnt"];
		
		[layer1 addChild:sister1];
		[layer1 addChild:sister2];
		[layer1 addChild:label];
		[self addChild: layer1 z:0 tag:kTagLayer];
		
		sister1.position = ccp( s.width*1/3, 0);
		sister2.position = ccp( s.width*2/3, 0);
		label.position = ccp( s.width/2, 0);

        [layer1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:6 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:6 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];

        [sister1 runAction:
         [CCRepeatForever actionWithAction:
          [CCSequence actions:
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:0],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:0 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:0 blue:255],
           [CCTintTo actionWithDuration:2 red:255 green:255 blue:255],
           [CCDelayTime actionWithDuration:1],
           nil]]];
	}
	return self;
}

-(NSString *) title
{
	return @"CCLayerColor: non-cascading color";
}
@end


@implementation LayerTest
-(id) init
{
	if( (self=[super init])) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}

-(NSString*) subtitle
{
	return nil;
}
@end

#pragma mark -
#pragma mark Example LayerTest1

@implementation LayerTest1
-(id) init
{
	if( (self=[super init] )) {

#if defined(__CC_PLATFORM_IOS)
		[self setTouchEnabled:YES];
#elif defined(__CC_PLATFORM_MAC)
		[self setMouseEnabled: YES];
#endif
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer = [CCLayerColor layerWithColor: ccc4(0xFF, 0x00, 0x00, 0x80)
												 width: 200
												height: 200];
		layer.ignoreAnchorPointForPosition =  NO;
		layer.position = ccp(s.width/2, s.height/2);
		[self addChild: layer z:1 tag:kTagLayer];
	}
	return self;
}

-(void) updateSize:(CGPoint)touchLocation
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGSize newSize = CGSizeMake( abs( touchLocation.x - s.width/2)*2, abs(touchLocation.y - s.height/2)*2);
	
	CCLayerColor *l = (CCLayerColor*) [self getChildByTag:kTagLayer];
	
	//	[l changeWidth:newSize.width];
	//	[l changeHeight:newSize.height];
	//	[l changeWidth:newSize.width height:newSize.height];
	
	[l setContentSize: newSize];
}

#if defined(__CC_PLATFORM_IOS)
-(void) ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
	[self ccTouchesMoved:touches withEvent:event];
}

-(void) ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent *)event
{
	[self ccTouchesMoved:touches withEvent:event];
}

-(void) ccTouchesCancelled:(NSSet*)touches withEvent:(UIEvent *)event
{
	[self ccTouchesMoved:touches withEvent:event];
}

-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	[self updateSize:touchLocation];
}

#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGPoint	location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self updateSize:location];
	return YES;
}
#endif


-(NSString *) title
{
	return @"LayerColor resize (tap & move)";
}
@end

#pragma mark -
#pragma mark Example LayerTest2

@implementation LayerTest2
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor: ccc4(255, 255, 0, 80)
												 width: 100
												height: 300];
		layer1.position = ccp(s.width/3, s.height/2);
		layer1.ignoreAnchorPointForPosition = NO;
		[self addChild: layer1 z:1];

		CCLayerColor* layer2 = [CCLayerColor layerWithColor: ccc4(0, 0, 255, 255)
												 width: 100
												height: 300];
		layer2.position = ccp((s.width/3)*2, s.height/2);
		layer2.ignoreAnchorPointForPosition = NO;
		[self addChild: layer2 z:1];

		id actionTint = [CCTintBy actionWithDuration:2 red:-255 green:-127 blue:0];
		id actionTintBack = [actionTint reverse];
		id seq1 = [CCSequence actions: actionTint, actionTintBack, nil];
		[layer1 runAction:seq1];


		id actionFade = [CCFadeOut actionWithDuration:2.0f];
		id actionFadeBack = [actionFade reverse];
		id seq2 = [CCSequence actions:actionFade, actionFadeBack, nil];
		[layer2 runAction:seq2];

	}
	return self;
}

-(NSString *) title
{
	return @"LayerColor: fade and tint";
}
@end

#pragma mark -
#pragma mark Example LayerTestBlend

@implementation LayerTestBlend
-(id) init
{
	if( (self=[super init] )) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor: ccc4(255, 255, 255, 80)];

//		id actionTint = [CCTintBy actionWithDuration:0.5f red:-255 green:-127 blue:0];
//		id actionTintBack = [actionTint reverse];
//		id seq1 = [CCSequence actions: actionTint, actionTintBack, nil];
//		[layer1 runAction: [CCRepeatForever actionWithAction:seq1]];


		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];

		[self addChild:sister1];
		[self addChild:sister2];
		[self addChild: layer1 z:100 tag:kTagLayer];

		sister1.position = ccp( s.width*1/3, s.height/2);
		sister2.position = ccp( s.width*2/3, s.height/2);

		[self schedule:@selector(newBlend:) interval:1];
	}
	return self;
}

-(void) newBlend:(ccTime)dt
{
	CCLayerColor *layer = (CCLayerColor*) [self getChildByTag:kTagLayer];
	if( layer.blendFunc.dst == GL_ZERO )
		[layer setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA } ];
	else
		[layer setBlendFunc:(ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ZERO}];

}

-(NSString *) title
{
	return @"LayerColor: blend";
}
@end

#pragma mark -
#pragma mark Example LayerGradient

@implementation LayerGradient
-(id) init
{
	if( (self=[super init] )) {

		CCLayerGradient* layer1 = [CCLayerGradient layerWithColor:ccc4(255,0,0,255) fadingTo:ccc4(0,255,0,255) alongVector:ccp(0.9f, 0.9f)];

		[self addChild:layer1 z:0 tag:kTagLayer];

#if defined(__CC_PLATFORM_IOS)
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Compressed Interpolation: Enabled" fontName:@"Marker Felt" fontSize:26];
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Compressed Interpolation: Disabled" fontName:@"Marker Felt" fontSize:26];
		CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:label1];
		CCMenuItemLabel *item2 = [CCMenuItemLabel itemWithLabel:label2];
		CCMenuItemToggle *item = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleItem:) items:item1, item2, nil];

		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		CGSize s = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp(s.width/2, 100)];
	}
	return self;
}

-(void) toggleItem:(id)sender
{
	CCLayerGradient *gradient = (CCLayerGradient*) [self getChildByTag:kTagLayer];
	[gradient setCompressedInterpolation: ! gradient.compressedInterpolation];
}

#if defined(__CC_PLATFORM_IOS)
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];
	start = [[CCDirector sharedDirector] convertToGL: start];

	CGPoint diff = ccpSub( ccp(s.width/2,s.height/2), start);
	diff = ccpNormalize(diff);

	CCLayerGradient *gradient = (CCLayerGradient*) [self getChildByTag:1];

	[gradient setVector:diff];
}
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGPoint	start = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CGPoint diff = ccpSub( ccp(s.width/2,s.height/2), start);
	diff = ccpNormalize(diff);
	
	CCLayerGradient *gradient = (CCLayerGradient*) [self getChildByTag:1];
	
	[gradient setVector:diff];
	
	return YES;
}
#endif

-(NSString *) title
{
	return @"LayerGradient";
}

-(NSString *) subtitle
{
	return @"Touch the screen and move your finger";
}
@end

#pragma mark -
#pragma mark Example LayerIgnoreAnchorPointPos

@implementation LayerIgnoreAnchorPointPos
-(id) init
{
	if( (self=[super init] )) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:150 height:150];
		
		l.anchorPoint = ccp(0.5f, 0.5f);
		l.position = ccp( s.width/2, s.height/2);
		
		CCMoveBy *move = [CCMoveBy actionWithDuration:2 position:ccp(100,2)];
		id back = [move reverse];
		CCSequence *seq = [CCSequence actions:move, back, nil];
		[l runAction: [CCRepeatForever actionWithAction:seq]];
		[self addChild:l];
		
		CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
		[l addChild:child];
		CGSize lsize = [l contentSize];
		[child setPosition:ccp(lsize.width/2, lsize.height/2)];
		
		CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Toggle ignore anchor point" block:^(id sender) {
			BOOL ignore = [l ignoreAnchorPointForPosition];
			[l setIgnoreAnchorPointForPosition: ! ignore];
		}
								];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}
	return self;
}

-(NSString *) title
{
	return @"IgnoreAnchorPoint - Position";
}

-(NSString *) subtitle
{
	return @"Ignoring Anchor Point for position";
}
@end

#pragma mark -
#pragma mark Example LayerIgnoreAnchorPointRot

@implementation LayerIgnoreAnchorPointRot
-(id) init
{
	if( (self=[super init] )) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:200 height:200];
		
		l.anchorPoint = ccp(0.5f, 0.5f);
		l.position = ccp( s.width/2, s.height/2);
		
		[self addChild:l];
		
		CCRotateBy *rot = [CCRotateBy actionWithDuration:2 angle:360];
		[l runAction: [CCRepeatForever actionWithAction:rot]];
		
		
		CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
		[l addChild:child];
		CGSize lsize = [l contentSize];
		[child setPosition:ccp(lsize.width/2, lsize.height/2)];

		CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Toogle ignore anchor point" block:^(id sender) {
			BOOL ignore = [l ignoreAnchorPointForPosition];
			[l setIgnoreAnchorPointForPosition: ! ignore];
		}
								];		
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}
	return self;
}

-(NSString *) title
{
	return @"IgnoreAnchorPoint - Rotation";
}

-(NSString *) subtitle
{
	return @"Ignoring Anchor Point for rotations";
}
@end

#pragma mark -
#pragma mark Example LayerIgnoreAnchorPointScale

@implementation LayerIgnoreAnchorPointScale
-(id) init
{
	if( (self=[super init] )) {
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:200 height:200];
		
		l.anchorPoint = ccp(0.5f, 1.0f);
		
		l.position = ccp( s.width/2, s.height/2);
		
		CCScaleBy *scale = [CCScaleBy actionWithDuration:2 scale:2];
		id back = [scale reverse];
		CCSequence *seq = [CCSequence actions:scale, back, nil];
		
		[l runAction: [CCRepeatForever actionWithAction:seq]];
		[self addChild:l];

		CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
		[l addChild:child];
		CGSize lsize = [l contentSize];
		[child setPosition:ccp(lsize.width/2, lsize.height/2)];

		CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Toogle ignore anchor point" block:^(id sender) {
			BOOL ignore = [l ignoreAnchorPointForPosition];
			[l setIgnoreAnchorPointForPosition: ! ignore];
		}
								];		
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}
	return self;
}

-(NSString *) title
{
	return @"IgnoreAnchorPoint - Scale";
}

-(NSString *) subtitle
{
	return @"Ignoring Anchor Point for scale";
}
@end

#pragma mark -
#pragma mark Extended Blend/Opacity tests

@implementation LayerExtendedBlendOpacityTest
-(id) init
{
	if( (self=[super init] )) {
        
		CCLayerGradient* layer1 = [CCLayerGradient layerWithColor:ccc4(255, 0, 0, 255) fadingTo:ccc4(255, 0, 255, 255)];
        layer1.contentSize = CGSizeMake(80, 80);
        layer1.position = ccp(50,50);
        [self addChild:layer1];
        
        CCLayerGradient* layer2 = [CCLayerGradient layerWithColor:ccc4(0, 0, 0, 127) fadingTo:ccc4(255, 255, 255, 127)];
        layer2.contentSize = CGSizeMake(80, 80);
        layer2.position = ccp(100,90);
        [self addChild:layer2];
        
        CCLayerGradient* layer3 = [[[CCLayerGradient alloc] init] autorelease];
        layer3.contentSize = CGSizeMake(80, 80);
        layer3.position = ccp(150,140);
        layer3.startColor = ccc3(255, 0, 0);
        layer3.endColor = ccc3(255, 0, 255);
        layer3.startOpacity = 255;
        layer3.endOpacity = 255;
        ccBlendFunc blend;
        blend.src = GL_SRC_ALPHA;
        blend.dst = GL_ONE_MINUS_SRC_ALPHA;
        layer3.blendFunc = blend;
        [self addChild:layer3];
	}
	return self;
}

-(NSString *) title
{
	return @"Extended Blend & Opacity";
}

-(NSString *) subtitle
{
	return @"You should see 3 layers";
}
@end

#pragma mark - AppController

#if defined(__CC_PLATFORM_IOS)

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];


	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	return YES;
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

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director_ runWithScene:scene];
}
@end
#endif

