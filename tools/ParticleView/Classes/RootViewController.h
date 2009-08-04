//
//  RootViewController.h
//  ParticleView
//
//  Created by Stas Skuratov on 7/14/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticlesScene.h"

enum {
	kTagAttach = 1,
	kTagDettach = 2,
};

enum {
	kStateRun,
	kStateEnd,
	kStateAttach,
	kStateDetach,
};

enum {
	kTagSprite = 1,
};

@interface RootViewController : UIViewController 
{
	int currentRow;
	int	state;
	
	IBOutlet UIButton *particleSystem1;
	IBOutlet UIButton *particleSystem2;
	IBOutlet UIButton *particleSystem3;
	IBOutlet UIButton *particleSystem4;
	IBOutlet UIButton *particleSystem5;
	
	IBOutlet UISwitch *switchSystem1;
	IBOutlet UISwitch *switchSystem2;
	IBOutlet UISwitch *switchSystem3;
	IBOutlet UISwitch *switchSystem4;
	IBOutlet UISwitch *switchSystem5;

	IBOutlet UIButton *saveButton;
}

@property (assign) int currentRow;
@property (nonatomic, retain) IBOutlet UIButton *particleSystem1;
@property (nonatomic, retain) IBOutlet UIButton *particleSystem2;
@property (nonatomic, retain) IBOutlet UIButton *particleSystem3;
@property (nonatomic, retain) IBOutlet UIButton *particleSystem4;
@property (nonatomic, retain) IBOutlet UIButton *particleSystem5;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;

@property (nonatomic, retain) IBOutlet UISwitch *switchSystem1;
@property (nonatomic, retain) IBOutlet UISwitch *switchSystem2;
@property (nonatomic, retain) IBOutlet UISwitch *switchSystem3;
@property (nonatomic, retain) IBOutlet UISwitch *switchSystem4;
@property (nonatomic, retain) IBOutlet UISwitch *switchSystem5;

- (IBAction) load: (id)sender;
- (IBAction) save: (id)sender;
- (IBAction) run: (id)sender;
- (IBAction) stop: (id)sender;
- (IBAction) buttonClick: (id)sender;
- (IBAction) valueChanged: (id)sender;

- (void) runCocos2d;
- (void) endCocos2d;
- (void) attachView;
- (void) detachView;

- (void) initWithValues: (NSMutableArray *)array scene:(ParticlesScene *)currentScene;

@end
