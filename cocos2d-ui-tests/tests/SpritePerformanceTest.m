#import "TestBase.h"

@interface SpritePerformanceTest : TestBase @end
@implementation SpritePerformanceTest

#define SPRITE_COUNT 3000
#define TILE_COUNT 37

- (void)setupSpritesUnbatchedUnatlassedTest
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (unatlassed, unbatched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"Tiles/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		[self.contentNode addChild:sprite];
	}
}

- (void)setupSpritesUnbatchedTest
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (atlassed, unbatched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"TilesAtlassed/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		[self.contentNode addChild:sprite];
	}
}

- (void)setupSpritesBatchedTest
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (atlassed, batched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"TilesAtlassed.png"];
	[self.contentNode addChild:batch];
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"TilesAtlassed/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		[batch addChild:sprite];
	}
}

- (void)setupSpritesUnbatchedUnatlassed2080Test
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (20%% visible, unatlassed, unbatched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"Tiles/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[self.contentNode addChild:sprite];
	}
}

- (void)setupSpritesUnbatched2080Test
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (20%% visible, atlassed, unbatched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"TilesAtlassed/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[self.contentNode addChild:sprite];
	}
}

- (void)setupSpritesBatched2080Test
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (20%% visible, atlassed, batched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"TilesAtlassed.png"];
	[self.contentNode addChild:batch];
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"TilesAtlassed/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[batch addChild:sprite];
	}
}

@end

