#import "TestBase.h"

@interface CCDrawNodeTest : TestBase @end
@implementation CCDrawNodeTest

- (void)setupDrawNodeTest
{
	CCDrawNode *draw = [CCDrawNode node];
	
	[draw drawDot:ccp(100, 100) radius:50 color:[CCColor redColor]];
	[draw drawSegmentFrom:ccp(100, 200) to:ccp(200, 200) radius:25 color:[CCColor blueColor]];
	
	CGPoint points1[] = {
		{300, 100},
		{350,  50},
		{400, 100},
		{400, 200},
		{350, 250},
		{300, 200},
	};
	[draw drawPolyWithVerts:points1 count:sizeof(points1)/sizeof(*points1) fillColor:[CCColor greenColor] borderWidth:5.0 borderColor:[CCColor whiteColor]];
	
	CGPoint points2[] = {
		{325, 125},
		{375, 125},
		{350, 200},
	};
	[draw drawPolyWithVerts:points2 count:sizeof(points2)/sizeof(*points2) fillColor:[CCColor blackColor] borderWidth:0.0 borderColor:[CCColor whiteColor]];
	
	[self.contentNode addChild:draw];
}

@end

