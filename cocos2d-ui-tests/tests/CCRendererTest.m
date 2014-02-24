#import "TestBase.h"

@interface CCDrawNodeTest : TestBase @end
@implementation CCDrawNodeTest

- (void)setupDrawNodeTest
{
	CCDrawNode *draw = [CCDrawNode node];
	
	[draw drawDot:ccp(100, 100) radius:50 color:[CCColor redColor]];
	[draw drawSegmentFrom:ccp(100, 200) to:ccp(200, 200) radius:25 color:[CCColor blueColor]];
	
//	CGPoint points[] = {};
//	[draw drawPolyWithVerts:points count:sizeof(points)/sizeof(*points) fillColor:[CCColor greenColor] borderWidth:5.0 borderColor:[CCColor whiteColor]];
	
	[self.contentNode addChild:draw];
}

@end

