//
//  TomTheTurretAppDelegate.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppController.h"

//Channel group ids, the channel groups define how voices
//will be shared.  If you wish you can simply have a single
//channel group and all sounds will share all the voices
#define CGROUP_PROJECTILE_EFFECTS   0
#define CGROUP_IMPACT_EFFECTS       1
#define CGROUP_TOTAL                2

#define SND_ID_BACKGROUND_MUSIC     0
#define SND_ID_SHOOT_EFFECT         1
#define SND_ID_MALE_HIT_EFFECT      2
#define SND_ID_FEMALE_HIT_EFFECT    3

@class LoadingScene;
@class MainMenuScene;
@class StoryScene;
@class ActionScene;

@interface TomTheTurretAppDelegate : BaseAppController {
    LoadingScene *_loadingScene;
    MainMenuScene *_mainMenuScene;
    StoryScene *_storyScene;
    ActionScene *_actionScene;
}

@property (nonatomic, retain) LoadingScene *loadingScene;
@property (nonatomic, retain) MainMenuScene *mainMenuScene;
@property (nonatomic, retain) StoryScene *storyScene;
@property (nonatomic, retain) ActionScene *actionScene;

- (void)loadScenes;
- (void)launchMainMenu;
- (void)launchNewGame;
- (void)launchNextLevel;
- (void)launchKillEnding;
- (void)launchSuicideEnding;
- (void)launchLoseEnding;

@end
