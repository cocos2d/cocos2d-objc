#import "QuestionContainerSprite.h"

#define kLabelTag


@implementation QuestionContainerSprite

-(id)init
{
    if ((self = [super init]))
    {
        //Add label
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Answer 1" fontName:@"Arial" fontSize:12];
        [label setTag:100];

        //Add the background
		CGSize size = [[CCDirector sharedDirector] winSize];

        CCSprite* corner = [CCSprite spriteWithFile:@"corner.png"];

        int width = size.width * 0.9f - (corner.contentSize.width * 2);
        int height = size.height * 0.15f  - (corner.contentSize.height * 2);

        CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255 * .75) width:width height:height];
        layer.position = ccp(-width / 2, -height / 2);

        //First button is blue,
        //Second is red
        //Used for testing - change later
        static int a = 0;

        if (a == 0)
            [label setColor:ccBLUE];
        else {
            CCLOG(@"Color changed");
            [label setColor:ccRED];
        }

        a++;


        [self addChild:layer];

        corner.position = ccp(-(width / 2 + corner.contentSize.width / 2), -(height / 2 + corner.contentSize.height / 2));
        [self addChild:corner];

        CCSprite* corner2 = [CCSprite spriteWithFile:@"corner.png"];
        corner2.position = ccp(-corner.position.x, corner.position.y);
        corner2.flipX = YES;
        [self addChild:corner2];

        CCSprite* corner3 = [CCSprite spriteWithFile:@"corner.png"];
        corner3.position = ccp(corner.position.x, -corner.position.y);
        corner3.flipY = YES;
        [self addChild:corner3];

        CCSprite* corner4 = [CCSprite spriteWithFile:@"corner.png"];
        corner4.position = ccp(corner2.position.x, -corner2.position.y);
        corner4.flipX = YES;
        corner4.flipY = YES;
        [self addChild:corner4];

        CCSprite* edge = [CCSprite spriteWithFile:@"edge.png"];
        [edge setScaleX:width];
        edge.position = ccp(corner.position.x + (corner.contentSize.width / 2) + (width / 2), corner.position.y);
        [self addChild:edge];

        CCSprite* edge2 = [CCSprite spriteWithFile:@"edge.png"];
        [edge2 setScaleX:width];
        edge2.position = ccp(corner.position.x + (corner.contentSize.width / 2) + (width / 2), -corner.position.y);
        edge2.flipY = YES;
        [self addChild:edge2];

        CCSprite* edge3 = [CCSprite spriteWithFile:@"edge.png"];
        edge3.rotation = 90;
        [edge3 setScaleX:height];
        edge3.position = ccp(corner.position.x, corner.position.y + (corner.contentSize.height / 2) + (height / 2));
        [self addChild:edge3];

        CCSprite* edge4 = [CCSprite spriteWithFile:@"edge.png"];
        edge4.rotation = 270;
        [edge4 setScaleX:height];
        edge4.position = ccp(-corner.position.x, corner.position.y + (corner.contentSize.height / 2) + (height / 2));
        [self addChild:edge4];

        [self addChild:label];
    }

    return self;
}

@end
