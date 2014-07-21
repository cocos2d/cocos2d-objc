#import "TestBase.h"
#import "CCNode_Private.h"

@interface SpritePerformanceTest : TestBase @end
@implementation SpritePerformanceTest

#define SPRITE_COUNT 3000
#define TILE_COUNT 37
#define SCALE 1.0

- (void)setupSpritesUnbatchedUnatlassedTest
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (unatlassed, unbatched)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"Tiles/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		sprite.scale = SCALE;
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
		sprite.scale = SCALE;
		[self.contentNode addChild:sprite];
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
		sprite.scale = SCALE;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[self.contentNode addChild:sprite];
	}
}

- (void)setupSpritesSorted2080Test
{
	self.subTitle = [NSString stringWithFormat:@"%d Sprites (20%% visible, sorted)", SPRITE_COUNT];
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
	NSMutableArray *sprites = [NSMutableArray array];
	
	for(int i=0; i<SPRITE_COUNT; i++){
		int num = arc4random()%TILE_COUNT + 1;
		CCSprite *sprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"Tiles/%02d.png", num]];
		sprite.position = ccp(CCRANDOM_0_1()*size.width, CCRANDOM_0_1()*size.height);
		sprite.rotation = CCRANDOM_0_1()*360;
		sprite.scale = SCALE;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[sprites addObject:sprite];
	}
	
	[sprites sortUsingComparator:^(CCSprite *a, CCSprite *b){
		return (NSComparisonResult)((intptr_t)[a renderState] - (intptr_t)[b renderState]);
	}];
	
	for(CCSprite *sprite in sprites) [self.contentNode addChild:sprite];
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
		sprite.scale = SCALE;
		
		if(i < 0.8*SPRITE_COUNT) sprite.position = ccp(-1000, -1000);
		
		[self.contentNode addChild:sprite];
	}
}

@end

