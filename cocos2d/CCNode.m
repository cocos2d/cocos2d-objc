/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "ccUtils.h"

#import "CCNode_Private.h"

#import "CCScene+Private.h"
#import "CCDirector_Private.h"
#import "CCScheduler_Private.h"

#import "CCAnimationManager.h"
#import "CCRenderer_Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "CCColor.h"
#import "CCLayout.h"
#import "CCScene.h"
#import "CCAction.h"


@interface CCAnimationManager()

- (void) addToScheduler;
- (void) removeFromScheduler;

@end


@implementation CCNode {
	// Rotation angle.
	float _rotationalSkewX, _rotationalSkewY;
    
	// Position of the node.
	CGPoint _position;
    
	// Transform.
	GLKMatrix4 _transform;
	BOOL _isTransformDirty;
    
	// Array of children.
	NSMutableArray *_children;
    
    // True to ensure reorder.
	BOOL _isReorderChildDirty;

    //Animation Manager used to handle CCB animations
    CCAnimationManager * _animationManager;
	
	// YES if the node is added to an active scene.
	BOOL _isInActiveScene;
	
	// Number of paused parent or ancestor nodes.
	int _pausedAncestors;
    
    // Blocks that are scheduled to run on this node when onEnter is called, contains scheduled stuff and actions.
    NSMutableArray *_queuedActions;
}

static inline
CCPhysicsBody *
GetBodyIfRunning(CCNode *node)
{
	return ([node isInActiveScene] ? node->_physicsBody : nil);
}

-(BOOL) isInActiveScene
{
    return _isInActiveScene;
}

GLKMatrix4
NodeToPhysicsTransform(CCNode *node)
{
	GLKMatrix4 transform = GLKMatrix4Identity;
	for(CCNode *n = node; n && !n.isPhysicsNode; n = n.parent){
	transform = GLKMatrix4Multiply(n.nodeToParentMatrix, transform);
	}
	
	return transform;
}

float
NodeToPhysicsRotation(CCNode *node)
{
	float rotation = 0.0;
	for(CCNode *n = node; n && !n.isPhysicsNode; n = n.parent){
		rotation -= n.rotationalSkewX;
	}
	
	return rotation;
}

CGPoint
NodeToPhysicsScale(CCNode * node)
{
    CGPoint scale = ccp(1.0f,1.0f);
    for(CCNode *n = node; n && !n.isPhysicsNode; n = n.parent){
        scale.x = scale.x * n.scaleX;
        scale.y = scale.y * n.scaleY;
	}
    
    return scale;
	
}

inline GLKMatrix4
RigidBodyToParentTransform(CCNode *node, CCPhysicsBody *body)
{
	return GLKMatrix4Multiply(GLKMatrix4Invert(NodeToPhysicsTransform(node.parent), NULL), body.absoluteTransform);
}

#pragma mark CCNode - Init & cleanup

+(instancetype) node
{
	return [[self alloc] init];
}

-(id) init
{
	if ((self=[super init]) ) {
		_isInActiveScene = NO;

		_skewX = _skewY = 0.0f;
		_rotationalSkewX = _rotationalSkewY = 0.0f;
		_scaleX = _scaleY = 1.0f;
        _position = CGPointZero;
        _contentSize = CGSizeZero;
		_anchorPointInPoints = _anchorPoint = CGPointZero;
        
		_isTransformDirty = YES;

		_zOrder = 0;
		_vertexZ = 0;
		_visible = YES;
        
		// set default touch handling
		self.hitAreaExpansion = 0.0f;
    
		_displayColor = _color = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
		_cascadeOpacityEnabled = NO;
		_cascadeColorEnabled = NO;
	}

	return self;
}

- (void)cleanup
{
	// Clean up timers and actions.
	[self stopAllActions];
	[self.scene.scheduler unscheduleTarget:self];

	[_children makeObjectsPerformSelector:@selector(cleanup)];
    
    // CCAnimationManager Cleanup (Set by SpriteBuilder)
    [_animationManager removeFromScheduler];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Name = %@>", [self class], self, _name];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
    
    [_name release];
    [_userObject release];
    [_children release];
    [_queuedActions release];
    [_animationManager release];
    [_physicsBody release];
    
    [super dealloc];
}

#pragma mark Setters

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		CGPoint position = self.position;
		body.absoluteRadians = -CC_DEGREES_TO_RADIANS(newRotation - NodeToPhysicsRotation(self.parent));
		body.relativeRotation = newRotation;
		// Rotating the body will cause the node to move unless the CoG is the same as the anchor point.
		self.position = position;
	} else {
		_rotationalSkewX = newRotation;
		_rotationalSkewY = newRotation;
		_isTransformDirty = YES;
	}
}

-(float) rotation
{
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		return -CC_RADIANS_TO_DEGREES(body.absoluteRadians) + NodeToPhysicsRotation(self.parent);
	} else {
		NSAssert( _rotationalSkewX == _rotationalSkewY, @"CCNode#rotation. rotationalSkewX != rotationalSkewY. Don't know which one to return");
		return _rotationalSkewX;
	}
}

-(float)rotationalSkewX {
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		return -CC_RADIANS_TO_DEGREES(body.absoluteRadians) + NodeToPhysicsRotation(self.parent);
	} else {
		return _rotationalSkewX;
	}
}

-(void) setRotationalSkewX: (float)newX
{
	NSAssert(_physicsBody == nil, @"Currently physics nodes don't support skewing.");
	
	_rotationalSkewX = newX;
	_isTransformDirty = YES;
}

-(float)rotationalSkewY
{
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		return -CC_RADIANS_TO_DEGREES(body.absoluteRadians) + NodeToPhysicsRotation(self.parent);
	} else {
		return _rotationalSkewY;
	}
}

-(void) setRotationalSkewY: (float)newY
{
	NSAssert(_physicsBody == nil, @"Currently physics nodes don't support skewing.");
	
	_rotationalSkewY = newY;
	_isTransformDirty = YES;
}

-(void) setScaleX: (float)newScaleX
{
	_scaleX = newScaleX;
	_isTransformDirty = YES;
}

-(void) setScaleY: (float)newScaleY
{
	_scaleY = newScaleY;
	_isTransformDirty = YES;
}

-(void) setSkewX:(float)newSkewX
{
	NSAssert(_physicsBody == nil, @"Currently physics nodes don't support skewing.");
	
	_skewX = newSkewX;
	_isTransformDirty = YES;
}

-(void) setSkewY:(float)newSkewY
{
	NSAssert(_physicsBody == nil, @"Currently physics nodes don't support skewing.");
	
	_skewY = newSkewY;
	_isTransformDirty = YES;
}

inline CGPoint
GetPositionFromBody(CCNode *node, CCPhysicsBody *body)
{
	return CGPointApplyGLKMatrix4(node->_anchorPointInPoints, [node nodeToParentMatrix]);
}

-(CGPoint)position
{
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		return [self convertPositionFromPoints:GetPositionFromBody(self, body) type:_positionType];
	} else {
		return _position;
	}
}

// Urg. CGPoint types. -_-
inline CGPoint
TransformPointAsVector(CGPoint p, GLKMatrix4 t)
{
	GLKVector4 v = GLKMatrix4MultiplyVector4(t, GLKVector4Make(p.x, p.y, 0.0f, 0.0f));
	return CGPointMake(v.x, v.y);
}

-(void) setPosition: (CGPoint)newPosition
{
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		CGPoint currentPosition = GetPositionFromBody(self, body);
        CGPoint newPositionInPoints = [self convertPositionToPoints:newPosition type:_positionType];
        
		CGPoint delta = ccpSub(newPositionInPoints, currentPosition);
		body.absolutePosition = ccpAdd(body.absolutePosition, TransformPointAsVector(delta, NodeToPhysicsTransform(self.parent)));
        body.relativePosition = newPositionInPoints;
	} else {
		_position = newPosition;
		_isTransformDirty = YES;
	}
}

-(void)setPositionType:(CCPositionType)positionType
{
	_positionType = positionType;
	_isTransformDirty = YES;
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) ) {
		_anchorPoint = point;
        CGSize contentSizeInPoints = self.contentSizeInPoints;
		_anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
		_isTransformDirty = YES;
	}
}

-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, _contentSize) )
    {
		_contentSize = size;
        [self contentSizeChanged];
	}
}

- (void) setContentSizeType:(CCSizeType)contentSizeType
{
    _contentSizeType = contentSizeType;
    [self contentSizeChanged];
}

- (void) contentSizeChanged
{
    // Update children
    CGSize contentSizeInPoints = self.contentSizeInPoints;
    _anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
    _isTransformDirty = YES;
    
    if ([_parent isKindOfClass:[CCLayout class]])
    {
        CCLayout* layout = (CCLayout*)_parent;
        [layout needsLayout];
    }
    
    // Update the children (if needed)
    for (CCNode* child in _children)
    {
        if (!CCPositionTypeIsBasicPoints(child->_positionType))
        {
            // This is a position type affected by content size
            child->_isTransformDirty = YES;
        }
    }
}

- (CGSize) convertContentSizeToPoints:(CGSize)contentSize type:(CCSizeType)type
{
    CGSize size = CGSizeZero;
    CCDirector* director = [CCDirector currentDirector];
    
    CCSizeUnit widthUnit = type.widthUnit;
    CCSizeUnit heightUnit = type.heightUnit;
    
    BOOL gotParentSize = NO;
    CGSize parentsContentSizeInPoints;
    
    // Width
    if (widthUnit == CCSizeUnitPoints)
    {
        size.width = contentSize.width;
    }
    else if (widthUnit == CCSizeUnitUIPoints)
    {
        size.width = director.UIScaleFactor * contentSize.width;
    }
    else if (widthUnit == CCSizeUnitNormalized)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        size.width = contentSize.width * parentsContentSizeInPoints.width;
    }
    else if (widthUnit == CCSizeUnitInsetPoints)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        size.width = parentsContentSizeInPoints.width - contentSize.width;
    }
    else if (widthUnit == CCSizeUnitInsetUIPoints)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        size.width = parentsContentSizeInPoints.width - contentSize.width * director.UIScaleFactor;
    }
    
    // Height
    if (heightUnit == CCSizeUnitPoints)
    {
        size.height = contentSize.height;
    }
    else if (heightUnit == CCSizeUnitUIPoints)
    {
        size.height = director.UIScaleFactor * contentSize.height;
    }
    else if (heightUnit == CCSizeUnitNormalized)
    {
        size.height = contentSize.height * (gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height);
    }
    else if (heightUnit == CCSizeUnitInsetPoints)
    {
        size.height = (gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height) - contentSize.height;
    }
    else if (heightUnit == CCSizeUnitInsetUIPoints)
    {
        size.height = (gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height) - contentSize.height * director.UIScaleFactor;
    }
    return size;
}

- (CGSize) convertContentSizeFromPoints:(CGSize)pointSize type:(CCSizeType)type
{
    CGSize size = CGSizeZero;
    
    CCDirector* director = [CCDirector currentDirector];
    
    CCSizeUnit widthUnit = type.widthUnit;
    CCSizeUnit heightUnit = type.heightUnit;
    
    BOOL gotParentSize = NO;
    CGSize parentsContentSizeInPoints;
    
    // Width
    if (widthUnit == CCSizeUnitPoints)
    {
        size.width = pointSize.width;
    }
    else if (widthUnit == CCSizeUnitUIPoints)
    {
        size.width = pointSize.width / director.UIScaleFactor;
    }
    else if (widthUnit == CCSizeUnitNormalized)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        
        float parentWidthInPoints = parentsContentSizeInPoints.width;
        if (parentWidthInPoints > 0)
        {
            size.width = pointSize.width/parentWidthInPoints;
        }
        else
        {
            size.width = 0;
        }
    }
    else if (widthUnit == CCSizeUnitInsetPoints)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        
        size.width = parentsContentSizeInPoints.width - pointSize.width;
    }
    else if (widthUnit == CCSizeUnitInsetUIPoints)
    {
        gotParentSize = YES;
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        
        size.width = (parentsContentSizeInPoints.width - pointSize.width) / director.UIScaleFactor;
    }
    
    // Height
    if (heightUnit == CCSizeUnitPoints)
    {
        size.height = pointSize.height;
    }
    else if (heightUnit == CCSizeUnitUIPoints)
    {
        size.height = pointSize.height / director.UIScaleFactor;
    }
    else if (heightUnit == CCSizeUnitNormalized)
    {
        float parentHeightInPoints = (gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height);
        if (parentHeightInPoints > 0)
        {
            size.height = pointSize.height/parentHeightInPoints;
        }
        else
        {
            size.height = 0;
        }
    }
    else if (heightUnit == CCSizeUnitInsetPoints)
    {
        size.height = (gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height) - pointSize.height;
    }
    else if (heightUnit == CCSizeUnitInsetUIPoints)
    {
        size.height = ((gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height) - pointSize.height) / director.UIScaleFactor;
    }
    return size;
}

- (CGSize) contentSizeInPoints
{
    return [self convertContentSizeToPoints:self.contentSize type:_contentSizeType];
}

-(void)setContentSizeInPoints:(CGSize)contentSizeInPoints
{
	self.contentSize = [self convertContentSizeFromPoints:contentSizeInPoints type:self.contentSizeType];
}

-(void) viewDidResizeTo: (CGSize) newViewSize
{
	for (CCNode* child in _children) [child viewDidResizeTo: newViewSize];
}

- (float) scaleInPoints
{
    if (_scaleType == CCScaleTypeScaled)
    {
        return self.scale * [CCDirector currentDirector].UIScaleFactor;
    }
    return self.scale;
}

- (float) scaleXInPoints
{
    if (_scaleType == CCScaleTypeScaled)
    {
        return _scaleX * [CCDirector currentDirector].UIScaleFactor;
    }
    return _scaleX;
}

- (float) scaleYInPoints
{
    if (_scaleType == CCScaleTypeScaled)
    {
        return _scaleY * [CCDirector currentDirector].UIScaleFactor;
    }
    return _scaleY;
}

- (void) setScaleType:(CCScaleType)scaleType
{
    _scaleType = scaleType;
    _isTransformDirty = YES;
}

- (CGRect) boundingBox
{
    CGSize contentSize = self.contentSizeInPoints;
    CGRect rect = CGRectMake(0, 0, contentSize.width, contentSize.height);
    GLKMatrix4 t = [self nodeToParentMatrix];
    return CGRectApplyAffineTransform(rect, CGAffineTransformMake(t.m[0], t.m[1], t.m[4], t.m[5], t.m[12], t.m[13]));
}

- (void)setVisible:(BOOL)visible
{
    if (visible == _visible) return;
    
    [[[CCDirector currentDirector] responderManager] markAsDirty];
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
	_isTransformDirty = YES;
}

- (void) setZOrder:(NSInteger)zOrder
{
    if(_zOrder != zOrder){
        _zOrder = zOrder;
        
        if(_parent){
            _parent->_isReorderChildDirty = YES;
        }
    }
}

#pragma mark CCNode Composition

// Recursively get a child by name, but don't return the root of the search.
-(CCNode*) getChildByNameRecursive:(NSString *)name root:(CCNode *)root
{
	if(self != root && [_name isEqualToString:name]) return self;
	
	for (CCNode* node in _children) {
		CCNode *n = [node getChildByNameRecursive:name root:root];
		if(n) return n;
	}

	// not found
	return nil;
}

-(CCNode*) getChildByName:(NSString *)name recursively:(bool)isRecursive
{
	NSAssert(name, @"name is nil.");
	
	if(isRecursive){
		return [self getChildByNameRecursive:name root:self];
	} else {
		for (CCNode* node in _children) {
			if([node.name isEqualToString:name]){
				return node;
			}
		}
	}

	// not found
	return nil;
}

// Recursively increment/decrement _pausedAncestors on the children of 'node'.
static void
RecursivelyIncrementPausedAncestors(CCNode *node, int increment)
{
	for(CCNode *child in node->_children){
		BOOL wasRunning = child.active;
		child->_pausedAncestors += increment;
		[child wasRunning:wasRunning];
		
		RecursivelyIncrementPausedAncestors(child, increment);
	}
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */
-(void) addChild: (CCNode*)child z:(NSInteger)z name:(NSString*)name
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added to another node. It can't be added again");
    NSAssert( [child class] != [CCScene class], @"Scenes may not be added as children of other nodes or scenes. Only one scene can exist in a hierarchy.");
    
	if(! _children){
        _children = [[NSMutableArray alloc] init];
    }

    child->_zOrder = z;
	child.name = name;
	child->_parent = self;

    [_children addObject:child];
	_isReorderChildDirty=YES;

	// Update pausing parameters
	child->_pausedAncestors = _pausedAncestors + (_paused ? 1 : 0);
	RecursivelyIncrementPausedAncestors(child, child->_pausedAncestors);
	
	if( [self isInActiveScene] ) {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
    
    [[[CCDirector currentDirector] responderManager] markAsDirty];
}

-(void) addChild: (CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:z name:child.name];
}

-(void) addChild: (CCNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:child.zOrder name:child.name];
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

	NSAssert([_children containsObject:child], @"This node does not contain the specified child.");
	
	[self detachChild:child cleanup:cleanup];
}

-(void) removeChildByName:(NSString*)name
{
	[self removeChildByName:name cleanup:YES];
}

-(void) removeChildByName:(NSString*)name cleanup:(BOOL)cleanup
{
	NSAssert( name, @"Invalid name");

	CCNode *child = [self getChildByName:name recursively:NO];

	if (child == nil)
		CCLOG(@"cocos2d: removeChildByName: child not found with name %@!", name);
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
		if ([self isInActiveScene])
		{
			[c onExitTransitionDidStart];
			[c onExit];
		}
		
		RecursivelyIncrementPausedAncestors(c, -c->_pausedAncestors);
		c->_pausedAncestors = 0;
		
		if (cleanup)
			[c cleanup];

		// set parent nil at the end (issue #476)
		c->_parent = nil;
        
        [[[CCDirector currentDirector] responderManager] markAsDirty];

	}

	[_children removeAllObjects];
}

-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if ([self isInActiveScene])
	{
		[child onExitTransitionDidStart];
		[child onExit];
	}
	
	RecursivelyIncrementPausedAncestors(child, -child->_pausedAncestors);
	child->_pausedAncestors = 0;
	
	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
		[child cleanup];

	// set parent nil at the end (issue #476)
	child->_parent = nil;

	[[[CCDirector currentDirector] responderManager] markAsDirty];

	[_children removeObject:child];
}

-(void)setParent:(CCNode *)parent
{
    if(_parent) [self removeFromParentAndCleanup:NO];
    [parent addChild:self];
}


-(void)setRawParent:(CCNode *)parent
{
    _parent = parent;
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
        [_children sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger z1 = [(CCNode *)obj1 zOrder];
            NSInteger z2 = [(CCNode *)obj2 zOrder];
            
            if(z1 < z2){
                return NSOrderedAscending;
            } else if(z1 > z2){
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];

		//don't need to check children recursively, that's done in visit of each child
        
		_isReorderChildDirty = NO;
        [[[CCDirector currentDirector] responderManager] markAsDirty];
	}
}

#pragma mark CCNode Draw

-(void)draw:(__unsafe_unretained CCRenderer *)renderer transform:(const GLKMatrix4 *)transform {}

-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// quick return if not visible. children won't be drawn.
	if (!_visible) return;
	
	[self sortAllChildren];
	
	GLKMatrix4 transform = GLKMatrix4Multiply(*parentTransform, [self nodeToParentMatrix]);
	BOOL drawn = NO;
	
	for(CCNode *child in _children){
		if(!drawn && child.zOrder >= 0){
			[self draw:renderer transform:&transform];
			drawn = YES;
		}
		
		[child visit:renderer parentTransform:&transform];
	}
	
	if(!drawn) [self draw:renderer transform:&transform];
}

-(void)visit
{
	CCRenderer *renderer = [CCRenderer currentRenderer];
	NSAssert(renderer, @"Cannot call [CCNode visit] without a currently bound renderer.");

	GLKMatrix4 projection; [renderer.globalShaderUniforms[CCShaderUniformProjection] getValue:&projection];
	[self visit:renderer parentTransform:&projection];
}

#pragma mark CCNode - Transformations

// Implemented in CCNoARC.m
//-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform

#pragma mark CCPhysics support.

inline GLKMatrix4
GLKMatrix4MakeRigid(CGPoint pos, CGFloat radians)
{
	CGPoint rot = ccpForAngle(radians);
	return GLKMatrix4Make(
		 rot.x, rot.y, 0.0f, 0.0f,
		-rot.y, rot.x, 0.0f, 0.0f,
		  0.0f,  0.0f, 1.0f, 0.0f,
		 pos.x, pos.y, 0.0f, 1.0f
	);
}

// Private method used to extract the non-rigid part of the node's transform relative to a CCPhysicsNode.
// This method can only be called in very specific circumstances.
-(GLKMatrix4)nonRigidTransform
{
	GLKMatrix4 toPhysics = NodeToPhysicsTransform(self);
	
	CCPhysicsBody *body = GetBodyIfRunning(self);
	if(body){
		return GLKMatrix4Multiply(GLKMatrix4Invert(body.absoluteTransform, NULL), toPhysics);
	} else {
		// Body is not active yet, so this is more of a mess. :-\
		// Need to guess the rigid part of the transform.
		float radians = CC_DEGREES_TO_RADIANS(NodeToPhysicsRotation(self));
		GLKMatrix4 absolute = GLKMatrix4MakeRigid(ccp(toPhysics.m[12], toPhysics.m[13]), radians);
		return GLKMatrix4Multiply(GLKMatrix4Invert(absolute, NULL), toPhysics);
	}
}

// Overriden by CCPhysicsNode to return YES.
-(BOOL)isPhysicsNode {return NO;}
-(CCPhysicsNode *)physicsNode {return (self.isPhysicsNode ? (CCPhysicsNode *)self : self.parent.physicsNode);}

-(void)setupPhysicsBody:(CCPhysicsBody *)physicsBody
{
	if(physicsBody){
		CCPhysicsNode *physics = self.physicsNode;
        
		if(physics == nil)
        {
            CCLOGWARN(@"Failed to find a parent CCPhysicsNode for this CCPhysicsBody. The CCPhysicsBody requires it be the child of a CCPhysicsNode when onEnter is called.");
            [_physicsBody release]; _physicsBody = nil;
            return;
        }
		
		// Copy the node's rotation first.
		// Otherwise it may cause the position to rotate around a non-zero center of gravity.
		physicsBody.absoluteRadians = CC_DEGREES_TO_RADIANS(NodeToPhysicsRotation(self));
		
		// Grab the origin position of the node from it's transform.
		GLKMatrix4 transform = NodeToPhysicsTransform(self);
		physicsBody.absolutePosition = ccp(transform.m[12], transform.m[13]);
        
        physicsBody.relativePosition = self.positionInPoints;
		physicsBody.relativeRotation = self.rotation;
        
		GLKMatrix4 nonRigid = self.nonRigidTransform;
		[_physicsBody willAddToPhysicsNode:physics nonRigidTransform:nonRigid];
		[physics.space smartAdd:physicsBody];
		[_physicsBody didAddToPhysicsNode:physics];
		
		NSArray *joints = physicsBody.joints;
		for(NSUInteger i=0, count=joints.count; i<count; i++){
			[joints[i] tryAddToPhysicsNode:physics];
		}
		
#ifndef NDEBUG
		// Reset these to zero since they shouldn't be read anyway.
		_position = CGPointZero;
		_rotationalSkewX = _rotationalSkewY = 0.0f;
#endif
	}
}

-(void)teardownPhysics
{
	if(_physicsBody){
		CCPhysicsNode *physics = self.physicsNode;
		NSAssert(physics != nil, @"A CCNode with an attached CCPhysicsBody must be a descendent of a CCPhysicsNode.");
		
		// Copy the positional data back to the ivars.
		_position = self.position;
		_rotationalSkewX = _rotationalSkewY = self.rotation;
		
		NSArray *joints = _physicsBody.joints;
		for(NSUInteger i=0, count=joints.count; i<count; i++){
			[joints[i] tryRemoveFromPhysicsNode:physics];
		}
		
		[physics.space smartRemove:_physicsBody];
		[_physicsBody didRemoveFromPhysicsNode:physics];
	}
}

-(void)setPhysicsBody:(CCPhysicsBody *)physicsBody
{
	if(physicsBody){
		NSAssert(_scaleType == CCScaleTypePoints, @"Currently only 'Points' is supported as a scale type for physics nodes.");
		NSAssert(_rotationalSkewX == _rotationalSkewY, @"Currently physics nodes don't support skewing.");
		NSAssert(_skewX == 0.0 && _skewY == 0.0, @"Currently physics nodes don't support skewing.");
	}
	
	if(physicsBody != _physicsBody){
		if([self isInActiveScene]){
			[self teardownPhysics];
			[self setupPhysicsBody:physicsBody];
		}
		
		// nil out the old body's node reference.
		_physicsBody.node = nil;
		
        [_physicsBody autorelease];
		_physicsBody = [physicsBody retain];
		_physicsBody.node = self;
	}
}

#pragma mark CCNode SceneManagement

-(CCScene *)scene
{
    return _parent.scene;
}


-(CCDirector *) director
{
    return self.scene.director;
}

-(CC_VIEW<CCView> *)view
{
    return self.director.view;
}

-(void) onEnter
{
    #warning Once CCDirector cleanup is done, we'll be able to add this assertion back in. Right now, it's hard to create complete scenes when writing unit tests, since the director is a singleton.
    //NSAssert(self.scene, @"Missing scene on node. Was it not added to the hierarchy?");
    
    [_children makeObjectsPerformSelector:@selector(onEnter)];
	
	[self setupPhysicsBody:_physicsBody];
	[self.scene.scheduler scheduleTarget:self];
    
	BOOL wasRunning = self.active;
	_isInActiveScene = YES;
	
    CCDirector* director = [CCDirector currentDirector];
    
	//If there's a physics node in the hierarchy, all actions should run on a fixed timestep.
    if(self.physicsNode != nil){
        self.scene.scheduler.actionsRunInFixedMode = YES;
    }

    if(_animationManager) {
        [_animationManager addToScheduler];
    }
    
    // Add queued actions or scheduled code, if needed:
    for( dispatch_block_t block in _queuedActions){
        block();
    }
    [_queuedActions release];
    _queuedActions = nil;
	
	[self wasRunning:wasRunning];
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
	[self teardownPhysics];
	
	BOOL wasRunning = self.active;
	_isInActiveScene = NO;
	[self wasRunning:wasRunning];
	
	[_children makeObjectsPerformSelector:@selector(onExit)];
}

#pragma mark CCNode Actions

-(CCAction*) runAction:(CCAction*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
    CCScheduler *scheduler = self.scheduler;
    
    __block CCAction *blockAction = action;
    if(scheduler == nil){
        if(_queuedActions == nil) _queuedActions = [[NSMutableArray alloc] init];
        dispatch_block_t block = ^(){
            [self.scheduler addAction:action target:self paused:!self.active];
        };
        [_queuedActions addObject:[block copy]];
    }else{
       	[scheduler addAction:action target:self paused:!self.active];
    }

	return action;
}

-(void) stopAllActions
{
	[self.scheduler removeAllActionsFromTarget:self];
}

-(void) stopAction: (CCAction*) action
{
	[self.scheduler removeAction:action fromTarget:self];
}

-(void) stopActionByName:(NSString *)name
{
	NSAssert(name, @"Name is nil.");
	[self.scheduler removeActionByName:name target:self];
}

-(CCAction*) getActionByName:(NSString *)name
{
	NSAssert(name, @"Name is nil.");
	return 	[self.scheduler getActionByName:name target:self];
}

-(NSArray *) actions
{
    return [self.scheduler actionsForTarget:self];
}

-(CCAnimationManager*)animationManager
{
    return _animationManager ?: _parent.animationManager;
}

#pragma mark CCNode - Scheduler

-(NSInteger)priority
{
	return 0;
}

-(CCTimer *) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay
{
	return [self.scheduler scheduleBlock:block forTarget:self withDelay:delay];
}


-(CCScheduler*) scheduler
{
	return self.scene.scheduler;
}

-(CCTimer *) schedule:(SEL)selector interval:(CCTime)interval
{
	return [self schedule:selector interval:interval repeat:CCTimerRepeatForever delay:interval];
}

-(CCTimer*)reschedule:(SEL)selector interval:(CCTime)interval
{
    NSString *selectorName = NSStringFromSelector(selector);
    
    CCTimer *currentTimerForSelector = nil;
    
    for (CCTimer *timer in [self.scheduler timersForTarget:self])
    {
        if([selectorName isEqual:timer.userData])
        {
            CCLOG(@"%@ was already scheduled on %@. Updating interval from %f to %f",NSStringFromSelector(selector),self,timer.repeatInterval,interval);
            timer.repeatInterval = interval;
            currentTimerForSelector = timer;
            break;
        }
    }
    
    if (currentTimerForSelector == nil)
    {
        CCLOG(@"%@ was never scheduled. Scheduling for the first time.",selectorName);
        currentTimerForSelector = [self schedule:selector interval:interval];
    }

    return currentTimerForSelector;
}

-(BOOL)unschedule_private:(SEL)selector
{
	NSString *selectorName = NSStringFromSelector(selector);
	
	for(CCTimer *timer in [self.scheduler timersForTarget:self]){
		if([selectorName isEqual:timer.userData]){
			[timer invalidate];
			return YES;
		}
	}
	
	return NO;
}

-(CCTimer *) schedule:(SEL)selector interval:(CCTime)interval repeat: (NSUInteger) repeat delay:(CCTime) delay
{
	NSAssert(selector != nil, @"Selector must be non-nil");
	NSAssert(selector != @selector(update:) && selector != @selector(fixedUpdate:), @"The update: and fixedUpdate: methods are scheduled automatically.");
	NSAssert(interval > 0.0, @"Scheduled method interval must be positive.");
	
	if([self unschedule_private:selector]){
		CCLOGWARN(@"Selector '%@' was already scheduled on %@", NSStringFromSelector(selector), self);
	}
	
	void (*imp)(id, SEL, CCTime) = (__typeof(imp))[self methodForSelector:selector];
	CCTimer *timer = [self.scheduler scheduleBlock:^(CCTimer *t){
		imp(self, selector, t.deltaTime);
	} forTarget:self withDelay:delay];
	
	timer.repeatCount = repeat;
	timer.repeatInterval = interval;
	timer.userData = NSStringFromSelector(selector);
	
	return timer;
}

- (CCTimer *) scheduleOnce:(SEL) selector delay:(CCTime) delay
{
	return [self schedule:selector interval:INFINITY repeat:0 delay:delay];
}

-(void)unschedule:(SEL)selector
{
	if(![self unschedule_private:selector]){
		CCLOGWARN(@"Selector '%@' was never scheduled on %@", NSStringFromSelector(selector), self);
	}
}

-(void)unscheduleAllSelectors
{
	for(CCTimer *timer in [self.scheduler timersForTarget:self]){
		if([timer.userData isKindOfClass:[NSString class]]) [timer invalidate];
	}
}

// Used to pause/unpause a node's actions and timers when it's isRunning state changes.
-(void)wasRunning:(BOOL)wasRunning
{
	BOOL isRunning = self.active;
	
    // Resume or pause scheduled update methods, CCActions, and animations if the pause state has changed
	if(isRunning != wasRunning){
		[self.scheduler setPaused:!isRunning target:self];
        [_animationManager setPaused:!isRunning];
	}
}


-(BOOL)active
{
	return ([self isInActiveScene] && !_paused && _pausedAncestors == 0);
}

-(void)setPaused:(BOOL)paused
{
	if(_paused != paused){
		BOOL wasRunning = self.active;
		_paused = paused;
		[self wasRunning:wasRunning];
		
		RecursivelyIncrementPausedAncestors(self, (paused ? 1 : -1));
	}
}

#pragma mark CCNode Transform

- (CGPoint) convertPositionToPoints:(CGPoint)position type:(CCPositionType)type
{
    CCDirector* director = [CCDirector currentDirector];
    
    BOOL gotParentSize = NO;
    CGSize parentsContentSizeInPoints;
    
    CGPoint positionInPoints;
    float x = 0;
    float y = 0;
    
    // Convert position to points
    CCPositionUnit xUnit = type.xUnit;
    if (xUnit == CCPositionUnitPoints) x = position.x;
    else if (xUnit == CCPositionUnitUIPoints) x = position.x * director.UIScaleFactor;
    else if(xUnit == CCPositionUnitNormalized){
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        gotParentSize = YES;
        x = position.x * parentsContentSizeInPoints.width;
    }
    
    CCPositionUnit yUnit = type.yUnit;
    if (yUnit == CCPositionUnitPoints) y = position.y;
    else if (yUnit == CCPositionUnitUIPoints) y = position.y * director.UIScaleFactor;
    else if (yUnit == CCPositionUnitNormalized){
        if(gotParentSize){
            y = position.y * parentsContentSizeInPoints.height;
        }else{
            parentsContentSizeInPoints = _parent.contentSizeInPoints;
            gotParentSize = YES;
            y = position.y * parentsContentSizeInPoints.height;
        }
    }
    
    // Account for reference corner
    CCPositionReferenceCorner corner = type.corner;
    if (corner == CCPositionReferenceCornerBottomLeft)
    {
        // Nothing needs to be done
    }
    else if (corner == CCPositionReferenceCornerTopLeft)
    {
        // Reverse y-axis
        y = gotParentSize?parentsContentSizeInPoints.height - y:_parent.contentSizeInPoints.height - y;
    }
    else if (corner == CCPositionReferenceCornerTopRight)
    {
        // Reverse x-axis and y-axis
        x = gotParentSize?parentsContentSizeInPoints.width - x:_parent.contentSizeInPoints.width - x;
        y = gotParentSize?parentsContentSizeInPoints.height - y:_parent.contentSizeInPoints.height - y;
    }
    else if (corner == CCPositionReferenceCornerBottomRight)
    {
        // Reverse x-axis
        x = gotParentSize?parentsContentSizeInPoints.width - x:_parent.contentSizeInPoints.width - x;
    }
    
    positionInPoints.x = x;
    positionInPoints.y = y;
    
    return positionInPoints;
}

- (CGPoint) convertPositionFromPoints:(CGPoint)positionInPoints type:(CCPositionType)type
{
    CCDirector* director = [CCDirector currentDirector];
    
    BOOL gotParentSize = NO;
    CGSize parentsContentSizeInPoints;
    
    CGPoint position;
    
    float x = positionInPoints.x;
    float y = positionInPoints.y;
    
    // Account for reference corner
    CCPositionReferenceCorner corner = type.corner;
    if (corner == CCPositionReferenceCornerBottomLeft)
    {
        // Nothing needs to be done
    }
    else if (corner == CCPositionReferenceCornerTopLeft)
    {
        // Reverse y-axis
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        gotParentSize = YES;
        y = parentsContentSizeInPoints.height - y;
    }
    else if (corner == CCPositionReferenceCornerTopRight)
    {
        // Reverse x-axis and y-axis
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        gotParentSize = YES;
        x = parentsContentSizeInPoints.width - x;
        y = parentsContentSizeInPoints.height - y;
    }
    else if (corner == CCPositionReferenceCornerBottomRight)
    {
        // Reverse x-axis
        parentsContentSizeInPoints = _parent.contentSizeInPoints;
        gotParentSize = YES;
        x = parentsContentSizeInPoints.width - x;
    }
    
    // Convert position from points
    CCPositionUnit xUnit = type.xUnit;
    if (xUnit == CCPositionUnitPoints) position.x = x;
    else if (xUnit == CCPositionUnitUIPoints) position.x = x / director.UIScaleFactor;
    else if (xUnit == CCPositionUnitNormalized)
    {
        float parentWidth = gotParentSize?parentsContentSizeInPoints.width:_parent.contentSizeInPoints.width;
        if (parentWidth > 0)
        {
            position.x = x / parentWidth;
        }
    }
    
    CCPositionUnit yUnit = type.yUnit;
    if (yUnit == CCPositionUnitPoints) position.y = y;
    else if (yUnit == CCPositionUnitUIPoints) position.y = y / director.UIScaleFactor;
    else if (yUnit == CCPositionUnitNormalized)
    {
        float parentHeight = gotParentSize?parentsContentSizeInPoints.height:_parent.contentSizeInPoints.height;
        if (parentHeight > 0)
        {
            position.y = y / parentHeight;
        }
    }
    
    return position;
}

- (CGPoint) positionInPoints
{
    return [self convertPositionToPoints:self.position type:_positionType];
}

-(void)setPositionInPoints:(CGPoint)positionInPoints
{
	self.position = [self convertPositionFromPoints:positionInPoints type:self.positionType];
}

- (GLKMatrix4)nodeToParentMatrix
{
	// The body ivar cannot be changed while this method is running and it's ARC retain/release is 70% of the profile samples for this method.
	__unsafe_unretained CCPhysicsBody *physicsBody = GetBodyIfRunning(self);
	if(physicsBody){
        
		GLKMatrix4 rigidTransform;
		
		if(physicsBody.type == CCPhysicsBodyTypeKinematic)
		{
			CGPoint anchorPointInPointsScaled = ccpCompMult(_anchorPointInPoints,
															ccp(_scaleX, _scaleY));
			CGPoint rot = ccpRotateByAngle(anchorPointInPointsScaled, CGPointZero, -CC_DEGREES_TO_RADIANS(physicsBody.relativeRotation));
			rigidTransform = GLKMatrix4MakeRigid(ccpSub(physicsBody.relativePosition , rot ), -CC_DEGREES_TO_RADIANS(physicsBody.relativeRotation));
		}
		else
		{
			CGPoint scaleToParent = NodeToPhysicsScale(self.parent);
			GLKMatrix4 nodeToPhysics = NodeToPhysicsTransform(self.parent);
			rigidTransform = GLKMatrix4Multiply(GLKMatrix4Invert(nodeToPhysics, NULL), physicsBody.absoluteTransform);
			rigidTransform = GLKMatrix4Multiply(rigidTransform, GLKMatrix4MakeScale(scaleToParent.x, scaleToParent.y, 1.0f));
		}
		
		_transform = GLKMatrix4Multiply(rigidTransform, GLKMatrix4MakeScale(_scaleX, _scaleY, 1.0));
	} else if ( _isTransformDirty ) {
        
        // Get content size
        CGSize contentSizeInPoints;
        if (CCSizeTypeIsBasicPoints(_contentSizeType))
        {
            // Optimization for basic content sizes (most common case)
            contentSizeInPoints = _contentSize;
        }
        else
        {
            contentSizeInPoints = self.contentSizeInPoints;
        }
        
        // Calculate the anchor point in points
        _anchorPointInPoints = ccp( contentSizeInPoints.width * _anchorPoint.x, contentSizeInPoints.height * _anchorPoint.y );
        
        // Convert position to points
        CGPoint positionInPoints;
        if (CCPositionTypeIsBasicPoints(_positionType))
        {
            // Optimization for basic points (most common case)
            positionInPoints = _position;
        }
        else
        {
            positionInPoints = [self convertPositionToPoints:_position type:_positionType];
        }
        
        // Get x and y
		float x = positionInPoints.x;
		float y = positionInPoints.y;
        
		// Rotation values
		// Change rotation code to handle X and Y
		// If we skew with the exact same value for both x and y then we're simply just rotating
		float cx = 1, sx = 0, cy = 1, sy = 0;
		if( _rotationalSkewX || _rotationalSkewY ) {
			float radiansX = -CC_DEGREES_TO_RADIANS(_rotationalSkewX);
			float radiansY = -CC_DEGREES_TO_RADIANS(_rotationalSkewY);
			cx = cosf(radiansX);
			sx = sinf(radiansX);
			cy = cosf(radiansY);
			sy = sinf(radiansY);
		}

		BOOL needsSkewMatrix = ( _skewX || _skewY );
        
        float scaleFactor = 1;
        if (_scaleType == CCScaleTypeScaled) scaleFactor = [CCDirector currentDirector].UIScaleFactor;

		// optimization:
		// inline anchor point calculation if skew is not needed
		// Adjusted transform calculation for rotational skew
		if( !needsSkewMatrix && !CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ) {
			x += cy * -_anchorPointInPoints.x * _scaleX * scaleFactor + -sx * -_anchorPointInPoints.y * _scaleY;
			y += sy * -_anchorPointInPoints.x * _scaleX * scaleFactor +  cx * -_anchorPointInPoints.y * _scaleY;
		}


		// Build Transform Matrix
		// Adjusted transfor m calculation for rotational skew
		_transform = GLKMatrix4Make( cy * _scaleX * scaleFactor, sy * _scaleX * scaleFactor, 0.0f, 0.0f,
										   -sx * _scaleY * scaleFactor, cx * _scaleY * scaleFactor, 0.0f, 0.0f,
											 0.0f, 0.0f, 1.0f, 0.0f,
										   x, y, _vertexZ, 1.0f);

		// XXX: Try to inline skew
		// If skew is needed, apply skew and then anchor point
		if( needsSkewMatrix ) {
			GLKMatrix4 skewMatrix = GLKMatrix4Make(1.0f, tanf(CC_DEGREES_TO_RADIANS(_skewY)), 0.0f, 0.0f,
																 tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1.0f, 0.0f, 0.0f,
											 0.0f, 0.0f, 1.0f, 0.0f,
																 0.0f, 0.0f, 0.0f, 1.0f);
			_transform = GLKMatrix4Multiply(_transform, skewMatrix);

			// adjust anchor point
			if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
				_transform = GLKMatrix4Translate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y, 0.0f);
		}

		_isTransformDirty = NO;
	}

	return _transform;
}

- (GLKMatrix4)parentToNodeMatrix
{
	return GLKMatrix4Invert([self nodeToParentMatrix], NULL);
}

- (GLKMatrix4)nodeToWorldMatrix
{
	GLKMatrix4 t = [self nodeToParentMatrix];

	for (CCNode *p = _parent; p != nil; p = p.parent)
		t = GLKMatrix4Multiply([p nodeToParentMatrix], t);

	return t;
}

- (GLKMatrix4)worldToNodeMatrix
{
	return GLKMatrix4Invert([self nodeToWorldMatrix], NULL);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return CGPointApplyGLKMatrix4(worldPoint, [self worldToNodeMatrix]);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	return CGPointApplyGLKMatrix4(nodePoint, [self nodeToWorldMatrix]);
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
	return [[CCDirector currentDirector] convertToUI:worldPoint];
}

// -----------------------------------------------------------------
#pragma mark - touch interface
// -----------------------------------------------------------------

/** Returns YES, if touch is inside sprite
 Added hit area expansion / contraction
 Override for alternative clipping behavior, such as if you want to clip input to a circle.
 */
- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    pos = [self convertToNodeSpace:pos];
    CGPoint offset = ccp(-self.hitAreaExpansion, -self.hitAreaExpansion);
    CGSize size = CGSizeMake(self.contentSizeInPoints.width - offset.x, self.contentSizeInPoints.height - offset.y);
    
    return !(pos.y < offset.y || pos.y > size.height || pos.x < offset.x || pos.x > size.width);
}

- (BOOL)clippedHitTestWithWorldPos:(CGPoint)pos
{
    // If *any* parent node clips input and we're outside their clipping range, reject the hit.
    if(_parent != nil && [_parent rejectClippedInput:pos]){
        return NO;
    }
    
    return [self hitTestWithWorldPos:pos];
}

- (BOOL) rejectClippedInput:(CGPoint)pos
{
    // If this clips input, do the bounds test to clip against this node
    if(self.clipsInput && ![self hitTestWithWorldPos:pos]){
        // outside of this node, reject this!
        return YES;
    }
    
    if(_parent == nil){
        // Terminating condition, the hit was not rejected
        return NO;
    }

    return [_parent rejectClippedInput:pos];
}
// -----------------------------------------------------------------

#pragma mark - CCColor methods

-(CGFloat) opacity
{
	return _color.a;
}

-(CGFloat) displayedOpacity
{
	return _displayColor.a;
}

- (void) setOpacity:(CGFloat)opacity
{
	_displayColor.a = _color.a = opacity;
	[self cascadeOpacityIfNeeded];
}

-(CCColor*) color
{
	return [CCColor colorWithGLKVector4:_color];
}

-(CCColor*) displayedColor
{
	return [CCColor colorWithGLKVector4:_displayColor];
}


- (void) setColor:(CCColor*)color
{
	// Retain old alpha.
	float alpha = _color.a;
	_displayColor = _color = color.glkVector4;
	_displayColor.a = _color.a = alpha;
	
	[self cascadeColorIfNeeded];
}

-(CCColor*) colorRGBA
{
	return [CCColor colorWithGLKVector4:_color];
}

- (void) setColorRGBA:(CCColor*)color
{
	// apply the new alpha too.
	_displayColor = _color = color.glkVector4;
	
	[self cascadeColorIfNeeded];
	[self cascadeOpacityIfNeeded];
}


- (void) cascadeColorIfNeeded
{
	if( _cascadeColorEnabled ) {
		CCColor* parentColor = [CCColor whiteColor];
		if( _parent.isCascadeColorEnabled )
			parentColor = [_parent displayedColor];
		[self updateDisplayedColor:parentColor.glkVector4];
	}
}

// Used internally to recurse through children, thus the parameter is not a CCColor*
- (void)updateDisplayedColor:(GLKVector4) parentColor
{
	_displayColor.r = _color.r * parentColor.r;
	_displayColor.g = _color.g * parentColor.g;
	_displayColor.b = _color.b * parentColor.b;
	
	// if (_cascadeColorEnabled) {
		for (CCNode* item in _children) {
			[item updateDisplayedColor:_displayColor];
		}
	// }
}

- (void) cascadeOpacityIfNeeded
{
	if( _cascadeOpacityEnabled ) {
		float parentOpacity = 1.0f;
		if( [_parent isCascadeOpacityEnabled] )
			parentOpacity = [_parent displayedOpacity];
		[self updateDisplayedOpacity:parentOpacity];
	}
}

- (void)updateDisplayedOpacity:(CGFloat)parentOpacity
{
	_displayColor.a = _color.a * parentOpacity;
	
	// if (_cascadeOpacityEnabled) {
		for (CCNode* item in _children) {
			[item updateDisplayedOpacity:_displayColor.a];
		}
	// }
}

@end
