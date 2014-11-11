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

#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

@interface ChipmunkGrab : NSObject<ChipmunkObject> {
	NSArray *_chipmunkObjects;
	
	cpVect _pos;
	cpFloat _smoothing;
	
	ChipmunkShape *_grabbedShape;
	
	id _data;
}

/// Last touch location of the grab.
@property(nonatomic, readonly) cpVect pos;

/// The ChipmunkShape that this grab was created for.
@property(nonatomic, readonly) ChipmunkShape *grabbedShape;

/// User definable pointer
@property(nonatomic, retain) id data;

@end


/// Simple class to implement multitouch grabbing of physics objects.
@interface ChipmunkMultiGrab : NSObject {
	ChipmunkSpace *_space;
	NSMutableArray *_grabs;
	
	cpFloat _smoothing;
	cpFloat _grabForce;
	
	cpFloat _grabFriction;
	cpFloat _grabRotaryFriction;
	cpFloat _grabRadius;
	
	cpShapeFilter filter;
	bool (^_grabFilter)(ChipmunkShape *shape);
	cpFloat (^_grabSort)(ChipmunkShape *shape, cpFloat depth);
	
	bool _pushMode, _pullMode;
	
	cpFloat _pushMass;
	cpFloat _pushFriction;
	cpFloat _pushElasticity;
	cpCollisionType _pushCollisionType;
}

@property(nonatomic, assign) cpFloat smoothing;
@property(nonatomic, assign) cpFloat grabForce;

/// Layers used for the point query when grabbing objects.
@property(nonatomic, assign) cpShapeFilter filter;

/// Group used for the point query when grabbing objects
@property(nonatomic, assign) cpGroup group;

/// Gives you the opportunity to further filter shapes. Return FALSE to ignore a shape.
/// The default implementation always returns TRUE.
@property(nonatomic, copy) bool (^grabFilter)(ChipmunkShape *shape);

/// When clicking on a spot where two shapes overlap, the default behavior is to grab the shape that
/// overlaps the grab point the most. It's possible to use a custom sorting order instead however.
/// The block is called with each shape and the grab depth.
/// It should return a positive float. The shape with the highest value is grabbed.
/// The block is only called if the touch location is within a shape.
@property(nonatomic, copy) cpFloat (^grabSort)(ChipmunkShape *shape, cpFloat depth);

/// Amount of friction applied by the touch.
/// Should be less than the grabForce. Defaults to 0.0.
@property(nonatomic, assign) cpFloat grabFriction;

/// The amount torque to apply to the grab to keep it from spinning.
/// Defaults to 0.0.
@property(nonatomic, assign) cpFloat grabRotaryFriction;

/// On a touch screen, a single point query can make it really hard to grab small objects with a fat finger.
/// By providing a radius, it will make it much easier for users to grab objects.
/// Defaults to 0.0.
@property(nonatomic, assign) cpFloat grabRadius;

@property(nonatomic, assign) bool pullMode;
@property(nonatomic, assign) bool pushMode;

@property(nonatomic, assign) cpFloat pushMass;
@property(nonatomic, assign) cpFloat pushFriction;
@property(nonatomic, assign) cpFloat pushElasticity;
@property(nonatomic, assign) cpCollisionType pushCollisionType;

@property(nonatomic, readonly) NSArray *grabs;


/**
	@c space is the space to grab shapes in.
	@c smoothing is the amount of mouse smoothing to apply as percentage of remaining error per second.
	cpfpow(0.8, 60) is a good starting point that provides fast response, but smooth mouse updates.
	@c force is the force the grab points can apply.
*/
-(id)initForSpace:(ChipmunkSpace *)space withSmoothing:(cpFloat)smoothing withGrabForce:(cpFloat)grabForce;

/// Start tracking a new grab point
/// Returns the ChipmunkGrab that is tracking the touch, but only if a shape was grabbed.
/// Returns nil when creating a push shape (if push mode is enabled), or when no shape is grabbed.
-(ChipmunkGrab *)beginLocation:(cpVect)pos;

/// Update a grab point.
/// Returns the ChipmunkGrab that is tracking the touch, but only if the grab is tracking a shape.
-(ChipmunkGrab *)updateLocation:(cpVect)pos;

/// End a grab point.
/// Returns the ChipmunkGrab that was tracking the touch, but only if the grab was tracking a shape.
-(ChipmunkGrab *)endLocation:(cpVect)pos;

@end
