
/**
 Stick all the audio code in here to make it easy to find
 */

#import "SimpleAudioEngine.h"
#import "CDXPropertyModifierAction.h"

@interface TheAudioCode : NSObject {
	CDSoundSource* sound1;
	CDSoundSource* sound2;
	CDSoundSource* sound3;
	//CDSoundSource* sound4;
	SimpleAudioEngine *sae;
	CDXPropertyModifierAction* faderAction;
	CDSoundSourceFader *sourceFader;
	CCActionManager *actionManager;
}

-(void) testOne:(id) sender;
-(void) testTwo:(id) sender;
-(void) testThree:(id) sender;
-(void) testFour:(id) sender;
-(void) testFive:(id) sender;
-(void) testSix:(id) sender;
-(void) testSeven:(id) sender;
-(void) testEight:(id) sender;

@end
