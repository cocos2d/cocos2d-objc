/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Lars Birkemose
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NewtonScene.h"
#import "IntroScene.h"
#import "NewtonConstants.h"
#import "NewtonSphere.h"
#import "LightBulb.h"
#import "Rope.h"

// -----------------------------------------------------------------------
#pragma mark NewtonScene
// -----------------------------------------------------------------------

@implementation NewtonScene
{
    LightBulb *_light;
    CCPhysicsNode *_physics;
}

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

+ (instancetype)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (instancetype)init
{
    // Apple recommend assigning self with supers return value, and handling self not created
    self = [super init];
    if (!self) return(nil);
     
    // Here is where custom code for the newton scene starts
    
    // set the clear color to a dark grey
    // This is a faster alternative to using a CCColorNode (former CCColorLayer) for a colored background
    glClearColor(NewtonBackgroundLuminance, NewtonBackgroundLuminance, NewtonBackgroundLuminance, 1.0);
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"newton.plist"];
    
    // find position for center letter (second C in cocos)
    CGPoint centerPos = ccp([CCDirector sharedDirector].viewSize.width * 0.5, [CCDirector sharedDirector].viewSize.height * 0.5);
    
    // add a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"left.png"]];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = NewtonButtonBackPosition;
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

    // add a reset button
    CCButton *resetButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"reset.png"]];
    resetButton.positionType = CCPositionTypeNormalized;
    resetButton.position = NewtonButtonResetPosition;
    [resetButton setTarget:self selector:@selector(onResetClicked:)];
    [self addChild:resetButton];

    // add toggle fire button
    CCButton *fireButton = [CCButton buttonWithTitle:@""
                                         spriteFrame:[CCSpriteFrame frameWithImageNamed:@"fire.off.png"]
                              highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"fire.on.png"]
                                 disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"fire.off.png"]];
    fireButton.positionType = CCPositionTypeNormalized;
    fireButton.position = NewtonButtonFirePosition;
    [fireButton setTarget:self selector:@selector(onFireClicked:)];
    [self addChild:fireButton];
    
    // Create light sprite, and enable user intercation. See the LightBulb class on how to handle this.
    // Created with a positive Z, to keep it above the newton spheres
    _light = [LightBulb spriteWithImageNamed:@"light.png"];
    _light.position = ccp([CCDirector sharedDirector].viewSize.width * NewtonLightPosition.x, [CCDirector sharedDirector].viewSize.height * NewtonLightPosition.y);
    _light.userInteractionEnabled = YES;
    [self addChild:_light z:1];
    
    // Create a physics node, to hold all the spheres
    // This node is a physics node, so that you can add physics to the spheres
    _physics = [CCPhysicsNode node];
    _physics.gravity = NewtonGravity;
    [self addChild:_physics];
    
    // show physice debug draw
    // _sphereNode.debugDraw = YES;
    
    // create an outline of the basic physics node, to keep physics "in door"
    // While the spheres in the template are hanging, and thus do not "fall out of the world", this is a normal step
    // Bodies made from poly lines, are default static
	CGRect worldRect = CGRectMake(0, 0, [CCDirector sharedDirector].viewSize.width, [CCDirector sharedDirector].viewSize.height);
    CCNode *outline = [CCNode node];
    outline.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:worldRect cornerRadius:0];
    outline.physicsBody.friction = NewtonOutlineFriction;
    outline.physicsBody.elasticity = NewtonOutlineElasticity;
    outline.physicsBody.collisionCategories = @[NewtonSphereCollisionOutline];
    outline.physicsBody.collisionMask = @[NewtonSphereCollisionSphere, NewtonSphereCollisionRope];
    [_physics addChild:outline];
    
    outline.physicsBody.collisionCategories = @[NewtonSphereCollisionOutline];
    outline.physicsBody.collisionMask = @[NewtonSphereCollisionSphere, NewtonSphereCollisionRope];
    
    // Create newton spheres
    for (int index = 0; index < NewtonLetterCount; index ++)
    {
        NewtonSphere *sphere = [NewtonSphere newtonSphereWithLetter:(NSString *)NewtonLetter[index]];
        sphere.position = ccpAdd(centerPos, ccpMult(NewtonLetterPosition[index], sphere.sphere.contentSize.width - NewtonSphereMargin + NewtonSphereSpacing));
        sphere.lightPos = _light.position;
        [_physics addChild:sphere];
       
        if (NewtonLetterHasRope[index])
        {
            if (NewtonRealRope)
            {
                Rope *rope = [Rope ropeWithSegments:NewtonRopeSegments
                                                objectA:sphere
                                                   posA:ccp(sphere.position.x, sphere.position.y + ((sphere.sphere.contentSize.height - NewtonSphereMargin) * 0.5))
                                                objectB:nil
                                                   posB:ccp(sphere.position.x, [CCDirector sharedDirector].viewSize.height)];
                [_physics addChild:rope];
            }
            else
            {
                // let the sphere pivot around the top
                CGPoint pivotPos = ccp(sphere.position.x, [CCDirector sharedDirector].viewSize.height);
                
                // create a static body to pivot around
                CCNode *pivotNode = [CCNode node];
                pivotNode.position = pivotPos;
                pivotNode.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
                pivotNode.physicsBody.type = CCPhysicsBodyTypeStatic;
                pivotNode.physicsBody.collisionMask = @[];
                [_physics addChild:pivotNode];
                
                [CCPhysicsJoint connectedPivotJointWithBodyA:sphere.physicsBody bodyB:pivotNode.physicsBody anchorA:ccpSub(pivotPos, sphere.position)];
            }
        }
    }
    
    // enable touch handling
    // See touchBegan below, for detailed information
    self.userInteractionEnabled = YES;
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    CCLOG(@"NewtonScene was deallocated");
    // clean up code goes here, should there be any
    
}

// -----------------------------------------------------------------------
#pragma mark - Enter and Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
    // Basically this will result in fewer having the need to override onEnter and onExit, but for clarity, it is shown
}

- (void)onExit
{
    
    
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------

- (void)onEnterTransitionDidFinish
{
    // always call super onEnterTransitionDidFinish first
    [super onEnterTransitionDidFinish];


}

- (void)onExitTransitionDidStart
{


    // always call super onExitTransitionDidStart last
    [super onExitTransitionDidStart];
}


// -----------------------------------------------------------------------
#pragma mark - Button callbacks
// -----------------------------------------------------------------------

- (void)onResetClicked:(id)sender
{
    // recreate the scene
    [[CCDirector sharedDirector] replaceScene:[NewtonScene scene]];
}

- (void)onBackClicked:(id)sender
{
    // pop previous scene back in place
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

- (void)onFireClicked:(id)sender
{
    // toggle the fire button
    CCButton *button = (CCButton *)sender;
    button.selected = !button.selected;
    
    // scan through nodes, and update effect on Newton Spheres
    for (CCNode *node in _physics.children)
    {
        if ([node isKindOfClass:[NewtonSphere class]])
        {
            NewtonSphere *sphere = (NewtonSphere *)node;
            sphere.effect = (button.selected) ? NewtonSphereEffectFire : NewtonSphereEffectLight;
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Touch implemenation
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // As userinteraction is enabled for the entire scene, touchBegan will be called, if the touch wasnt grabbed by any other touch responder
    // See touchBegan in LightBulb, for a more detailed explanation.
    CCLOG(@"The background was touched");
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // does nothing for now. Does not need to be implemented
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // does nothing for now. Does not need to be implemented
}

// -----------------------------------------------------------------------
#pragma mark - Scheduled update
// -----------------------------------------------------------------------
// Notice, that update is now automatically called for any descendant of CCNode, if the method is implemented
// Previously this had to be done in onEnter and onExit

- (void)update:(CCTime)delta
{
    // Brute force update of light
    for (CCNode *node in _physics.children)
    {
        // update light on all nodes which are of type NewtonSphere
        // Includes some "old scholl" casting.
        // Be careful with casting, unless you are 100% certain about what you do. Can create some nasty bugs
        if ([node isKindOfClass:[NewtonSphere class]])
        {
            NewtonSphere *sphere = (NewtonSphere *)node;
            sphere.lightPos = _light.position;
        }
    }
}

// -----------------------------------------------------------------------
@end
