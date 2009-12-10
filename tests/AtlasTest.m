//
// Atlas Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "AtlasTest.h"
static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Atlas1",
			@"Atlas2",
			@"Atlas3",
			@"Atlas4",
			@"Atlas5",
			@"Atlas6",
			@"AtlasBitmapColor",
			@"AtlasFastBitmap",
};

enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
	kTagBitmapAtlas1 = 1,
	kTagBitmapAtlas2 = 2,
	kTagBitmapAtlas3 = 3,
};

enum {
	kTagSprite1,
	kTagSprite2,
	kTagSprite3,
	kTagSprite4,
	kTagSprite5,
	kTagSprite6,
	kTagSprite7,
	kTagSprite8,
};

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


@implementation AtlasDemo
-(id) init
{
	[super init];


	CGSize s = [[CCDirector sharedDirector] winSize];
		
	CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
	[self addChild: label z:1];
	[label setPosition: ccp(s.width/2, s.height-50)];
	
	CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
	
	menu.position = CGPointZero;
	item1.position = ccp( s.width/2 - 100,30);
	item2.position = ccp( s.width/2, 30);
	item3.position = ccp( s.width/2 + 100,30);
	[self addChild: menu z:1];	

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
@end

#pragma mark Example Atlas 1

@implementation Atlas1


-(id) init
{
	if( ![super init] )
		return nil;
	
	textureAtlas = [[CCTextureAtlas textureAtlasWithFile: @"atlastest.png" capacity:3] retain];
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	//
	// Notice: u,v tex coordinates are inverted
	//
	ccV3F_C4B_T2F_Quad quads[] = {
		{
			{{0,0,0},{0,0,255,255},{0.0f,1.0f},},				// bottom left
			{{s.width,0,0},{0,0,255,0},{1.0f,1.0f},},			// bottom right
			{{0,s.height,0},{0,0,255,0},{0.0f,0.0f},},			// top left
			{{s.width,s.height,0},{0,0,255,255},{1.0f,0.0f},},	// top right
		},		
		{
			{{40,40,0},{255,255,255,255},{0.0f,0.2f},},			// bottom left
			{{120,80,0},{255,0,0,255},{0.5f,0.2f},},			// bottom right
			{{40,160,0},{255,255,255,255},{0.0f,0.0f},},		// top left
			{{160,160,0},{0,255,0,255},{0.5f,0.0f},},			// top right
		},

		{
			{{s.width/2,40,0},{255,0,0,255},{0.0f,1.0f},},		// bottom left
			{{s.width,40,0},{0,255,0,255},{1.0f,1.0f},},		// bottom right
			{{s.width/2-50,200,0},{0,0,255,255},{0.0f,0.0f},},		// top left
			{{s.width,100,0},{255,255,0,255},{1.0f,0.0f},},		// top right
		},
		
	};
	
	
	for( int i=0;i<3;i++) {
		[textureAtlas updateQuad:&quads[i] atIndex:i];
	}
		
//	[textureAtlas removeQuadAtIndex:0];

	return self;
}

-(void) dealloc
{
	[textureAtlas release];
	[super dealloc];
}


-(void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glEnableClientState( GL_COLOR_ARRAY);
	
	glEnable( GL_TEXTURE_2D);

	[textureAtlas drawQuads];

//	[textureAtlas drawNumberOfQuads:3];
		
	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}
					
-(NSString *) title
{
	return @"Atlas: TextureAtlas";
}
@end

#pragma mark Example Atlas 2

@implementation Atlas2
-(id) init
{
	if( ![super init] )
		return nil;
	
	CCLabelAtlas *label1 = [CCLabelAtlas labelAtlasWithString:@"123 Test" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
	[self addChild:label1 z:0 tag:kTagSprite1];
	label1.position = ccp(10,100);
	label1.opacity = 200;

	CCLabelAtlas *label2 = [CCLabelAtlas labelAtlasWithString:@"0123456789" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
	[self addChild:label2 z:0 tag:kTagSprite2];
	label2.position = ccp(10,200);
	label2.opacity = 32;

	[self schedule:@selector(step:)];
	return self;
	
}

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%2.2f Test", time];
	CCLabelAtlas *label1 = (CCLabelAtlas*) [self getChildByTag:kTagSprite1];
	[label1 setString:string];

	CCLabelAtlas *label2 = (CCLabelAtlas*) [self getChildByTag:kTagSprite2];
	[label2 setString: [NSString stringWithFormat:@"%d", (int)time]];
}

-(void) dealloc
{
	[super dealloc];
}

-(NSString *) title
{
	return @"Atlas: LabelAtlas";
}
@end


#pragma mark Example Atlas3

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */
@implementation Atlas3
-(id) init
{
	if( (self=[super init]) ) {
		
		CCColorLayer *col = [CCColorLayer layerWithColor:ccc4(128,128,128,255)];
		[self addChild:col z:-10];
		
		CCBitmapFontAtlas *label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];
		
		// testing anchors
		label1.anchorPoint = ccp(0,0);
		[self addChild:label1 z:0 tag:kTagBitmapAtlas1];
		id fade = [CCFadeOut actionWithDuration:1.0f];
		id fade_in = [fade reverse];
		id seq = [CCSequence actions:fade, fade_in, nil];
		id repeat = [CCRepeatForever actionWithAction:seq];
		[label1 runAction:repeat];
		

		// VERY IMPORTANT
		// color and opacity work OK because bitmapFontAltas2 loads a BMP image (not a PNG image)
		// If you want to use both opacity and color, it is recommended to use NON premultiplied images like BMP images
		// Of course, you can also tell XCode not to compress PNG images, but I think it doesn't work as expected
		CCBitmapFontAtlas *label2 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];
		// testing anchors
		label2.anchorPoint = ccp(0.5f, 0.5f);
		label2.color = ccRED;
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		[label2 runAction: [[repeat copy] autorelease]];
		
		CCBitmapFontAtlas *label3 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];
		// testing anchors
		label3.anchorPoint = ccp(1,1);
		[self addChild:label3 z:0 tag:kTagBitmapAtlas3];
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];	
		label1.position = ccp( 0,0);
		label2.position = ccp( s.width/2, s.height/2);
		label3.position = ccp( s.width, s.height);

		[self schedule:@selector(step:)];
	}
	
	return self;
}

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%2.2f Test j", time];
	
	CCBitmapFontAtlas *label1 = (CCBitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas1];
	[label1 setString:string];
	
	CCBitmapFontAtlas *label2 = (CCBitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas2];
	[label2 setString:string];
	
	CCBitmapFontAtlas *label3 = (CCBitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas3];
	[label3 setString:string];
}

-(NSString*) title
{
	return @"BitmapFontAtlas: alignment";
}
@end

#pragma mark Example Atlas4

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */

@implementation Atlas4
-(id) init
{
	if( (self=[super init]) ) {
		
		// Upper Label
		CCBitmapFontAtlas *label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Bitmap Font Atlas" fntFile:@"bitmapFontTest.fnt"];
		[self addChild:label];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		label.position = ccp(s.width/2, s.height/2);
		label.anchorPoint = ccp(0.5f, 0.5f);
		
		
		CCSprite *BChar = (CCSprite*) [label getChildByTag:0];
		CCSprite *FChar = (CCSprite*) [label getChildByTag:7];
		CCSprite *AChar = (CCSprite*) [label getChildByTag:12];
		
		
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id rot_4ever = [CCRepeatForever actionWithAction:rotate];
		
		id scale = [CCScaleBy actionWithDuration:2 scale:1.5f];
		id scale_back = [scale reverse];
		id scale_seq = [CCSequence actions:scale, scale_back,nil];
		id scale_4ever = [CCRepeatForever actionWithAction:scale_seq];
		
		id jump = [CCJumpBy actionWithDuration:0.5f position:CGPointZero height:60 jumps:1];
		id jump_4ever = [CCRepeatForever actionWithAction:jump];
		
		id fade_out = [CCFadeOut actionWithDuration:1];
		id fade_in = [CCFadeIn actionWithDuration:1];
		id seq = [CCSequence actions:fade_out, fade_in, nil];
		id fade_4ever = [CCRepeatForever actionWithAction:seq];
		
		[BChar runAction:rot_4ever];
		[BChar runAction:scale_4ever];
		[FChar runAction:jump_4ever];
		[AChar runAction:fade_4ever];
		
		
		// Bottom Label
		CCBitmapFontAtlas *label2 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"00.0" fntFile:@"bitmapFontTest.fnt"];
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		label2.position = ccp(s.width/2.0f, 80);
		
		CCSprite *lastChar = (CCSprite*) [label2 getChildByTag:3];
		[lastChar runAction: [[rot_4ever copy] autorelease]];
		
		[self schedule:@selector(step:) interval:0.1f];
	}
	
	return self;
}

-(void) draw
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	ccDrawLine( ccp(0, s.height/2), ccp(s.width, s.height/2) );
	ccDrawLine( ccp(s.width/2, 0), ccp(s.width/2, s.height) );

}

-(NSString*) title
{
	return @"BitmapFontAtlas: animation";
}
-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%04.1f", time];
	
	CCBitmapFontAtlas *label1 = (CCBitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas2];
	[label1 setString:string];	
}

@end


#pragma mark Example Atlas5

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */

@implementation Atlas5
-(id) init
{
	if( (self=[super init]) ) {
		
		CCBitmapFontAtlas *label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"abcdefg" fntFile:@"bitmapFontTest4.fnt"];
		[self addChild:label];
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		label.position = ccp(s.width/2, s.height/2);
		label.anchorPoint = ccp(0.5f, 0.5f);
	}
	
	return self;
}

-(NSString*) title
{
	return @"BitmapFontAtlas: padding";
}
@end

#pragma mark -
#pragma mark Example Atlas6

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */

@implementation Atlas6
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCBitmapFontAtlas *label = nil;
		label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"FaFeFiFoFu" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2+50);
		label.anchorPoint = ccp(0.5f, 0.5f);
		
		label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"fafefifofu" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2);
		label.anchorPoint = ccp(0.5f, 0.5f);

		label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"aeiou" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2-50);
		label.anchorPoint = ccp(0.5f, 0.5f);
		
	}
	
	return self;
}

-(NSString*) title
{
	return @"BitmapFontAtlas: offset";
}
@end

#pragma mark -
#pragma mark Example AtlasBitmapColor

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */

@implementation AtlasBitmapColor
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCBitmapFontAtlas *label = nil;
		label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Blue" fntFile:@"bitmapFontTest5.fnt"];
		label.color = ccBLUE;
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2+50);
		label.anchorPoint = ccp(0.5f, 0.5f);

		label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Red" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2-50);
		label.anchorPoint = ccp(0.5f, 0.5f);
		label.color = ccRED;
		
	}
	
	return self;
}

-(NSString*) title
{
	return @"BitmapFontAtlas: color";
}
@end

#pragma mark -
#pragma mark Example AtlasFastBitmap

/*
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 */

@implementation AtlasFastBitmap
-(id) init
{
	if( (self=[super init]) ) {
		
		// Upper Label
		for( int i=0 ; i < 100;i ++ ) {
			CCBitmapFontAtlas *label = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"-%d-",i] fntFile:@"bitmapFontTest.fnt"];
			[self addChild:label];
			
			CGSize s = [[CCDirector sharedDirector] winSize];

			CGPoint p = ccp( CCRANDOM_0_1() * s.width, CCRANDOM_0_1() * s.height);
			label.position = p;
			label.anchorPoint = ccp(0.5f, 0.5f);
		}
	}
	
	return self;
}

-(NSString*) title
{
	return @"BitmapFontAtlas FastCache";
}
@end

#pragma mark -
#pragma mark Application Delegate

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
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[[CCDirector sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
