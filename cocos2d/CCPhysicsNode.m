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

#define CP_ALLOW_PRIVATE_ACCESS 1

#import "CCPhysicsNode.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import <objc/runtime.h>


// Do not change this value unless you redefine the cpBitmask type to have more than 32 bits.
#define MAX_CATEGORIES 32

// Maximum number of categories to cache
// There are usually few unique categories in a given simulation.
#define MAX_CACHED_CATEGORIES 64


@interface CCPhysicsNode(Private)

@property(nonatomic, readonly) CCPhysicsCollisionPair *collisionPairSingleton;

@end


@implementation CCPhysicsCollisionPair {
	@public
	cpArbiter *_arbiter;
}

-(cpArbiter *)arbiter {return _arbiter;}
-(void)setArbiter:(cpArbiter *)arbiter {_arbiter = arbiter;}

// Check that the arbiter is set and return it.
-(cpArbiter *)arb
{
	NSAssert(_arbiter, @"This CCPhysicsCollisionPair has been invalidated. Do not store references to CCPhysicsCollisionPair objects.");
	return _arbiter;
}

-(CCContactSet)contacts
{
	// TODO this needs to be fixed for 64 bit if CG types are disabled.
	// This function cast should be safe on any ABI that also supports objc_msgSend_stret().
	return ((CCContactSet (*)(cpArbiter *))cpArbiterGetContactPointSet)(self.arb);
}

-(CGFloat)friction {return cpArbiterGetFriction(self.arb);}
-(void)setFriction:(CGFloat)friction {cpArbiterSetFriction(self.arb, friction);}

-(CGFloat)restitution {return cpArbiterGetRestitution(self.arb);}
-(void)setRestitution:(CGFloat)restitution {cpArbiterSetRestitution(self.arb, restitution);}

-(CGPoint)surfaceVelocity {return CPV_TO_CCP(cpArbiterGetSurfaceVelocity(self.arb));}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {cpArbiterSetSurfaceVelocity(self.arb, CCP_TO_CPV(surfaceVelocity));}

-(CGFloat)totalKineticEnergy {return cpArbiterTotalKE(self.arb);}
-(CGPoint)totalImpulse {return CPV_TO_CCP(cpArbiterTotalImpulse(self.arb));}

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
	__weak id _delegate;
	
	// Cache the CCPhysicsNode's collision pair singleton.
	CCPhysicsCollisionPair *_collisionPairSingleton;
	
	// Is this handler for a wildcard or not.
	BOOL _wildcard;
	
	// Cache all the methods, imps and selectors.
	// TODO should move to using objc_msgSend instead?
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
    
    //List of moving static handlers that need updating due to thier parent nodes moving.
    NSMutableSet * _kineticNodes;
    
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
        _kineticNodes = [NSMutableSet set];
	}
	
	return self;
}

-(CGPoint)gravity {return CPV_TO_CCP(_space.gravity);}
-(void)setGravity:(CGPoint)gravity {_space.gravity = CCP_TO_CPV(gravity);}

-(int)iterations {return _space.iterations;}
-(void)setIterations:(int)iterations {_space.iterations = iterations;}

-(CCTime)sleepTimeThreshold {return _space.sleepTimeThreshold;}
-(void)setSleepTimeThreshold:(CCTime)sleepTimeThreshold {_space.sleepTimeThreshold = sleepTimeThreshold;}

-(NSMutableSet*)kineticNodes
{
    return _kineticNodes;
}

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
				NSAssert(strcmp(returnType, @encode(BOOL)) == 0, @"CCPhysicsCollisionBegin delegate methods must return a BOOL.");
				[self handlerForTypeA:typeA typeB:typeB].begin = methods[i];
			} else if([phase isEqualToString:@"ccPhysicsCollisionPreSolve"]){
				NSAssert(strcmp(returnType, @encode(BOOL)) == 0, @"CCPhysicsCollisionPreSolve delegate methods must return a BOOL.");
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

-(void)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(void (^)(CCPhysicsShape *, CGPoint, CGFloat))block
{
	cpSpacePointQuery_b(_space.space, CCP_TO_CPV(point), radius, CP_SHAPE_FILTER_ALL, ^(cpShape *shape, cpVect p, cpFloat d, cpVect g){
		block([cpShapeGetUserData(shape) userData], CPV_TO_CCP(p), d);
	});
}

-(void)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(void (^)(CCPhysicsShape *, CGPoint, CGPoint, CGFloat))block
{
	cpSpaceSegmentQuery_b(_space.space, CCP_TO_CPV(start), CCP_TO_CPV(end), 0.0, CP_SHAPE_FILTER_ALL, ^(cpShape *shape, cpVect p, cpVect n, cpFloat t){
		block([cpShapeGetUserData(shape) userData], CPV_TO_CCP(p), CPV_TO_CCP(n), t);
	});
}

-(void)rectQuery:(CGRect)rect block:(void (^)(CCPhysicsShape *shape))block
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
    NSSet * tempKinetics = [_kineticNodes copy];
    for(CCNode * node in tempKinetics)
    {
        NSAssert(node.physicsBody, @"Should have a physics body");
        NSAssert(node.physicsBody.type == CCPhysicsBodyTypeKinematic, @"Should be kinematic");
        
        [node.physicsBody updateKinetics:delta];
        if(node.physicsBody.type != CCPhysicsBodyTypeKinematic)
        {
            [_kineticNodes removeObject:node];
        }
    }
    
	[_space step:delta];
	
	// Null out the arbiter just in case somebody retained a pair.
	_collisionPairSingleton->_arbiter = NULL;
}

//MARK: Debug Drawing:
const cpSpaceDebugColor CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR_STATIC = {0.0, 0.0, 1.0, 0.8};
const cpSpaceDebugColor CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR_KINEMATIC = {1.0, 1.0, 0.0, 0.8};
const cpSpaceDebugColor CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR = {1.0, 0.0, 0.0, 0.25};
const cpSpaceDebugColor CC_PHYSICS_SHAPE_DEBUG_OUTLINE_COLOR = {1.0, 1.0, 1.0, 0.5};
const cpSpaceDebugColor CC_PHYSICS_SHAPE_JOINT_COLOR = {0.0, 1.0, 0.0, 0.5};
const cpSpaceDebugColor CC_PHYSICS_SHAPE_COLLISION_COLOR = {1.0, 0.0, 0.0, 0.5};

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

static inline CCColor* ToCCColor(cpSpaceDebugColor c){return [CCColor colorWithRed:c.r green:c.g blue:c.b alpha:c.a];}

static void
DrawCircle(cpVect p, cpFloat a, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawDot:CPV_TO_CCP(p) radius:r color:ToCCColor(fill)];}

static void
DrawSegment(cpVect a, cpVect b, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawSegmentFrom:CPV_TO_CCP(a) to:CPV_TO_CCP(b) radius:1.0 color:ToCCColor(color)];}

static void
DrawFatSegment(cpVect a, cpVect b, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawSegmentFrom:CPV_TO_CCP(a) to:CPV_TO_CCP(b) radius:r color:ToCCColor(fill)];}

static void
DrawPolygon(int count, const cpVect *verts, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{
#if !CP_USE_CGTYPES
	CGPoint _verts[count];
	for(int i=0; i<count; i++) _verts[i] = CPV_TO_CCP(verts[i]);
	[draw drawPolyWithVerts:_verts count:count fillColor:ToCCColor(fill) borderWidth:1.0 borderColor:ToCCColor(outline)];
#else
	[draw drawPolyWithVerts:verts count:count fillColor:ToCCColor(fill) borderWidth:1.0 borderColor:ToCCColor(outline)];
#endif
}

static void
DrawDot(cpFloat size, cpVect pos, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawDot:CPV_TO_CCP(pos) radius:size/2.0 color:ToCCColor(color)];}


static cpSpaceDebugColor
ColorForShape(cpShape *shape, CCDrawNode *draw)
{

    cpBodyType bodyType = cpBodyGetType(shape->body);
    
    if(bodyType == CP_BODY_TYPE_KINEMATIC)
    {
        return CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR_KINEMATIC;
    }
    if(bodyType == CP_BODY_TYPE_STATIC)
    {
        return CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR_STATIC;
    }
    
    return CC_PHYSICS_SHAPE_DEBUG_FILL_COLOR;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if(!_debugDraw) return;
	
	cpSpaceDebugDrawOptions drawOptions = {
		(cpSpaceDebugDrawCircleImpl)DrawCircle,
		(cpSpaceDebugDrawSegmentImpl)DrawSegment,
		(cpSpaceDebugDrawFatSegmentImpl)DrawFatSegment,
		(cpSpaceDebugDrawPolygonImpl)DrawPolygon,
		(cpSpaceDebugDrawDotImpl)DrawDot,
		
		CP_SPACE_DEBUG_DRAW_SHAPES | CP_SPACE_DEBUG_DRAW_CONSTRAINTS | CP_SPACE_DEBUG_DRAW_COLLISION_POINTS,
		
		CC_PHYSICS_SHAPE_DEBUG_OUTLINE_COLOR,
		(cpSpaceDebugDrawColorForShapeImpl)ColorForShape,
		CC_PHYSICS_SHAPE_JOINT_COLOR,
		CC_PHYSICS_SHAPE_COLLISION_COLOR,
		_debugDraw,
	};
	
	[_debugDraw clear];
	cpSpaceDebugDraw(_space.space, &drawOptions);
	
	cpSpaceEachBody_b(_space.space, ^(cpBody *body){
		if(cpBodyGetType(body) == CP_BODY_TYPE_DYNAMIC){
			cpVect cog = cpBodyLocalToWorld(body, cpBodyGetCenterOfGravity(body));
			[_debugDraw drawDot:CPV_TO_CCP(cog) radius:1.5 color:[CCColor colorWithRed:1 green:1 blue:0 alpha:1]];
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
		NSAssert(_categories.count < MAX_CATEGORIES, @"A space can only track up to %d categories.", MAX_CATEGORIES);
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
