//
//  Scene.m
//  cocos2d
//

#import "Scene.h"
#import "Director.h"

@implementation Scene
-(id) init
{
	if( ! [super init] )
		return nil;
	
	CGRect s = [[Director sharedDirector] winSize];
	
	transformAnchor.x = s.size.width / 2;
	transformAnchor.y = s.size.height / 2;
	
	return self;
}
@end
