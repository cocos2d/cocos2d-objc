//
// Texture2D Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "Texture2dTest.h"

enum {
	kTagLabel = 1,
	kTagSprite1 = 2,
	kTagSprite2 = 3,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
						@"TextureLabel",
						@"TextureLabel2",
						@"TextureAlias",
						@"TexturePVRMipMap",
						@"TexturePVR",
						@"TexturePVRRaw",
						@"TexturePNG",
						@"TextureBMP",
						@"TextureJPEG",
						@"TextureTIFF",
						@"TextureGIF",
						@"TexturePixelFormat",
						@"TextureBlend",
						@"TextureAsync",
						@"TexturePNGAlpha",
};

#pragma mark Callbacks

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
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
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

@implementation TextureDemo
-(id) init
{
	if( (self = [super init]) ) {

		CGSize s = [[Director sharedDirector] winSize];	
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:0 tag:kTagLabel];
		[label setPosition: ccp(s.width/2, s.height-50)];

		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];

	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[TextureMgr sharedTextureMgr] removeUnusedTextures];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark Examples

@implementation TextureLabel
-(void) onEnter
{
	[super onEnter];

	Label *left = [Label labelWithString:@"alignment left" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:32];
	Label *center = [Label labelWithString:@"alignment center" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:32];
	Label *right = [Label labelWithString:@"alignment right" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:32];

	left.position = ccp(240,200);
	center.position = ccp(240,150);
	right.position = ccp(240,100);

	[[[self addChild:left z:0]
			addChild:right z:0]
			addChild:center z:0];
	
//	id s = [Sprite spriteWithFile:@"grossini_indexed.png"];
//	id s2 = [Sprite spriteWithFile:@"grossini_indexed.gif"];
//	[self addChild:s];
//	[self addChild:s2];
}

-(NSString *) title
{
	return @"Label Alignments";
}
@end

@implementation TextureLabel2
-(void) onEnter
{
	[super onEnter];
	
	Label *center1 = [Label labelWithString:@"Marker Felt 32" fontName:@"Marker Felt" fontSize:32];
	Label *center2 = [Label labelWithString:@"Times New Roman 48" fontName:@"Times New Roman" fontSize:48];
	Label *center3 = [Label labelWithString:@"Courier 64" fontName:@"Courier" fontSize:64];
	
	center1.position = ccp(240,200);
	center2.position = ccp(240,150);
	center3.position = ccp(240,100);
	
	[[[self addChild:center1 z:0]
			addChild:center2 z:0]
			addChild:center3 z:0];
}

-(NSString *) title
{
	return @"Label Dynamic Size";
}
@end

@implementation TexturePNG
-(void) onEnter
{
	[super onEnter];	

	CGSize s = [[Director sharedDirector] winSize];

	Sprite *img = [Sprite spriteWithFile:@"test_image.png"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PNG Test";
}
@end

@implementation TextureJPEG
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.jpeg"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"JPEG Test";
}
@end

@implementation TextureBMP
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.bmp"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"BMP Test";
}
@end

@implementation TextureTIFF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.tiff"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"TIFF Test";
}
@end

@implementation TextureGIF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.gif"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"GIF Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRMipMap
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];

	Sprite *imgMipMap = [Sprite spriteWithFile:@"logo-mipmap.pvr"];
	imgMipMap.position = ccp( s.width/2.0f-100, s.height/2.0f);
	[self addChild:imgMipMap];

	// support mipmap filtering
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[imgMipMap.texture setTexParameters:&texParams];
	Sprite *img = [Sprite spriteWithFile:@"logo-nomipmap.pvr"];
	img.position = ccp( s.width/2.0f+100, s.height/2.0f);
	[self addChild:img];
	
	id scale1 = [EaseOut actionWithAction: [ScaleBy actionWithDuration:4 scale:0.01f] rate:3];
	id sc_back = [scale1 reverse];
	
	id scale2 = [[scale1 copy] autorelease];
	id sc_back2 = [scale2 reverse];
	
	[imgMipMap runAction: [RepeatForever actionWithAction: [Sequence actions: scale1, sc_back, nil]]];
	[img runAction: [RepeatForever actionWithAction: [Sequence actions: scale2, sc_back2, nil]]];
}

-(NSString *) title
{
	return @"PVR MipMap Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVR
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *img = [Sprite spriteWithFile:@"test_image.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PVR Test";
}
@end

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRRaw
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addPVRTCImage:@"test_image.pvrraw" bpp:4 hasAlpha:YES width:128];
	Sprite *img = [Sprite spriteWithTexture:tex];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	
}

-(NSString *) title
{
	return @"PVR Raw Test";
}
@end

@implementation TextureAlias
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	
	//
	// Sprite 1: GL_LINEAR
	//
	// Default filter is GL_LINEAR
	
	Sprite *sprite = [Sprite spriteWithFile:@"grossinis_sister1.png"];
	sprite.position = ccp( s.width/3.0f, s.height/2.0f);
	[self addChild:sprite];
	
	// this is the default filterting
	[sprite.texture setAntiAliasTexParameters];
	
	//
	// Sprite 1: GL_NEAREST
	//	
	
	Sprite *sprite2 = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	sprite2.position = ccp( 2*s.width/3.0f, s.height/2.0f);
	[self addChild:sprite2];
	
	// Use Nearest in this one
	[sprite2.texture setAliasTexParameters];

		
	// scale them to show
	id sc = [ScaleBy actionWithDuration:3 scale:8.0f];
	id sc_back = [sc reverse];
	id scaleforever = [RepeatForever actionWithAction: [Sequence actions: sc, sc_back, nil]];
	
	[sprite2 runAction:scaleforever];
	[sprite runAction: [[scaleforever copy] autorelease]];
}

-(NSString *) title
{
	return @"AntiAlias / Alias textures";
}
@end

#pragma mark TexturePixelFormat
@implementation TexturePixelFormat
-(void) onEnter
{
	//
	// This example displays 1 png images 4 times.
	// Each time the image is generated using:
	// 1- 32-bit RGBA8
	// 2- 16-bit RGBA4
	// 3- 16-bit RGB5A1
	// 4- 16-bit RGB565
	[super onEnter];
	
	Label *label = (Label*) [self getChildByTag:kTagLabel];
	[label setColor:ccc3(16,16,255)];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	Sprite *background = [Sprite spriteWithFile:@"background1.jpg"];
	background.position = ccp(240,160);
	[self addChild:background z:-1];
	
	// RGBA 8888 image (32-bit)
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	Sprite *sprite1 = [Sprite spriteWithFile:@"test-rgba1.png"];
	sprite1.position = ccp(64, s.height/2);
	[self addChild:sprite1 z:0];
	
	// remove texture from texture manager	
	[[TextureMgr sharedTextureMgr] removeTexture:sprite1.texture];

	// RGBA 4444 image (16-bit)
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
	Sprite *sprite2 = [Sprite spriteWithFile:@"test-rgba1.png"];
	sprite2.position = ccp(64+128, s.height/2);
	[self addChild:sprite2 z:0];

	// remove texture from texture manager	
	[[TextureMgr sharedTextureMgr] removeTexture:sprite2.texture];

	// RGB5A1 image (16-bit)
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB5A1];
	Sprite *sprite3 = [Sprite spriteWithFile:@"test-rgba1.png"];
	sprite3.position = ccp(64+128*2, s.height/2);
	[self addChild:sprite3 z:0];

	// remove texture from texture manager	
	[[TextureMgr sharedTextureMgr] removeTexture:sprite3.texture];

	// RGB565 image (16-bit)
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGB565];
	Sprite *sprite4 = [Sprite spriteWithFile:@"test-rgba1.png"];
	sprite4.position = ccp(64+128*3, s.height/2);
	[self addChild:sprite4 z:0];

	// remove texture from texture manager	
	[[TextureMgr sharedTextureMgr] removeTexture:sprite4.texture];

	
	id fadeout = [FadeOut actionWithDuration:2];
	id fadein = [FadeIn actionWithDuration:2];
	id seq = [Sequence actions: [DelayTime actionWithDuration:2], fadeout, fadein, nil];
	id seq_4ever = [RepeatForever actionWithAction:seq];
	
	[sprite1 runAction:seq_4ever];
	[sprite2 runAction: [[seq_4ever copy] autorelease]];
	[sprite3 runAction: [[seq_4ever copy] autorelease]];
	[sprite4 runAction: [[seq_4ever copy] autorelease]];

	// restore default
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_Default];
}

-(NSString *) title
{
	return @"Texture Pixel Formats";
}
@end


#pragma mark TextureBlend
@implementation TextureBlend
-(id) init
{
	if( (self=[super init]) ) {
		
		for( int i=0;i < 15;i++ ) {
			
			// BOTTOM sprites have alpha pre-multiplied
			// they use by default GL_ONE, GL_ONE_MINUS_SRC_ALPHA
			Sprite *cloud = [Sprite spriteWithFile:@"test_blend.png"];
			[self addChild:cloud z:i+1 tag:100+i];
			cloud.position = ccp(50+25*i, 80);
			if( ! cloud.texture.hasPremultipliedAlpha )
				NSLog(@"Texture Blend failed. Test it on the device, not simulator");

			// CENTER sprites don't have alpha pre-multiplied
			// they use by default GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			cloud = [Sprite spriteWithFile:@"test_blend.bmp"];
			[self addChild:cloud z:i+1 tag:200+i];
			cloud.position = ccp(50+25*i, 160);
			if( cloud.texture.hasPremultipliedAlpha )
				NSLog(@"Texture Blend failed. Test it on the device, not simulator");
			
			// UPPER sprites are using custom blending function
			// You can set any blend function to your sprites
			cloud = [Sprite spriteWithFile:@"test_blend.bmp"];
			[self addChild:cloud z:i+1 tag:200+i];
			cloud.position = ccp(50+25*i, 320-80);
			cloud.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE };  // additive blending
		}
	}
	return self;
}

-(NSString *) title
{
	return @"Texture Blending";
}
@end

#pragma mark TextureAsync
@implementation TextureAsync
-(id) init
{
	if( (self=[super init]) ) {
		
		imageOffset = 0;
	
		CGSize size =[[Director sharedDirector] winSize];

		Label *label = [Label labelWithString:@"Loading..." fontName:@"Marker Felt" fontSize:32];
		label.position = ccp( size.width/2, size.height/2);
		[self addChild:label z:10];
		
		id scale = [ScaleBy actionWithDuration:0.3f scale:2];
		id scale_back = [scale reverse];
		id seq = [Sequence actions: scale, scale_back, nil];
		[label runAction: [RepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(loadImages:) interval:1.0f];
		
	}
	return self;
}

- (void) dealloc
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
	[super dealloc];
}


-(void) loadImages:(ccTime) dt
{
	[self unschedule:_cmd];

	for( int i=0;i < 8;i++) {
		for( int j=0;j < 8; j++) {
			NSString *sprite = [NSString stringWithFormat:@"sprite-%d-%d.png", i, j];
			[[TextureMgr sharedTextureMgr] addImageAsync:sprite target:self selector:@selector(imageLoaded:)];
		}
	}	

	[[TextureMgr sharedTextureMgr] addImageAsync:@"background1.jpg" target:self selector:@selector(imageLoaded:)];
	[[TextureMgr sharedTextureMgr] addImageAsync:@"background2.jpg" target:self selector:@selector(imageLoaded:)];
	[[TextureMgr sharedTextureMgr] addImageAsync:@"background.png" target:self selector:@selector(imageLoaded:)];
	[[TextureMgr sharedTextureMgr] addImageAsync:@"atlastest.png" target:self selector:@selector(imageLoaded:)];
	[[TextureMgr sharedTextureMgr] addImageAsync:@"grossini_dance_atlas.png" target:self selector:@selector(imageLoaded:)];
}


-(void) imageLoaded: (Texture2D*) tex
{
	// IMPORTANT: The order on the callback is not guaranteed. Don't depend on the callback

	// This test just creates a sprite based on the Texture
	
	Sprite *sprite = [Sprite spriteWithTexture:tex];
	sprite.anchorPoint = ccp(0,0);
	[self addChild:sprite z:-1];
	
	CGSize size =[[Director sharedDirector] winSize];
	
	int i = imageOffset * 32;
	sprite.position = ccp( i % (int)size.width, (i / (int)size.width) * 32 );
	
	imageOffset++;
}

-(NSString *) title
{
	return @"Texture Async Load";
}
@end

#pragma mark TexturePNGAlpha
@implementation TexturePNGAlpha
-(id) init
{
	if( (self=[super init]) ) {
				
		CGSize size =[[Director sharedDirector] winSize];
	
		NSLog(@"background3.jpg");
		Sprite *background = [Sprite spriteWithFile:@"background3.jpg"];
		background.anchorPoint = CGPointZero;
		[self addChild:background z:-1];
		
		
		// PNG compressed sprite has pre multiplied alpha channel
		//   you CAN have opacity + tint at the same time
		//   but opacity SHOULD be before COLOR
		Sprite *png1 = [Sprite spriteWithFile:@"grossinis_sister1-testalpha.png"];
		[self addChild:png1 z:0];
		png1.position = ccp(size.width/6, size.height/2);
		png1.opacity = 200;
		png1.color = ccRED;
		
		// PNG compressed sprite has pre multiplied alpha channel
		//   you CAN'T have opacity + tint at the same time
		//   if color goes BEFORE opacity
		Sprite *png2 = [Sprite spriteWithFile:@"grossinis_sister1-testalpha.png"];
		[self addChild:png2 z:0];
		png2.position = ccp(size.width/6*2, size.height/2);
		png2.color = ccRED;
		png2.opacity = 200;
		
		// PNG uncompressed sprite has pre multiplied alpha
		//   Same rule as compressed sprites. why ???
		Sprite *uncPNG = [Sprite spriteWithFile:@"grossinis_sister1-testalpha.xxx"];
		[self addChild:uncPNG z:0];
		uncPNG.position = ccp(size.width/6*3, size.height/2);
		uncPNG.color = ccRED;
		uncPNG.opacity = 200;
		
		// PNG compressed sprite has pre multiplied alpha channel
		//  - with opacity doesn't modify color
		//  - blend func: GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
		Sprite *png3 = [Sprite spriteWithFile:@"grossinis_sister1-testalpha.png"];
		[self addChild:png3 z:0];
		png3.position = ccp(size.width/6*4, size.height/2);
		[png3 setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA}];
		[png3 setOpacityModifyRGB:NO];
		png3.color = ccRED;
		png3.opacity = 200;
		
		// BMP  sprite doesn't have pre multiplied alpha channel
		//   you CAN have opacity + tint at the same time
		Sprite *bmp = [Sprite spriteWithFile:@"grossinis_sister1-testalpha.bmp"];
		[self addChild:bmp z:0];
		bmp.position = ccp(size.width/6*5, size.height/2);
		bmp.color = ccRED;
		bmp.opacity = 200;
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(NSString *) title
{
	return @"PNG alpha pre vs. non-pre";
}
@end




#pragma mark -
#pragma mark AppController - Main


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];

	//
	[[Director sharedDirector] setPixelFormat:kRGBA8];

	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change it at anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];

	[[Director sharedDirector] runWithScene: scene];
}

// geting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}


- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
