
//
// Performance Texture Test
// http://www.cocos2d-iphone.org
//

#import "cocos2d.h"

Class nextAction();

@interface PerformanceTextureTest : CCNodeColor
{
}
- (NSString*) title;
- (NSString*) subtitle;
- (void) performTests;

+ (CCScene*) scene;

@end

@interface TextureTest : PerformanceTextureTest
@end






