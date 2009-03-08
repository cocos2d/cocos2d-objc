//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

Class nextAction();


@interface MainScene : Scene {
	int		lastRenderedCount;
	int		quantityNodes;
}

-(void)updateNodes;
-(NSString*) title;

-(void) doTest:(id) sprite;
-(id) createSprite;
@end



@interface PerformanceSprite1 : MainScene
{}
@end

@interface PerformanceSprite2 : PerformanceSprite1
{}
@end

@interface PerformanceSprite3 : PerformanceSprite1
{}
@end

@interface PerformanceSprite4 : PerformanceSprite1
{}
@end

@interface PerformanceSprite5 : PerformanceSprite4
{}
@end

@interface PerformanceSprite6 : PerformanceSprite4
{}
@end

@interface PerformanceSprite7 : PerformanceSprite4
{}
@end

@interface PerformanceSprite8 : PerformanceSprite4
{}
@end

@interface PerformanceSprite9 : PerformanceSprite4
{}
@end

@interface PerformanceAtlasSprite1 : MainScene
{
	AtlasSpriteManager	*spriteManager;
}
-(id) createSpriteManager;
@end

@interface PerformanceAtlasSprite2 : PerformanceAtlasSprite1
{}
@end

@interface PerformanceAtlasSprite3 : PerformanceAtlasSprite1
{}
@end

@interface PerformanceAtlasSprite4 : PerformanceAtlasSprite1
{}
@end

@interface PerformanceAtlasSprite5 : PerformanceAtlasSprite4
{}
@end

@interface PerformanceAtlasSprite6 : PerformanceAtlasSprite4
{}
@end

@interface PerformanceAtlasSprite7 : PerformanceAtlasSprite4
{}
@end

@interface PerformanceAtlasSprite8 : PerformanceAtlasSprite4
{}
@end

@interface PerformanceAtlasSprite9 : PerformanceAtlasSprite4
{}
@end
