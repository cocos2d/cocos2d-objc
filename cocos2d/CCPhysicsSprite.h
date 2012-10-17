/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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

#import "ccConfig.h"
#import "CCSprite.h"


#if CC_ENABLE_CHIPMUNK_INTEGRATION
#import "chipmunk.h"
@class ChipmunkBody;

#elif CC_ENABLE_BOX2D_INTEGRATION
class b2Body;
#endif // CC_ENABLE_BOX2D_INTEGRATION

/** A CCSprite subclass that is bound to a physics body.
 It works with:
	- Chipmunk
	- Objective-Chipmunk
	- Box2d
 */
@interface CCPhysicsSprite : CCSprite
{
	BOOL	_ignoreBodyRotation;

#if CC_ENABLE_CHIPMUNK_INTEGRATION
	cpBody	*_body;

#elif CC_ENABLE_BOX2D_INTEGRATION
	b2Body	*_body;

	// Pixels to Meters ratio
	float	_PTMRatio;
#endif // CC_ENABLE_BOX2D_INTEGRATION
}

/** Keep the sprite's rotation separate from the body. */
@property(nonatomic, assign) BOOL ignoreBodyRotation;

#if CC_ENABLE_CHIPMUNK_INTEGRATION

/** Body accessor when using regular Chipmunk */
@property(nonatomic, assign) cpBody *body;

/** Body accessor when using Objective-Chipmunk */
@property(nonatomic, assign) ChipmunkBody *chipmunkBody;


#elif CC_ENABLE_BOX2D_INTEGRATION

/** Body accessor when using box2d */
@property(nonatomic, assign) b2Body *body;

@property(nonatomic, assign) float PTMRatio;

#endif // CC_ENABLE_BOX2D_INTEGRATION

@end
