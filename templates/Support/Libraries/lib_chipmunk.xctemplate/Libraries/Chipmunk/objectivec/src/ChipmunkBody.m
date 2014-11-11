/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#define CP_ALLOW_PRIVATE_ACCESS 1
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

@interface ChipmunkSpace(DoubleDispatch)

- (ChipmunkBody *)addBody:(ChipmunkBody *)obj;
- (ChipmunkBody *)removeBody:(ChipmunkBody *)obj;

@end

@implementation ChipmunkBody {
	cpBody _body;
	id _userData;
}

// MARK: Integration Helpers

-(void)updateVelocity:(cpFloat)dt gravity:(cpVect)gravity damping:(cpFloat)damping
{
	cpBodyUpdateVelocity(&_body, gravity, damping, dt);
}

-(void)updatePosition:(cpFloat)dt
{
	cpBodyUpdatePosition(&_body, dt);
}

static void
VelocityFunction
(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	[(ChipmunkBody *)body->userData updateVelocity:dt gravity:gravity damping:damping];
}

static void
PositionFunction
(cpBody *body, cpFloat dt)
{
	[(ChipmunkBody *)body->userData updatePosition:dt];
}

// Check if the method was overridden.
// No reason to add the extra method overhead if it's not needed.
-(BOOL)methodIsOverriden:(SEL)selector
{
	return ([self methodForSelector:selector] != [[ChipmunkBody class] instanceMethodForSelector:selector]);
}

// MARK: Constructors

+(ChipmunkBody *)bodyFromCPBody:(cpBody *)body
{	
	ChipmunkBody *obj = body->userData;
	cpAssertHard([obj isKindOfClass:[ChipmunkBody class]], "'body->data' is not a pointer to a ChipmunkBody object.");
	
	return obj;
}

+ (id)bodyWithMass:(cpFloat)mass andMoment:(cpFloat)moment
{
	return [[[self alloc] initWithMass:mass andMoment:moment] autorelease];
}

+ (id)staticBody
{
	ChipmunkBody *body = [[self alloc] initWithMass:0.0f andMoment:0.0f];
	body.type = CP_BODY_TYPE_STATIC;
	
	return [body autorelease];
}

+ (id)kinematicBody
{
	ChipmunkBody *body = [[self alloc] initWithMass:0.0f andMoment:0.0f];
	body.type = CP_BODY_TYPE_KINEMATIC;
	
	return [body autorelease];
}

- (id)initWithMass:(cpFloat)mass andMoment:(cpFloat)moment
{
	if((self = [super init])){
		cpBodyInit(&_body, mass, moment);
		_body.userData = self;
		
		// Setup integration callbacks if necessary.
		if([self methodIsOverriden:@selector(updateVelocity:gravity:damping:)]){
			_body.velocity_func = VelocityFunction;
		}
		
		if([self methodIsOverriden:@selector(updatePosition:)]){
			_body.position_func = PositionFunction;
		}
	}
	
	return self;
}

- (void) dealloc
{
	cpBodyDestroy(&_body);
	[super dealloc];
}

- (cpTransform)transform {return _body.transform;}
- (cpBody *)body {return &_body;}


@synthesize userData = _userData;

// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return cpBodyGet##upper(&_body);}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {cpBodySet##upper(&_body, value);};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)


both(cpBodyType, type, Type)
both(cpFloat, mass, Mass)
both(cpFloat, moment, Moment)
both(cpVect, centerOfGravity, CenterOfGravity)
both(cpVect, position, Position)
both(cpVect, velocity, Velocity)
both(cpVect, force, Force)
both(cpFloat, angle, Angle)
both(cpFloat, angularVelocity, AngularVelocity)
both(cpFloat, torque, Torque)

-(ChipmunkSpace *)space {
	cpSpace *space = cpBodyGetSpace(&_body);
	return (ChipmunkSpace *)(space ? cpSpaceGetUserData(space) : nil);
}

- (cpFloat)kineticEnergy {return cpBodyKineticEnergy(&_body);}

- (cpVect)localToWorld:(cpVect)v {return cpBodyLocalToWorld(&_body, v);}
- (cpVect)worldToLocal:(cpVect)v {return cpBodyWorldToLocal(&_body, v);}

- (cpVect)velocityAtLocalPoint:(cpVect)p {return cpBodyGetVelocityAtLocalPoint(&_body, p);}
- (cpVect)velocityAtWorldPoint:(cpVect)p {return cpBodyGetVelocityAtWorldPoint(&_body, p);}

- (void)applyForce:(cpVect)force atLocalPoint:(cpVect)point {cpBodyApplyForceAtLocalPoint(&_body, force, point);}
- (void)applyForce:(cpVect)force atWorldPoint:(cpVect)point {cpBodyApplyForceAtWorldPoint(&_body, force, point);}
- (void)applyImpulse:(cpVect)impulse atLocalPoint:(cpVect)point {cpBodyApplyImpulseAtLocalPoint(&_body, impulse, point);}
- (void)applyImpulse:(cpVect)impulse atWorldPoint:(cpVect)point {cpBodyApplyImpulseAtWorldPoint(&_body, impulse, point);}

- (bool)isSleeping {return cpBodyIsSleeping(&_body);}

- (void)activate {cpBodyActivate(&_body);}
- (void)activateStatic:(ChipmunkShape *)filter {cpBodyActivateStatic(&_body, filter.shape);}
- (void)sleepWithGroup:(ChipmunkBody *)group {cpBodySleepWithGroup(&_body, group.body);}
- (void)sleep {cpBodySleep(&_body);}

- (NSArray *)chipmunkObjects {return [NSArray arrayWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addBody:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeBody:self];}

static void PushShape(cpBody *ignored, cpShape *shape, NSMutableArray *arr){[arr addObject:shape->userData];}
- (NSArray *)shapes
{
	NSMutableArray *arr = [NSMutableArray array];
	cpBodyEachShape(&_body, (cpBodyShapeIteratorFunc)PushShape, arr);
	
	return arr;
}

static void PushConstraint(cpBody *ignored, cpConstraint *constraint, NSMutableArray *arr){[arr addObject:constraint->userData];}
- (NSArray *)constraints
{
	NSMutableArray *arr = [NSMutableArray array];
	cpBodyEachConstraint(&_body, (cpBodyConstraintIteratorFunc)PushConstraint, arr);
	
	return arr;
}

static void CallArbiterBlock(cpBody *body, cpArbiter *arbiter, ChipmunkBodyArbiterIteratorBlock block){block(arbiter);}
- (void)eachArbiter:(ChipmunkBodyArbiterIteratorBlock)block
{
	cpBodyEachArbiter(&_body, (cpBodyArbiterIteratorFunc)CallArbiterBlock, block);
}

@end
