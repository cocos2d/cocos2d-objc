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
@synthesize body = _body;
#endif
#if CC_ENABLE_BOX2D_INTEGRATION
@synthesize body = _body;
@synthesize PTMRatio = _PTMRatio;
#endif

#pragma mark - Chipmunk support

#if CC_ENABLE_CHIPMUNK_INTEGRATION
-(ChipmunkBody *)chipmunkBody
{
	return (ChipmunkBody *) _body->data;
}

-(void)setChipmunkBody:(ChipmunkBody *)chipmunkBody
{
	_body = chipmunkBody.body;
}
// Override the setters and getters to always reflect the body's properties.
-(CGPoint)position
{
	return cpBodyGetPos(_body);
}

-(void)setPosition:(CGPoint)position
{
	cpBodySetPos(_body, position);
}

-(float)rotation
{
	return (_ignoreBodyRotation ? super.rotation : -CC_RADIANS_TO_DEGREES(cpBodyGetAngle(_body)));
}

-(void)setRotation:(float)rotation
{
	if(_ignoreBodyRotation){
		super.rotation = rotation;
	} else {
		cpBodySetAngle(_body, -CC_DEGREES_TO_RADIANS(rotation));
	}
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	// Although scale is not used by physics engines, it is calculated just in case
	// the sprite is animated (scaled up/down) using actions.
	// For more info see: http://www.cocos2d-iphone.org/forum/topic/68990
	cpVect rot = (_ignoreBodyRotation ? cpvforangle(-CC_DEGREES_TO_RADIANS(rotationX_)) : _body->rot);
	CGFloat x = _body->p.x + rot.x * -anchorPointInPoints_.x * scaleX_ - rot.y * -anchorPointInPoints_.y * scaleY_;
	CGFloat y = _body->p.y + rot.y * -anchorPointInPoints_.x * scaleX_ + rot.x * -anchorPointInPoints_.y * scaleY_;
	
	if(ignoreAnchorPointForPosition_){
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	return (transform_ = CGAffineTransformMake(rot.x * scaleX_, rot.y * scaleX_,
											   -rot.y * scaleY_, rot.x * scaleY_,
											   x,	y));
}

#elif CC_ENABLE_BOX2D_INTEGRATION

#pragma mark - Box2d support

// Override the setters and getters to always reflect the body's properties.
-(CGPoint)position
{
	b2Vec2 pos  = _body->GetPosition();
	
	float x = pos.x * _PTMRatio;
	float y = pos.y * _PTMRatio;
	return ccp(x,y);
}

-(void)setPosition:(CGPoint)position
{
	float angle = _body->GetAngle();
	_body->SetTransform( b2Vec2(position.x / _PTMRatio, position.y / _PTMRatio), angle );
}

-(float)rotation
{
	return (_ignoreBodyRotation ? super.rotation :
			CC_RADIANS_TO_DEGREES( _body->GetAngle() ) );
}

-(void)setRotation:(float)rotation
{
	if(_ignoreBodyRotation){
		super.rotation = rotation;
	} else {
		b2Vec2 p = _body->GetPosition();
		float radians = CC_DEGREES_TO_RADIANS(rotation);
		_body->SetTransform( p, radians);
	}
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	b2Vec2 pos  = _body->GetPosition();
	
	float x = pos.x * _PTMRatio;
	float y = pos.y * _PTMRatio;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = _body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	// Although scale is not used by physics engines, it is calculated just in case
	// the sprite is animated (scaled up/down) using actions.
	// For more info see: http://www.cocos2d-iphone.org/forum/topic/68990
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x * scaleX_ + -s*-anchorPointInPoints_.y * scaleY_;
		y += s*-anchorPointInPoints_.x * scaleX_ + c*-anchorPointInPoints_.y * scaleY_;
	}
		
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c * scaleX_,	s * scaleX_,
									   -s * scaleY_,	c * scaleY_,
									   x,	y );
	
	return transform_;
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
