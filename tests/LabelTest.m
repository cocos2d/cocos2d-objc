//
// Atlas Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "LabelTest.h"
static int sceneIdx=-1;
static NSString *transitions[] = {

	@"LabelAtlasTest",
	@"LabelAtlasColorTest",
	@"Atlas3",
	@"Atlas4",
	@"Atlas5",
	@"Atlas6",
	@"AtlasBitmapColor",
	@"AtlasFastBitmap",
	@"BitmapFontMultiLine",
	@"BitmapFontMultiLineAlignment",
	@"LabelsEmpty",
	@"LabelBMFontHD",
	@"LabelAtlasHD",
	@"LabelGlyphDesigner",
	@"LabelBMFontBounds",
	@"LabelTTFTest",
	@"LabelTTFMultiline",
	@"LabelTTFMultiline2",
	@"LabelTTFA8Test",
	@"LabelTTFScaleToFit",
    @"LabelTTFShadowStroke",
	@"BMFontOneAtlas",
	@"BMFontUnicode",
    @"BMFontInit",
    @"TTFFontInit",
	@"Issue1343",
    @"LabelTTFAlignment",

	// Not a label test. Should be moved to Atlas test
	@"Atlas1",
    
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


@implementation AtlasDemo
-(id) init
{
	if( (self = [super init])) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF* label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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

#pragma mark Example Atlas 1

@implementation Atlas1


-(id) init
{
	if( (self=[super init] ) ) {

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
				{{s.width/2-50,200,0},{0,0,255,255},{0.0f,0.0f},},	// top left
				{{s.width,100,0},{255,0,255,255},{1.0f,0.0f},},		// top right
			},

		};


		for( int i=0;i<3;i++) {
			[textureAtlas updateQuad:&quads[i] atIndex:i];
		}
	}

	return self;
}

-(void) dealloc
{
	[textureAtlas release];
	[super dealloc];
}


-(void) draw
{
	// Default client GL state:
	// GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// GL_TEXTURE_2D

	[textureAtlas drawQuads];

//	[textureAtlas drawNumberOfQuads:3];

}

-(NSString *) title
{
	return @"CCTextureAtlas";
}

-(NSString *) subtitle
{
	return @"Manual creation of CCTextureAtlas";
}

@end

#pragma mark Example LabelAtlasTest

@implementation LabelAtlasTest
-(id) init
{
	if( (self=[super init] )) {

		CCLabelAtlas *label1 = [CCLabelAtlas labelWithString:@"123 Test" fntFile:@"tuffy_bold_italic-charmap.plist"];
		[self addChild:label1 z:0 tag:kTagSprite1];
		label1.position = ccp(10,100);
		label1.opacity = 200;

		CCLabelAtlas *label2 = [CCLabelAtlas labelWithString:@"0123456789" fntFile:@"tuffy_bold_italic-charmap.plist"];
		[self addChild:label2 z:0 tag:kTagSprite2];
		label2.position = ccp(10,200);
		label2.opacity = 32;

		[self schedule:@selector(step:)];
	}
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

-(NSString*) title
{
	return @"CCLabelAtlas";
}

-(NSString *) subtitle
{
	return @"Updating label should be fast";
}
@end

#pragma mark Example LabelAtlasColorTest

@implementation LabelAtlasColorTest
-(id) init
{
	if( (self=[super init] )) {

		CCLabelAtlas *label1 = [CCLabelAtlas labelWithString:@"123 Test" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
		[self addChild:label1 z:0 tag:kTagSprite1];
		label1.position = ccp(10,100);
		label1.opacity = 200;

		CCLabelAtlas *label2 = [CCLabelAtlas labelWithString:@"0123456789" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
		[self addChild:label2 z:0 tag:kTagSprite2];
		label2.position = ccp(10,200);
		label2.color = ccRED;

		id fade = [CCFadeOut actionWithDuration:1.0f];
		id fade_in = [fade reverse];
		id call = [CCCallBlock actionWithBlock:^(void) { CCLOG(@"Action finished"); }];
		id seq = [CCSequence actions:fade, fade_in, call, nil];

		id repeat = [CCRepeatForever actionWithAction:seq];
		[label2 runAction:repeat];


		[self schedule:@selector(step:)];
	}
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

-(NSString*) title
{
	return @"CCLabelAtlas";
}

-(NSString *) subtitle
{
	return @"Opacity + Color should work at the same time";
}
@end


#pragma mark LabelTTFAlignment

@implementation LabelTTFAlignment
-(id) init
{
	if( (self=[super init] )) {
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* ttf0 = [CCLabelTTF labelWithString:@"Alignment 0\nnew line" fontName:@"Helvetica" fontSize:12 dimensions:CGSizeMake(256, 32)];
        ttf0.horizontalAlignment = 0;
        ttf0.position = ccp(s.width/2,(s.height/6)*2);
        ttf0.anchorPoint = ccp(0.5f,0.5f);
        [self addChild:ttf0];
        
        CCLabelTTF* ttf1 = [CCLabelTTF labelWithString:@"Alignment 1\nnew line" fontName:@"Helvetica" fontSize:12 dimensions:CGSizeMake(256, 32)];
        ttf1.horizontalAlignment = 1;
        ttf1.position = ccp(s.width/2,(s.height/6)*3);
        ttf1.anchorPoint = ccp(0.5f,0.5f);
        [self addChild:ttf1];
        
        CCLabelTTF* ttf2 = [CCLabelTTF labelWithString:@"Alignment 2\nnew line" fontName:@"Helvetica" fontSize:12 dimensions:CGSizeMake(256, 32)];
        ttf2.horizontalAlignment = 2;
        ttf2.position = ccp(s.width/2,(s.height/6)*4);
        ttf2.anchorPoint = ccp(0.5f,0.5f);
        [self addChild:ttf2];

	}
	return self;
}



-(void) dealloc
{
	[super dealloc];
}

-(NSString*) title
{
	return @"CCLabelTTF alignment";
}

-(NSString *) subtitle
{
	return @"Tests alignment values for Mac/iOS";
}
@end



#pragma mark Example Atlas3

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */
@implementation Atlas3
-(id) init
{
	if( (self=[super init]) ) {

		CCLayerColor *col = [CCLayerColor layerWithColor:ccc4(128,128,128,255)];
		[self addChild:col z:-10];

		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];

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
		CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];
		// testing anchors
		label2.anchorPoint = ccp(0.5f, 0.5f);
		label2.color = ccRED;
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		[label2 runAction: [[repeat copy] autorelease]];

		CCLabelBMFont *label3 = [CCLabelBMFont labelWithString:@"Test" fntFile:@"bitmapFontTest2.fnt"];
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

	CCLabelBMFont *label1 = (CCLabelBMFont*) [self getChildByTag:kTagBitmapAtlas1];
	[label1 setString:string];

	CCLabelBMFont *label2 = (CCLabelBMFont*) [self getChildByTag:kTagBitmapAtlas2];
	[label2 setString:string];

	CCLabelBMFont *label3 = (CCLabelBMFont*) [self getChildByTag:kTagBitmapAtlas3];
	[label3 setString:string];
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Testing alignment. Testing opacity + tint";
}

@end

#pragma mark Example Atlas4

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation Atlas4
-(id) init
{
	if( (self=[super init]) ) {

		// Upper Label
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"BMFont label" fntFile:@"bitmapFontTest.fnt"];
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
		CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"00.0" fntFile:@"bitmapFontTest.fnt"];
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

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%04.1f", time];

	CCLabelBMFont *label1 = (CCLabelBMFont*) [self getChildByTag:kTagBitmapAtlas2];
	[label1 setString:string];
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Using fonts as CCSprite objects. Some characters should rotate.";
}
@end


#pragma mark Example Atlas5

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation Atlas5
-(id) init
{
	if( (self=[super init]) ) {

		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"abcdefg" fntFile:@"bitmapFontTest4.fnt"];
		[self addChild:label];

		CGSize s = [[CCDirector sharedDirector] winSize];

		label.position = ccp(s.width/2, s.height/2);
		label.anchorPoint = ccp(0.5f, 0.5f);
	}

	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Testing padding";
}

@end

#pragma mark -
#pragma mark Example Atlas6

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation Atlas6
-(id) init
{
	if( (self=[super init]) ) {

        CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelBMFont *label = nil;
		label = [CCLabelBMFont labelWithString:@"FaFeFiFoFu" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2+50);
		label.anchorPoint = ccp(0.5f, 0.5f);

		label = [CCLabelBMFont labelWithString:@"fafefifofu" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2);
		label.anchorPoint = ccp(0.5f, 0.5f);

		label = [CCLabelBMFont labelWithString:@"aeiou" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/2-50);
		label.anchorPoint = ccp(0.5f, 0.5f);

	}

	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Rendering should be OK. Testing offset";
}

@end

#pragma mark -
#pragma mark Example AtlasBitmapColor

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation AtlasBitmapColor
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelBMFont *label = nil;
		label = [CCLabelBMFont labelWithString:@"Blue" fntFile:@"bitmapFontTest5.fnt"];
		label.color = ccBLUE;
		[self addChild:label];
		label.position = ccp(s.width/2, s.height/4);
		label.anchorPoint = ccp(0.5f, 0.5f);

		label = [CCLabelBMFont labelWithString:@"Red" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, 2*s.height/4);
		label.anchorPoint = ccp(0.5f, 0.5f);
		label.color = ccRED;

		label = [CCLabelBMFont labelWithString:@"G" fntFile:@"bitmapFontTest5.fnt"];
		[self addChild:label];
		label.position = ccp(s.width/2, 3*s.height/4);
		label.anchorPoint = ccp(0.5f, 0.5f);
		label.color = ccGREEN;
		[label setString: @"Green"];

	}

	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Testing color";
}

@end

#pragma mark -
#pragma mark Example AtlasFastBitmap

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation AtlasFastBitmap
-(id) init
{
	if( (self=[super init]) ) {

		// Upper Label
		for( int i=0 ; i < 100;i ++ ) {
			CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"-%d-",i] fntFile:@"bitmapFontTest.fnt"];
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
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Creating several CCLabelBMFont with the same .fnt file should be fast";
}

@end

#pragma mark -
#pragma mark BitmapFontMultiLine

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

@implementation BitmapFontMultiLine
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s;

		// Left
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Multi line\nLeft" fntFile:@"bitmapFontTest3.fnt"];
		label1.anchorPoint = ccp(0,0);
		[self addChild:label1 z:0 tag:kTagBitmapAtlas1];

		s = [label1 contentSize];
		NSLog(@"content size: %.2fx%.2f", s.width, s.height);


		// Center
		CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"Multi line\nCenter" fntFile:@"bitmapFontTest3.fnt"];
		label2.anchorPoint = ccp(0.5f, 0.5f);
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];

		s = [label2 contentSize];
		NSLog(@"content size: %.2fx%.2f", s.width, s.height);


		// right
		CCLabelBMFont *label3 = [CCLabelBMFont labelWithString:@"Multi line\nRight\nThree lines Three" fntFile:@"bitmapFontTest3.fnt"];
		label3.anchorPoint = ccp(1,1);
		[self addChild:label3 z:0 tag:kTagBitmapAtlas3];

		s = [label3 contentSize];
		NSLog(@"content size: %.2fx%.2f", s.width, s.height);


		s = [[CCDirector sharedDirector] winSize];
		label1.position = ccp( 0,0);
		label2.position = ccp( s.width/2, s.height/2);
		label3.position = ccp( s.width, s.height);
	}

	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont";
}

-(NSString *) subtitle
{
	return @"Multiline + anchor point";
}

@end

#pragma mark -
#pragma mark BitmapFontMultiLineAlignment

/*
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#define LongSentencesExample @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
#define LineBreaksExample @"Lorem ipsum dolor\nsit amet\nconsectetur adipisicing elit\nblah\nblah"
#define MixedExample @"ABC\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt\nDEF"

#define ArrowsMax 0.95
#define ArrowsMin 0.7

#define LeftAlign 0
#define CenterAlign 1
#define RightAlign 2

#define LongSentences 0
#define LineBreaks 1
#define Mixed 2

static float alignmentItemPadding = 50;
static float menuItemPaddingCenter = 50;


@implementation BitmapFontMultiLineAlignment

@synthesize label = label_;
@synthesize arrowsBar = arrowsBar_;
@synthesize arrows = arrows_;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

		// create and initialize a Label
		self.label = [CCLabelBMFont labelWithString:LongSentencesExample fntFile:@"markerFelt.fnt" width:size.width/1.5 alignment:kCCTextAlignmentCenter];
        //self.label.debug = YES;

        self.arrowsBar = [CCSprite spriteWithFile:@"arrowsBar.png"];
        self.arrows = [CCSprite spriteWithFile:@"arrows.png"];

        [CCMenuItemFont setFontSize:20];
        CCMenuItemFont *longSentences = [CCMenuItemFont itemWithString:@"Long Flowing Sentences" target:self selector:@selector(stringChanged:)];
        CCMenuItemFont *lineBreaks = [CCMenuItemFont itemWithString:@"Short Sentences With Intentional Line Breaks" target:self selector:@selector(stringChanged:)];
        CCMenuItemFont *mixed = [CCMenuItemFont itemWithString:@"Long Sentences Mixed With Intentional Line Breaks" target:self selector:@selector(stringChanged:)];
        CCMenu *stringMenu = [CCMenu menuWithItems:longSentences, lineBreaks, mixed, nil];
        [stringMenu alignItemsVertically];

        [longSentences setColor:ccRED];
        lastSentenceItem_ = longSentences;
        longSentences.tag = LongSentences;
        lineBreaks.tag = LineBreaks;
        mixed.tag = Mixed;

        [CCMenuItemFont setFontSize:30];

        CCMenuItemFont *left = [CCMenuItemFont itemWithString:@"Left" target:self selector:@selector(alignmentChanged:)];
        CCMenuItemFont *center = [CCMenuItemFont itemWithString:@"Center" target:self selector:@selector(alignmentChanged:)];
        CCMenuItemFont *right = [CCMenuItemFont itemWithString:@"Right" target:self selector:@selector(alignmentChanged:)];
        CCMenu *alignmentMenu = [CCMenu menuWithItems:left, center, right, nil];
        [alignmentMenu alignItemsHorizontallyWithPadding:alignmentItemPadding];

        [center setColor:ccRED];
        lastAlignmentItem_ = center;
        left.tag = LeftAlign;
        center.tag = CenterAlign;
        right.tag = RightAlign;

		// position the label on the center of the screen
		self.label.position =  ccp( size.width/2 , size.height/2 );

        self.arrowsBar.visible = NO;

        float arrowsWidth = (ArrowsMax - ArrowsMin) * size.width;
        self.arrowsBar.scaleX = arrowsWidth / self.arrowsBar.contentSize.width;
        self.arrowsBar.position = ccp(((ArrowsMax + ArrowsMin) / 2) * size.width, self.label.position.y);

        [self snapArrowsToEdge];

        stringMenu.position = ccp(size.width/2, size.height - menuItemPaddingCenter);
        alignmentMenu.position = ccp(size.width/2, menuItemPaddingCenter+15);

		// add the label as a child to this Layer
		[self addChild:self.label];
        [self addChild:self.arrowsBar];
        [self addChild:self.arrows];
        [self addChild:stringMenu];
        [self addChild:alignmentMenu];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    self.label = nil;
    self.arrows = nil;
    self.arrowsBar = nil;

	[super dealloc];
}

#pragma mark Action Methods

- (void)stringChanged:(id)sender {
    CCMenuItemFont *item = sender;
    [item setColor:ccRED];
    [lastSentenceItem_ setColor:ccWHITE];
    lastSentenceItem_ = item;

    switch (item.tag) {
        case LongSentences:
            [self.label setString:LongSentencesExample];
            break;
        case LineBreaks:
            [self.label setString:LineBreaksExample];
            break;
        case Mixed:
            [self.label setString:MixedExample];
            break;

        default:
            break;
    }

    [self snapArrowsToEdge];
}

- (void)alignmentChanged:(id)sender {
    CCMenuItemFont *item = sender;
    [item setColor:ccRED];
    [lastAlignmentItem_ setColor:ccWHITE];
    lastAlignmentItem_ = item;

    switch (item.tag) {
        case LeftAlign:
            [self.label setAlignment:kCCTextAlignmentLeft];
            break;
        case CenterAlign:
            [self.label setAlignment:kCCTextAlignmentCenter];
            break;
        case RightAlign:
            [self.label setAlignment:kCCTextAlignmentRight];
            break;

        default:
            break;
    }

    [self snapArrowsToEdge];
}

#pragma mark Touch Methods

#ifdef __CC_PLATFORM_IOS
- (void)touchesBegan:( NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [ touches anyObject ];
    CGPoint location = [touch locationInView:[touch view]];

    if (CGRectContainsPoint([self.arrows boundingBox], location)) {
        drag_ = YES;
        self.arrowsBar.visible = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    drag_ = NO;
    [self snapArrowsToEdge];

    self.arrowsBar.visible = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!drag_) return;

    UITouch* touch = [ touches anyObject ];

    CGPoint location = [touch locationInView:[touch view]];

    CGSize winSize = [CCDirector sharedDirector].winSize;

    self.arrows.position = ccp(MAX(MIN(location.x, ArrowsMax*winSize.width), ArrowsMin*winSize.width), self.arrows.position.y);

    float labelWidth = abs(self.arrows.position.x - self.label.position.x) * 2;

    [self.label setWidth:labelWidth];
}

#elif defined(__CC_PLATFORM_MAC)

- (void)mouseDown:(NSEvent *)theEvent
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:theEvent];

    if (CGRectContainsPoint([self.arrows boundingBox], location)) {
        drag_ = YES;
        self.arrowsBar.visible = YES;

    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    drag_ = NO;
    [self snapArrowsToEdge];

    self.arrowsBar.visible = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if ( drag_) {

		CGPoint location = [[CCDirector sharedDirector] convertEventToGL:theEvent];

		CGSize winSize = [CCDirector sharedDirector].winSize;

		self.arrows.position = ccp(MAX(MIN(location.x, ArrowsMax*winSize.width), ArrowsMin*winSize.width), self.arrows.position.y);

		float labelWidth = abs(self.arrows.position.x - self.label.position.x) * 2;

		[self.label setWidth:labelWidth];

	}
}

#endif // __CC_PLATFORM_MAC

- (void)snapArrowsToEdge {
    self.arrows.position = ccp(self.label.position.x + self.label.contentSize.width/2, self.label.position.y);
}

-(NSString*) title
{
	return @"";
}

-(NSString *) subtitle
{
	return @"";
}

@end


#pragma mark -
#pragma mark LabelsEmpty

@implementation LabelsEmpty
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// CCLabelBMFont
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"" fntFile:@"bitmapFontTest3.fnt"];
		[self addChild:label1 z:0 tag:kTagBitmapAtlas1];
		[label1 setPosition: ccp(s.width/2, s.height-100)];


		// CCLabelTTF
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:24];
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		[label2 setPosition: ccp(s.width/2, s.height/2) ];

		// CCLabelAtlas
		CCLabelAtlas *label3 = [CCLabelAtlas labelWithString:@"" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
		[self addChild:label3 z:0 tag:kTagBitmapAtlas3];
		label3.position = ccp(s.width/2, 0+100);


		[self schedule:@selector(updateStrings:) interval:1];

		setEmpty = NO;

	}

	return self;
}

-(void) updateStrings:(ccTime)dt
{
	id<CCLabelProtocol> label1 = (id<CCLabelProtocol>) [self getChildByTag:kTagBitmapAtlas1];
	id<CCLabelProtocol> label2 = (id<CCLabelProtocol>) [self getChildByTag:kTagBitmapAtlas2];
	id<CCLabelProtocol> label3 = (id<CCLabelProtocol>) [self getChildByTag:kTagBitmapAtlas3];

	if( ! setEmpty ) {
		[label1 setString: @"not empty"];
		[label2 setString: @"not empty"];
		[label3 setString: @"hi"];

		setEmpty = YES;

	} else {

		[label1 setString:@""];
		[label2 setString:@""];
		[label3 setString:@""];

		setEmpty = NO;
	}

}

-(NSString*) title
{
	return @"Testing empty labels";
}

-(NSString *) subtitle
{
	return @"3 empty labels: LabelAtlas, LabelTTF and LabelBMFont";
}

@end

#pragma mark -
#pragma mark LabelBMFontHD

@implementation LabelBMFontHD
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// CCLabelBMFont
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"TESTING RETINA DISPLAY" fntFile:@"konqa32.fnt"];
		[self addChild:label1];
		[label1 setPosition: ccp(s.width/2, s.height/2)];

	}

	return self;
}

-(NSString*) title
{
	return @"Testing Retina Display BMFont";
}

-(NSString *) subtitle
{
	return @"loading arista16 or arista16-hd";
}

@end

#pragma mark -
#pragma mark LabelAtlasHD

@implementation LabelAtlasHD
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// CCLabelBMFont
		CCLabelAtlas *label1 = [CCLabelAtlas labelWithString:@"TESTING RETINA DISPLAY" fntFile:@"larabie-16.plist"];
		label1.anchorPoint = ccp(0.5f, 0.5f);

		[self addChild:label1];
		[label1 setPosition: ccp(s.width/2, s.height/2)];

	}

	return self;
}

-(NSString*) title
{
	return @"LabelAtlas with Retina Display";
}

-(NSString *) subtitle
{
	return @"loading larabie-16 / larabie-16-hd";
}

@end

#pragma mark -
#pragma mark LabelBMFontBounds

@implementation LabelBMFontBounds
-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
		CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(128,128,128,255)];
		[self addChild:layer z:-10];
        
		// CCLabelBMFont
		label1 = [CCLabelBMFont labelWithString:@"Testing Glyph Designer" fntFile:@"boundsTestFont.fnt"];
        
		[self addChild:label1];
		[label1 setPosition: ccp(s.width/2, s.height/2)];
        
	}
    
	return self;
}

- (void)draw
{
    CGSize labelSize = [label1 contentSize];
    CGSize origin = [[CCDirector sharedDirector] winSize];
    
    origin.width = origin.width / 2 - (labelSize.width / 2);
    origin.height = origin.height / 2 - (labelSize.height / 2);
    
    CGPoint vertices[4]={
        ccp(origin.width, origin.height),
        ccp(labelSize.width + origin.width, origin.height),
        ccp(labelSize.width + origin.width, labelSize.height + origin.height),
        ccp(origin.width, labelSize.height + origin.height)
    };
    ccDrawPoly(vertices, 4, YES);
    
}

-(NSString*) title
{
	return @"Testing LabelBMFont Bounds";
}

-(NSString *) subtitle
{
	return @"You should see string enclosed by a box";
}

@end

#pragma mark -
#pragma mark LabelGlyphDesigner

@implementation LabelGlyphDesigner
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(128,128,128,255)];
		[self addChild:layer z:-10];

		// CCLabelBMFont
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Testing Glyph Designer" fntFile:@"futura-48.fnt"];
        
		[self addChild:label1];
		[label1 setPosition: ccp(s.width/2, s.height/2)];
        
	}

	return self;
}

-(NSString*) title
{
	return @"Testing Glyph Designer";
}

-(NSString *) subtitle
{
	return @"You should see a font with shadows and outline";
}

@end

#pragma mark -
#pragma mark LabelTTFTest

@interface LabelTTFTest ()

- (void) updateAlignment;

- (NSString*) currentAlignment;

@end

@implementation LabelTTFTest

@synthesize label = label_;

-(id) init
{
	if( (self=[super init]) ) {

        CGSize blockSize = CGSizeMake(200, 160);
		CGSize s = [[CCDirector sharedDirector] winSize];

        CCLayerColor *colorLayer = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 255) width:blockSize.width height:blockSize.height];
        colorLayer.anchorPoint = ccp(0,0);
        colorLayer.position = ccp((s.width - blockSize.width) / 2, (s.height - blockSize.height) / 2);

        [self addChild:colorLayer];

        [CCMenuItemFont setFontSize:30];
        CCMenu *menu;

        menu = [CCMenu menuWithItems:
                [CCMenuItemFont itemWithString:@"Left" target:self selector:@selector(setAlignmentLeft)],
                [CCMenuItemFont itemWithString:@"Center" target:self selector:@selector(setAlignmentCenter)],
                [CCMenuItemFont itemWithString:@"Right" target:self selector:@selector(setAlignmentRight)],
                nil];
        [menu alignItemsVerticallyWithPadding:4];
        menu.position = ccp(50, s.height / 2 - 20);
        [self addChild:menu];
        
        menu = [CCMenu menuWithItems:
                [CCMenuItemFont itemWithString:@"Top" target:self selector:@selector(setAlignmentTop)],
                [CCMenuItemFont itemWithString:@"Middle" target:self selector:@selector(setAlignmentMiddle)],
                [CCMenuItemFont itemWithString:@"Bottom" target:self selector:@selector(setAlignmentBottom)],
                nil];
        [menu alignItemsVerticallyWithPadding:4];
        menu.position = ccp(s.width - 50, s.height / 2 - 20);
        [self addChild:menu];
        
        horizAlign = kCCTextAlignmentLeft;
        vertAlign = kCCVerticalTextAlignmentTop;
        
        [self updateAlignment];
	}

	return self;
}

- (void)dealloc
{
    [label_ release];
    [super dealloc];
}

- (void) updateAlignment
{
    CGSize blockSize = CGSizeMake(200, 160);
    CGSize s = [[CCDirector sharedDirector] winSize];

    [self.label removeFromParentAndCleanup:YES];
    self.label = [CCLabelTTF labelWithString:[self currentAlignment]
									fontName:@"Marker Felt"
                                    fontSize:32
                                  dimensions:blockSize
				  ];
    self.label.horizontalAlignment = horizAlign;
    self.label.verticalAlignment = vertAlign;
    self.label.anchorPoint = ccp(0,0);
    self.label.position = ccp((s.width - blockSize.width) / 2, (s.height - blockSize.height)/2 );
    
    [self addChild:self.label];
}

- (void) setAlignmentLeft
{
    horizAlign = kCCTextAlignmentLeft;
    [self updateAlignment];
}

- (void) setAlignmentCenter
{
    horizAlign = kCCTextAlignmentCenter;
    [self updateAlignment];
}

- (void) setAlignmentRight
{
    horizAlign = kCCTextAlignmentRight;
    [self updateAlignment];
}

- (void) setAlignmentTop
{
    vertAlign = kCCVerticalTextAlignmentTop;
    [self updateAlignment];
}

- (void) setAlignmentMiddle
{
    vertAlign = kCCVerticalTextAlignmentCenter;
    [self updateAlignment];
}

- (void) setAlignmentBottom
{
    vertAlign = kCCVerticalTextAlignmentBottom;
    [self updateAlignment];
}


- (NSString*) currentAlignment
{
    NSString* vertical = nil;
    NSString* horizontal = nil;
    switch (vertAlign) {
        case kCCVerticalTextAlignmentTop:
            vertical = @"Top";
            break;
        case kCCVerticalTextAlignmentCenter:
            vertical = @"Middle";
            break;
        case kCCVerticalTextAlignmentBottom:
            vertical = @"Bottom";
            break;
    }
    switch (horizAlign) {
        case kCCTextAlignmentLeft:
            horizontal = @"Left";
            break;
        case kCCTextAlignmentCenter:
            horizontal = @"Center";
            break;
        case kCCTextAlignmentRight:
            horizontal = @"Right";
            break;
    }
    
    return [NSString stringWithFormat:@"Alignment %@ %@", vertical, horizontal];
}

-(NSString*) title
{
	return @"Testing CCLabelTTF";
}

-(NSString *) subtitle
{
	return @"Select the buttons on the sides to change alignment";
}

@end



#pragma mark -
#pragma mark LabelTTFShadowStroke

@implementation LabelTTFShadowStroke
-(id) init
{
	if( (self=[super init]) ) {
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(0,190,0,255) width:s.width height:s.height];
        [self addChild:layer];
        
        CCLabelTTF *shadowLabel =[CCLabelTTF labelWithString:@"Shadow" fontName:@"Helvetica" fontSize:32];
        shadowLabel.shadowColor = ccc4(0, 0, 0, 255);
        shadowLabel.shadowBlurRadius = 3;
        shadowLabel.shadowOffset = ccp(0, -3);
		shadowLabel.position = ccp(s.width/2,s.height/2 + 50);
		[self addChild:shadowLabel];
        
        CCLabelTTF *strokeLabel =[CCLabelTTF labelWithString:@"Stroke" fontName:@"Helvetica" fontSize:32];
		strokeLabel.position = ccp(s.width/2,s.height/2 );
        strokeLabel.outlineColor = ccc4(255, 0, 0, 255);
        strokeLabel.outlineWidth = 2;
		[self addChild:strokeLabel];
        
        CCLabelTTF *strokeShadowLabel =[CCLabelTTF labelWithString:@"Shadow & Stroke" fontName:@"Helvetica" fontSize:32];
		strokeShadowLabel.position = ccp(s.width/2,s.height/2 - 50);
        strokeShadowLabel.outlineColor = ccc4(255, 0, 0, 255);
        strokeShadowLabel.outlineWidth = 3;
        strokeShadowLabel.shadowColor = ccc4(0, 0, 0, 255);
        strokeShadowLabel.shadowBlurRadius = 3;
        strokeShadowLabel.shadowOffset = ccp(0, -3);
        strokeShadowLabel.fontColor = ccc4(255, 255, 0, 255);
		[self addChild:strokeShadowLabel];
	}
    
	return self;
}

-(NSString*) title
{
	return @"Testing CCLabelTTF Shadow Stroke";
}

-(NSString *) subtitle
{
	return @"";
}
@end




#pragma mark -
#pragma mark LabelTTFMultiline

@implementation LabelTTFMultiline
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// CCLabelBMFont
//		CCLabelTTF *center =  [[CCLabelTTF alloc] initWithString:@"Bla bla bla bla bla bla bla bla bla bla bla (bla)" dimensions:CGSizeMake(150,84) alignment:UITextAlignmentLeft fontName: @"MarkerFelt.ttc" fontSize: 14];

		CCLabelTTF *center = [CCLabelTTF labelWithString:@"word wrap \"testing\" (bla0) bla1 'bla2' [bla3] (bla4) {bla5} {bla6} [bla7] (bla8) [bla9] 'bla0' \"bla1\""
												fontName:@"Paint Boy"
												fontSize:32
											  dimensions:CGSizeMake(s.width/2,200)
							  ];
        center.horizontalAlignment = kCCTextAlignmentCenter;
        center.verticalAlignment = kCCVerticalTextAlignmentTop;
		center.position = ccp(s.width/2,150);

		[self addChild:center];
	}

	return self;
}

-(NSString*) title
{
	return @"Testing CCLabelTTF Word Wrap";
}

-(NSString *) subtitle
{
	return @"Word wrap using CCLabelTTF and a custom TTF font";
}
@end

#pragma mark -
#pragma mark LabelTTFMultiline2

@implementation LabelTTFMultiline2
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Line 1\nThis is line 2\nAnd this is line 3" fontName:@"Marker Felt" fontSize:32];
		label.position = ccp(s.width/2,s.height/2);
		
		[self addChild:label];
	}
	
	return self;
}

-(NSString*) title
{
	return @"Testing CCLabelTTF multiline";
}

-(NSString *) subtitle
{
	return @"Multiline wihtout dimensions";
}
@end


#pragma mark -
#pragma mark LabelTTFA8Test

@implementation LabelTTFA8Test
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(128,128,128,255)];
		[self addChild:layer z:-10];

		// CCLabelBMFont
		CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Testing A8 Format" fontName:@"Marker Felt" fontSize:48];
		[self addChild:label1];
		[label1 setColor:ccRED];
		[label1 setPosition: ccp(s.width/2, s.height/2)];

		CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:2];
		CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:2];
		CCSequence *seq = [CCSequence actions:fadeOut, fadeIn, nil];
		CCRepeatForever *forever = [CCRepeatForever actionWithAction:seq];
		[label1 runAction:forever];
	}

	return self;
}

-(NSString*) title
{
	return @"Testing A8 Format";
}

-(NSString *) subtitle
{
	return @"RED label, fading In and Out in the center of the screen";
}
@end


#pragma mark -
#pragma mark LabelTTFScaleToFit

@implementation LabelTTFScaleToFit
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

        CCLabelTTF *lbl0 = [CCLabelTTF labelWithString:@"Label"
												  fontName:@"Marker Felt"
												  fontSize:16
												dimensions:CGSizeMake(80,20)
								];
		lbl0.position = ccp(s.width/2,s.height/2 + 40);
        lbl0.adjustsFontSizeToFit = YES;
        lbl0.horizontalAlignment = kCCTextAlignmentCenter;
        lbl0.verticalAlignment = kCCVerticalTextAlignmentCenter;
        [self addChild:lbl0];
        
        
        CCLabelTTF *lbl1 = [CCLabelTTF labelWithString:@"This is a long label"
                                              fontName:@"Marker Felt"
                                              fontSize:16
                                            dimensions:CGSizeMake(80,20)
                            ];
		lbl1.position = ccp(s.width/2,s.height/2);
        lbl1.adjustsFontSizeToFit = YES;
        lbl1.horizontalAlignment = kCCTextAlignmentCenter;
        lbl1.verticalAlignment = kCCVerticalTextAlignmentCenter;
        [self addChild:lbl1];
        
        
        CCLabelTTF *lbl2 = [CCLabelTTF labelWithString:@"Label\nNew line"
                                              fontName:@"Marker Felt"
                                              fontSize:16
                                            dimensions:CGSizeMake(80,20)
                            ];
		lbl2.position = ccp(s.width/2,s.height/2 - 40);
        lbl2.horizontalAlignment = kCCTextAlignmentCenter;
        lbl2.verticalAlignment = kCCVerticalTextAlignmentCenter;
        lbl2.adjustsFontSizeToFit = YES;
        [self addChild:lbl2];
	}

	return self;
}

-(NSString*) title
{
	return @"CCLabelTTF Size to Fit";
}

-(NSString *) subtitle
{
    return @"Tests adjustsFontSizeToFit property";
}
@end

#pragma mark - BMFontOneAtlas

@implementation BMFontOneAtlas
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
	
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"This is Helvetica" fntFile:@"helvetica-32.fnt" width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft imageOffset:CGPointZero];
		[self addChild:label1];
		[label1 setPosition:ccp(s.width/2,s.height/3*2)];

		CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"And this is Geneva" fntFile:@"geneva-32.fnt" width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft imageOffset:ccp(0,128)];		
		[self addChild:label2];
		[label2 setPosition:ccp(s.width/2,s.height/3*1)];
	}
	
	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont with one texture";
}

-(NSString *) subtitle
{
	return @"Using 2 .fnt definitions that share the same texture atlas.";
}
@end

#pragma mark - BMFontUnicode

@implementation BMFontUnicode
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Buen día" fntFile:@"arial-unicode-26.fnt"];
		[self addChild:label1];
		[label1 setPosition:ccp(s.width/2,s.height/4*3)];

		CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"美好的一天" fntFile:@"arial-unicode-26.fnt"];
		[self addChild:label2];
		[label2 setPosition:ccp(s.width/2,s.height/4*2)];

		CCLabelBMFont *label3 = [CCLabelBMFont labelWithString:@"良い一日を" fntFile:@"arial-unicode-26.fnt"];
		[self addChild:label3];
		[label3 setPosition:ccp(s.width/2,s.height/4*1)];

	}
	
	return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont with Unicode support";
}

-(NSString *) subtitle
{
	return @"You should see 3 differnt labels: In Spanish, Chinese and Korean";
}
@end


#pragma mark - BMFontInit

@implementation BMFontInit

- (id) init
{
    if( (self=[super init]) ) {
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLabelBMFont* bmFont = [[[CCLabelBMFont alloc] init] autorelease];
        //CCLabelBMFont* bmFont = [CCLabelBMFont labelWithString:@"Foo" fntFile:@"arial-unicode-26.fnt"];
        bmFont.fntFile = @"helvetica-32.fnt";
        bmFont.string = @"It is working!";
        [self addChild:bmFont];
        [bmFont setPosition:ccp(s.width/2,s.height/4*2)];
    }
    return self;
}

-(NSString*) title
{
	return @"CCLabelBMFont init";
}

-(NSString *) subtitle
{
	return @"Test for support of init method without parameters.";
}
@end

#pragma mark - TTFFontInit

@implementation TTFFontInit

- (id) init
{
    if( (self=[super init]) ) {
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* font = [[[CCLabelTTF alloc] init] autorelease];
        font.fontName = @"Marker Felt";
		font.fontSize = 48;
        font.string = @"It is working!";
        [self addChild:font];
        [font setPosition:ccp(s.width/2,s.height/4*2)];
    }
    return self;
}

-(NSString*) title
{
	return @"CCLabelTTF init";
}

-(NSString *) subtitle
{
	return @"Test for support of init method without parameters.";
}
@end


#pragma mark - Issue1343

@implementation Issue1343

- (id) init
{
    if( (self=[super init]) ) {
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLabelBMFont* bmFont = [[CCLabelBMFont alloc] init];
        bmFont.fntFile = @"font-issue1343.fnt";
        bmFont.string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz.,'";
        [self addChild:bmFont];
		[bmFont release];
		bmFont.scale = 0.3f;
	
        [bmFont setPosition:ccp(s.width/2,s.height/4*2)];
    }
    return self;
}

-(NSString*) title
{
	return @"Issue 1343";
}

-(NSString *) subtitle
{
	return @"You should see: ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz.,'";
}
@end


#pragma mark -
#pragma mark Application Delegate - iPhone

// CLASS IMPLEMENTATIONS

#ifdef __CC_PLATFORM_IOS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];
	
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

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

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end


#elif defined(__CC_PLATFORM_MAC)

#pragma mark AppController - Mac

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

