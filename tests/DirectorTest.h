
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end


@interface DirectorTest: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
-(void) restartCallback: (id) sender;
-(void) nextCallback: (id) sender;
-(void) backCallback: (id) sender;
@end


@interface DirectorViewDidDisappear : DirectorTest
{}
@end

@interface DirectorAndGameCenter : DirectorTest <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{}
@end

@interface DirectorStartStopAnimating : DirectorTest
{}
@end

@interface DirectorRootToLevel : DirectorTest
{
	NSUInteger	 _level;
}
@property (nonatomic, readwrite) NSUInteger level;
-(id) initWithLevel:(NSUInteger)level;
@end

