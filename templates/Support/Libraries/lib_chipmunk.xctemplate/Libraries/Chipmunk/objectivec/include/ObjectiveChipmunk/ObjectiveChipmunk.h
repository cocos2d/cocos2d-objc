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

#import <Foundation/Foundation.h>

#if __has_feature(objc_arc)
	#define CP_DATA_POINTER_TYPE __unsafe_unretained id
	#define CP_GROUP_TYPE __unsafe_unretained id
	#define CP_COLLISION_TYPE_TYPE __unsafe_unretained id
#else
	#define CP_DATA_POINTER_TYPE id
	#define CP_GROUP_TYPE id
	#define CP_COLLISION_TYPE_TYPE id
#endif

#ifdef CP_ALLOW_PRIVATE_ACCESS
	#undef CP_ALLOW_PRIVATE_ACCESS
	#import "chipmunk/chipmunk_private.h"
#else
	#import "chipmunk/chipmunk.h"
#endif

/**
	Allows you to add composite objects to a space in a single method call.
	The easiest way to implement the ChipmunkObject protocol is to add a @c chipmunkObjects instance variable with a type of @c NSArray* to your class,
	create a synthesized property for it, and initialize it with the ChipmunkObjectFlatten() function.
*/
@protocol ChipmunkObject

/// Returns a list of ChipmunkBaseObject objects.
- (id <NSFastEnumeration>)chipmunkObjects;

@end


/// A category to have NSArray implement the ChipmunkObject protocol.
/// They make for very easy containers.
@interface NSArray(ChipmunkObject) <ChipmunkObject>
@end


@class ChipmunkSpace;

/**
	This protocol is implemented by objects that know how to add themselves to a space.
	It's used internally as part of the ChipmunkObject protocol. You should never need to implement it yourself.
*/
@protocol ChipmunkBaseObject <ChipmunkObject>

- (void)addToSpace:(ChipmunkSpace *)space;
- (void)removeFromSpace:(ChipmunkSpace *)space;

@end

#import "ChipmunkBody.h"
#import "ChipmunkShape.h"
#import "ChipmunkConstraint.h"
#import "ChipmunkSpace.h"
#import "ChipmunkMultiGrab.h"
