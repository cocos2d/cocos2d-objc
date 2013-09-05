/* TouchesTest (c) Valentin Milea 2009
 */
#import "Paddle.h"
#import "cocos2d.h"

@implementation Paddle

- (CGRect)rectInPixels
{
	CGSize s = [self.texture contentSizeInPixels];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (CGRect)rect
{
	CGSize s = [self.texture contentSize];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

+ (id)paddleWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

- (id)initWithTexture:(CCTexture2D *)aTexture
{
	if ((self = [super initWithTexture:aTexture]) ) {

		state = kPaddleStateUngrabbed;
        
        self.userInteractionEnabled = YES;
	}

	return self;
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
	return CGRectContainsPoint(r, p);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (state != kPaddleStateUngrabbed) return;
	if ( ![self containsTouchLocation:[touches anyObject]] ) return;

	state = kPaddleStateGrabbed;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If it weren't for the TouchDispatcher, you would need to keep a reference
	// to the touch from touchesBegan and check that the current touch is the same
	// as that one.
	// Actually, it would be even more complicated since in the Cocos dispatcher
	// you get NSSets instead of 1 UITouch, so you'd need to loop through the set
	// in each touchXXX method.

	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");

    UITouch* touch = [ touches anyObject ];
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

	self.position = CGPointMake(touchPoint.x, self.position.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");

	state = kPaddleStateUngrabbed;
}
@end
