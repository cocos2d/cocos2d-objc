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

-(id) init
{
	if ((self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

#if 1
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

#if 1
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

#if 1
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
		
#if 1
		{
			// particle. Works OK
			CCParticleSystem *particle = [CCParticleFlower node];
			particle.position = ccp(80, s.height/2);
			[self addChild:particle z:10];
		}
#endif

#if 1
		{
			// particle designer. Works OK
			CCParticleSystem *particle = [CCParticleSystemQuad particleWithFile:@"Particles/SpookyPeas.plist"];
			particle.position = ccp(s.width, s.height/2);
			[self addChild:particle z:10];
		}
#endif
		
		
#if 1
		{
			// BMFont. Works OK.
			CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"cocos2d for Mac" fntFile:@"bitmapFontTest4.fnt"];
			label.position = ccp(s.width/2, s.height-80);
			[self addChild:label];
		}
#endif
		
		
#if 1
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
		
#if 1
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

@synthesize window, glView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	
	CCDirector *director = [CCDirector sharedDirector];

	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView];
	
//	[director setProjection:kCCDirectorProjection2D];
	
	CCScene *scene = [CCScene node];
	MyLayer *layer = [MyLayer node];
	[scene addChild:layer];
	
	[director runWithScene:scene];
}

@end
