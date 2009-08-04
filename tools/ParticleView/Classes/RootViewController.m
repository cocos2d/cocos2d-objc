//
//  RootViewController.m
//  ParticleView
//
//  Created by Stas Skuratov on 7/14/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "RootViewController.h"
#import "ParticleViewAppDelegate.h"
#import "Constants.h"
#import "cocos2d.h"
#import "ParticlesViewController.h"

@implementation RootViewController

@synthesize currentRow;
@synthesize particleSystem1;
@synthesize particleSystem2;
@synthesize particleSystem3;
@synthesize particleSystem4;
@synthesize particleSystem5;
@synthesize saveButton;
@synthesize switchSystem1;
@synthesize switchSystem2;
@synthesize switchSystem3;
@synthesize switchSystem4;
@synthesize switchSystem5;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
	state = kStateEnd;
			
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
	
	[super dealloc];
}

- (IBAction) load: (id)sender
{
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	switchSystem1.on = [[delegate.settings1 objectAtIndex:___enabled] intValue];
	switchSystem2.on = [[delegate.settings2 objectAtIndex:___enabled] intValue];
	switchSystem3.on = [[delegate.settings3 objectAtIndex:___enabled] intValue];
	switchSystem4.on = [[delegate.settings4 objectAtIndex:___enabled] intValue];
	switchSystem5.on = [[delegate.settings5 objectAtIndex:___enabled] intValue];	
}

- (IBAction) save: (id) sender
{
	[self endCocos2d];
	
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate save];
}

- (IBAction) run: (id) sender
{
	[self runCocos2d];
}

- (IBAction) stop: (id) sender
{
	[self endCocos2d];
}

- (IBAction) buttonClick: (id) sender
{
	ParticlesViewController *controller = [[ParticlesViewController alloc] initWithNibName:@"ParticlesViewController" bundle:nil];
	
	// Set selected Particle system
	controller.particleSystem = ((UIButton *)sender).tag;
	
	// Animate transition to next view
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	UIViewController *coming = nil;
	UIViewController *going = nil;
	UIViewAnimationTransition transition;
	
	transition = UIViewAnimationTransitionFlipFromLeft;
	
	[UIView setAnimationTransition: transition forView:self.view cache:YES];
	[coming viewWillAppear:YES];
	[going viewWillDisappear:YES];
	[going.view removeFromSuperview];
	[self.view insertSubview: controller.view atIndex:14];
	[going viewDidDisappear:YES];
	[coming viewDidAppear:YES];
	
	[UIView commitAnimations];
}

- (IBAction) valueChanged: (id)sender
{
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	UISwitch *s = (UISwitch *)sender;
	
	if (((UIButton *)sender).tag == kParticleSystem1)
	{
		[delegate.settings1 replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d", s.on]];
	}
	if (((UIButton *)sender).tag == kParticleSystem2)
	{
		[delegate.settings2 replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d", s.on]];
	}
	if (((UIButton *)sender).tag == kParticleSystem3)
	{
		[delegate.settings3 replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d", s.on]];
	}
	if (((UIButton *)sender).tag == kParticleSystem4)
	{
		[delegate.settings4 replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d", s.on]];
	}
	if (((UIButton *)sender).tag == kParticleSystem5)
	{
		[delegate.settings5 replaceObjectAtIndex:___enabled withObject:[NSString stringWithFormat:@"%d", s.on]];
	}
}

- (void) initWithValues: (NSMutableArray *)array scene: (ParticlesScene *)currentScene
{
	ParticleSmoke2 *smoke = [[ParticleSmoke2 alloc] initWithTotalParticles:[[array objectAtIndex:___totalParticles] intValue]];
	smoke.duration = [[array objectAtIndex:___duration] floatValue];
	smoke.gravity = CGPointMake([[array objectAtIndex:___gravityX] floatValue], [[array objectAtIndex:___gravityY] floatValue]);
	smoke.angle = [[array objectAtIndex:___angle] floatValue];
	smoke.angleVar = [[array objectAtIndex:___angleVar] floatValue];
	smoke.radialAccel = [[array objectAtIndex:___accel] floatValue];
	smoke.radialAccelVar = [[array objectAtIndex:___accelVar] floatValue];
	smoke.position = CGPointMake([[array objectAtIndex:___emitterPosX] floatValue], [[array objectAtIndex:___emitterPosY] floatValue]);
	smoke.posVar = CGPointMake([[array objectAtIndex:___emitterPosVarX] floatValue], [[array objectAtIndex:___emitterPosVarY] floatValue]);
	smoke.life = [[array objectAtIndex:___life] floatValue];
	smoke.lifeVar = [[array objectAtIndex:___lifeVar] floatValue];
	smoke.speed = [[array objectAtIndex:___speed] floatValue];
	smoke.speedVar = [[array objectAtIndex:___speedVar] floatValue];
	smoke.startSize = [[array objectAtIndex:___startSize] floatValue];
	smoke.startSizeVar = [[array objectAtIndex:___startSizeVar] floatValue];
	smoke.endSize = [[array objectAtIndex:___endSize] floatValue];
	//smoke.emissionRate = totalParticles / life;
	ccColor4F startColor = {[[array objectAtIndex:___startR] floatValue], [[array objectAtIndex:___startG] floatValue], [[array objectAtIndex:___startB] floatValue], 
	[[array objectAtIndex:___startA] floatValue]};
	smoke.startColor = startColor;
	
	ccColor4F startColorVar = {[[array objectAtIndex:___startRVar] floatValue], [[array objectAtIndex:___startGVar] floatValue], [[array objectAtIndex:___startBVar] floatValue], 
	[[array objectAtIndex:___startAVar] floatValue]};
	smoke.startColorVar = startColorVar;		
	
	ccColor4F endColor = {[[array objectAtIndex:___endR] floatValue], [[array objectAtIndex:___endG] floatValue], [[array objectAtIndex:___endB] floatValue], 
	[[array objectAtIndex:___endA] floatValue]};
	smoke.endColor = endColor;
	
	ccColor4F endColorVar = {[[array objectAtIndex:___endRVar] floatValue], [[array objectAtIndex:___endGVar] floatValue], [[array objectAtIndex:___endBVar] floatValue], 
	[[array objectAtIndex:___endAVar] floatValue]};
	smoke.endColorVar = endColorVar;
	
	smoke.blendAdditive = YES;//[blendingAddictive.on intValue];
	smoke.startSpin = [[array objectAtIndex:___startSpin] floatValue];
	smoke.startSpinVar = [[array objectAtIndex:___startSpinVar] floatValue];
	smoke.endSpin = [[array objectAtIndex:___endSpin] floatValue];
	smoke.endSpinVar = [[array objectAtIndex:___endSpinVar] floatValue];
	
	int textureNum = [[array objectAtIndex:___textureNumber] intValue];
	switch (textureNum)
	{
		case 1 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"1.png"];
			[smoke.texture retain];								
			break;
		case 2 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"2.png"];
			[smoke.texture retain];								
			break;
		case 3 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"3.png"];
			[smoke.texture retain];								
			break;
		case 4 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"4.png"];
			[smoke.texture retain];								
			break;
		case 5 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"5.png"];
			[smoke.texture retain];								
			break;
		case 6 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"6.png"];
			[smoke.texture retain];								
			break;
		case 7 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"7.png"];
			[smoke.texture retain];								
			break;
		case 8 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"8.png"];
			[smoke.texture retain];								
			break;
		case 9 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"9.png"];
			[smoke.texture retain];								
			break;
		case 10 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"10.png"];
			[smoke.texture retain];								
			break;
		case 11 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"11.png"];
			[smoke.texture retain];								
			break;
		case 12 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"12.png"];
			[smoke.texture retain];								
			break;
		case 13 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"13.png"];
			[smoke.texture retain];								
			break;
		case 14 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"14.png"];
			[smoke.texture retain];								
			break;
		case 15 :
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"15.png"];
			[smoke.texture retain];								
			break;
		default:
			smoke.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
			[smoke.texture retain];				
	}
	
	[currentScene.layer addChild:smoke];
	//[smoke release];
}

#pragma mark -
#pragma mark Cocos2d Functions

//
// Use runWithScene / end
// to remove /add the cocos2d view
// This is the recommended way since it removes the Scenes from memory
//
-(void) runCocos2d
{
	if( state == kStateEnd ) 
	{
		[[Director sharedDirector] attachInView:self.view withFrame:CGRectMake(0, 0, 320,400)];
		
		ParticlesScene *scene = [ParticlesScene node];
		ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		
		if ([[delegate.settings1 objectAtIndex:___enabled] intValue] == 1)
		{
			[self initWithValues: delegate.settings1 scene:scene];
		}
		if ([[delegate.settings2 objectAtIndex:___enabled] intValue] == 1)
		{
			[self initWithValues: delegate.settings2 scene:scene];
		}
		if ([[delegate.settings3 objectAtIndex:___enabled] intValue] == 1)
		{
			[self initWithValues: delegate.settings3 scene:scene];
		}
		if ([[delegate.settings4 objectAtIndex:___enabled] intValue] == 1)
		{
			[self initWithValues: delegate.settings4 scene:scene];
		}
		if ([[delegate.settings5 objectAtIndex:___enabled] intValue] == 1)
		{
			[self initWithValues: delegate.settings5 scene:scene];
		}

		[Director sharedDirector].displayFPS = YES;
		[[Director sharedDirector] runWithScene:scene];

		state = kStateRun;
	}
	else 
	{
		NSLog(@"End the view before running it");
	}
}

-(void) endCocos2d
{
	if( state == kStateRun || state == kStateAttach) {
		// Director end releases the "inner" objects from memory
		[[Director sharedDirector] end];
		state = kStateEnd;
	}
	else
		NSLog(@"Run or Attach the view before calling end");
}

//
// Use attach / detach
// To hide / unhide the cocos2d view.
// If you want to remove them, use runWithScene / end
// IMPORTANT: Memory is not released if you use attach / detach
//
-(void) attachView
{
	if( state == kStateDetach ) {
		[[Director sharedDirector] attachInView:self.view withFrame:CGRectMake(0, 0, 320,350)];
		[[Director sharedDirector] startAnimation];
		
		state = kStateAttach;
	}
	else
		NSLog(@"Dettach the view before attaching it");
}

-(void) detachView
{
	if( state == kStateRun || state == kStateAttach ) {
		[[Director sharedDirector] detach];
		[[Director sharedDirector] stopAnimation];
		state = kStateDetach;
	} else {
		NSLog(@"Run or Attach the view before calling detach");
	}
}

@end
