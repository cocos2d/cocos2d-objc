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

@class ChipmunkPointQueryInfo;
@class ChipmunkSegmentQueryInfo;


/// Abstract base class for collsion shape types.
@interface ChipmunkShape : NSObject <ChipmunkBaseObject> {
@private
	id _userData;
}

/// Get the ChipmunkShape object associciated with a cpShape pointer.
/// Undefined if the cpShape wasn't created using Objective-Chipmunk.
+(ChipmunkShape *)shapeFromCPShape:(cpShape *)shape;

/// Returns a pointer to the underlying cpShape C struct.
@property(nonatomic, readonly) cpShape *shape;

/// The ChipmunkBody that this shape is attached to.
@property(nonatomic, retain) ChipmunkBody *body;

// TODO doc
@property(nonatomic, assign) cpFloat mass;
@property(nonatomic, assign) cpFloat density;
@property(nonatomic, readonly) cpFloat moment;
@property(nonatomic, readonly) cpFloat area;
@property(nonatomic, readonly) cpVect centerOfGravity;

/// The axis-aligned bounding box for this shape.
@property(nonatomic, readonly) cpBB bb;

/// Sensor shapes send collision callback messages, but don't create a collision response.
@property(nonatomic, assign) BOOL sensor;

/// How bouncy this shape is.
@property(nonatomic, assign) cpFloat elasticity;

/// How much friction this shape has.
@property(nonatomic, assign) cpFloat friction;

/**
	The velocity of the shape's surface.
	This velocity is used in the collision response when calculating the friction only.
*/
@property(nonatomic, assign) cpVect surfaceVelocity;

/**
	An object reference used as a collision type identifier. This is used when defining collision handlers.
	@attention Like most @c delegate properties this is a weak reference and does not call @c retain.
*/
@property(nonatomic, assign) cpCollisionType collisionType;

/**
	The collision filtering parameters of this shape.
*/
@property(nonatomic, assign) cpShapeFilter filter;

/// Get the space the body is added to.
@property(nonatomic, readonly) ChipmunkSpace *space;

/**
	An object that this shape is associated with. You can use this get a reference to your game object or controller object from within callbacks.
	@attention Like most @c delegate properties this is a weak reference and does not call @c retain. This prevents reference cycles from occuring.
*/
@property(nonatomic, assign) id userData;

/// Update and cache the axis-aligned bounding box for this shape.
- (cpBB)cacheBB;

- (ChipmunkPointQueryInfo *)pointQuery:(cpVect)point;
- (ChipmunkSegmentQueryInfo *)segmentQueryFrom:(cpVect)start to:(cpVect)end radius:(cpFloat)radius;

@end


@interface ChipmunkPointQueryInfo : NSObject {
	@private
	cpPointQueryInfo _info;
}

- (id)initWithInfo:(cpPointQueryInfo *)info;

/// Returns a pointer to the underlying cpNearestPointQueryInfo C struct.
@property(nonatomic, readonly) cpPointQueryInfo *info;

/// The ChipmunkShape found.
@property(nonatomic, readonly) ChipmunkShape *shape;

/// The closest point on the surface of the shape to the point.
@property(nonatomic, readonly) cpVect point;

/// The distance between the point and the surface of the shape.
/// Negative distances mean that the point is that depth inside the shape.
@property(nonatomic, readonly) cpFloat distance;

/// The gradient of the signed distance function.
/// The same as info.point/info.dist, but accurate even for very small values of info.dist.
@property(nonatomic, readonly) cpVect gradient;

@end


/// Holds collision information from segment queries. You should never need to create one.
@interface ChipmunkSegmentQueryInfo : NSObject {
@private
	cpSegmentQueryInfo _info;
	cpVect _start, _end;
}

- (id)initWithInfo:(cpSegmentQueryInfo *)info start:(cpVect)start end:(cpVect)end;

/// Returns a pointer to the underlying cpSegmentQueryInfo C struct.
@property(nonatomic, readonly) cpSegmentQueryInfo *info;

/// The ChipmunkShape found.
@property(nonatomic, readonly) ChipmunkShape *shape;

/// The percentage between the start and end points where the collision occurred.
@property(nonatomic, readonly) cpFloat t;

/// The normal of the collision with the shape.
@property(nonatomic, readonly) cpVect normal;

/// The point of the collision in absolute (world) coordinates.
@property(nonatomic, readonly) cpVect point;

/// The distance from the start point where the collision occurred.
@property(nonatomic, readonly) cpFloat dist;

/// The start point.
@property(nonatomic, readonly) cpVect start;

/// The end point.
@property(nonatomic, readonly) cpVect end;

@end


/// Holds collision information from segment queries. You should never need to create one.
@interface ChipmunkShapeQueryInfo : NSObject {
@private
	ChipmunkShape *_shape;
	cpContactPointSet _contactPoints;
}

- (id)initWithShape:(ChipmunkShape *)shape andPoints:(cpContactPointSet *)set;

@property(nonatomic, readonly) ChipmunkShape *shape;
@property(nonatomic, readonly) cpContactPointSet *contactPoints;

@end


/// A perfect circle shape.
@interface ChipmunkCircleShape : ChipmunkShape

/// Create an autoreleased circle shape with the given radius and offset from the center of gravity.
+ (id)circleWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;

/// Initialize a circle shape with the given radius and offset from the center of gravity.
- (id)initWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;

/// The radius of the circle.
@property(nonatomic, readonly) cpFloat radius;

/// The offset from the center of gravity.
@property(nonatomic, readonly) cpVect offset;

@end


/// A beveled (rounded) segment shape.
@interface ChipmunkSegmentShape : ChipmunkShape

/// Create an autoreleased segment shape with the given endpoints and radius.
+ (id)segmentWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius;

/// Initialize a segment shape with the given endpoints and radius.
- (id)initWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius;

/// Let Chipmunk know about the geometry of adjacent segments to avoid colliding with endcaps.
- (void)setPrevNeighbor:(cpVect)prev nextNeighbor:(cpVect)next;

/// The start of the segment shape.
@property(nonatomic, readonly) cpVect a;

/// The end of the segment shape.
@property(nonatomic, readonly) cpVect b;

/// The normal of the segment shape.
@property(nonatomic, readonly) cpVect normal;

/// The beveling radius of the segment shape.
@property(nonatomic, readonly) cpFloat radius;

@end


/// A convex polygon shape.
@interface ChipmunkPolyShape : ChipmunkShape

/// Create an autoreleased polygon shape from the given vertexes after applying the transform and with the given rounding radius.
+ (id)polyWithBody:(ChipmunkBody *)body count:(int)count verts:(const cpVect *)verts transform:(cpTransform)transform radius:(cpFloat)radius;

/// Create an autoreleased box shape centered on the center of gravity.
+ (id)boxWithBody:(ChipmunkBody *)body width:(cpFloat)width height:(cpFloat)height radius:(cpFloat)radius;

/// Create an autoreleased box shape with the given bounding box in body local coordinates and rounding radius.
+ (id)boxWithBody:(ChipmunkBody *)body bb:(cpBB)bb radius:(cpFloat)radius;

/// Initialize a polygon shape from the given vertexes after applying the transform and with the given rounding radius.
- (id)initWithBody:(ChipmunkBody *)body count:(int)count verts:(const cpVect *)verts transform:(cpTransform)transform radius:(cpFloat)radius;

/// Initialize a box shape centered on the center of gravity.
- (id)initBoxWithBody:(ChipmunkBody *)body width:(cpFloat)width height:(cpFloat)height radius:(cpFloat)radius;

/// Initialize a box shape with the given bounding box in body local coordinates and rounding radius.
- (id)initBoxWithBody:(ChipmunkBody *)body bb:(cpBB)bb radius:(cpFloat)radius;

/// The number of vertexes in this polygon.
@property(nonatomic, readonly) int count;

/// Get the rounding radius of the polygon.
@property(nonatomic, readonly) cpFloat radius;

/// Access the vertexes of this polygon.
- (cpVect)getVertex:(int)index;

@end
