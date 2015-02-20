#import "TestBase.h"

#define CLASS_NAME KeyboardTest

@interface CLASS_NAME : TestBase{
        CCLabelTTF* _message;
}
@end

@implementation CLASS_NAME

- (void) setupBasicLoopTest
{
    self.subTitle = @"On desktop platforms, pressing a key should change the message on screen.";

    _message = [CCLabelTTF labelWithString:@"Last Key:" fontName:@"HelveticaNeue-Light" fontSize:32];
    _message.positionType = CCPositionTypeNormalized;
    _message.position = ccp(0.5, 0.5);
    _message.horizontalAlignment = CCTextAlignmentCenter;

    self.userInteractionEnabled = YES;

    CCNode *keycatcher = [CCNode node];
    keycatcher.userInteractionEnabled = YES;
    keycatcher.name = @"key catcher";

    [self addChild:keycatcher];
    [self addChild:_message];
}

-(void)keyDown:(NSEvent *)theEvent
{
    NSString *s = [NSString stringWithFormat:@"Key Down: code=%d  chars=%@", theEvent.keyCode, theEvent.characters];
    _message.string = s;
}

-(void)keyUp:(NSEvent *)theEvent
{
    NSString *s = [NSString stringWithFormat:@"Key Up: code=%d  chars=%@", theEvent.keyCode, theEvent.characters];
    _message.string = s;
}

@end