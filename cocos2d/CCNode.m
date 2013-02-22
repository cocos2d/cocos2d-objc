/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "Support/ccCArray.h"
#import "Support/TransformUtils.h"
#import "ccMacros.h"
#import "CCGLProgram.h"

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

@implementation CCNode

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

@synthesize rotationX = _rotationX, rotationY = _rotationY, scaleX = _scaleX, scaleY = _scaleY;
@synthesize position = _position;
@synthesize anchorPoint = _anchorPoint, anchorPointInPoints = _anchorPointInPoints;
@synthesize contentSize = _contentSize;
@synthesize ignoreAnchorPointForPosition = _ignoreAnchorPointForPosition;
@synthesize skewX = _skewX, skewY = _skewY;

#pragma mark CCNode - Init & cleanup

+(id) node
{
	return [[[self alloc] init] autorelease];
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


		// "whole screen" objects. like Scenes and Layers, should set ignoreAnchorPointForPosition to YES
		_ignoreAnchorPointForPosition = NO;

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

	[_actionManager release];
	[_scheduler release];
	[_camera release];
	[_grid release];
	[_shaderProgram release];
	[_userObject release];

	// children
	CCNode *child;
	CCARRAY_FOREACH(_children, child)
		child.parent = nil;

	[_children release];

	[super dealloc];
}

#pragma mark Setters

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	_rotationX = _rotationY = newRotation;
	_isTransformDirty = _isInverseDirty = YES;
}

-(float) rotation
{
	NSAssert( _rotationX == _rotationY, @"CCNode#rotation. RotationX != RotationY. Don't know which one to return");
	return _rotationX;
}

-(void) setRotationX: (float)newX
{
	_rotationX = newX;
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setRotationY: (float)newY
{
	_rotationY = newY;
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

-(void) setPosition: (CGPoint)newPosition
{
	_position = newPosition;
	_isTransformDirty = _isInverseDirty = YES;
}

-(void) setIgnoreAnchorPointForPosition: (BOOL)newValue
{
	if( newValue != _ignoreAnchorPointForPosition ) {
		_ignoreAnchorPointForPosition = newValue;
		_isTransformDirty = _isInverseDirty = YES;
	}
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) ) {
		_anchorPoint = point;
		_anchorPointInPoints = ccp( _contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
	}
}

-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, _contentSize) ) {
		_contentSize = size;

		_anchorPointInPoints = ccp( _contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
	}
}

- (CGRect) boundingBox
{
	CGRect rect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
	return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
}

-(void) setVertexZ:(float)vertexZ
{
	_vertexZ = vertexZ;
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
	_children = [[CCArray alloc] initWithCapacity:4];
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

	CCNode *node;
	CCARRAY_FOREACH(_children, node){
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
	CCNode *c;
	CCARRAY_FOREACH(_children, c)
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

	ccArrayAppendObjectWithResize(_children->data, child);
	[child _setZOrder:z];
}

-(void) reorderChild:(CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");

	_isReorderChildDirty = YES;

	[child setOrderOfArrival: globalOrderOfArrival++];
	[child _setZOrder:z];
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
		NSInteger i,j,length = _children->data->num;
		CCNode ** x = _children->data->arr;
		CCNode *tempItem;

		// insertion sort
		for(i=1; i<length; i++)
		{
			tempItem = x[i];
			j = i-1;

			//continue moving element downwards while zOrder is smaller or when zOrder is the same but mutatedIndex is smaller
			while(j>=0 && ( tempItem.zOrder < x[j].zOrder || ( tempItem.zOrder== x[j].zOrder && tempItem.orderOfArrival < x[j].orderOfArrival ) ) )
			{
				x[j+1] = x[j];
				j = j-1;
			}
			x[j+1] = tempItem;
		}

		//don't need to check children recursively, that's done in visit of each child

		_isReorderChildDirty = NO;
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

		ccArray *arrayData = _children->data;
		NSUInteger i = 0;

		// draw children zOrder < 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child = arrayData->arr[i];
			if ( [child zOrder] < 0 )
				[child visit];
			else
				break;
		}

		// self draw
		[self draw];

		// draw children zOrder >= 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child =  arrayData->arr[i];
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

#pragma mark CCNode SceneManagement

-(void) onEnter
{
	[_children makeObjectsPerformSelector:@selector(onEnter)];
	[self resumeSchedulerAndActions];

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
		[_actionManager release];

		_actionManager = [actionManager retain];
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
		[_scheduler release];

		_scheduler = [scheduler retain];
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

- (CGAffineTransform)nodeToParentTransform
{
	if ( _isTransformDirty ) {

		// Translate values
		float x = _position.x;
		float y = _position.y;

		if ( _ignoreAnchorPointForPosition ) {
			x += _anchorPointInPoints.x;
			y += _anchorPointInPoints.y;
		}
    
		// Rotation values
		// Change rotation code to handle X and Y
		// If we skew with the exact same value for both x and y then we're simply just rotating
		float cx = 1, sx = 0, cy = 1, sy = 0;
		if( _rotationX || _rotationY ) {
			float radiansX = -CC_DEGREES_TO_RADIANS(_rotationX);
			float radiansY = -CC_DEGREES_TO_RADIANS(_rotationY);
			cx = cosf(radiansX);
			sx = sinf(radiansX);
			cy = cosf(radiansY);
			sy = sinf(radiansY);
		}

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
	if ( _isInverseDirty ) {
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
        id<CCRGBAProtocol> item;
        CCARRAY_FOREACH(_children, item) {
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
        id<CCRGBAProtocol> item;
        CCARRAY_FOREACH(_children, item) {
            if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
                [item updateDisplayedColor:_displayedColor];
            }
        }
    }
}

@end
