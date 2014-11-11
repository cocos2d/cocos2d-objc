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

- (ChipmunkConstraint *)addConstraint:(ChipmunkConstraint *)obj;
- (ChipmunkConstraint *)removeConstraint:(ChipmunkConstraint *)obj;

@end

@implementation ChipmunkConstraint

@synthesize userData = _userData;

+(ChipmunkConstraint *)constraintFromCPConstraint:(cpConstraint *)constraint
{	
	ChipmunkConstraint *obj = constraint->userData;
	cpAssertHard([obj isKindOfClass:[ChipmunkConstraint class]], "'constraint->data' is not a pointer to a ChipmunkConstraint object.");
	
	return obj;
}

- (void) dealloc
{
	cpConstraint *constraint = self.constraint;
	[self.bodyA release];
	[self.bodyB release];
	cpConstraintDestroy(constraint);
	
	[super dealloc];
}

- (cpConstraint *)constraint
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// accessor macros
#define getter(type, lower, upper) \
- (type)lower {return cpConstraintGet##upper(self.constraint);}
#define setter(type, lower, upper) \
- (void)set##upper:(type)value {cpConstraintSet##upper(self.constraint, value);};
#define both(type, lower, upper) \
getter(type, lower, upper) \
setter(type, lower, upper)

both(cpFloat, maxForce, MaxForce)
both(cpFloat, errorBias, ErrorBias)
both(cpFloat, maxBias, MaxBias)
both(BOOL, collideBodies, CollideBodies)

-(cpFloat)impulse {return cpConstraintGetImpulse(self.constraint);}

-(ChipmunkSpace *)space {
	cpSpace *space = cpConstraintGetSpace(self.constraint);
	return (ChipmunkSpace *)(space ? cpSpaceGetUserData(space) : nil);
}

- (ChipmunkBody *)bodyA
{
	cpBody *body = cpConstraintGetBodyA(self.constraint);
	return (body ? cpBodyGetUserData(body) : nil);
}

//- (void)setBodyA:(ChipmunkBody *)value {
//	if(self.bodyA != value){
//		[self.bodyA release];
//		self.constraint->a = [[value retain] body];
//	}
//}

- (ChipmunkBody *)bodyB
{
	cpBody *body = cpConstraintGetBodyB(self.constraint);
	return (body ? cpBodyGetUserData(body) : nil);
}

//- (void)setBodyB:(ChipmunkBody *)value {
//	if(self.bodyB != value){
//		[self.bodyB release];
//		self.constraint->b = [[value retain] body];
//	}
//}

- (NSArray *)chipmunkObjects {return [NSArray arrayWithObject:self];}
- (void)addToSpace:(ChipmunkSpace *)space {[space addConstraint:self];}
- (void)removeFromSpace:(ChipmunkSpace *)space {[space removeConstraint:self];}

-(void)preSolve:(ChipmunkSpace *)space {}
-(void)postSolve:(ChipmunkSpace *)space {}

// MARK: Callbacks
static void
PreSolve(cpConstraint *constraint, cpSpace *space)
{
	[(ChipmunkConstraint *)constraint->userData preSolve:(ChipmunkSpace *)space->userData];
}

static void
PostSolve(cpConstraint *constraint, cpSpace *space)
{
	[(ChipmunkConstraint *)constraint->userData postSolve:(ChipmunkSpace *)space->userData];
}

// Check if the method was overridden.
// No reason to add the extra method overhead if it's not needed.
-(BOOL)methodIsOverriden:(SEL)selector
{
	return ([self methodForSelector:selector] != [[ChipmunkConstraint class] instanceMethodForSelector:selector]);
}

-(void)setupCallbacks
{
	if([self methodIsOverriden:@selector(preSolve:)]){
		cpConstraintSetPreSolveFunc(self.constraint, PreSolve);
	}
	
	if([self methodIsOverriden:@selector(postSolve:)]){
		cpConstraintSetPostSolveFunc(self.constraint, PostSolve);
	}
}

@end

// accessor macros
#define getter2(type, struct, lower, upper) \
- (type)lower {return struct##Get##upper((cpConstraint *)&_constraint);}
#define setter2(type, struct, lower, upper) \
- (void)set##upper:(type)value {struct##Set##upper((cpConstraint *)&_constraint, value);};
#define both2(type, struct, lower, upper) \
getter2(type, struct, lower, upper) \
setter2(type, struct, lower, upper)


@implementation ChipmunkPinJoint {
	cpPinJoint _constraint;
}

+ (id)pinJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB
{
	return [[[self alloc] initWithBodyA:a bodyB:b anchorA:anchorA anchorB:anchorB] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpPinJointInit(&_constraint, a.body, b.body, anchorA, anchorB);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpVect, cpPinJoint, anchorA, AnchorA)
both2(cpVect, cpPinJoint, anchorB, AnchorB)
both2(cpFloat, cpPinJoint, dist, Dist)

@end


@implementation ChipmunkSlideJoint {
	cpSlideJoint _constraint;
}

+ (id)slideJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB min:(cpFloat)min max:(cpFloat)max
{
	return [[[self alloc] initWithBodyA:a bodyB:b anchorA:anchorA anchorB:anchorB min:min max:max] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB min:(cpFloat)min max:(cpFloat)max
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpSlideJointInit(&_constraint, a.body, b.body, anchorA, anchorB, min, max);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpVect, cpSlideJoint, anchorA, AnchorA)
both2(cpVect, cpSlideJoint, anchorB, AnchorB)
both2(cpFloat, cpSlideJoint, min, Min)
both2(cpFloat, cpSlideJoint, max, Max)

@end


@implementation ChipmunkPivotJoint {
	cpPivotJoint _constraint;
}

+ (id)pivotJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB
{
	return [[[self alloc] initWithBodyA:a bodyB:b anchorA:anchorA anchorB:anchorB] autorelease];
}

+ (id)pivotJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot
{
	return [[[self alloc] initWithBodyA:a bodyB:b pivot:pivot] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpPivotJointInit(&_constraint, a.body, b.body, anchorA, anchorB);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot
{
	return [self initWithBodyA:a bodyB:b anchorA:[a worldToLocal:pivot] anchorB:[b worldToLocal:pivot]];
}

both2(cpVect, cpPivotJoint, anchorA, AnchorA)
both2(cpVect, cpPivotJoint, anchorB, AnchorB)

@end


@implementation ChipmunkGrooveJoint {
	cpGrooveJoint _constraint;
}

+ (id)grooveJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b grooveA:(cpVect)grooveA grooveB:(cpVect)grooveB anchorB:(cpVect)anchorB
{
	return [[[self alloc] initWithBodyA:a bodyB:b grooveA:grooveA grooveB:grooveB anchorB:anchorB] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b grooveA:(cpVect)grooveA grooveB:(cpVect)grooveB anchorB:(cpVect)anchorB
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpGrooveJointInit(&_constraint, a.body, b.body, grooveA, grooveB, anchorB);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpVect, cpGrooveJoint, grooveA, GrooveA)
both2(cpVect, cpGrooveJoint, grooveB, GrooveB)
both2(cpVect, cpGrooveJoint, anchorB, AnchorB)

@end


@implementation ChipmunkDampedSpring {
	cpDampedSpring _constraint;
}

+ (id)dampedSpringWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping
{
	return [[[self alloc] initWithBodyA:a bodyB:b anchorA:anchorA anchorB:anchorB restLength:restLength stiffness:stiffness damping:damping] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpDampedSpringInit(&_constraint, a.body, b.body, anchorA, anchorB, restLength, stiffness, damping);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpVect, cpDampedSpring, anchorA, AnchorA)
both2(cpVect, cpDampedSpring, anchorB, AnchorB)
both2(cpFloat, cpDampedSpring, restLength, RestLength)
both2(cpFloat, cpDampedSpring, stiffness, Stiffness)
both2(cpFloat, cpDampedSpring, damping, Damping)

@end


@implementation ChipmunkDampedRotarySpring {
	cpDampedRotarySpring _constraint;
}

+ (id)dampedRotarySpringWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping
{
	return [[[self alloc] initWithBodyA:a bodyB:b restAngle:restAngle stiffness:stiffness damping:damping] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpDampedRotarySpringInit(&_constraint, a.body, b.body, restAngle, stiffness, damping);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpFloat, cpDampedRotarySpring, restAngle, RestAngle)
both2(cpFloat, cpDampedRotarySpring, stiffness, Stiffness)
both2(cpFloat, cpDampedRotarySpring, damping, Damping)

@end


@implementation ChipmunkRotaryLimitJoint {
	cpRotaryLimitJoint _constraint;
}

+ (id)rotaryLimitJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max
{
	return [[[self alloc] initWithBodyA:a bodyB:b min:min max:max] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpRotaryLimitJointInit(&_constraint, a.body, b.body, min, max);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpFloat, cpRotaryLimitJoint, min, Min)
both2(cpFloat, cpRotaryLimitJoint, max, Max)

@end


@implementation ChipmunkSimpleMotor {
	cpSimpleMotor _constraint;
}

+ (id)simpleMotorWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate
{
	return [[[self alloc] initWithBodyA:a bodyB:b rate:rate] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpSimpleMotorInit(&_constraint, a.body, b.body, rate);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpFloat, cpSimpleMotor, rate, Rate)

@end


@implementation ChipmunkGearJoint {
	cpGearJoint _constraint;
}

+ (id)gearJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio
{
	return [[[self alloc] initWithBodyA:a bodyB:b phase:phase ratio:ratio] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpGearJointInit(&_constraint, a.body, b.body, phase, ratio);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpFloat, cpGearJoint, phase, Phase)
both2(cpFloat, cpGearJoint, ratio, Ratio)

@end


@implementation ChipmunkRatchetJoint {
	cpRatchetJoint _constraint;
}

+ (id)ratchetJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet
{
	return [[[self alloc] initWithBodyA:a bodyB:b phase:phase ratchet:ratchet] autorelease];
}

- (cpConstraint *)constraint {return (cpConstraint *)&_constraint;}

- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet
{
	if((self = [super init])){
		[a retain];
		[b retain];
		cpRatchetJointInit(&_constraint, a.body, b.body, phase, ratchet);
		self.constraint->userData = self;
		
		[self setupCallbacks];
	}
	
	return self;
}

both2(cpFloat, cpRatchetJoint, angle, Angle)
both2(cpFloat, cpRatchetJoint, phase, Phase)
both2(cpFloat, cpRatchetJoint, ratchet, Ratchet)

@end
