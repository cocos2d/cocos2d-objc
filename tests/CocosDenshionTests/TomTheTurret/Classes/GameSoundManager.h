#import "SimpleAudioEngine.h"

typedef enum {
	kGSUninitialised,
	kGSAudioManagerInitialising,
	kGSAudioManagerInitialised,
	kGSLoadingSounds,
	kGSOkay,//only use when in this state
	kGSFailed
} tGameSoundState;

@interface GameSoundManager : NSObject {
	tGameSoundState state_;
	SimpleAudioEngine *soundEngine_;
}

@property (readonly) tGameSoundState state;
@property (readonly) SimpleAudioEngine *soundEngine;

+ (GameSoundManager*) sharedManager;
-(void) setup;
-(void) fadeOutMusic;

@end
