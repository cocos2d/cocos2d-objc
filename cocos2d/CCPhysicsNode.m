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

// Do not change this value unless you redefine the cpBitmask type to have more than 32 bits.
#define MAX_CATEGORIES 32

// Maximum number of categories to cache
// There are usually few unique categories in a given simulation.
#define MAX_CACHED_CATEGORIES 64

// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}


@implementation CCPhysicsCollisionPair {
	cpArbiter *_arbiter;
}

-(cpArbiter *)arbiter {return _arbiter;}
-(void)setArbiter:(cpArbiter *)arbiter {_arbiter = arbiter;}

// Check that the arbiter is set and return it.
-(cpArbiter *)arb
{
	NSAssert(_arbiter, @"Do not store references to CCPhysicsCollisionPair objects.");
	return _arbiter;
}

-(BOOL)ignore
{
	return cpArbiterIgnore(self.arb);
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

@end


@implementation CCPhysicsNode {
	ChipmunkSpace *_space;
	
	NSMutableDictionary *_internedStrings;
	NSMutableArray *_categories;
	NSMutableDictionary *_cachedCategories;
	
	CCDrawNode *_debug;
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
		
		_debug = [CCDrawNode node];
		[self addChild:_debug z:1000]; // TODO magic z-order
	}
	
	return self;
}

-(CGPoint)gravity {return _space.gravity;}
-(void)setGravity:(CGPoint)gravity {_space.gravity = gravity;}

-(ccTime)sleepTimeThreshold {return _space.sleepTimeThreshold;}
-(void)setSleepTimeThreshold:(ccTime)sleepTimeThreshold {_space.sleepTimeThreshold = sleepTimeThreshold;}

-(void)setDelegate:(id<CCPhysicsCollisionPairDelegate>)delegate {NYI();}

//MARK: Queries:

-(CCPhysicsBody *)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(BOOL (^)(CCPhysicsBody *, CGPoint, CGFloat))block
{
	NYI();
	return nil;
}

-(CCPhysicsBody *)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(BOOL (^)(CCPhysicsBody *, CGPoint, CGPoint, CGFloat))block
{
	NYI();
	return nil;
}

-(BOOL)rectQuery:(CGRect)rect block:(BOOL (^)(CCPhysicsBody *))block
{
	NYI();
	return NO;
}

//MARK: Lifecycle and Scheduling

-(void)onEnter
{
	[super onEnter];
	[self scheduleUpdate];
}

-(void)onExit
{
	[super onExit];
	[self unscheduleUpdate];
}

-(void)fixedUpdate:(ccTime)delta
{
	[_space step:1.0f/60.0f];
}

-(void)update:(ccTime)delta
{
	// TODO need a real fixed time step here.
	[self fixedUpdate:1.0/60.0];
}

//MARK: Debug Drawing:

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
		_debug,
	};
	
	[_debug clear];
	cpSpaceDebugDraw(_space.space, &drawOptions);
	
	cpSpaceEachBody_b(_space.space, ^(cpBody *body){
		if(cpBodyGetType(body) == CP_BODY_TYPE_DYNAMIC){
			[_debug drawDot:cpBodyGetPosition(body) radius:5.0 color:ccc4f(1, 0, 0, 1)];
			
			cpVect cog = cpBodyLocalToWorld(body, cpBodyGetCenterOfGravity(body));
			[_debug drawDot:cog radius:5.0 color:ccc4f(1, 1, 0, 1)];
//			CCLOG(@"%p cog: %@", body, NSStringFromCGPoint(cog));
		}
	});
}

@end

@implementation CCPhysicsNode(ObjectiveChipmunk)

-(ChipmunkSpace *)space {return _space;}

//MARK: Interned Strings and Categories:

-(NSString *)internString:(NSString *)string
{
	if(string == nil) return nil;
	
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
