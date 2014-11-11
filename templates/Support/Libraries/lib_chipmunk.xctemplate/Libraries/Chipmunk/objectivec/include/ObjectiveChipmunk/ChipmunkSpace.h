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


/**
	Chipmunk spaces are simulation containers. You add a bunch of physics objects to a space (rigid bodies, collision shapes, and joints) and step the entire space forward through time as a whole.
	If you have Chipmunk Pro, you'll want to use the ChipmunkHastySpace subclass instead as it has iPhone specific optimizations.
	Unfortunately because of how Objective-C code is linked I can't dynamically substitute a ChipmunkHastySpace from a static library.
*/
@interface ChipmunkSpace : NSObject {
@protected
	struct cpSpace *_space;
	ChipmunkBody *_staticBody;
	
	NSMutableSet *_children;
	NSMutableArray *_handlers;
	
	id _userData;
}

/**
	The iteration count is how many solver passes the space should use when solving collisions and joints (default is 10).
	Fewer iterations mean less CPU usage, but lower quality (mushy looking) physics.
*/
@property(nonatomic, assign) int iterations;

/// Global gravity value to use for all rigid bodies in this space (default value is @c cpvzero).
@property(nonatomic, assign) cpVect gravity;

/**
	Global viscous damping value to use for all rigid bodies in this space (default value is 1.0 which disables damping).
	This value is the fraction of velocity a body should have after 1 second.
	A value of 0.9 would mean that each second, a body would have 80% of the velocity it had the previous second.
*/
@property(nonatomic, assign) cpFloat damping;

/// If a body is moving slower than this speed, it is considered idle. The default value is 0, which signals that the space should guess a good value based on the current gravity.
@property(nonatomic, assign) cpFloat idleSpeedThreshold;

/**
	Elapsed time before a group of idle bodies is put to sleep (defaults to infinity which disables sleeping).
	If an entire group of touching or jointed bodies has been idle for at least this long, the space will put all of the bodies into a sleeping state where they consume very little CPU.
*/
@property(nonatomic, assign) cpFloat sleepTimeThreshold;

/**
	Amount of encouraged penetration between colliding shapes..
	Used to reduce oscillating contacts and keep the collision cache warm.
	Defaults to 0.1. If you have poor simulation quality,
	increase this number as much as possible without allowing visible amounts of overlap.
*/
@property(nonatomic, assign) cpFloat collisionSlop;

/**
	Determines how fast overlapping shapes are pushed apart.
	Expressed as a fraction of the error remaining after each second.
	Defaults to pow(1.0 - 0.1, 60.0) meaning that Chipmunk fixes 10% of overlap each frame at 60Hz.
*/
@property(nonatomic, assign) cpFloat collisionBias;

/**
	Number of frames that contact information should persist.
	Defaults to 3. There is probably never a reason to change this value.
*/
@property(nonatomic, assign) cpTimestamp collisionPersistence;

/// Returns a pointer to the underlying cpSpace C struct
@property(nonatomic, readonly) cpSpace *space;

/**
	The space's designated static body.
	Collision shapes added to the body will automatically be marked as static shapes, and rigid bodies that come to rest while touching or jointed to this body will fall asleep.
*/
@property(nonatomic, readonly) ChipmunkBody *staticBody;

/**
	Retrieves the current (if you are in a callback from [ChipmunkSpace step:]) or most recent (outside of a [ChipmunkSpace step:] call) timestep.
*/
@property(nonatomic, readonly) cpFloat currentTimeStep;

/**
	Returns true if the space is currently executing a timestep.
*/
@property(nonatomic, readonly) BOOL locked;

/**
	An object that this space is associated with. You can use this get a reference to your game state or controller object from within callbacks.
	@attention Like most @c delegate properties this is a weak reference and does not call @c retain. This prevents reference cycles from occuring.
*/
@property(nonatomic, assign) id userData;

/// Get the ChipmunkSpace object associciated with a cpSpace pointer.
/// Undefined if the cpSpace wasn't created using Objective-Chipmunk.
+(ChipmunkSpace *)spaceFromCPSpace:(cpSpace *)space;

/**
  Set the default collision handler.
  The default handler is used for all collisions when a specific collision handler cannot be found.
  
  The expected method selectors are as follows:
	@code
- (bool)begin:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (bool)preSolve:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (void)postSolve:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (void)separate:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
	@endcode
*/
- (void)setDefaultCollisionHandler:(id)delegate
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;

/**
  Set a collision handler to handle specific collision types.
  The methods are called only when shapes with the specified collisionTypes collide.
  
  @c typeA and @c typeB should be the same object references set to ChipmunkShape.collisionType. They can be any uniquely identifying object.
	Class and global NSString objects work well as collision types as they are easy to get a reference to and do not require you to allocate any objects.
  
  The expected method selectors are as follows:
	@code
- (bool)begin:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (bool)preSolve:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (void)postSolve:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
- (void)separate:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
	@endcode
*/
- (void)addCollisionHandler:(id)delegate
	typeA:(cpCollisionType)a typeB:(cpCollisionType)b
	begin:(SEL)begin
	preSolve:(SEL)preSolve
	postSolve:(SEL)postSolve
	separate:(SEL)separate;


/**
  Add an object to the space.
  This can be any object that implements the ChipmunkObject protocol.
	This includes all the basic types such as ChipmunkBody, ChipmunkShape and ChipmunkConstraint as well as any composite game objects you may define that implement the protocol.
	@warning This method may not be called from a collision handler callback. See smartAdd: or ChipmunkSpace.addPostStepCallback:selector:context: for information on how to do that.
*/
-(id)add:(NSObject<ChipmunkObject> *)obj;

/**
  Remove an object from the space.
  This can be any object that implements the ChipmunkObject protocol.
	This includes all the basic types such as ChipmunkBody, ChipmunkShape and ChipmunkConstraint as well as any composite game objects you may define that implement the protocol.
	@warning This method may not be called from a collision handler callback. See smartRemove: or ChipmunkSpace.addPostStepCallback:selector:context: for information on how to do that.
*/
-(id)remove:(NSObject<ChipmunkObject> *)obj;

/// Check if a space already contains a particular object:
-(BOOL)contains:(NSObject<ChipmunkObject> *)obj;

/// If the space is locked and it's unsafe to call add: it will call addPostStepAddition: instead.
- (id)smartAdd:(NSObject<ChipmunkObject> *)obj;

/// If the space is locked and it's unsafe to call remove: it will call addPostStepRemoval: instead.
- (id)smartRemove:(NSObject<ChipmunkObject> *)obj;

/// Handy utility method to add a border of collision segments around a box. See ChipmunkShape for more information on the other parameters.
/// Returns an NSArray of the shapes. Since NSArray implements the ChipmunkObject protocol, you can use the [ChipmunkSpace remove:] method to remove the bounds.
- (NSArray *)addBounds:(cpBB)bounds thickness:(cpFloat)radius
	elasticity:(cpFloat)elasticity friction:(cpFloat)friction
	filter:(cpShapeFilter)filter collisionType:(id)collisionType;


/**
  Define a callback to be run just before [ChipmunkSpace step:] finishes.
  The main reason you want to define post-step callbacks is to get around the restriction that you cannot call the add/remove methods from a collision handler callback.
	Post-step callbacks run right before the next (or current) call to ChipmunkSpace.step: returns when it is safe to add and remove objects.
	You can only schedule one post-step callback per key value, this prevents you from accidentally removing an object twice. Registering a second callback for the same key is a no-op.
  
  The method signature of the method should be:
  @code
- (void)postStepCallback:(id)key</code></pre>
	@endcode
	
  This makes it easy to call a removal method on your game controller to remove a game object that died or was destroyed as the result of a collision:
  @code
[space addPostStepCallback:gameController selector:@selector(remove:) key:gameObject];
	@endcode
	
	@attention Not to be confused with post-solve collision handler callbacks.
	@warning @c target and @c object cannot be retained by the ChipmunkSpace. If you need to release either after registering the callback, use autorelease to ensure that they won't be deallocated until after [ChipmunkSpace step:] returns.
	@see ChipmunkSpace.addPostStepRemoval:
*/
- (BOOL)addPostStepCallback:(id)target selector:(SEL)selector key:(id)key;

/// Block type used with [ChipmunkSpace addPostStepBlock:]
typedef void (^ChipmunkPostStepBlock)(void);

/// Same as [ChipmunkSpace addPostStepCallback:] but with a block. The block is copied.
- (BOOL)addPostStepBlock:(ChipmunkPostStepBlock)block key:(id)key;

/// Add the Chipmunk Object to the space at the end of the step.
- (void)addPostStepAddition:(NSObject<ChipmunkObject> *)obj;

/// Remove the Chipmunk Object from the space at the end of the step.
- (void)addPostStepRemoval:(NSObject<ChipmunkObject> *)obj;

/// Return an array of ChipmunkNearestPointQueryInfo objects for shapes within @c maxDistance of @c point.
/// The point is treated as having the given group and layers.
- (NSArray *)pointQueryAll:(cpVect)point maxDistance:(cpFloat)maxDistance filter:(cpShapeFilter)filter;

/// Find the closest shape to a point that is within @c maxDistance of @c point.
/// The point is treated as having the given layers and group.
- (ChipmunkPointQueryInfo *)pointQueryNearest:(cpVect)point maxDistance:(cpFloat)maxDistance filter:(cpShapeFilter)filter;

/// Return a NSArray of ChipmunkSegmentQueryInfo objects for all the shapes that overlap the segment. The objects are unsorted.
- (NSArray *)segmentQueryAllFrom:(cpVect)start to:(cpVect)end radius:(cpFloat)radius filter:(cpShapeFilter)filter;

/// Returns the first shape that overlaps the given segment. The segment is treated as having the given group and layers. 
- (ChipmunkSegmentQueryInfo *)segmentQueryFirstFrom:(cpVect)start to:(cpVect)end radius:(cpFloat)radius filter:(cpShapeFilter)filter;

/// Returns a NSArray of all shapes whose bounding boxes overlap the given bounding box. The box is treated as having the given group and layers. 
- (NSArray *)bbQueryAll:(cpBB)bb filter:(cpShapeFilter)filter;

/// Returns a NSArray of ChipmunkShapeQueryInfo objects for all the shapes that overlap @c shape.
- (NSArray *)shapeQueryAll:(ChipmunkShape *)shape;

/// Returns true if the shape overlaps anything in the space.
- (BOOL)shapeTest:(ChipmunkShape *)shape;

/// Get a copy of the list of all the bodies in the space.
- (NSArray *)bodies;

/// Get a copy of the list of all the shapes in the space
- (NSArray *)shapes;

/// Get a copy of the list of all the constraints in the space
- (NSArray *)constraints;

/// Update all the static shapes.
- (void)reindexStatic;

/// Update the collision info for a single shape.
/// Can be used to update individual static shapes that were moved or active shapes that were moved that you want to query against.
- (void)reindexShape:(ChipmunkShape *)shape;

/// Update the collision info for all shapes attached to a body.
- (void)reindexShapesForBody:(ChipmunkBody *)body;

/// Step time forward. While variable timesteps may be used, a constant timestep will allow you to reduce CPU usage by using fewer iterations.
- (void)step:(cpFloat)dt;

@end

//MARK: Misc

/**
	A macro that defines and initializes shape variables for you in a collision callback.
	They are initialized in the order that they were defined in the collision handler associated with the arbiter.
	If you defined the handler as:
	
	@code
		[space addCollisionHandler:target typeA:foo typeB:bar ...]
	@endcode
	
	You you will find that @code a->collision_type == 1 @endcode and @code b->collision_type == 2 @endcode.
*/
#define CHIPMUNK_ARBITER_GET_SHAPES(__arb__, __a__, __b__) ChipmunkShape *__a__, *__b__; { \
	cpShape *__shapeA__, *__shapeB__; \
	cpArbiterGetShapes(__arb__, &__shapeA__, &__shapeB__); \
	__a__ = cpShapeGetUserData(__shapeA__); __b__ = cpShapeGetUserData(__shapeB__); \
}

#define CHIPMUNK_ARBITER_GET_BODIES(__arb__, __a__, __b__) ChipmunkBody *__a__, *__b__; { \
	cpBody *__bodyA__, *__bodyB__; \
	cpArbiterGetBodies(__arb__, &__bodyA__, &__bodyB__); \
	__a__ = cpBodyGetUserData(__bodyA__); __b__ = cpBodyGetUserData(__bodyB__); \
}


