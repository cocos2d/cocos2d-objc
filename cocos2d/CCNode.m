/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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

#import "CCNode.h"
#import "CCGrid.h"
#import "CCDirector.h"
#import "CCActionManager.h"
#import "CCCamera.h"
#import "CCScheduler.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"
#import "ccMacros.h"
#import "CCGLProgram.h"
#import "CCPhysics.h"

// externals
#import "kazmath/GL/matrix.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif


#if CC_NODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__ARGS__) (ceil(__ARGS__))
#endif


@interface CCPhysicsBody(Absolute)
@property(nonatomic, assign) CGPoint absolutePosition;
@property(nonatomic, assign) float absoluteRadians;
@end

#pragma mark - Node

@interface CCNode ()
// lazy allocs
-(void) childrenAlloc;
// helper that reorder a child
-(void) insertChild:(CCNode*)child z:(NSInteger)z;
// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(NSInteger) z;
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;
@end

@implementation CCNode {

}

static inline
CGPoint GetPosition(CCNode *self)
{
	// TODO convert coordinate systems.
	CCPhysicsBody *body = self->_physicsBody;
	if(body){
		CGPoint anchor = self->_anchorPointInPoints;
		return cpTransformPoint(body.absoluteTransform, cpv(anchor.x*self->_scaleX, anchor.y*self->_scaleY));
	} else {
		return self->_position;
	}
}

static inline void
SetPosition(CCNode *self, CGPoint position)
{
	CCPhysicsBody *body = self->_physicsBody;
	if(body){
		// TODO convert coordinate systems.
		//body.absolutePosition = position;
		CGPoint anchor = self->_anchorPointInPoints;
		body.absolutePosition = cpvsub(position, cpTransformVect(body.absoluteTransform, cpv(anchor.x*self->_scaleX, anchor.y*self->_scaleY)));
		//(cpTransformRigidInverse(body.absoluteTransform), self->_anchorPointInPoints);
	} else {
		self->_position = position;
	}
}

static inline float
GetRotationX(CCNode *self)
{
	CCPhysicsBody *body = self->_physicsBody;
	return (body ? -CC_RADIANS_TO_DEGREES(body.absoluteRadians) : self->_rotationX);
}

static inline float
GetRotationY(CCNode *self)
{
	CCPhysicsBody *body = self->_physicsBody;
	return (body ? -CC_RADIANS_TO_DEGREES(body.absoluteRadians) : self->_rotationY);
}

static inline void
SetRotationX(CCNode *self, float rotation)
{
	CCPhysicsBody *body = self->_physicsBody;
	if(body){
		// TODO convert coordinate systems.
		body.absoluteRadians = -CC_DEGREES_TO_RADIANS(rotation);
	} else {
		self->_rotationX = rotation;
	}
}

static inline void
SetRotationY(CCNode *self, float rotation)
{
	CCPhysicsBody *body = self->_physicsBody;
	if(body){
		// TODO ??? really just need to move the weird rotation skew to a generic transform property.
	} else {
		self->_rotationY = rotation;
	}
}

// XXX: Yes, nodes might have a sort problem once every 15 days if the game runs at 60 FPS and each frame sprites are reordered.
static NSUInteger globalOrderOfArrival = 1;

@synthesize children = _children;
@synthesize visible = _visible;
@synthesize parent = _parent;
@synthesize grid = _grid;
@synthesize zOrder = _zOrder;
@synthesize tag = _tag;
@synthesize vertexZ = _vertexZ;
@synthesize isRunning = _isRunning;
@synthesize userData = _userData, userObject = _userObject;
@synthesize	shaderProgram = _shaderProgram;
@synthesize orderOfArrival = _orderOfArrival;
@synthesize glServerState = _glServerState;

#pragma mark CCNode - Transform related properties

@synthesize scaleX = _scaleX, scaleY = _scaleY;
@synthesize anchorPoint = _anchorPoint, anchorPointInPoints = _anchorPointInPoints;
@synthesize contentSize = _contentSize;
@synthesize skewX = _skewX, skewY = _skewY;

#pragma mark CCNode - Init & cleanup

+(id) node
{
	return [[self alloc] init];
}

-(id) init
{
	if ((self=[super init]) ) {

		_isRunning = NO;

		_skewX = _skewY = 0.0f;
		_rotationX = _rotationY = 0.0f;
		_scaleX = _scaleY = 1.0f;
        _position = CGPointZero;
        _contentSize = CGSizeZero;
		_anchorPointInPoints = _anchorPoint = CGPointZero;

		_isTransformDirty = _isInverseDirty = YES;

		_vertexZ = 0;

		_grid = nil;

		_visible = YES;

		_tag = kCCNodeTagInvalid;

		_zOrder = 0;

		// lazy alloc
		_camera = nil;

		// children (lazy allocs)
		_children = nil;

		// userData is always inited as nil
		_userData = NULL;
		_userObject = nil;

		//initialize parent to nil
		_parent = nil;

		_shaderProgram = nil;

		_orderOfArrival = 0;

		_glServerState = 0;
		
		// set default scheduler and actionManager
		CCDirector *director = [CCDirector sharedDirector];
		self.actionManager = [director actionManager];
		self.scheduler = [director scheduler];
        
        // set default touch handling
        self.userInteractionEnabled = NO;
        self.userInteractionClaimed = YES;
        self.multipleTouchEnabled = NO;
        self.hitAreaExpansion = 1.0f;
        
	}

	return self;
}

- (void)cleanup
{
	// actions
	[self stopAllActions];
	[self unscheduleAllSelectors];

	// timers
	[_children makeObjectsPerformSelector:@selector(cleanup)];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)_tag];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);


	// children
    for (CCNode* child in _children)
		child.parent = nil;


}

#pragma mark Setters

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	SetRotationX(self, newRotation);
	SetRotationY(self, newRotation);
	_isTransformDirty = _isInverseDirty = YES;
}

-(float) rotation
{
	NSAssert( _rotationX == _rotationY, @"CCNode#rotation. RotationX != RotationY. Don't know which one to return");
	return GetRotationX(self);
}

-(float)rotationX {
	return GetRotationX(self);
}

-(void) setRotationX: (float)newX
{
	SetRotationX(self, newX);
	_isTransformDirty = _isInverseDirty = YES;
}

-(float)rotationY
{
	return GetRotationY(self);
}

-(void) setRotationY: (float)newY
{
	SetRotationY(self, newY);
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setScaleX: (float)newScaleX
{
	_scaleX = newScaleX;
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setScaleY: (float)newScaleY
{
	_scaleY = newScaleY;
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setSkewX:(float)newSkewX
{
	_skewX = newSkewX;
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setSkewY:(float)newSkewY
{
	_skewY = newSkewY;
	_isTransformDirty = _isInverseDirty = YES;
}

-(CGPoint)position
{
	return GetPosition(self);
}

-(void) setPosition: (CGPoint)newPosition
{
	SetPosition(self, newPosition);
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) ) {
		_anchorPoint = point;
        CGSize contentSizeInPoints = self.contentSizeInPoints;
		_anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
	}
}

-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, _contentSize) ) {
		_contentSize = size;
        
        CGSize contentSizeInPoints = self.contentSizeInPoints;
		_anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
	}
}

- (void) setContentSizeType:(CCContentSizeType)contentSizeType
{
    _contentSizeType = contentSizeType;
    
    CGSize contentSizeInPoints = self.contentSizeInPoints;
    _anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
    _isTransformDirty = _isInverseDirty = YES;
}

- (CGSize) convertContentSizeToPoints:(CGSize)contentSize
{
    CGSize size = CGSizeZero;
    CCDirector* director = [CCDirector sharedDirector];
    
    CCContentSizeUnit widthUnit = _contentSizeType.widthUnit;
    CCContentSizeUnit heightUnit = _contentSizeType.heightUnit;
    
    // Width
    if (widthUnit == kCCContentSizeUnitPoints)
    {
        size.width = contentSize.width;
    }
    else if (widthUnit == kCCContentSizeUnitScaled)
    {
        size.width = director.positionScaleFactor * contentSize.width;
    }
    else if (widthUnit == kCCContentSizeUnitNormalized)
    {
        size.width = contentSize.width * _parent.contentSizeInPoints.width;
    }
    else if (widthUnit == kCCContentSizeUnitInsetPoints)
    {
        size.width = _parent.contentSizeInPoints.width - contentSize.width;
    }
    else if (widthUnit == kCCContentSizeUnitInsetScaled)
    {
        size.width = _parent.contentSizeInPoints.width - contentSize.width * director.positionScaleFactor;
    }
    
    // Height
    if (heightUnit == kCCContentSizeUnitPoints)
    {
        size.height = contentSize.height;
    }
    else if (heightUnit == kCCContentSizeUnitScaled)
    {
        size.height = director.positionScaleFactor * contentSize.height;
    }
    else if (heightUnit == kCCContentSizeUnitNormalized)
    {
        size.height = contentSize.height * _parent.contentSizeInPoints.height;
    }
    else if (heightUnit == kCCContentSizeUnitInsetPoints)
    {
        size.height = _parent.contentSizeInPoints.height - contentSize.height;
    }
    else if (heightUnit == kCCContentSizeUnitInsetScaled)
    {
        size.height = _parent.contentSizeInPoints.height - contentSize.height * director.positionScaleFactor;
    }
    
    return size;
}

- (CGSize) convertContentSizeFromPoints:(CGSize)pointSize
{
    CGSize size = CGSizeZero;
    
    CCDirector* director = [CCDirector sharedDirector];
    
    CCContentSizeUnit widthUnit = _contentSizeType.widthUnit;
    CCContentSizeUnit heightUnit = _contentSizeType.heightUnit;
    
    // Width
    if (widthUnit == kCCContentSizeUnitPoints)
    {
        size.width = pointSize.width;
    }
    else if (widthUnit == kCCContentSizeUnitScaled)
    {
        size.width = pointSize.width / director.positionScaleFactor;
    }
    else if (widthUnit == kCCContentSizeUnitNormalized)
    {
        
        float parentWidthInPoints = _parent.contentSizeInPoints.width;
        if (parentWidthInPoints > 0)
        {
            size.width = pointSize.width/parentWidthInPoints;
        }
        else
        {
            size.width = 0;
        }
    }
    else if (widthUnit == kCCContentSizeUnitInsetPoints)
    {
        size.width = _parent.contentSizeInPoints.width - pointSize.width;
    }
    else if (widthUnit == kCCContentSizeUnitInsetScaled)
    {
        size.width = (_parent.contentSizeInPoints.width - pointSize.width) / director.positionScaleFactor;
    }
    
    // Height
    if (heightUnit == kCCContentSizeUnitPoints)
    {
        size.height = pointSize.height;
    }
    else if (heightUnit == kCCContentSizeUnitScaled)
    {
        size.height = pointSize.height / director.positionScaleFactor;
    }
    else if (heightUnit == kCCContentSizeUnitNormalized)
    {
        
        float parentHeightInPoints = _parent.contentSizeInPoints.height;
        if (parentHeightInPoints > 0)
        {
            size.height = pointSize.height/parentHeightInPoints;
        }
        else
        {
            size.height = 0;
        }
    }
    else if (heightUnit == kCCContentSizeUnitInsetPoints)
    {
        size.height = _parent.contentSizeInPoints.height - pointSize.height;
    }
    else if (heightUnit == kCCContentSizeUnitInsetScaled)
    {
        size.height = (_parent.contentSizeInPoints.height - pointSize.height) / director.positionScaleFactor;
    }
    
    return size;
}

- (CGSize) contentSizeInPoints
{
    return [self convertContentSizeToPoints:self.contentSize];
}

- (CGRect) boundingBox
{
    CGSize contentSize = self.contentSizeInPoints;
    CGRect rect = CGRectMake(0, 0, contentSize.width, contentSize.height);
    return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
}

-(void) setVertexZ:(float)vertexZ
{
	_vertexZ = vertexZ;
}

- (void)setVisible:(BOOL)visible
{
    if (visible == _visible) return;
    
    /** mark responder manager as dirty
     @since v2.5
     */
    [[[CCDirector sharedDirector] responderManager] markAsDirty];
    _visible = visible;
}

-(float) scale
{
	NSAssert( _scaleX == _scaleY, @"CCNode#scale. ScaleX != ScaleY. Don't know which one to return");
	return _scaleX;
}

-(void) setScale:(float) s
{
	_scaleX = _scaleY = s;
	_isTransformDirty = _isInverseDirty = YES;
}

- (void) setZOrder:(NSInteger)zOrder
{
	[self _setZOrder:zOrder];

    if (_parent)
        [_parent reorderChild:self z:zOrder];
}

#pragma mark CCNode Composition

-(void) childrenAlloc
{
	_children = [[NSMutableArray alloc] init];
}

// camera: lazy alloc
-(CCCamera*) camera
{
	if( ! _camera ) {
		_camera = [[CCCamera alloc] init];

		// by default, center camera at the Sprite's anchor point
//		[_camera setCenterX:_anchorPointInPoints.x centerY:_anchorPointInPoints.y centerZ:0];
//		[_camera setEyeX:_anchorPointInPoints.x eyeY:_anchorPointInPoints.y eyeZ:1];

//		[_camera setCenterX:0 centerY:0 centerZ:0];
//		[_camera setEyeX:0 eyeY:0 eyeZ:1];
	}

	return _camera;
}

-(CCNode*) getChildByTag:(NSInteger) aTag
{
	NSAssert( aTag != kCCNodeTagInvalid, @"Invalid tag");

    for (CCNode* node in _children) {
		if( node.tag == aTag )
			return node;
	}
	// not found
	return nil;
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */
-(void) addChild: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");

	if( ! _children )
		[self childrenAlloc];

	[self insertChild:child z:z];

	child.tag = aTag;

	[child setParent: self];

	[child setOrderOfArrival: globalOrderOfArrival++];

	if( _isRunning ) {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
    
    /** mark responder manager as dirty
     @since v2.5
     */
    [[[CCDirector sharedDirector] responderManager] markAsDirty];
}

-(void) addChild: (CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:z tag:child.tag];
}

-(void) addChild: (CCNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:child.zOrder tag:child.tag];
}

-(void) removeFromParent
{
	[self removeFromParentAndCleanup:YES];
}

-(void) removeFromParentAndCleanup:(BOOL)cleanup
{
	[_parent removeChild:self cleanup:cleanup];
}

-(void) removeChild: (CCNode*)child
{
	[self removeChild:child cleanup:YES];
}

/* "remove" logic MUST only be on this method
 * If a class wants to extend the 'removeChild' behavior it only needs
 * to override this method
 */
-(void) removeChild: (CCNode*)child cleanup:(BOOL)cleanup
{
	// explicit nil handling
	if (child == nil)
		return;

	if ( [_children containsObject:child] )
		[self detachChild:child cleanup:cleanup];
}

-(void) removeChildByTag:(NSInteger)aTag
{
	[self removeChildByTag:aTag cleanup:YES];
}

-(void) removeChildByTag:(NSInteger)aTag cleanup:(BOOL)cleanup
{
	NSAssert( aTag != kCCNodeTagInvalid, @"Invalid tag");

	CCNode *child = [self getChildByTag:aTag];

	if (child == nil)
		CCLOG(@"cocos2d: removeChildByTag: child not found!");
	else
		[self removeChild:child cleanup:cleanup];
}

-(void) removeAllChildren
{
	[self removeAllChildrenWithCleanup:YES];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	// not using detachChild improves speed here
    for (CCNode* c in _children)
	{
		// IMPORTANT:
		//  -1st do onExit
		//  -2nd cleanup
		if (_isRunning)
		{
			[c onExitTransitionDidStart];
			[c onExit];
		}

		if (cleanup)
			[c cleanup];

		// set parent nil at the end (issue #476)
		[c setParent:nil];
        
        /** mark responder manager as dirty
         @since v2.5
         */
        [[[CCDirector sharedDirector] responderManager] markAsDirty];

	}

	[_children removeAllObjects];
}

-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if (_isRunning)
	{
		[child onExitTransitionDidStart];
		[child onExit];
	}

	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
		[child cleanup];

	// set parent nil at the end (issue #476)
	[child setParent:nil];

    /** mark responder manager as dirty
     @since v2.5
     */
    [[[CCDirector sharedDirector] responderManager] markAsDirty];

	[_children removeObject:child];
}

// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(NSInteger) z
{
	_zOrder = z;
}

// helper used by reorderChild & add
-(void) insertChild:(CCNode*)child z:(NSInteger)z
{
	_isReorderChildDirty=YES;

    [_children addObject:child];
	[child _setZOrder:z];
}

-(void) reorderChild:(CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");

	_isReorderChildDirty = YES;

	[child setOrderOfArrival: globalOrderOfArrival++];
	[child _setZOrder:z];
}

- (NSComparisonResult) compareZOrderToNode:(CCNode*)node
{
    if (node->_zOrder == _zOrder)
    {
        if (node->_orderOfArrival == _orderOfArrival)
        {
            return NSOrderedSame;
        }
        else if (node->_orderOfArrival < _orderOfArrival)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }
    else if (node->_zOrder < _zOrder)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedAscending;
    }
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
        [_children sortUsingSelector:@selector(compareZOrderToNode:)];

		//don't need to check children recursively, that's done in visit of each child
        
		_isReorderChildDirty = NO;
        
        /** mark responder manager as dirty
         @since v2.5
         */
        [[[CCDirector sharedDirector] responderManager] markAsDirty];

	}
}

#pragma mark CCNode Draw

-(void) draw
{
}

-(void) visit
{
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
	kmGLPushMatrix();

	if ( _grid && _grid.active)
		[_grid beforeDraw];

	[self transform];

	if(_children) {

		[self sortAllChildren];

		NSUInteger i = 0;

		// draw children zOrder < 0
		for( ; i < _children.count; i++ ) {
			CCNode *child = [_children objectAtIndex:i];
			if ( [child zOrder] < 0 )
				[child visit];
			else
				break;
		}

		// self draw
		[self draw];

		// draw children zOrder >= 0
		for( ; i < _children.count; i++ ) {
			CCNode *child = [_children objectAtIndex:i];
			[child visit];
		}

	} else
		[self draw];

	// reset for next frame
	_orderOfArrival = 0;

	if ( _grid && _grid.active)
		[_grid afterDraw:self];

	kmGLPopMatrix();
}

#pragma mark CCNode - Transformations

-(void) transformAncestors
{
	if( _parent ) {
		[_parent transformAncestors];
		[_parent transform];
	}
}

-(void) transform
{
	kmMat4 transfrom4x4;

	// Convert 3x3 into 4x4 matrix
	CGAffineTransform tmpAffine = [self nodeToParentTransform];
	CGAffineToGL(&tmpAffine, transfrom4x4.mat);

	// Update Z vertex manually
	transfrom4x4.mat[14] = _vertexZ;

	kmGLMultMatrix( &transfrom4x4 );


	// XXX: Expensive calls. Camera should be integrated into the cached affine matrix
	if ( _camera && !(_grid && _grid.active) )
	{
		BOOL translate = (_anchorPointInPoints.x != 0.0f || _anchorPointInPoints.y != 0.0f);

		if( translate )
			kmGLTranslatef(RENDER_IN_SUBPIXEL(_anchorPointInPoints.x), RENDER_IN_SUBPIXEL(_anchorPointInPoints.y), 0 );

		[_camera locate];

		if( translate )
			kmGLTranslatef(RENDER_IN_SUBPIXEL(-_anchorPointInPoints.x), RENDER_IN_SUBPIXEL(-_anchorPointInPoints.y), 0 );
	}
}

#pragma mark CCPhysics support.

// Overriden by CCPhysicsNode to return YES.
-(BOOL)isPhysicsNode {return NO;}
-(CCPhysicsNode *)physicsNode {return (self.isPhysicsNode ? (CCPhysicsNode *)self : self.parent.physicsNode);}

-(void)setPhysicsBody:(CCPhysicsBody *)physicsBody
{
	// Copy the node's rotation first.
	// Otherwise it will cause the position to rotate around the center of gravity.
	physicsBody.absoluteRadians = -CC_DEGREES_TO_RADIANS(_rotationX);
	
	// Grab the position of the node's origin (not it's anchor point position!) from it's transform matrix.
	// TODO need to use a "nodeToSpace" transform here.
	CGAffineTransform transform = [self nodeToParentTransform];
	physicsBody.absolutePosition = ccp(transform.tx, transform.ty);
	
	_physicsBody = physicsBody;
	
	// TODO needs to be more magic here for handling node already added to a scene.
	// TODO only handles going from nil -> some value.
}

-(void)setupPhysics
{
	if(_physicsBody){
		CCPhysicsNode *physics = self.physicsNode;
		NSAssert(physics != nil, @"A CCNode with an attached CCPhysicsBody must be added as a descendent of a CCPhysicsNode.");
		
		[physics.space add:_physicsBody];
	}
}

-(void)teardownPhysics
{
	@throw @"Not yet implemented.";
}

#pragma mark CCNode SceneManagement

// Overriden by CCScene to return YES.
-(BOOL)isScene {return NO;}
-(CCScene *)scene {return (self.isScene ? (CCScene *)self : self.parent.scene);}

-(void) onEnter
{
	[_children makeObjectsPerformSelector:@selector(onEnter)];
	[self resumeSchedulerAndActions];
	
	[self setupPhysics];
	
	_isRunning = YES;
}

-(void) onEnterTransitionDidFinish
{
	[_children makeObjectsPerformSelector:@selector(onEnterTransitionDidFinish)];
}

-(void) onExitTransitionDidStart
{
	[_children makeObjectsPerformSelector:@selector(onExitTransitionDidStart)];
}

-(void) onExit
{
	[self pauseSchedulerAndActions];
	_isRunning = NO;

	[_children makeObjectsPerformSelector:@selector(onExit)];
}

#pragma mark CCNode Actions

-(void) setActionManager:(CCActionManager *)actionManager
{
	if( actionManager != _actionManager ) {
		[self stopAllActions];

		_actionManager = actionManager;
	}
}

-(CCActionManager*) actionManager
{
	return _actionManager;
}

-(CCAction*) runAction:(CCAction*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");

	[_actionManager addAction:action target:self paused:!_isRunning];
	return action;
}

-(void) stopAllActions
{
	[_actionManager removeAllActionsFromTarget:self];
}

-(void) stopAction: (CCAction*) action
{
	[_actionManager removeAction:action];
}

-(void) stopActionByTag:(NSInteger)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[_actionManager removeActionByTag:aTag target:self];
}

-(CCAction*) getActionByTag:(NSInteger) aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return 	[_actionManager getActionByTag:aTag target:self];
}

-(NSUInteger) numberOfRunningActions
{
	return [_actionManager numberOfRunningActionsInTarget:self];
}

#pragma mark CCNode - Scheduler

-(void) setScheduler:(CCScheduler *)scheduler
{
	if( scheduler != _scheduler ) {
		[self unscheduleAllSelectors];

		_scheduler = scheduler;
	}
}

-(CCScheduler*) scheduler
{
	return _scheduler;
}

-(void) scheduleUpdate
{
	[self scheduleUpdateWithPriority:0];
}

-(void) scheduleUpdateWithPriority:(NSInteger)priority
{
	[_scheduler scheduleUpdateForTarget:self priority:priority paused:!_isRunning];
}

-(void) unscheduleUpdate
{
	[_scheduler unscheduleUpdateForTarget:self];
}

-(void) schedule:(SEL)selector
{
	[self schedule:selector interval:0 repeat:kCCRepeatForever delay:0];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval
{
	[self schedule:selector interval:interval repeat:kCCRepeatForever delay:0];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval repeat: (uint) repeat delay:(ccTime) delay
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");

	[_scheduler scheduleSelector:selector forTarget:self interval:interval repeat:repeat delay:delay paused:!_isRunning];
}

- (void) scheduleOnce:(SEL) selector delay:(ccTime) delay
{
	[self schedule:selector interval:0.f repeat:0 delay:delay];
}

-(void) unschedule:(SEL)selector
{
	// explicit nil handling
	if (selector == nil)
		return;

	[_scheduler unscheduleSelector:selector forTarget:self];
}

-(void) unscheduleAllSelectors
{
	[_scheduler unscheduleAllForTarget:self];
}
- (void) resumeSchedulerAndActions
{
	[_scheduler resumeTarget:self];
	[_actionManager resumeTarget:self];
}

- (void) pauseSchedulerAndActions
{
	[_scheduler pauseTarget:self];
	[_actionManager pauseTarget:self];
}

/* override me */
-(void) update:(ccTime)delta
{
}

#pragma mark CCNode Transform

- (CGPoint) convertPositionToPoints:(CGPoint)position
{
    CCDirector* director = [CCDirector sharedDirector];
    
    CGPoint positionInPoints;
    float x = 0;
    float y = 0;
    
    // Convert position to points
    CCPositionUnit xUnit = _positionType.xUnit;
    if (xUnit == kCCPositionUnitPoints) x = position.x;
    else if (xUnit == kCCPositionUnitScaled) x = position.x * director.positionScaleFactor;
    else if (xUnit == kCCPositionUnitNormalized) x = position.x * _parent.contentSizeInPoints.width;
    
    CCPositionUnit yUnit = _positionType.yUnit;
    if (yUnit == kCCPositionUnitPoints) y = position.y;
    else if (yUnit == kCCPositionUnitScaled) y = position.y * director.positionScaleFactor;
    else if (yUnit == kCCPositionUnitNormalized) y = position.y * _parent.contentSizeInPoints.height;
    
    // Account for reference corner
    CCPositionReferenceCorner corner = _positionType.corner;
    if (corner == kCCPositionReferenceCornerBottomLeft)
    {
        // Nothing needs to be done
    }
    else if (corner == kCCPositionReferenceCornerTopLeft)
    {
        // Reverse y-axis
        y = _parent.contentSizeInPoints.height - y;
    }
    else if (corner == kCCPositionReferenceCornerTopRight)
    {
        // Reverse x-axis and y-axis
        x = _parent.contentSizeInPoints.width - x;
        y = _parent.contentSizeInPoints.height - y;
    }
    else if (corner == kCCPositionReferenceCornerBottomRight)
    {
        // Reverse x-axis
        x = _parent.contentSizeInPoints.width - x;
    }
    
    positionInPoints.x = x;
    positionInPoints.y = y;
    
    return positionInPoints;
}

- (CGPoint) convertPositionFromPoints:(CGPoint)positionInPoints
{
    CCDirector* director = [CCDirector sharedDirector];
    
    CGPoint position;
    
    float x = positionInPoints.x;
    float y = positionInPoints.y;
    
    // Account for reference corner
    CCPositionReferenceCorner corner = _positionType.corner;
    if (corner == kCCPositionReferenceCornerBottomLeft)
    {
        // Nothing needs to be done
    }
    else if (corner == kCCPositionReferenceCornerTopLeft)
    {
        // Reverse y-axis
        y = _parent.contentSizeInPoints.height - y;
    }
    else if (corner == kCCPositionReferenceCornerTopRight)
    {
        // Reverse x-axis and y-axis
        x = _parent.contentSizeInPoints.width - x;
        y = _parent.contentSizeInPoints.height - y;
    }
    else if (corner == kCCPositionReferenceCornerBottomRight)
    {
        // Reverse x-axis
        x = _parent.contentSizeInPoints.width - x;
    }
    
    // Convert position from points
    CCPositionUnit xUnit = _positionType.xUnit;
    if (xUnit == kCCPositionUnitPoints) position.x = x;
    else if (xUnit == kCCPositionUnitScaled) position.x = x / director.positionScaleFactor;
    else if (xUnit == kCCPositionUnitNormalized)
    {
        float parentWidth = _parent.contentSizeInPoints.width;
        if (parentWidth > 0)
        {
            position.x = x / parentWidth;
        }
    }
    
    CCPositionUnit yUnit = _positionType.yUnit;
    if (yUnit == kCCPositionUnitPoints) position.y = y;
    else if (yUnit == kCCPositionUnitScaled) position.y = y / director.positionScaleFactor;
    else if (yUnit == kCCPositionUnitNormalized)
    {
        float parentHeight = _parent.contentSizeInPoints.height;
        if (parentHeight > 0)
        {
            position.y = y / parentHeight;
        }
    }
    
    return position;
}

- (CGPoint) positionInPoints
{
    return [self convertPositionToPoints:GetPosition(self)];
}

- (CGAffineTransform)nodeToParentTransform
{
	// TODO need to find a better way to mark physics transforms as dirty.
	if ( _isTransformDirty || _physicsBody ) {
        
        // TODO: Make this more efficient
        CGSize contentSizeInPoints = self.contentSizeInPoints;
        _anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
        
        // Convert position to points
        CGPoint positionInPoints = [self convertPositionToPoints:GetPosition(self)];
		float x = positionInPoints.x;
		float y = positionInPoints.y;
        
		// Rotation values
		// Change rotation code to handle X and Y
		// If we skew with the exact same value for both x and y then we're simply just rotating
//		float cx = 1, sx = 0, cy = 1, sy = 0;
//		if( _rotationX || _rotationY ) {
			float radiansX = -CC_DEGREES_TO_RADIANS(GetRotationX(self));
			float radiansY = -CC_DEGREES_TO_RADIANS(GetRotationY(self));
			float cx = cosf(radiansX);
			float sx = sinf(radiansX);
			float cy = cosf(radiansY);
			float sy = sinf(radiansY);
//		}

		BOOL needsSkewMatrix = ( _skewX || _skewY );

		// optimization:
		// inline anchor point calculation if skew is not needed
		// Adjusted transform calculation for rotational skew
		if( !needsSkewMatrix && !CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ) {
			x += cy * -_anchorPointInPoints.x * _scaleX + -sx * -_anchorPointInPoints.y * _scaleY;
			y += sy * -_anchorPointInPoints.x * _scaleX +  cx * -_anchorPointInPoints.y * _scaleY;
		}


		// Build Transform Matrix
		// Adjusted transfor m calculation for rotational skew
		_transform = CGAffineTransformMake( cy * _scaleX, sy * _scaleX,
										   -sx * _scaleY, cx * _scaleY,
										   x, y );

		// XXX: Try to inline skew
		// If skew is needed, apply skew and then anchor point
		if( needsSkewMatrix ) {
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(_skewY)),
																 tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1.0f,
																 0.0f, 0.0f );
			_transform = CGAffineTransformConcat(skewMatrix, _transform);

			// adjust anchor point
			if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
				_transform = CGAffineTransformTranslate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y);
		}

		_isTransformDirty = NO;
	}

	return _transform;
}

- (CGAffineTransform)parentToNodeTransform
{
	// TODO Need to find a better way to mark physics transforms as dirty
	if ( _isInverseDirty || _physicsBody ) {
		_inverse = CGAffineTransformInvert([self nodeToParentTransform]);
		_isInverseDirty = NO;
	}

	return _inverse;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];

	for (CCNode *p = _parent; p != nil; p = p.parent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);

	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	CGPoint ret = CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
	return ret;
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	CGPoint ret = CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
	return ret;
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return ccpSub(nodePoint, _anchorPointInPoints);
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint = ccpAdd(nodePoint, _anchorPointInPoints);
	return [self convertToWorldSpace:nodePoint];
}

- (CGPoint)convertToWindowSpace:(CGPoint)nodePoint
{
    CGPoint worldPoint = [self convertToWorldSpace:nodePoint];
	return [[CCDirector sharedDirector] convertToUI:worldPoint];
}

// convenience methods which take a UITouch instead of CGPoint

#ifdef __CC_PLATFORM_IOS

- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpaceAR:point];
}

#endif // __CC_PLATFORM_IOS

// -----------------------------------------------------------------
#pragma mark - touch interface
// -----------------------------------------------------------------

/** Returns YES, if touch is inside sprite
 Added hit area expansion / contraction
 @since v2.5
 */
- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    pos = [self convertToNodeSpace:pos];
    CGPoint offset = CGPointMake(self.contentSizeInPoints.width * (1 - _hitAreaExpansion) / 2, self.contentSizeInPoints.height * (1 - _hitAreaExpansion) / 2 );
    CGSize size = CGSizeMake(self.contentSizeInPoints.width - offset.x, self.contentSizeInPoints.height - offset.y);
    if ((pos.y < offset.y) || (pos.y > size.height) || (pos.x < offset.x) || (pos.x > size.width)) return(NO);
    
    return(YES);
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    if (_userInteractionEnabled == userInteractionEnabled) return;
    _userInteractionEnabled = userInteractionEnabled;
    [[[CCDirector sharedDirector] responderManager] markAsDirty];
}

// -----------------------------------------------------------------

@end

#pragma mark - NodeRGBA

@implementation CCNodeRGBA

@synthesize cascadeColorEnabled=_cascadeColorEnabled;
@synthesize cascadeOpacityEnabled=_cascadeOpacityEnabled;

-(id) init
{
	if ((self=[super init]) ) {
        _displayedOpacity = _realOpacity = 255;
        _displayedColor = _realColor = ccWHITE;
        _cascadeOpacityEnabled = NO;
        _cascadeColorEnabled = NO;
    }
    return self;
}

-(GLubyte) opacity
{
	return _realOpacity;
}

-(GLubyte) displayedOpacity
{
	return _displayedOpacity;
}

- (void) setOpacity:(GLubyte)opacity
{
	_displayedOpacity = _realOpacity = opacity;
	
	if( _cascadeOpacityEnabled ) {
		GLubyte parentOpacity = 255;
		if( [_parent conformsToProtocol:@protocol(CCRGBAProtocol)] && [(id<CCRGBAProtocol>)_parent isCascadeOpacityEnabled] )
			parentOpacity = [(id<CCRGBAProtocol>)_parent displayedOpacity];
		[self updateDisplayedOpacity:parentOpacity];
	}
}

- (void)updateDisplayedOpacity:(GLubyte)parentOpacity
{
	_displayedOpacity = _realOpacity * parentOpacity/255.0;
	
    if (_cascadeOpacityEnabled) {
        for (id<CCRGBAProtocol> item in _children) {
            if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
                [item updateDisplayedOpacity:_displayedOpacity];
            }
        }
    }
}

-(ccColor3B) color
{
	return _realColor;
}

-(ccColor3B) displayedColor
{
	return _displayedColor;
}

- (void) setColor:(ccColor3B)color
{
	_displayedColor = _realColor = color;
	
	if( _cascadeColorEnabled ) {
		ccColor3B parentColor = ccWHITE;
		if( [_parent conformsToProtocol:@protocol(CCRGBAProtocol)] && [(id<CCRGBAProtocol>)_parent isCascadeColorEnabled] )
			parentColor = [(id<CCRGBAProtocol>)_parent displayedColor];
		[self updateDisplayedColor:parentColor];
	}
}

- (void)updateDisplayedColor:(ccColor3B)parentColor
{
	_displayedColor.r = _realColor.r * parentColor.r/255.0;
	_displayedColor.g = _realColor.g * parentColor.g/255.0;
	_displayedColor.b = _realColor.b * parentColor.b/255.0;

    if (_cascadeColorEnabled) {
        for (id<CCRGBAProtocol> item in _children) {
            if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
                [item updateDisplayedColor:_displayedColor];
            }
        }
    }
}

@end




























































