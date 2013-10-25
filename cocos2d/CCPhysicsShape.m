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

#import "CCPhysicsShape.h"
#import "CCPhysics+ObjectiveChipmunk.h"


#define DEFAULT_FRICTION 0.7
#define DEFAULT_ELASTICITY 0.2


@interface CCPhysicsCircleShape : CCPhysicsShape
-(id)initWithRadius:(CGFloat)radius center:(CGPoint)center;
@end


@implementation CCPhysicsShape {
	@protected
	ChipmunkShape *_shape;
}

+(CCPhysicsShape *)circleShapeWithRadius:(CGFloat)radius center:(CGPoint)center
{
	return [[CCPhysicsCircleShape alloc] initWithRadius:radius center:center];
}

@end


@implementation CCPhysicsShape(ObjectiveChipmunk)

-(id)initWithShape:(ChipmunkShape *)shape
{
	if((self = [super init])){
		_shape = shape;
	}
	
	return self;
}

@end


@implementation CCPhysicsCircleShape {
	CGFloat _radius;
	CGPoint _center;
}

-(id)initWithRadius:(CGFloat)radius center:(CGPoint)center
{
	ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:nil radius:radius offset:center];
	
	if((self = [super initWithShape:shape])){
		_radius = radius;
		_center = center;
		
		_shape = [ChipmunkCircleShape circleWithBody:nil radius:radius offset:center];
		_shape.mass = 1.0;
		_shape.friction = DEFAULT_FRICTION;
		_shape.elasticity = DEFAULT_ELASTICITY;
		_shape.userData = self;
	}
	
	return self;
}

@end
