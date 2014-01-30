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

#import "NewtonSphere.h"

// -----------------------------------------------------------------------
#pragma mark NewtonSphere
// -----------------------------------------------------------------------

@implementation NewtonSphere
{
    CCSprite *_highlight; 
    CCSprite *_shadow;
    CCParticleSystem *_fire;
    
    BOOL _grabbed;
    NSTimeInterval _previousTime;
    CGPoint _previousVelocity;
    CGPoint _previousPos;
}

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

+ (instancetype)newtonSphereWithLetter:(NSString *)letter;
{
    return([[NewtonSphere alloc] initWithLetter:letter]);
}

- (instancetype)initWithLetter:(NSString *)letter
{
    // Apple recommend assigning self with supers return value, and handling self not created
    self = [super init];
    if (!self) return(nil);
    
    // Custom code goes here
    // Images are expected to be in a previously loaded sprite sheet (See NewtonScene)
    // *********************
    
    // As the sphere is a compound object, it should be build on a simple CCNode with no content size. This makes placement a lot easier
    
    // fist create a sphere with a letter
    _sphere = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"letter.%@.png", letter]];
    [self addChild:_sphere];
    
    // Give the sprite a physics body.
    // Use the content size from the sphere, and subtract NewtonSphereMargin (a constant), as the image we are using, has a transparent edge
    CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:(_sphere.contentSize.width - NewtonSphereMargin) * 0.5 andCenter:CGPointZero];
    
    // Assign the physics to our base node
    self.physicsBody = body;
    
    // Set the physics properties, trying to simulate a newtons cradle
    body.friction = NewtonSphereFriction;
    body.elasticity = NewtonSphereElasticity;
    
    // Assign the collision category
    // As you can assign several categories, this becomes an extremely flexible and clever way of filtering collisions.
    body.collisionCategories = @[NewtonSphereCollisionSphere];
    
    // Spheres should collide with both other spheres, and the outline
    body.collisionMask = @[NewtonSphereCollisionSphere, NewtonSphereCollisionOutline];

    // Give the sphere a random color. Not white and black
    // randomColor will create a pattern 001 -> 110, which are then used to create RGB
    int randomColor = 1 + (arc4random() % 5);
    _sphere.color = [CCColor colorWithRed:(randomColor & 1) green:(randomColor >> 1 & 1) blue:(randomColor >> 2 & 1)];
    
    // Create the shadow
    _shadow = [CCSprite spriteWithImageNamed:@"letter.shadow.png"];
    [self addChild:_shadow];
    
    // Create the highlight
    _highlight = [CCSprite spriteWithImageNamed:@"letter.highlight.png"];
    [self addChild:_highlight];
    
    // enable touch for the sphere
    self.userInteractionEnabled = YES;
    
    // body.collisionType = color;
    
    // create fire
    _fire = [CCParticleSystem particleWithFile:@"fire.plist"];
    _fire.particlePositionType = CCParticleSystemPositionTypeFree;

    // place the fire effect in upper half of sphere (looks better)
    _fire.position = ccp(0, _sphere.contentSize.height * NewtonParticleDisplacement);

    // ----------
    // Issue #484
    // There is a bug in particle systems, that prevents free particles from being scaled. In stead the properties must be scaled.
    float particleScale = NewtonParticleScale * [CCDirector sharedDirector].viewSize.width / 1000;
    _fire.startSize *= particleScale;
    _fire.startSizeVar *= particleScale;
    _fire.endSize *= particleScale;
    _fire.endSizeVar *= particleScale;
    _fire.gravity = ccpMult(_fire.gravity, particleScale);
    _fire.posVar = ccpMult(_fire.posVar, particleScale);
    
    // this produces weird results
    // _fire.scale = particleScale;
    // ----------
    
    [self addChild:_fire];
    
    // set effect mode and control data
    _lightPos = CGPointZero;
    self.effect = NewtonSphereEffectLight;
    
    // done
    return(self);
}

- (void)dealloc
{
    CCLOG(@"A Newton Sphere was deallocated");
    // clean up code goes here, should there be any
    
}

// -----------------------------------------------------------------------
#pragma mark - Hit test override
// -----------------------------------------------------------------------

- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    // The Newton Sphere is a compound physics object, and thus based on a CCNode.
    // Because of that, the object has no content size, and default touch registration will not work
    // Giving the node a content size, will ruin the compound placement.
    
    // To fix this, the hit test function is overridden.
    // As this is a simple sphere, the hit test will return YES, if the touch distance to sphere, is less than radius
    
    // calculate distance from touch to node position
    float distance = ccpDistance(pos, self.position);
    return(distance < _sphere.contentSize.width * 0.5);
}

// -----------------------------------------------------------------------
#pragma mark - Touch implementation
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // The spehre was grabbed.
    // To move the sphere around in a "believeable" manner, two things has to be done
    // 1) the mass has to be increased, to simulate "an unstopable force" (please dont add an imovable object to the space, or chipmunk will crash ... no it wont :)
    self.physicsBody.mass = NewtonSphereMovingMass;

    // 2) Save state data, like time and position, so that a velocity can be calculated when moving the sphere.
    // Velocity must be set on forced movement, otherwise the collisions will feel "mushy"
    _grabbed = YES;
    _previousVelocity = CGPointZero;
    _previousTime = event.timestamp;
    _previousPos = touch.locationInWorld;
    CCLOG(@"A Newton Sphere was touched");
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // on each move, calculate a velocity used in update, and save new state data
    _previousVelocity = ccpMult( ccpSub(touch.locationInWorld, _previousPos), 1 / (event.timestamp - _previousTime));
    _previousTime = event.timestamp;
    _previousPos = touch.locationInWorld;
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // if not grabbed anymore, return mass to normal
    _grabbed = NO;
    self.physicsBody.mass = NewtonSphereNormalMass;
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self touchEnded:touch withEvent:event];
}

// -----------------------------------------------------------------------
#pragma mark - Scheduled update
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    // update needs not to be scheduled anymore. Just overriding update:, will automatically cause it to be called
    
    // if the sphere is grabbed, force it into position, and update its velocity.
    if (_grabbed)
    {
        self.position = _previousPos;
        self.physicsBody.velocity = _previousVelocity;
    }
    
    // check which effect is currently active
    switch (_effect)
    {
        case NewtonSphereEffectLight:
        {
            // if light is active, calculate the light vector (not normalized)
            CGPoint lightVector = ccpSub(_lightPos, self.position);
            
            // calculate angle and distance to light source
            float angle = ccpToAngle(lightVector);
            float distance = ccpLength(lightVector);
            
            // set highlight and shadow rotation, based on angle
            // Note.
            // Highlight and shadow are children of the physics node, and will as such, rotate with it
            // As highlight and shadow should only rotate with light position, self.rotation is subtracted
            _highlight.rotation = 90 - (angle * 180 / M_PI) - self.rotation;
            _shadow.rotation = 90 - (angle * 180 / M_PI) - self.rotation;
            
            // calculate highlight and shadow intensity, based on distance
            // normalize distance, based on screen width
            distance /= [CCDirector sharedDirector].viewSize.width;
            
            // calculate opacity for highlight and shadow, to make the lighting look believeable
            // I know ... this is kind of hardcoded ... Sorry ...
            _highlight.opacity = clampf(1 - (2 * distance),0,1);
            _shadow.opacity = clampf(3 * distance,0,1);
            
            break;
        }
        case NewtonSphereEffectFire:
        {
            // In fiery mode, highlight is not visible, and shadow is placed at zero rotation, so give the illusion of a burnt bottom
            _shadow.rotation = -self.rotation;
            break;
        }
    }
    
    // fire might also be present in light mode, as the flames die out.
    // So fire rotation is always set to zero, no matter the mode.
    _fire.rotation = -self.rotation;
}

// -----------------------------------------------------------------------
#pragma mark - Property implementation
// -----------------------------------------------------------------------

- (void)setEffect:(NewtonSphereEffect)effect
{
    // sets the effect for the Newton Sphere
    _effect = effect;
    
    switch (effect)
    {
        case NewtonSphereEffectLight:
        {
            // highlight visible, and no fire
            _highlight.visible = YES;
            [_fire stopSystem];
            break;
        }
        case NewtonSphereEffectFire:
        {
            // highlight not visible, full opacity on shadow, and fire enabled
            _highlight.visible = NO;
            _shadow.opacity = 1.00;
            [_fire resetSystem];
        }
    }
}

// -----------------------------------------------------------------------

@end
