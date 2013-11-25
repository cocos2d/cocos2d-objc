//
//  ParticleTest
//  cocos2d-ui-tests-ios
//
//  Created by Andy Korth on November 25th, 2013.
//

#import "ParticleTest.h"

@implementation ParticleTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupComet",
            nil];
}

- (void) setupAlignedTTFs{
  [self pressedReset:nil];
}

-(void) setupComet
{
	[super onEnter];
  
//	[self setColor:ccBLACK];
//	[self removeChild:background cleanup:YES];
//	background = nil;
  
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Comet.plist"];
	[self addChild:self.emitter z:10];
}


- (void)createScene
{
  self.subTitle = @"Test alignment and fonts (click next a bunch of times)";
  
  self.userInteractionEnabled = TRUE;
  
  CGSize s = [[CCDirector sharedDirector] viewSize];
  
//  CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
//                             [CCMenuItemFont itemWithString: @"Free Movement"],
//                             [CCMenuItemFont itemWithString: @"Relative Movement"],
//                             [CCMenuItemFont itemWithString: @"Grouped Movement"],
//                             
//                             nil];
  
  
  // moving background
  background = [CCSprite spriteWithImageNamed:@"background3.png"];
  [self addChild:background z:5];
  [background setPosition:ccp(s.width/2, s.height-180)];
  
  id move = [CCActionMoveBy actionWithDuration:4 position:ccp(300,0)];
  id move_back = [move reverse];
  id seq = [CCActionSequence actions: move, move_back, nil];
  [background runAction:[CCActionRepeatForever actionWithAction:seq]];
  

}


-(void) update:(CCTime) dt
{
//	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:CCTagParticleCount];
//  
//	NSString *str = [NSString stringWithFormat:@"%4ld", (unsigned long)emitter_.particleCount];
//	[atlas setString:str];
}
-(void) restartCallback: (id) sender
{
  //	Scene *s = [Scene node];
  //	[s addChild: [restartAction() node]];
  //	[[Director sharedDirector] replaceScene: s];
  
	[emitter resetSystem];
  //	[emitter_ stopSystem];
}

#ifdef __CC_PLATFORM_IOS

-(void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event
{
  UITouch* touch = [ touches anyObject ];
  
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
  
	CGPoint pos = CGPointZero;
  
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter.position = ccpSub(convertedLocation, pos);
}

#elif defined(__CC_PLATFORM_MAC)

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertEventToGL:theEvent];
  
	CGPoint pos = CGPointZero;
  
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter_.position = ccpSub(convertedLocation, pos);
}
#endif // __CC_PLATFORM_MAC


@end
