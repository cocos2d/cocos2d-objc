//
//  cocos2dmacAppDelegate.m
//  cocos2d-mac
//
//  Created by Ricardo Quesada on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2dmacAppDelegate.h"

#import "cocos2d.h"

@implementation MyLayer

-(void) menuCallback:(id)sender
{
}

-(id) init
{
	if ((self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

#if 1
		{
			// menu.
			[CCMenuItemFont setFontSize:30];
			[CCMenuItemFont setFontName: @"Courier New"];
			
			// Font Item
			
			CCSprite *spriteNormal = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*2,115,23)];
			CCSprite *spriteSelected = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*1,115,23)];
			CCSprite *spriteDisabled = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*0,115,23)];
			CCMenuItemSprite *item1 = [CCMenuItemSprite itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:self selector:@selector(menuCallback:)];
			
			// Image Item
			CCMenuItem *item2 = [CCMenuItemImage itemFromNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" target:self selector:@selector(menuCallback:)];
			
			// Label Item (LabelAtlas)
			CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0123456789" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
			CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:labelAtlas target:self selector:@selector(menuCallback:)];
			item3.disabledColor = ccc3(32,32,64);
			item3.color = ccc3(200,200,255);
			
			
			// Font Item
			CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallback:)];
			
			// Label Item (BitmapFontAtlas)
			CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"configuration" fntFile:@"bitmapFontTest3.fnt"];
			CCMenuItemLabel *item5 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(menuCallback:)];
			
			// Testing issue #500
			item5.scale = 0.8f;
			
			// Font Item
			CCMenuItemFont *item6 = [CCMenuItemFont itemFromString: @"Quit" target:self selector:@selector(menuCallback:)];
			
			id color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
			id color_back = [color_action reverse];
			id seq = [CCSequence actions:color_action, color_back, nil];
			[item6 runAction:[CCRepeatForever actionWithAction:seq]];
			
			CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, item4, item5, item6, nil];
			[menu alignItemsVertically];
			
			
			// elastic effect
			int i=0;
			for( CCNode *child in [menu children] ) {
				CGPoint dstPoint = child.position;
				int offset = s.width/2 + 50;
				if( i % 2 == 0)
					offset = -offset;
				child.position = ccp( dstPoint.x + offset, dstPoint.y);
				[child runAction: 
				 [CCEaseElasticOut actionWithAction:
				  [CCMoveBy actionWithDuration:2 position:ccp(dstPoint.x - offset,0)]
											 period: 0.35f]
				 ];
				i++;
			}
						
			[self addChild: menu];
		}
#endif
#if 0
		{
			// sprite. Works OK.
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
			sprite.position = ccp(s.width/4, s.height/2);
			[self addChild:sprite];
			
			id rotate = [CCRotateBy actionWithDuration:2 angle:360];
			id forever = [CCRepeatForever actionWithAction:rotate];
			[sprite runAction:forever];
		}
#endif

#if 0
		{
			// Effects. Works OK.			
			CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
			[self addChild:sister1 z:1];
			sister1.position = ccp(s.width/2, s.height/2);
			id sc = [CCScaleBy actionWithDuration:2 scale:5];
			id sc_back = [sc reverse];
			[sister1 runAction: [CCRepeatForever actionWithAction: [CCSequence actions:sc, sc_back, nil]]];
			
			
//			id action = [CCWaves3D actionWithWaves:5 amplitude:40 grid:ccg(15,10) duration:4];
			id action = [CCLiquid actionWithWaves:4 amplitude:20 grid:ccg(16,12) duration:4];
			[sister1 runAction:[CCRepeatForever actionWithAction:action]];

		}
#endif

#if 0
		{
			// Progress action. Works OK.
			CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];

			CCProgressTimer *sprite = [CCProgressTimer progressWithFile:@"grossinis_sister1.png"];
			sprite.type = kCCProgressTimerTypeRadialCW;
			[self addChild:sprite];
			[sprite setPosition:ccp(s.width-50, s.height/2)];
			[sprite runAction: [CCRepeatForever actionWithAction:to1]];
		}
#endif
		
#if 0
		{
			// particle. Works OK
			CCParticleSystem *particle = [CCParticleFlower node];
			particle.position = ccp(80, s.height/2);
			[self addChild:particle z:10];
		}
#endif

#if 0
		{
			// particle designer. Works OK
			CCParticleSystem *particle = [CCParticleSystemQuad particleWithFile:@"Particles/SpookyPeas.plist"];
			particle.position = ccp(s.width, s.height/2);
			[self addChild:particle z:10];
		}
#endif
		
		
#if 0
		{
			// BMFont. Works OK.
			CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"cocos2d for Mac" fntFile:@"bitmapFontTest4.fnt"];
			label.position = ccp(s.width/2, s.height-80);
			[self addChild:label];
		}
#endif
		
#if 0
		{
			// TTFFont. Works OK.
			CCLabelBMFont *label = [CCLabelTTF labelWithString:@"Hello world" fontName:@"Arial" fontSize:18];
			label.position = ccp(s.width/2, 120);
			[self addChild:label z:12];
			
			// TTFFont alignment. Works OK.
			CCLabelBMFont *left = [CCLabelTTF labelWithString:@"Left" dimensions:CGSizeMake(s.width, 30) alignment:CCTextAlignmentLeft fontName:@"Verdana" fontSize:12];
			left.position = ccp(s.width/2, 80);
			[self addChild:left z:12];
			
			CCLabelBMFont *center = [CCLabelTTF labelWithString:@"Center" dimensions:CGSizeMake(s.width, 30) alignment:CCTextAlignmentCenter fontName:@"Verdana" fontSize:12];
			center.position = ccp(s.width/2, 60);
			[self addChild:center z:12];
			
			CCLabelBMFont *right = [CCLabelTTF labelWithString:@"Right" dimensions:CGSizeMake(s.width, 30) alignment:CCTextAlignmentRight fontName:@"Verdana" fontSize:12];
			right.position = ccp(s.width/2, 40);
			[self addChild:right z:12];
		}
#endif
		
#if 0
		{
			// Tile Map 1. Works OK.
			CCTileMapAtlas *map = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];
			// Convert it to "anti alias" (GL_LINEAR filtering)
			[map.texture setAntiAliasTexParameters];
			
			
			// If you are not going to use the Map, you can free it now
			// NEW since v0.7
			[map releaseMap];
			
			[self addChild:map z:-1];
			
			map.anchorPoint = ccp(0, 0.5f);
			
			CCScaleBy *scale = [CCScaleBy actionWithDuration:4 scale:0.8f];
			CCActionInterval *scaleBack = [scale reverse];
			
			id seq = [CCSequence actions: scale,
					  scaleBack,
					  nil];
			
			[map runAction:[CCRepeatForever actionWithAction:seq]];
		}
#endif
		
#if 0
		{
			// Tile map 2. Works OK.			
			CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test2.tmx"];
			[self addChild:map z:-10];
			
			CGSize s = map.contentSize;
			NSLog(@"ContentSize: %f, %f", s.width,s.height);
			
			for( CCSpriteBatchNode* child in [map children] ) {
				[[child texture] setAntiAliasTexParameters];
			}
			
			float x, y, z;
			[[map camera] eyeX:&x eyeY:&y eyeZ:&z];
			[[map camera] setEyeX:x-200 eyeY:y eyeZ:z+300];		
			
		}		
#endif
		
	}
	
	return self;
}
@end

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	
	CCDirector *director = [CCDirector sharedDirector];

	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	
	CCScene *scene = [CCScene node];
	MyLayer *layer = [MyLayer node];
	[scene addChild:layer];
	
	[director runWithScene:scene];
}

@end
