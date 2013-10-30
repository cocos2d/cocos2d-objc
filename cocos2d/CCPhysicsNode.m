/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Scott Lembcke
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

#import "CCPhysicsNode.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#import <objc/runtime.h>

// Do not change this value unless you redefine the cpBitmask type to have more than 32 bits.
#define MAX_CATEGORIES 32

// Maximum number of categories to cache
// There are usually few unique categories in a given simulation.
#define MAX_CACHED_CATEGORIES 64

// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}


@interface CCPhysicsNode(Private)

@property(nonatomic, readonly) CCPhysicsCollisionPair *collisionPairSingleton;

@end


@implementation CCPhysicsCollisionPair {
	@public
	cpArbiter *_arbiter;
}

-(cpArbiter *)arbiter {return _arbiter;}

// Check that the arbiter is set and return it.
-(cpArbiter *)arb
{
	NSAssert(_arbiter, @"This CCPhysicsCollisionPair has been invalidated. Do not store references to CCPhysicsCollisionPair objects.");
	return _arbiter;
}

-(CGFloat)friction {return cpArbiterGetFriction(self.arb);}
-(void)setFriction:(CGFloat)friction {cpArbiterSetFriction(self.arb, friction);}

-(CGFloat)restitution {return cpArbiterGetRestitution(self.arb);}
-(void)setRestitution:(CGFloat)restitution {cpArbiterSetRestitution(self.arb, restitution);}

-(CGPoint)surfaceVelocity {return cpArbiterGetSurfaceVelocity(self.arb);}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {cpArbiterSetSurfaceVelocity(self.arb, surfaceVelocity);}

-(CGFloat)totalKineticEnergy {return cpArbiterTotalKE(self.arb);}
-(CGPoint)totalImpulse {return cpArbiterTotalImpulse(self.arb);}

-(id)userData {return cpArbiterGetUserData(self.arb);}
-(void)setUserData:(id)userData {cpArbiterSetUserData(self.arb, userData);}

-(void)shapeA:(CCPhysicsShape *__autoreleasing *)shapeA shapeB:(CCPhysicsShape *__autoreleasing *)shapeB
{
	CHIPMUNK_ARBITER_GET_SHAPES(self.arb, a, b)
	(*shapeA) = a.userData;
	(*shapeB) = b.userData;
}

-(BOOL)ignore
{
	return cpArbiterIgnore(self.arb);
}

@end


/// Internal class used to wrap cpCollisionHandlers
@interface CCPhysicsCollisionHandler : NSObject {
	cpCollisionHandler *_handler;
	id _delegate;
	
	// Cache the CCPhysicsNode's collision pair singleton.
	CCPhysicsCollisionPair *_collisionPairSingleton;
	
	// Is this handler for a wildcard or not.
	BOOL _wildcard;
	
	// Cache all the methods, imps and selectors.
	Method _begin, _preSolve, _postSolve, _separate;
	IMP _beginImp, _preSolveImp, _postSolveImp, _separateImp;
	SEL _beginSel, _preSolveSel, _postSolveSel, _separateSel;
}

+(CCPhysicsCollisionHandler *)wrapCPHandler:(cpCollisionHandler *)cpHandler ForPhysicsNode:(CCPhysicsNode *)physicsNode wildcard:(BOOL)wildcard;

@property(nonatomic, assign) Method begin;
@property(nonatomic, assign) Method preSolve;
@property(nonatomic, assign) Method postSolve;
@property(nonatomic, assign) Method separate;

@end


@implementation CCPhysicsCollisionHandler

+(CCPhysicsCollisionHandler *)wrapCPHandler:(cpCollisionHandler *)cpHandler ForPhysicsNode:(CCPhysicsNode *)physicsNode wildcard:(BOOL)wildcard
{
	CCPhysicsCollisionHandler *ccHandler = [[self alloc] init];
	ccHandler->_delegate = physicsNode.collisionDelegate;
	ccHandler->_collisionPairSingleton = physicsNode.collisionPairSingleton;
	ccHandler->_wildcard = wildcard;
	
	ccHandler->_handler = cpHandler;
	cpHandler->userData = ccHandler;
	
	return ccHandler;
}

static cpBool PhysicsBegin(cpArbiter *arb, cpSpace *space, CCPhysicsCollisionHandler *handler){
	CHIPMUNK_ARBITER_GET_BODIES(arb, bodyA, bodyB);
	CCPhysicsCollisionPair *pair = handler->_collisionPairSingleton;
	pair->_arbiter = arb;
	
	cpBool (*imp)(id, SEL, id, id, id) = (__typeof(imp))handler->_beginImp;
	BOOL retval = imp(handler->_delegate, handler->_beginSel, pair, [bodyA.userData node], [bodyB.userData node]);
	
	if(!handler->_wildcard){
		retval = cpArbiterCallWildcardBeginA(arb, space) && retval;
		retval = cpArbiterCallWildcardBeginB(arb, space) && retval;
	}
	
	return retval;
}

-(void)setBegin:(Method)m
{
	NSAssert(m, @"Internal Error: Method is NULL.");
	_begin = m;
	_beginImp = method_getImplementation(m);
	_beginSel = method_getName(m);
	_handler->beginFunc = PhysicsBegin;
}

static cpBool PhysicsPreSolve(cpArbiter *arb, cpSpace *space, CCPhysicsCollisionHandler *handler){
	CHIPMUNK_ARBITER_GET_BODIES(arb, bodyA, bodyB);
	CCPhysicsCollisionPair *pair = handler->_collisionPairSingleton;
	pair->_arbiter = arb;
	
	cpBool (*imp)(id, SEL, id, id, id) = (__typeof(imp))handler->_preSolveImp;
	BOOL retval = imp(handler->_delegate, handler->_preSolveSel, pair, [bodyA.userData node], [bodyB.userData node]);
	
	if(!handler->_wildcard){
		retval = cpArbiterCallWildcardPreSolveA(arb, space) && retval;
		retval = cpArbiterCallWildcardPreSolveB(arb, space) && retval;
	}
	
	return retval;
}

-(void)setPreSolve:(Method)m
{
	NSAssert(m, @"Internal Error: Method is NULL.");
	_preSolve = m;
	_preSolveImp = method_getImplementation(m);
	_preSolveSel = method_getName(m);
	_handler->preSolveFunc = PhysicsPreSolve;
}

static void PhysicsPostSolve(cpArbiter *arb, cpSpace *space, CCPhysicsCollisionHandler *handler){
	CHIPMUNK_ARBITER_GET_BODIES(arb, bodyA, bodyB);
	CCPhysicsCollisionPair *pair = handler->_collisionPairSingleton;
	pair->_arbiter = arb;
	
	void (*imp)(id, SEL, id, id, id) = (__typeof(imp))handler->_postSolveImp;
	imp(handler->_delegate, handler->_postSolveSel, pair, [bodyA.userData node], [bodyB.userData node]);
	
	if(!handler->_wildcard){
		cpArbiterCallWildcardPostSolveA(arb, space);
		cpArbiterCallWildcardPostSolveB(arb, space);
	}
}

-(void)setPostSolve:(Method)m
{
	NSAssert(m, @"Internal Error: Method is NULL.");
	_postSolve = m;
	_postSolveImp = method_getImplementation(m);
	_postSolveSel = method_getName(m);
	_handler->postSolveFunc = PhysicsPostSolve;
}

static void PhysicsSeparate(cpArbiter *arb, cpSpace *space, CCPhysicsCollisionHandler *handler){
	CHIPMUNK_ARBITER_GET_BODIES(arb, bodyA, bodyB);
	CCPhysicsCollisionPair *pair = handler->_collisionPairSingleton;
	pair->_arbiter = arb;
	
	void (*imp)(id, SEL, id, id, id) = (__typeof(imp))handler->_separateImp;
	imp(handler->_delegate, handler->_separateSel, pair, [bodyA.userData node], [bodyB.userData node]);
	
	if(!handler->_wildcard){
		cpArbiterCallWildcardSeparateA(arb, space);
		cpArbiterCallWildcardSeparateB(arb, space);
	}
}

-(void)setSeparate:(Method)m
{
	NSAssert(m, @"Internal Error: Method is NULL.");
	_separate = m;
	_separateImp = method_getImplementation(m);
	_separateSel = method_getName(m);
	_handler->separateFunc = PhysicsSeparate;
}

@end


@implementation CCPhysicsNode {
	ChipmunkSpace *_space;
	
	// Interned strings for collision and category types.
	NSMutableDictionary *_internedStrings;
	
	// List of category strings used in this space.
	NSMutableArray *_categories;
	
	// Cached category arrays for category bitmasks.
	// Used for fast lookup when possible.
	// Limited to MAX_CACHED_CATEGORIES in size.
	NSMutableDictionary *_cachedCategories;
	
	// All collisions in a CCPhysicsNode share the same CCPhysicsCollisionPair.
	// The cpArbiter it wraps is simply changed each time.
	// That's one of the reasons you aren't allowed to keep references to CCPhysicsCollisionPair objects.
	CCPhysicsCollisionPair *_collisionPairSingleton;
	
	// Interned copies of the two reserved types.
	NSString *_wildcardType;
	
	// Need a way to retain the CCPhysicsCollisionHandler objects.
	NSMutableSet *_handlers;
	
	// CCDrawNode used for drawing the debug overlay.
	// Only allocated if CCPhysicsNode.debugDraw is YES.
	CCDrawNode *_debugDraw;
}

// Used by CCNode.physicsNode
-(BOOL)isPhysicsNode {return YES;}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpvzero;
		_space.sleepTimeThreshold = 0.5f;
		_space.userData = self;
		
		_internedStrings = [NSMutableDictionary dictionary];
		_categories = [NSMutableArray array];
		_cachedCategories = [NSMutableDictionary dictionary];
		
		// Intern the reserved string @"wildcard"
		_wildcardType = [self internString:@"wildcard"];
		
		_collisionPairSingleton = [[CCPhysicsCollisionPair alloc] init];
		_handlers = [NSMutableSet set];
	}
	
	return self;
}

-(CGPoint)gravity {return _space.gravity;}
-(void)setGravity:(CGPoint)gravity {_space.gravity = gravity;}

-(CCTime)sleepTimeThreshold {return _space.sleepTimeThreshold;}
-(void)setSleepTimeThreshold:(CCTime)sleepTimeThreshold {_space.sleepTimeThreshold = sleepTimeThreshold;}

// Collision Delegates

-(CCPhysicsCollisionPair *)collisionPairSingleton {return _collisionPairSingleton;}

-(CCPhysicsCollisionHandler *)handlerForTypeA:(NSString *)typeA typeB:(NSString *)typeB
{
	NSAssert(typeA != _wildcardType, @"'wildcard' is only allowed as the second type identifier.");
	
	BOOL wildcard = (typeB == _wildcardType);
	cpCollisionHandler *cpHandler = (wildcard ?
		cpSpaceAddWildcardHandler(_space.space, typeA) : cpSpaceAddCollisionHandler(_space.space, typeA, typeB)
	);
	
	// Assume that the userData pointer is a CCPhysicsCollisionHandler.
	// Dangerous, so be careful about mixing vanilla Chipmunk and Objective-Chipmunk handlers here.
	if(cpHandler->userData == nil){
		// Retain the handler in the _handlers set.
		[_handlers addObject:[CCPhysicsCollisionHandler wrapCPHandler:cpHandler ForPhysicsNode:self wildcard:wildcard]];
	}
	
	return cpHandler->userData;
}

-(void)registerDelegateMethodsForClass:(Class)class
{
	if(class == nil) return;
	
	// Search for superclass delegate methods first.
	[self registerDelegateMethodsForClass:class_getSuperclass(class)];
	
	unsigned int count;
	Method *methods = class_copyMethodList(class, &count);
	for(int i=0; i<count; i++){
		NSString *name = NSStringFromSelector(method_getName(methods[i]));
		
		if([name hasPrefix:@"ccPhysicsCollision"]){
			// self, _cmd, pair, typeA, typeB
			if(method_getNumberOfArguments(methods[i]) != 5) continue;
			
			NSArray *components = [name componentsSeparatedByString:@":"];
			NSString *phase = components[0];
			NSString *typeA = [self internString:components[1]];
			NSString *typeB = [self internString:components[2]];
			
			// TODO check return and argument types in the handler setters?
			char returnType[2];
			method_getReturnType(methods[i], returnType, 2);
			
			if([phase isEqualToString:@"ccPhysicsCollisionBegin"]){
				NSAssert(strcmp(returnType, "c") == 0, @"CCPhysicsCollisionBegin delegate methods must return a BOOL.");
				[self handlerForTypeA:typeA typeB:typeB].begin = methods[i];
			} else if([phase isEqualToString:@"ccPhysicsCollisionPreSolve"]){
				NSAssert(strcmp(returnType, "c") == 0, @"CCPhysicsCollisionPreSolve delegate methods must return a BOOL.");
				[self handlerForTypeA:typeA typeB:typeB].preSolve = methods[i];
			} else if([phase isEqualToString:@"ccPhysicsCollisionPostSolve"]){
				// TODO check for no return value?
				[self handlerForTypeA:typeA typeB:typeB].postSolve = methods[i];
			} else if([phase isEqualToString:@"ccPhysicsCollisionSeparate"]){
				[self handlerForTypeA:typeA typeB:typeB].separate = methods[i];
			}
		}
	}
	
	free(methods);
}

-(void)setCollisionDelegate:(NSObject<CCPhysicsCollisionDelegate> *)collisionDelegate
{
	NSAssert(_collisionDelegate == nil, @"The collision delegate can only be set once per CCPhysicsNode.");
	_collisionDelegate = collisionDelegate;
	
	// Recurse the inheritance tree to find all the matching collision delegate methods.
	[self registerDelegateMethodsForClass:collisionDelegate.class];
}

//MARK: Queries:

-(void)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(BOOL (^)(CCPhysicsShape *, CGPoint, CGFloat))block
{
	cpSpacePointQuery_b(_space.space, point, radius, CP_SHAPE_FILTER_ALL, ^(cpShape *shape, CGPoint p, CGFloat d, CGPoint g){
		block([cpShapeGetUserData(shape) userData], p, d);
	});
}

-(void)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(BOOL (^)(CCPhysicsShape *, CGPoint, CGPoint, CGFloat))block
{
	cpSpaceSegmentQuery_b(_space.space, start, end, 0.0, CP_SHAPE_FILTER_ALL, ^(cpShape *shape, CGPoint p, CGPoint n, CGFloat t){
		block([cpShapeGetUserData(shape) userData], p, n, t);
	});
}

-(void)rectQuery:(CGRect)rect block:(BOOL (^)(CCPhysicsShape *shape))block
{
	cpBB bb = cpBBNew(
		CGRectGetMinX(rect),
		CGRectGetMinY(rect),
		CGRectGetMaxX(rect),
		CGRectGetMaxY(rect)
	);
	
	cpSpaceBBQuery_b(_space.space, bb, CP_SHAPE_FILTER_ALL, ^(cpShape *shape){
		block([cpShapeGetUserData(shape) userData]);
	});
}

//MARK: Time Stepping

-(NSInteger)priority
{
	return NSIntegerMax;
}

-(void)fixedUpdate:(CCTime)delta
{
	[_space step:delta];
	
	// Null out the arbiter just in case somebody retained a pair.
	_collisionPairSingleton->_arbiter = NULL;
}

//MARK: Debug Drawing:

-(BOOL)debugDraw {return (_debugDraw != nil);}
-(void)setDebugDraw:(BOOL)debugDraw
{
	if(debugDraw){
		_debugDraw = [CCDrawNode node];
		[self addChild:_debugDraw z:NSIntegerMax];
	} else {
		[_debugDraw removeFromParent];
	}
}

static inline ccColor4F ToCCColor4f(cpSpaceDebugColor c){return (ccColor4F){c.r, c.g, c.b, c.a};}

static void
DrawCircle(cpVect p, cpFloat a, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawDot:p radius:r color:ToCCColor4f(fill)];}

static void
DrawSegment(cpVect a, cpVect b, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawSegmentFrom:a to:b radius:1.0 color:ToCCColor4f(color)];}

static void
DrawFatSegment(cpVect a, cpVect b, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawSegmentFrom:a to:b radius:r color:ToCCColor4f(fill)];}

static void
DrawPolygon(int count, const cpVect *verts, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawPolyWithVerts:verts count:count fillColor:ToCCColor4f(fill) borderWidth:1.0 borderColor:ToCCColor4f(outline)];}

static void
DrawDot(cpFloat size, cpVect pos, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawDot:pos radius:size/2.0 color:ToCCColor4f(color)];}

static cpSpaceDebugColor
ColorForShape(cpShape *shape, CCDrawNode *draw)
{return (cpSpaceDebugColor){0.8, 0.0, 0.0, 0.75};}

-(void)draw
{
	if(!_debugDraw) return;
	
	cpSpaceDebugDrawOptions drawOptions = {
		(cpSpaceDebugDrawCircleImpl)DrawCircle,
		(cpSpaceDebugDrawSegmentImpl)DrawSegment,
		(cpSpaceDebugDrawFatSegmentImpl)DrawFatSegment,
		(cpSpaceDebugDrawPolygonImpl)DrawPolygon,
		(cpSpaceDebugDrawDotImpl)DrawDot,
		
		CP_SPACE_DEBUG_DRAW_SHAPES | CP_SPACE_DEBUG_DRAW_CONSTRAINTS | CP_SPACE_DEBUG_DRAW_COLLISION_POINTS,
		
		{1.0, 1.0, 1.0, 1.0},
		(cpSpaceDebugDrawColorForShapeImpl)ColorForShape,
		{0.0, 1.0, 0.0, 1.0},
		{1.0, 0.0, 0.0, 1.0},
		_debugDraw,
	};
	
	[_debugDraw clear];
	cpSpaceDebugDraw(_space.space, &drawOptions);
	
	cpSpaceEachBody_b(_space.space, ^(cpBody *body){
		if(cpBodyGetType(body) == CP_BODY_TYPE_DYNAMIC){
			cpVect cog = cpBodyLocalToWorld(body, cpBodyGetCenterOfGravity(body));
			[_debugDraw drawDot:cog radius:1.5 color:ccc4f(1, 1, 0, 1)];
		}
	});
}

@end

@implementation CCPhysicsNode(ObjectiveChipmunk)

-(ChipmunkSpace *)space {return _space;}

//MARK: Interned Strings and Categories:

-(NSString *)internString:(NSString *)string
{
	if(string == nil || [string isEqualToString:@"default"]) return nil;
	
	NSString *interned = [_internedStrings objectForKey:string];
	if(interned == nil){
		interned = [string copy];
		[_internedStrings setObject:interned forKey:interned];
	}
	
	return interned;
}

-(NSUInteger)indexForCategory:(NSString *)category
{
	// Add the category if it doesn't exist yet.
	if(![_categories containsObject:category]){
		NSAssert(_categories.count <= MAX_CATEGORIES, @"A space can only track up to %d categories.", MAX_CATEGORIES);
		[_categories addObject:category];
	}
	
	return [_categories indexOfObject:category];
}

-(cpBitmask)bitmaskForCategories:(NSArray *)categories
{
	if(categories){
		cpBitmask bitmask = 0;
		
		for(NSString *category in categories){
			bitmask |= (1 << [self indexForCategory:category]);
		}
		
		if(_cachedCategories.count < MAX_CACHED_CATEGORIES){
			[_cachedCategories setObject:[categories copy] forKey:@(bitmask)];
		}
		
		return bitmask;
	} else {
		// nil (the default value) is equivalent to all categories.
		return CP_ALL_CATEGORIES;
	}
}

-(NSArray *)categoriesForBitmask:(cpBitmask)bitmask
{
	// nil (the default value) is equivalent to all categories.
	if(bitmask == CP_ALL_CATEGORIES) return nil;
	
	// First check if it has been cached.
	NSArray *cached = [_cachedCategories objectForKey:@(bitmask)];
	if(cached) return cached;
	
	NSString *arr[MAX_CATEGORIES] = {};
	NSUInteger count = 0;
	
	for(int i=0; i<_categories.count; i++){
		if(bitmask & (1<<i)){
			arr[i] = [_categories objectAtIndex:i];
		}
	}
	
	return [NSArray arrayWithObjects:arr count:count];
}

@end
