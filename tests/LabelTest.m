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
	@"LabelsEmpty",
	@"LabelBMFontHD",
	@"LabelAtlasHD",
	@"LabelGlyphDesigner",
	@"LabelTTFTest",
	@"LabelTTFMultiline",
	
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
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
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
	
		CCLabelAtlas *label1 = [CCLabelAtlas labelWithString:@"123 Test" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
		[self addChild:label1 z:0 tag:kTagSprite1];
		label1.position = ccp(10,100);
		label1.opacity = 200;

		CCLabelAtlas *label2 = [CCLabelAtlas labelWithString:@"0123456789" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
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
		id seq = [CCSequence actions:fade, fade_in, nil];
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



#pragma mark Example Atlas3

/*
 * Use any of these editors to generate BMFont labels:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
 * Use any of these editors to generate BMFont labels:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
 * Use any of these editors to generate BMFont labels:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
 * Use any of these editors to generate BMFont label:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
 * Use any of these editors to generate BMFont label:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
 * Use any of these editors to generate BMFont label:
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
 * Use any of these editors to generate BMFont label:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
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
	return @"3 empty labels: LabelAtlas, Label and BitmapFontAtlas";
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
		CCLabelAtlas *label1 = [CCLabelAtlas labelWithString:@"TESTING RETINA DISPLAY" charMapFile:@"larabie-16.png" itemWidth:10 itemHeight:20 startCharMap:'A'];
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

@implementation LabelTTFTest
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// CCLabelBMFont
		CCLabelTTF *left = [CCLabelTTF labelWithString:@"alignment left" dimensions:CGSizeMake(s.width,50) alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:32];
		CCLabelTTF *center = [CCLabelTTF labelWithString:@"alignment center" dimensions:CGSizeMake(s.width,50) alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:32];
		CCLabelTTF *right = [CCLabelTTF labelWithString:@"alignment right" dimensions:CGSizeMake(s.width,50) alignment:CCTextAlignmentRight fontName:@"Marker Felt" fontSize:32];

		left.position = ccp(s.width/2,200);
		center.position = ccp(s.width/2,150);
		right.position = ccp(s.width/2,100);
		
		[self addChild:left];
		[self addChild:right];
		[self addChild:center];
	}
	
	return self;
}

-(NSString*) title
{
	return @"Testing CCLabelTTF";
}

-(NSString *) subtitle
{
	return @"You should see 3 labels aligned left, center and right";
}

@end

#pragma mark -
#pragma mark LabelTTFMultiline

@implementation LabelTTFMultiline
-(id) init
{
	if( (self=[super init]) ) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// CCLabelBMFont
//		CCLabelTTF *center =  [[CCLabelTTF alloc] initWithString:@"Bla bla bla bla bla bla bla bla bla bla bla (bla)" dimensions:CGSizeMake(150,84) alignment:UITextAlignmentLeft fontName: @"MarkerFelt.ttc" fontSize: 14];

		CCLabelTTF *center = [CCLabelTTF labelWithString:@"word wrap \"testing\" (bla0) bla1 'bla2' [bla3] (bla4) {bla5} {bla6} [bla7] (bla8) [bla9] 'bla0' \"bla1\"" dimensions:CGSizeMake(s.width/2,200) alignment:CCTextAlignmentCenter fontName:@"MarkerFelt.ttc" fontSize:32];
		center.position = ccp(s.width/2,150);
		
		[self addChild:center];
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
	}
	
	return self;
}

-(NSString*) title
{
	return @"Testing CCLabelTTF Word Wrap";
}

-(NSString *) subtitle
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return @"Word wrap using CCLabelTTF";
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	return @"Custom TTF are not supported in Mac OS X";
#endif
}

@end



#pragma mark -
#pragma mark Application Delegate - iPhone

// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director runWithScene: scene];
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

// sent to background
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// sent to foreground
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
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


#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark AppController - Mac

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif

