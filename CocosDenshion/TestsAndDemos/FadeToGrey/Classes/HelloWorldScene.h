
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "TheAudioCode.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	TheAudioCode* audioTests;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
