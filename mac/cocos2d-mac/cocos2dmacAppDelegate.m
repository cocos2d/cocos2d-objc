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
		
		// sprite
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.position = ccp(s.width/4, s.height/2);
		[self addChild:sprite];
		
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id forever = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:forever];
		
		
		// particle. NOT WORKING !?!?
		CCParticleSystem *particle = [CCParticleSun node];
		particle.position = ccp(s.width/2, s.height/2);
		[self addChild:particle z:10];
		
		
		// BMFont
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"cocos2d for Mac" fntFile:@"bitmapFontTest4.fnt"];
		label.position = ccp(s.width/2, s.height-80);
		[self addChild:label];
		
		
		// Tile Map 1.
		{
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
		
		// Tile map 2
		{
			//
			// Test orthogonal with 3d camera and anti-alias textures
			//
			// it should not flicker. No artifacts should appear
			//
			
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
