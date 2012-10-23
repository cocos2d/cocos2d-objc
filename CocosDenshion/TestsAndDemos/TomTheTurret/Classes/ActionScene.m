//
//  ActionScene.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "ActionScene.h"
#import "TomTheTurretAppDelegate.h"
#import "Monster.h"
#import "GameState.h"
#import "Level.h"
#import "GameSoundManager.h"

@implementation ActionScene
@synthesize layer = _layer;

- (id)init {

    if ((self = [super init])) {
        self.layer = [[[ActionLayer alloc] init] autorelease];
        [self addChild:_layer];
    }
    return self;

}

@end

@interface ActionLayer (PrivateMethods)
-(void) fadeOutMusic;
@end


@implementation ActionLayer
@synthesize batchNode = _batchNode;
@synthesize level_bkgrnd = _level_bkgrnd;
@synthesize player = _player;
@synthesize monsters = _monsters;
@synthesize projectiles = _projectiles;
@synthesize nextProjectile = _nextProjectile;
@synthesize monsterHit = _monsterHit;
@synthesize levelBegin = _levelBegin;
@synthesize lastTimeMonsterAdded = _lastTimeMonsterAdded;
@synthesize inLevel = _inLevel;

SimpleAudioEngine *soundEngine;

- (id) init {

    if ((self = [super init])) {

        self.touchEnabled = YES;
        self.monsters = [[[NSMutableArray alloc] init] autorelease];
        self.projectiles = [[[NSMutableArray alloc] init] autorelease];

        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [self addChild:_batchNode z:-1];

        // Add main background to scene
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.level_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Level_bkgrnd.png"];
        _level_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_level_bkgrnd];

        // Add tom to the scene
        static int TOM_LEFT_MARGIN = 80;
        self.player = [CCSprite spriteWithSpriteFrameName:@"Level_Tom.png"];
        _player.position = ccp(_player.contentSize.width/2 + TOM_LEFT_MARGIN, winSize.height/2);
        [self addChild:_player z:0];

		//Get the sound engine instance, if something went wrong this will be nil
		soundEngine = [GameSoundManager sharedManager].soundEngine;

    }
    return self;

}

- (void)onEnter {

    [super onEnter];

    // Clear out old monsters/projectiles
    for (CCSprite *monster in _monsters) {
        [_batchNode removeChild:monster cleanup:YES];
    }
    [_monsters removeAllObjects];
    for (CCSprite *projectile in _projectiles) {
        [_batchNode removeChild:projectile cleanup:YES];
    }
    [_projectiles removeAllObjects];

    // Reset stats
    self.monsterHit = FALSE;
    self.nextProjectile = nil;
    self.levelBegin = 0;
    self.lastTimeMonsterAdded = 0;
    self.inLevel = YES;

    // Make Tom blink, for fun
    NSMutableArray *blinkAnimFrames = [NSMutableArray array];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Level_Tom.png"]];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Level_Tom_blink.png"]];
    [blinkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Level_Tom.png"]];
    CCAnimation *blinkAnimation = [CCAnimation animationWithSpriteFrames:blinkAnimFrames delay:0.1f];
    [_player runAction:[CCRepeatForever actionWithAction:
                     [CCSequence actions:
                      [CCAnimate actionWithAnimation:blinkAnimation],
                      [CCDelayTime actionWithDuration:2.5f],
                      nil]]];



	// Schedule loops
    [self schedule:@selector(update:)];
    [self schedule:@selector(gameLogic:) interval:0.1f];

}

- (void)update:(ccTime)dt {

	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (CCSprite *projectile in _projectiles) {
		CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2),
										   projectile.position.y - (projectile.contentSize.height/2),
										   projectile.contentSize.width,
										   projectile.contentSize.height);

        Monster * monster = nil;
		for (Monster *curMonster in _monsters) {
			CGRect monsterRect = CGRectMake(curMonster.position.x - (curMonster.contentSize.width/2),
										    curMonster.position.y - (curMonster.contentSize.height/2),
										    curMonster.contentSize.width,
										    curMonster.contentSize.height);
			if (CGRectIntersectsRect(projectileRect, monsterRect)) {
                monster = curMonster;
                break;
			}
		}

		if (monster != nil) {

            // Subtract HP
            self.monsterHit = YES;
            monster.hp--;

            // Play the hit sound effect
			if (monster.hitEffectSoundId == SND_ID_FEMALE_HIT_EFFECT) {
				[soundEngine playEffect:@"femaleHit.wav" pitch:1.0f pan:0.0f gain:monster.hitEffectGain];
            } else {
				[soundEngine playEffect:@"maleHit.wav"  pitch:1.0f pan:0.0f gain:monster.hitEffectGain];
			}
            // Remove the monster if it's dead
            if (monster.hp <= 0) {
                [_monsters removeObject:monster];
                [_batchNode removeChild:monster cleanup:YES];
            }

            // Add the projectile to the list to delete
			[projectilesToDelete addObject:projectile];
		}
	}

	for (CCSprite *projectile in projectilesToDelete) {
		[_projectiles removeObject:projectile];
		[_batchNode removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];
}

-(void)addMonster:(Monster *)monster {

	// Determine where to spawn the monster along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = monster.contentSize.height/2;
	int maxY = winSize.height - monster.contentSize.height/2;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;

	// Create the monster slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	monster.position = ccp(winSize.width + (monster.contentSize.width/2), actualY);
	[_batchNode addChild:monster z:1];

	// Determine speed of the monster
	int minDuration = monster.minMoveDuration; //2.0;
	int maxDuration = monster.maxMoveDuration; //4.0;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;

	// Create the actions
    static int X_OFFSET = 40;
	id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(X_OFFSET+monster.contentSize.width/2, actualY)];
    id actionPause = [CCDelayTime actionWithDuration:0.5f];
    id actionMoveBack = [CCMoveTo actionWithDuration:actualDuration position:monster.position];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
	[monster runAction:[CCSequence actions:actionMove, actionPause, actionMoveBack, actionMoveDone, nil]];

	// Add to monsters array
	monster.tag = 1;
	[_monsters addObject:monster];

}

-(void)addMonsters {

    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;
    for (NSNumber *monsterIdNumber in curLevel.spawnIds) {
        int monsterId = monsterIdNumber.intValue;
        Monster *monster = [Monster monsterWithType:monsterId];
        if (monster != nil) {
            [self addMonster:monster];
        }
    }

}

-(void)gameLogic:(ccTime)dt {

    if (!_inLevel) return;
    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;
    double now = [[NSDate date] timeIntervalSince1970];

    // Check to see if level is over

    if (_levelBegin == 0) {
		//Start background music
		soundEngine.backgroundMusicVolume = 1.0f;
		[soundEngine rewindBackgroundMusic];
		[soundEngine playBackgroundMusic:@"background.caf"];
        self.levelBegin = now;
        return;
    } else {
        if (now - _levelBegin >= curLevel.spawnSeconds) {

            if (_monsters.count == 0) {
                // We're done
                _inLevel = FALSE;
                [self fadeOutMusic];
				ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;

				TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate*) [[UIApplication sharedApplication] delegate];

                if (curLevel.isFinalLevel) {
                    [delegate launchKillEnding];
                } else {
                    [delegate launchNextLevel];
                }
            }
            return;
        }
    }

    // Spawn monsters if appropriate
    if(_lastTimeMonsterAdded == 0 || now - _lastTimeMonsterAdded >= curLevel.spawnRate) {
        [self addMonsters];
        self.lastTimeMonsterAdded = now;
    }

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (_nextProjectile != nil) return;

    // Get current touch location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    // Play a sound!
    [soundEngine playEffect:@"shoot.wav"];

    // Set up initial location of projectile
    self.nextProjectile = [CCSprite spriteWithSpriteFrameName:@"Level_bullet.png"];

    // Determine the angle to rotate
    CGPoint shootVector = ccpSub(location, _player.position);
    CGFloat shootAngle = ccpToAngle(shootVector);
    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * shootAngle);

    // Determine how long it should take to rotate to that angle
    CGFloat curAngle = _player.rotation;
    CGFloat rotateDiff = cocosAngle - curAngle;
    if (rotateDiff > 180)
		rotateDiff -= 360;
    if (rotateDiff < -180)
        rotateDiff += 360;
    CGFloat rotateSpeed = 0.5f / 180; // Would take 0.5 seconds to rotate half a circle
    CGFloat rotateDuration = fabsf(rotateDiff * rotateSpeed);

    // Actually set up the actions
    [_player runAction:[CCSequence actions:
                        [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];

    // Make sure projectile is rotated at same angle
    _nextProjectile.rotation = cocosAngle;

    // Move projectile offscreen
    ccTime delta = 1.0f;
    CGPoint normalizedShootVector = ccpNormalize(shootVector);
    CGPoint overshotVector = ccpMult(normalizedShootVector, 420);

    [_nextProjectile runAction:[CCSequence actions:
                                [CCMoveBy actionWithDuration:delta position:overshotVector],
                                [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                                nil]];

    // Add to projectiles array
    _nextProjectile.tag = 2;

}

- (void)finishShoot {

    // Ok to add now - we've finished rotation!
    _nextProjectile.position = [_player convertToWorldSpace:ccp(_player.contentSize.width, _player.contentSize.height/2)];
    [_batchNode addChild:_nextProjectile z:1];
    [_projectiles addObject:_nextProjectile];

    // Release
    [_nextProjectile release];
    _nextProjectile = nil;

}

-(void)spriteMoveFinished:(id)sender {

    if (!_inLevel) return;
	CCSprite *sprite = (CCSprite *)sender;
	[_batchNode removeChild:sprite cleanup:YES];

	if (sprite.tag == 1) { // monster
		[_monsters removeObject:sprite];

        // TODO: Explosion
        self.inLevel = FALSE;
        ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;

		TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate*) [[UIApplication sharedApplication] delegate];

        if (!curLevel.isFinalLevel || self.monsterHit) {
            [self fadeOutMusic];
			[delegate launchLoseEnding];
        } else {
			[self fadeOutMusic];
            [delegate launchSuicideEnding];
        }

	} else if (sprite.tag == 2) { // projectile
		[_projectiles removeObject:sprite];
	}

}

- (void)draw {

    for (Monster *monster in _monsters) {

        static int lineBuffer = 10;
        int lineHeight = 3;
        int startY = monster.position.y - (monster.contentSize.height/2);
        int endY = monster.position.y + (monster.contentSize.height/2) - lineBuffer;
        int actualX = monster.position.x + (monster.contentSize.width/2) + lineHeight*2;

        static int maxColor = 200;
        static int colorBuffer = 55;
        float percentage = ((float) monster.hp) / ((float) monster.maxHp);
        int actualY = ((endY-startY) * percentage) + startY;
        int amtRed = ((1.0f-percentage)*maxColor)+colorBuffer;
        int amtGreen = (percentage*maxColor)+colorBuffer;

		ccDrawColor4B(amtRed, amtGreen, 0, 255);
        ccDrawLine(ccp(actualX, startY), ccp(actualX, actualY));
    }

    [super draw];
}

- (void) dealloc
{
    self.monsters = nil;
    self.projectiles = nil;
    self.nextProjectile = nil;

    [super dealloc];
}

-(void) fadeOutMusic {
	[[GameSoundManager sharedManager] fadeOutMusic];
}

@end
