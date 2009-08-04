//
//  ParticlesViewController.h
//  Particles
//
//  Created by Type your name here on 7/22/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticlesViewController : UIViewController 
{
	IBOutlet UIScrollView *scrollView;
	IBOutlet UISwitch *switchEnabled;
	IBOutlet UITextField *duration;
	IBOutlet UITextField *graviryX;
	IBOutlet UITextField *gravityY;
	IBOutlet UITextField *angle;
	IBOutlet UITextField *angleVar;
	IBOutlet UITextField *accel;
	IBOutlet UITextField *accelVar;
	IBOutlet UITextField *emitterPosX;
	IBOutlet UITextField *emitterPosY;
	IBOutlet UITextField *emitterPosVarX;
	IBOutlet UITextField *emitterPosVarY;
	IBOutlet UITextField *life;
	IBOutlet UITextField *lifeVar;
	IBOutlet UITextField *speed;
	IBOutlet UITextField *speedVar;
	IBOutlet UITextField *startSize;
	IBOutlet UITextField *startSizeVar;
	IBOutlet UITextField *endSize;
	IBOutlet UITextField *startR;
	IBOutlet UITextField *startG;
	IBOutlet UITextField *startB;
	IBOutlet UITextField *startA;
	IBOutlet UITextField *startRVar;
	IBOutlet UITextField *startGVar;
	IBOutlet UITextField *startBVar;
	IBOutlet UITextField *startAVar;
	IBOutlet UITextField *endR;
	IBOutlet UITextField *endG;
	IBOutlet UITextField *endB;
	IBOutlet UITextField *endA;
	IBOutlet UITextField *endRVar;
	IBOutlet UITextField *endGVar;
	IBOutlet UITextField *endBVar;
	IBOutlet UITextField *endAVar;
	IBOutlet UITextField *totalParticles;
	IBOutlet UITextField *textureNumber;
	IBOutlet UITextField *startSpin;
	IBOutlet UITextField *startSpinVar;
	IBOutlet UITextField *endSpin;
	IBOutlet UITextField *endSpinVar;
	IBOutlet UIButton *btnBack;
	IBOutlet UIButton *btnBack2;
	IBOutlet UIButton *btnImages;
	
	int particleSystem;
}

@property int particleSystem;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UISwitch *switchEnabled;
@property (nonatomic, retain) IBOutlet UITextField *duration;
@property (nonatomic, retain) IBOutlet UITextField *graviryX;
@property (nonatomic, retain) IBOutlet UITextField *gravityY;
@property (nonatomic, retain) IBOutlet UITextField *angle;
@property (nonatomic, retain) IBOutlet UITextField *angleVar;
@property (nonatomic, retain) IBOutlet UITextField *accel;
@property (nonatomic, retain) IBOutlet UITextField *accelVar;
@property (nonatomic, retain) IBOutlet UITextField *emitterPosX;
@property (nonatomic, retain) IBOutlet UITextField *emitterPosY;
@property (nonatomic, retain) IBOutlet UITextField *emitterPosVarX;
@property (nonatomic, retain) IBOutlet UITextField *emitterPosVarY;
@property (nonatomic, retain) IBOutlet UITextField *life;
@property (nonatomic, retain) IBOutlet UITextField *lifeVar;
@property (nonatomic, retain) IBOutlet UITextField *speed;
@property (nonatomic, retain) IBOutlet UITextField *speedVar;
@property (nonatomic, retain) IBOutlet UITextField *startSize;
@property (nonatomic, retain) IBOutlet UITextField *startSizeVar;
@property (nonatomic, retain) IBOutlet UITextField *endSize;
@property (nonatomic, retain) IBOutlet UITextField *startR;
@property (nonatomic, retain) IBOutlet UITextField *startG;
@property (nonatomic, retain) IBOutlet UITextField *startB;
@property (nonatomic, retain) IBOutlet UITextField *startA;
@property (nonatomic, retain) IBOutlet UITextField *startRVar;
@property (nonatomic, retain) IBOutlet UITextField *startGVar;
@property (nonatomic, retain) IBOutlet UITextField *startBVar;
@property (nonatomic, retain) IBOutlet UITextField *startAVar;
@property (nonatomic, retain) IBOutlet UITextField *endR;
@property (nonatomic, retain) IBOutlet UITextField *endG;
@property (nonatomic, retain) IBOutlet UITextField *endB;
@property (nonatomic, retain) IBOutlet UITextField *endA;
@property (nonatomic, retain) IBOutlet UITextField *endRVar;
@property (nonatomic, retain) IBOutlet UITextField *endGVar;
@property (nonatomic, retain) IBOutlet UITextField *endBVar;
@property (nonatomic, retain) IBOutlet UITextField *endAVar;
@property (nonatomic, retain) IBOutlet UITextField *totalParticles;
@property (nonatomic, retain) IBOutlet UITextField *textureNumber;
@property (nonatomic, retain) IBOutlet UITextField *startSpin;
@property (nonatomic, retain) IBOutlet UITextField *startSpinVar;
@property (nonatomic, retain) IBOutlet UITextField *endSpin;
@property (nonatomic, retain) IBOutlet UITextField *endSpinVar;
@property (nonatomic, retain) IBOutlet UIButton *btnBack;
@property (nonatomic, retain) IBOutlet UIButton *btnBack2;
@property (nonatomic, retain) IBOutlet UIButton *btnImages;

- (IBAction) back: (id)sender;
- (IBAction) selectImage: (id)sender;
- (IBAction) textFieldDoneEditing:(id) sender;
- (void) loadValues;
- (void) saveValues;

@end

