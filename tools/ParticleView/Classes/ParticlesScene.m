//
//  ParticlesScene.m
//  ParticlesTest
//
//  Created by Stas Skuratov on 7/9/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "ParticlesScene.h"

#define kTagEmitter 10

@implementation ParticlesScene

@synthesize layer;

- (id) init
{
	if ((self = [super init]))
	{		
		layer = [ParticlesLayer node];
		[self addChild: layer];
	}	
	
	return self;
}

/////////////////////////////////////////////////////////////////
// 
// Finalization
//
/////////////////////////////////////////////////////////////////

- (void) dealloc
{
	
	[super dealloc];
}

- (void) start: (int) totalParticels
{
	layer = [ParticlesLayer node];
	[layer start:totalParticels];
	[self addChild: layer];
}

@end

@implementation ParticlesLayer

@synthesize smoke;

- (id) init
{
	if ((self = [super init]))
	{		
		isTouchEnabled = true;
	}
	
	return self;
}

/////////////////////////////////////////////////////////////////
// 
// Finalization
//
/////////////////////////////////////////////////////////////////

- (void) dealloc
{
	[smoke release];
	[super dealloc];
}

- (void) start: (int) totalParticels
{
	smoke = [[ParticleSmoke2 alloc] initWithTotalParticles:totalParticels];
	smoke.tag = kTagEmitter;
	//smoke = [ParticleSmoke2 node];
	[self addChild:smoke];	
}

#pragma mark -
#pragma mark Touch Events

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	return [self ccTouchesEnded:touches withEvent:event];
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
/**
	UITouch *touch = [touches anyObject];
	
	if( touch ) {
		CGPoint location = [touch locationInView: [touch view]];
		CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
		
		ParticleSmoke2 *s = (ParticleSmoke2 *) [self getChildByTag:kTagEmitter];
		
		//	CGPoint source = ccpSub( convertedLocation, s.position );
		//	s.source = source;
		s.position = convertedLocation;
		
		return kEventHandled;
	}
/**/	
	return kEventIgnored;
}

@end
