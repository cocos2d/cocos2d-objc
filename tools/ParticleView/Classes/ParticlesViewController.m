//
//  ParticlesViewController.m
//  Particles
//
//  Created by Type your name here on 7/22/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "ParticlesViewController.h"
#import "ParticleViewAppDelegate.h"
#import "TableViewImages.h"
#import "Constants.h"

@implementation ParticlesViewController

@synthesize particleSystem;
@synthesize scrollView;
@synthesize switchEnabled;
@synthesize duration;
@synthesize graviryX;
@synthesize gravityY;
@synthesize angle;
@synthesize angleVar;
@synthesize accel;
@synthesize accelVar;
@synthesize emitterPosX;
@synthesize emitterPosY;
@synthesize emitterPosVarX;
@synthesize emitterPosVarY;
@synthesize life;
@synthesize lifeVar;
@synthesize speed;
@synthesize speedVar;
@synthesize startSize;
@synthesize startSizeVar;
@synthesize endSize;
@synthesize startR;
@synthesize startG;
@synthesize startB;
@synthesize startA;
@synthesize startA;
@synthesize startRVar;
@synthesize startGVar;
@synthesize startBVar;
@synthesize startAVar;
@synthesize endR;
@synthesize endG;
@synthesize endB;
@synthesize endA;
@synthesize endRVar;
@synthesize endGVar;
@synthesize endBVar;
@synthesize endAVar;
@synthesize totalParticles;
@synthesize textureNumber;
@synthesize startSpin;
@synthesize startSpinVar;
@synthesize endSpin;
@synthesize endSpinVar;
@synthesize btnBack;
@synthesize btnBack2;
@synthesize btnImages;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	scrollView.contentSize = CGSizeMake(320, 1000);
	scrollView.bounces = NO;
	scrollView.delaysContentTouches = YES;
	scrollView.showsVerticalScrollIndicator = YES;

	[self loadValues];
	
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction) back: (id)sender
{
	[self saveValues];
	
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:1.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	UIViewController *coming = nil;
	UIViewController *going = nil;
	UIViewAnimationTransition transition;
	
	//coming = controller;
	//going = self;
	transition = UIViewAnimationTransitionFlipFromLeft;
	
	[UIView setAnimationTransition: transition forView:self.view cache:YES];
	[coming viewWillAppear:YES];
	[going viewWillDisappear:YES];
	[going.view removeFromSuperview];
	[self.view removeFromSuperview];
	[going viewDidDisappear:YES];
	[coming viewDidAppear:YES];
	
	[UIView commitAnimations];
}

- (IBAction) textFieldDoneEditing:(id) sender
{
	[sender resignFirstResponder];
}

- (IBAction) selectImage: (id)sender
{
	TableViewImages *controller = [[TableViewImages alloc] initWithStyle:UITableViewStylePlain];
	
	controller.particleSystem = self.particleSystem;
	
	[self.view insertSubview:controller.view atIndex: 50];
}

- (void) loadValues
{
	NSMutableArray *array = nil;
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	if (self.particleSystem == kParticleSystem1)
	{
		array = delegate.settings1;
	}
	else if (self.particleSystem == kParticleSystem2)
	{
		array = delegate.settings2;
	}
	else if (self.particleSystem == kParticleSystem3)
	{
		array = delegate.settings3;
	}
	else if (self.particleSystem == kParticleSystem4)
	{
		array = delegate.settings4;
	}
	else if (self.particleSystem == kParticleSystem5)
	{
		array = delegate.settings5;
	}
	
	switchEnabled.on = [[array objectAtIndex:___enabled] intValue] == 0 ? NO : YES;
	duration.text = [array objectAtIndex:___duration];
	graviryX.text = [array objectAtIndex:___gravityX];
	gravityY.text = [array objectAtIndex:___gravityY];
	angle.text = [array objectAtIndex:___angle];
	angleVar.text = [array objectAtIndex:___angleVar];
	accel.text = [array objectAtIndex:___accel];
	accelVar.text = [array objectAtIndex:___accelVar];
	emitterPosX.text = [array objectAtIndex:___emitterPosX];
	emitterPosY.text = [array objectAtIndex:___emitterPosY];
	emitterPosVarX.text = [array objectAtIndex:___emitterPosVarX];
	emitterPosVarY.text = [array objectAtIndex:___emitterPosVarY];
	life.text = [array objectAtIndex:___life];
	lifeVar.text = [array objectAtIndex:___lifeVar];
	speed.text = [array objectAtIndex:___speed];
	speedVar.text = [array objectAtIndex:___speedVar];
	startSize.text = [array objectAtIndex:___startSize];
	startSizeVar.text = [array objectAtIndex:___startSizeVar];
	endSize.text = [array objectAtIndex:___endSize];
	startR.text = [array objectAtIndex:___startR];
	startG.text = [array objectAtIndex:___startG];
	startB.text = [array objectAtIndex:___startB];
	startA.text = [array objectAtIndex:___startA];
	startA.text = [array objectAtIndex:___startA];
	startRVar.text = [array objectAtIndex:___startRVar];
	startGVar.text = [array objectAtIndex:___startGVar];
	startBVar.text = [array objectAtIndex:___startBVar];
	startAVar.text = [array objectAtIndex:___startAVar];
	endR.text = [array objectAtIndex:___endR];
	endG.text = [array objectAtIndex:___endG];
	endB.text = [array objectAtIndex:___endB];
	endA.text = [array objectAtIndex:___endA];
	endRVar.text = [array objectAtIndex:___endRVar];
	endGVar.text = [array objectAtIndex:___endGVar];
	endBVar.text = [array objectAtIndex:___endBVar];
	endAVar.text = [array objectAtIndex:___endAVar];
	totalParticles.text = [array objectAtIndex:___totalParticles];
	textureNumber.text = [array objectAtIndex:___textureNumber];
	startSpin.text = [array objectAtIndex:___startSpin];
	startSpinVar.text = [array objectAtIndex:___startSpinVar];
	endSpin.text = [array objectAtIndex:___endSpin];
	endSpinVar.text = [array objectAtIndex:___endSpinVar];
}

- (void) saveValues
{
	NSMutableArray *array = nil;
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	if (self.particleSystem == kParticleSystem1)
	{
		array = delegate.settings1;
	}
	else if (self.particleSystem == kParticleSystem2)
	{
		array = delegate.settings2;
	}
	else if (self.particleSystem == kParticleSystem3)
	{
		array = delegate.settings3;
	}
	else if (self.particleSystem == kParticleSystem4)
	{
		array = delegate.settings4;
	}
	else if (self.particleSystem == kParticleSystem5)
	{
		array = delegate.settings5;
	}
	[array replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d",switchEnabled.on]];
	[array replaceObjectAtIndex:___duration withObject:duration.text];
	[array replaceObjectAtIndex:___gravityX withObject:graviryX.text];
	[array replaceObjectAtIndex:___gravityY withObject:gravityY.text];
	[array replaceObjectAtIndex:___angle withObject:angle.text];
	[array replaceObjectAtIndex:___angleVar withObject:angleVar.text];
	[array replaceObjectAtIndex:___accel withObject:accel.text];
	[array replaceObjectAtIndex:___accelVar withObject:accelVar.text];
	[array replaceObjectAtIndex:___emitterPosX withObject:emitterPosX.text];
	[array replaceObjectAtIndex:___emitterPosY withObject:emitterPosY.text];
	[array replaceObjectAtIndex:___emitterPosVarX withObject:emitterPosVarX.text];
	[array replaceObjectAtIndex:___emitterPosVarY withObject:emitterPosVarY.text];
	[array replaceObjectAtIndex:___life withObject:life.text];
	[array replaceObjectAtIndex:___lifeVar withObject:lifeVar.text];
	[array replaceObjectAtIndex:___speed withObject:speed.text];
	[array replaceObjectAtIndex:___speedVar withObject:speedVar.text];
	[array replaceObjectAtIndex:___startSize withObject:startSize.text];
	[array replaceObjectAtIndex:___startSizeVar withObject:startSizeVar.text];
	[array replaceObjectAtIndex:___endSize withObject:endSize.text];
	[array replaceObjectAtIndex:___startR withObject:startR.text];
	[array replaceObjectAtIndex:___startG withObject:startG.text];
	[array replaceObjectAtIndex:___startB withObject:startB.text];
	[array replaceObjectAtIndex:___startA withObject:startA.text];
	[array replaceObjectAtIndex:___startRVar withObject:startRVar.text];
	[array replaceObjectAtIndex:___startGVar withObject:startGVar.text];
	[array replaceObjectAtIndex:___startBVar withObject:startBVar.text];
	[array replaceObjectAtIndex:___startAVar withObject:startAVar.text];
	[array replaceObjectAtIndex:___endR withObject:endR.text];
	[array replaceObjectAtIndex:___endG withObject:endG.text];
	[array replaceObjectAtIndex:___endB withObject:endB.text];
	[array replaceObjectAtIndex:___endA withObject:endA.text];
	[array replaceObjectAtIndex:___endRVar withObject:endRVar.text];
	[array replaceObjectAtIndex:___endGVar withObject:endGVar.text];
	[array replaceObjectAtIndex:___endBVar withObject:endBVar.text];
	[array replaceObjectAtIndex:___endAVar withObject:endAVar.text];
	[array replaceObjectAtIndex:___totalParticles withObject:totalParticles.text];
	//[array replaceObjectAtIndex:___textureNumber withObject:textureNumber.text];
	[array replaceObjectAtIndex:___startSpin withObject:startSpin.text];
	[array replaceObjectAtIndex:___startSpinVar withObject:startSpinVar.text];
	[array replaceObjectAtIndex:___endSpin withObject:endSpin.text];
	[array replaceObjectAtIndex:___endSpinVar withObject:endSpinVar.text];	
}

@end
