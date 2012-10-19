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
#import "CGPointExtension.h"
#import "TransformUtils.h"
#import "CCGrid.h"
#import "CCSprite.h"

// XXX: Optmization
struct transformValues_ {
	CGPoint pos;		// position x and y
	CGPoint	scale;		// scale x and y
	float	rotation;
	CGPoint skew;		// skew x and y
	CGPoint ap;			// anchor point in pixels
	BOOL	visible;
};

//added here, TransFormUtils wasn't properly included
void CGAffineToGL(const CGAffineTransform *t, GLfloat *m)
{
	// | m[0] m[4] m[8]  m[12] |     | m11 m21 m31 m41 |     | a c 0 tx |
	// | m[1] m[5] m[9]  m[13] |     | m12 m22 m32 m42 |     | b d 0 ty |
	// | m[2] m[6] m[10] m[14] | <=> | m13 m23 m33 m43 | <=> | 0 0 1  0 |
	// | m[3] m[7] m[11] m[15] |     | m14 m24 m34 m44 |     | 0 0 0  1 |

	m[2] = m[3] = m[6] = m[7] = m[8] = m[9] = m[11] = m[14] = 0.0f;
	m[10] = m[15] = 1.0f;
	m[0] = t->a; m[4] = t->c; m[12] = t->tx;
	m[1] = t->b; m[5] = t->d; m[13] = t->ty;
}

#if CC_COCOSNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (NSInteger)
#endif

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

- (void) transform
{

    // transformations

#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
    // BEGIN alternative -- using cached transform
    //
#if CC_ENABLE_CHIPMUNK_INTEGRATION || CC_ENABLE_BOX2D_INTEGRATION
    //always use nodeToParentTransform, since it updates the sprite with the physics body values
    CGAffineTransform t = [self nodeToParentTransform];
    CGAffineToGL(&t, transformGL_);
#else
    if( isTransformGLDirty_ ) {
		CGAffineTransform t = [self nodeToParentTransform];
		CGAffineToGL(&t, transformGL_);
		isTransformGLDirty_ = NO;
	}
#endif
    //glMultMatrixf(transformGL_);
    if( vertexZ_ )
        glTranslatef(0, 0, vertexZ_);

    // XXX: Expensive calls. Camera should be integrated into the cached affine matrix
    if ( camera_ && !(grid_ && grid_.active) )
    {
        BOOL translate = (anchorPointInPixels_.x != 0.0f || anchorPointInPixels_.y != 0.0f);

        if( translate )
            ccglTranslate(RENDER_IN_SUBPIXEL(anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(anchorPointInPixels_.y), 0);

        [camera_ locate];

        if( translate )
            ccglTranslate(RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);
    }


    // END alternative

#else
    // BEGIN original implementation
    //
    // translate
    if ( isRelativeAnchorPoint_ && (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0 ) )
        glTranslatef( RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);

    if (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0)
        glTranslatef( RENDER_IN_SUBPIXEL(positionInPixels_.x + anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(positionInPixels_.y + anchorPointInPixels_.y), vertexZ_);
    else if ( positionInPixels_.x !=0 || positionInPixels_.y !=0 || vertexZ_ != 0)
        glTranslatef( RENDER_IN_SUBPIXEL(positionInPixels_.x), RENDER_IN_SUBPIXEL(positionInPixels_.y), vertexZ_ );

    // rotate
    if (rotation_ != 0.0f )
        glRotatef( -rotation_, 0.0f, 0.0f, 1.0f );

    // scale
    if (scaleX_ != 1.0f || scaleY_ != 1.0f)
        glScalef( scaleX_, scaleY_, 1.0f );

    // skew
    if ( (skewX_ != 0.0f) || (skewY_ != 0.0f) ) {
        CGAffineTransform skewMatrix = CGAffineTransformMake( 1.0f, tanf(CC_DEGREES_TO_RADIANS(skewY_)), tanf(CC_DEGREES_TO_RADIANS(skewX_)), 1.0f, 0.0f, 0.0f );
        GLfloat	glMatrix[16];
        CGAffineToGL(&skewMatrix, glMatrix);
        glMultMatrixf(glMatrix);
    }

    if ( camera_ && !(grid_ && grid_.active) )
        [camera_ locate];

    // restore and re-position point
    if (anchorPointInPixels_.x != 0.0f || anchorPointInPixels_.y != 0.0f)
        glTranslatef(RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);

    //
    // END original implementation
#endif
}

-(void)updateTransform
{
	NSAssert( usesBatchNode_, @"updateTransform is only valid when CCSprite is being renderd using an CCSpriteBatchNode");

	CGAffineTransform matrix;

	// Optimization: if it is not visible, then do nothing
	if( ! visible_ ) {
		quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = (ccVertex3F){0,0,0};
		[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
		dirty_ = recursiveDirty_ = NO;
		return ;
	}

	// Optimization: If parent is batchnode, or parent is nil
	// build Affine transform manually
	if( ! parent_ || parent_ == (CCNode*) batchNode_ ) {

#if CC_ENABLE_CHIPMUNK_INTEGRATION || CC_ENABLE_BOX2D_INTEGRATION
        matrix = [self nodeToParentTransform];
#else
        float radians = -CC_DEGREES_TO_RADIANS(rotation_);
		float c = cosf(radians);
		float s = sinf(radians);

		matrix = CGAffineTransformMake( c * scaleX_,  s * scaleX_,
									   -s * scaleY_, c * scaleY_,
									   positionInPixels_.x, positionInPixels_.y);
#endif
		if( skewX_ || skewY_ ) {
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(skewY_)),
																 tanf(CC_DEGREES_TO_RADIANS(skewX_)), 1.0f,
																 0.0f, 0.0f);
			matrix = CGAffineTransformConcat(skewMatrix, matrix);
		}


#if ! CC_ENABLE_CHIPMUNK_INTEGRATION && ! CC_ENABLE_BOX2D_INTEGRATION
		matrix = CGAffineTransformTranslate(matrix, -anchorPointInPixels_.x, -anchorPointInPixels_.y);
#endif
	}
    else
    {
        CCLOG(@"PhysicsSprite: parent should be a batchNode");
    }

	//
	// calculate the Quad based on the Affine Matrix
	//

	CGSize size = rectInPixels_.size;

	float x1 = offsetPositionInPixels_.x;
	float y1 = offsetPositionInPixels_.y;

	float x2 = x1 + size.width;
	float y2 = y1 + size.height;
	float x = matrix.tx;
	float y = matrix.ty;

	float cr = matrix.a;
	float sr = matrix.b;
	float cr2 = matrix.d;
	float sr2 = -matrix.c;
	float ax = x1 * cr - y1 * sr2 + x;
	float ay = x1 * sr + y1 * cr2 + y;

	float bx = x2 * cr - y1 * sr2 + x;
	float by = x2 * sr + y1 * cr2 + y;

	float cx = x2 * cr - y2 * sr2 + x;
	float cy = x2 * sr + y2 * cr2 + y;

	float dx = x1 * cr - y2 * sr2 + x;
	float dy = x1 * sr + y2 * cr2 + y;

	quad_.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(ax), RENDER_IN_SUBPIXEL(ay), vertexZ_ };
	quad_.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(bx), RENDER_IN_SUBPIXEL(by), vertexZ_ };
	quad_.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(dx), RENDER_IN_SUBPIXEL(dy), vertexZ_ };
	quad_.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(cx), RENDER_IN_SUBPIXEL(cy), vertexZ_ };

	[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	dirty_ = recursiveDirty_ = NO;
}


// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	cpVect rot = (_ignoreBodyRotation ? cpvforangle(-CC_DEGREES_TO_RADIANS(rotation_)) : _body->rot);
    CGPoint ap = anchorPointInPixels_;
    ap.x /= CC_CONTENT_SCALE_FACTOR();
    ap.y /= CC_CONTENT_SCALE_FACTOR();
	CGFloat x = _body->p.x + rot.x*-ap.x - rot.y*-ap.y;
	CGFloat y = _body->p.y + rot.y*-ap.x + rot.x*-ap.y;


	return (transform_ = CGAffineTransformMake(rot.x, rot.y, -rot.y,	rot.x, x,	y));
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
// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
	b2Vec2 pos  = _body->GetPosition();

	float x = pos.x * _PTMRatio;
	float y = pos.y * _PTMRatio;


	// Make matrix
	float radians = _body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);

	if( ! CGPointEqualToPoint(anchorPoint_, CGPointZero) ){
        CGPoint ap = anchorPointInPixels_;
        ap.x /= CC_CONTENT_SCALE_FACTOR();
        ap.y /= CC_CONTENT_SCALE_FACTOR();

		x += c*-ap.x + -s*-ap.y;
		y += s*-ap.x + c*-ap.y;
	}

	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
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
