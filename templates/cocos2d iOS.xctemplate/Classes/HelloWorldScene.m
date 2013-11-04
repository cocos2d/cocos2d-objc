//
//  HelloWorldScene.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCLabelTTF *_helloLabel;
    float _runtime;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    // Crash if basic initialization for some reason failed
    NSAssert(self, @"Unable to create class HelloWorldScene");
    
    // Here is where custom code for the scene starts
    _runtime = 0;
    
    // create a lebal on the centre of the sceen
    _helloLabel = [CCLabelTTF labelWithString:@"Hello World (v3)" fontName:@"Arial" fontSize:48];
    _helloLabel.positionType = CCPositionTypeNormalized;
    _helloLabel.position = ccp(0.5f, 0.8f);
    [self addChild:_helloLabel];
    
    // create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Back ]"];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.1f, 0.9f);
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Pr frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    
    
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - update
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    // manually move hello label up and down
    _runtime += delta * 5.0f;
    _helloLabel.position = ccp(0.5f, 0.8f + (sinf(_runtime) * 0.1f));
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
@end