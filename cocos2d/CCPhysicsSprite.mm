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

#import "CCPhysicsSprite.h"
#import "Support/CGPointExtension.h"

#if CC_ENABLE_CHIPMUNK_INTEGRATION
#import "chipmunk.h"
#elif CC_ENABLE_BOX2D_INTEGRATION
#import "Box2D.h"
#endif

#if CC_ENABLE_CHIPMUNK_INTEGRATION
@interface ChipmunkBody : NSObject
-(cpBody *)body;
@end
#endif // CC_ENABLE_CHIPMUNK_INTEGRATION

@implementation CCPhysicsSprite

@synthesize ignoreBodyRotation = _ignoreBodyRotation;

#if CC_ENABLE_CHIPMUNK_INTEGRATION
@synthesize CPBody = _cpBody;
#endif
#if CC_ENABLE_BOX2D_INTEGRATION
@synthesize b2Body = _b2Body;
@synthesize PTMRatio = _PTMRatio;
#endif

#pragma mark - Chipmunk support

#if CC_ENABLE_CHIPMUNK_INTEGRATION
-(ChipmunkBody *)chipmunkBody
{
	return (ChipmunkBody *) _cpBody->data;
}

-(void)setChipmunkBody:(ChipmunkBody *)chipmunkBody
{
	_cpBody = chipmunkBody.body;
}
// Override the setters and getters to always reflect the body's properties.
-(CGPoint)position
{
	return cpBodyGetPos(_cpBody);
}

-(void)setPosition:(CGPoint)position
{
	cpBodySetPos(_cpBody, position);
}

-(float)rotation
{
	return (_ignoreBodyRotation ? super.rotation : -CC_RADIANS_TO_DEGREES(cpBodyGetAngle(_cpBody)));
}

-(void)setRotation:(float)rotation
{
	if(_ignoreBodyRotation){
		super.rotation = rotation;
	} else {
		cpBodySetAngle(_cpBody, -CC_DEGREES_TO_RADIANS(rotation));
	}
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	// Although scale is not used by physics engines, it is calculated just in case
	// the sprite is animated (scaled up/down) using actions.
	// For more info see: http://www.cocos2d-iphone.org/forum/topic/68990
	cpVect rot = (_ignoreBodyRotation ? cpvforangle(-CC_DEGREES_TO_RADIANS(_rotationX)) : _cpBody->rot);
	CGFloat x = _cpBody->p.x + rot.x * -_anchorPointInPoints.x * _scaleX - rot.y * -_anchorPointInPoints.y * _scaleY;
	CGFloat y = _cpBody->p.y + rot.y * -_anchorPointInPoints.x * _scaleX + rot.x * -_anchorPointInPoints.y * _scaleY;
	
	if(_ignoreAnchorPointForPosition){
		x += _anchorPointInPoints.x;
		y += _anchorPointInPoints.y;
	}
	
	return (_transform = CGAffineTransformMake(rot.x * _scaleX, rot.y * _scaleX,
											   -rot.y * _scaleY, rot.x * _scaleY,
											   x,	y));
}

#elif CC_ENABLE_BOX2D_INTEGRATION

#pragma mark - Box2d support

// Override the setters and getters to always reflect the body's properties.
-(CGPoint)position
{
	b2Vec2 pos  = _b2Body->GetPosition();
	
	float x = pos.x * _PTMRatio;
	float y = pos.y * _PTMRatio;
	return ccp(x,y);
}

-(void)setPosition:(CGPoint)position
{
	float angle = _b2Body->GetAngle();
	_b2Body->SetTransform( b2Vec2(position.x / _PTMRatio, position.y / _PTMRatio), angle );
}

-(float)rotation
{
	return (_ignoreBodyRotation ? super.rotation :
			CC_RADIANS_TO_DEGREES( _b2Body->GetAngle() ) );
}

-(void)setRotation:(float)rotation
{
	if(_ignoreBodyRotation){
		super.rotation = rotation;
	} else {
		b2Vec2 p = _b2Body->GetPosition();
		float radians = CC_DEGREES_TO_RADIANS(rotation);
		_b2Body->SetTransform( p, radians);
	}
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	b2Vec2 pos  = _b2Body->GetPosition();
	
	float x = pos.x * _PTMRatio;
	float y = pos.y * _PTMRatio;
	
	if ( _ignoreAnchorPointForPosition ) {
		x += _anchorPointInPoints.x;
		y += _anchorPointInPoints.y;
	}
	
	// Make matrix
	float radians = _b2Body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	// Although scale is not used by physics engines, it is calculated just in case
	// the sprite is animated (scaled up/down) using actions.
	// For more info see: http://www.cocos2d-iphone.org/forum/topic/68990
	if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ){
		x += c*-_anchorPointInPoints.x * _scaleX + -s*-_anchorPointInPoints.y * _scaleY;
		y += s*-_anchorPointInPoints.x * _scaleX + c*-_anchorPointInPoints.y * _scaleY;
	}
		
	// Rot, Translate Matrix
	_transform = CGAffineTransformMake( c * _scaleX,	s * _scaleX,
									   -s * _scaleY,	c * _scaleY,
									   x,	y );
	
	return _transform;
}
#endif // CC_ENABLE_BOX2D_INTEGRATION

// this method will only get called if the sprite is batched.
// return YES if the physic's values (angles, position ) changed.
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}


@end
