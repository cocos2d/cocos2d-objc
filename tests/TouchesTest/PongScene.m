/* TouchesTest (c) Valentin Milea 2009
 */
#import "PongScene.h"
#import "Paddle.h"
#import "Ball.h"

enum tagPlayer {
	kHighPlayer,
	kLowPlayer
} Player;

#define kStatusBarHeight 20.0f
#define k1UpperLimit (480.0f - kStatusBarHeight)

enum {
	kSpriteTag
};

@interface PongLayer ()
@end

@implementation PongScene

- (id)init
{
	if ((self = [super init]) == nil) return nil;

	PongLayer *pongLayer = [PongLayer node];
	[self addChild:pongLayer];

	return self;
}

- (void)onExit
{
	[super onExit];
}

@end

@implementation PongLayer

- (id)init
{
	if ((self = [super init]) == nil) return nil;

	ballStartingVelocity = CGPointMake(20.0f, -100.0f);

	ball = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
	ball.position = CGPointMake(160.0f, 240.0f);
	ball.velocity = ballStartingVelocity;
	[self addChild:ball];

	CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"paddle.png"];

	NSMutableArray *paddlesM = [NSMutableArray arrayWithCapacity:4];

	Paddle *paddle = [Paddle paddleWithTexture:paddleTexture];
	paddle.position = CGPointMake(160, 15);
	[paddlesM addObject:paddle];

	paddle = [Paddle paddleWithTexture:paddleTexture];
	paddle.position = CGPointMake(160, 480 - kStatusBarHeight - 15);
	[paddlesM addObject:paddle];

	paddle = [Paddle paddleWithTexture:paddleTexture];
	paddle.position = CGPointMake(160, 100);
	[paddlesM addObject:paddle];

	paddle = [Paddle paddleWithTexture:paddleTexture];
	paddle.position = CGPointMake(160, 480 - kStatusBarHeight - 100);
	[paddlesM addObject:paddle];

	paddles = [paddlesM copy];

	for (Paddle *paddle in paddles)
		[self addChild:paddle];

	[self schedule:@selector(doStep:)];

	return self;
}

- (void)dealloc
{
	[ball release];
	[paddles release];
	[super dealloc];
}

- (void)resetAndScoreBallForPlayer:(int)player
{
	ballStartingVelocity = ccpMult(ballStartingVelocity, -1.1f);
	ball.velocity = ballStartingVelocity;
	ball.position = CGPointMake(160.0f, 240.0f);

	// TODO -- scoring
}

- (void)doStep:(ccTime)delta
{
	[ball move:delta];

	for (Paddle *paddle in paddles)
		[ball collideWithPaddle:paddle];

	if (ball.position.y > 480 - kStatusBarHeight + ball.radius)
		[self resetAndScoreBallForPlayer:kLowPlayer];
	else if (ball.position.y < -ball.radius)
		[self resetAndScoreBallForPlayer:kHighPlayer];
}

@end
