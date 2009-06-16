/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CocosNode.h"
#import "Camera.h"
#import "Grid.h"
#import "Scheduler.h"
#import "ccMacros.h"
#import "Director.h"
#import "Support/CGPointExtension.h"
#import "Support/ccArray.h"
#import "Support/TransformUtils.h"

@interface CocosNode (Private)
-(void) step_: (ccTime) dt;
// lazy allocs
-(void) actionAlloc;
-(void) childrenAlloc;
-(void) timerAlloc;
// helper that reorder a child
-(void) insertChild:(CocosNode*)child z:(int)z;
// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(int) z;
-(void) detachChild:(CocosNode *)child cleanup:(BOOL)doCleanup;
@end

@implementation CocosNode

@synthesize visible;
@synthesize parent, children;
@synthesize grid;
@synthesize zOrder;
@synthesize tag;
@synthesize vertexZ = vertexZ_;

#pragma mark CocosNode - Transform related properties

@synthesize rotation=rotation_, scaleX=scaleX_, scaleY=scaleY_, position=position_;
@synthesize transformAnchor=transformAnchor_, relativeTransformAnchor=relativeTransformAnchor_;

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	rotation_ = newRotation;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setScaleX: (float)newScaleX
{
	scaleX_ = newScaleX;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setScaleY: (float)newScaleY
{
	scaleY_ = newScaleY;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setPosition: (CGPoint)newPosition
{
	position_ = newPosition;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setTransformAnchor: (CGPoint)newTransformAnchor
{
	transformAnchor_ = newTransformAnchor;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setRelativeTransformAnchor: (BOOL)newValue
{
	relativeTransformAnchor_ = newValue;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, anchorPoint_) ) {
		anchorPoint_ = point;
		self.transformAnchor = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
	}
}
-(CGPoint) anchorPoint
{
	return anchorPoint_;
}
-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, contentSize_) ) {
		contentSize_ = size;
		self.transformAnchor = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
	}
}
-(CGSize) contentSize
{
	return contentSize_;
}

-(float) scale
{
	if( scaleX_ == scaleY_)
		return scaleX_;
	else
		[NSException raise:@"CocosNode scale:" format:@"scaleX is different from scaleY"];
	
	return 0;
}

-(void) setScale:(float) s
{
	scaleX_ = scaleY_ = s;
	isTransformDirty_ = isInverseDirty_ = YES;
}


#pragma mark CocosNode - Init & cleanup

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if ((self=[super init]) ) {

		isRunning = NO;
	
		rotation_ = 0.0f;
		scaleX_ = scaleY_ = 1.0f;
		position_ = CGPointZero;
		transformAnchor_ = CGPointZero;
		anchorPoint_ = CGPointZero;
		contentSize_ = CGSizeZero;

		// "whole screen" objects. like Scenes and Layers, should set relativeTransformAnchor to NO
		relativeTransformAnchor_ = YES; 
		
		isTransformDirty_ = isInverseDirty_ = YES;
		
		
		vertexZ_ = 0;

		grid = nil;
		
		visible = YES;

		tag = kCocosNodeTagInvalid;
		
		zOrder = 0;

		// lazy alloc
		camera = nil;

		// children (lazy allocs)
		children = nil;

		// actions (lazy allocs)
		actions = nil;
		
		// scheduled selectors (lazy allocs)
		scheduledSelectors = nil;
	}
	
	return self;
}

- (void)cleanup
{
	// actions
	[self stopAllActions];
	
	// timers
	[scheduledSelectors release];
	scheduledSelectors = nil;
	
	[children makeObjectsPerformSelector:@selector(cleanup)];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>", [self class], self, tag];
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);
	
	// attributes
	[camera release];

	[grid release];
	
	// children
	
	for (CocosNode *child in children) {
		child.parent = nil;
		[child cleanup];
	}
	
	[children release];
	
	// timers
	[scheduledSelectors release];
	
	// actions
	[self stopAllActions];
	ccArrayFree(actions);
	
	[super dealloc];
}

#pragma mark CocosNode Composition

-(void) childrenAlloc
{
	children = [[NSMutableArray arrayWithCapacity:4] retain];
}

// camera: lazy alloc
-(Camera*) camera
{
	if( ! camera )
		camera = [[Camera alloc] init];

	return camera;
}

/* "add" logic MUST only be on this selector
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this selector
 */
-(id) addChild: (CocosNode*) child z:(int)z tag:(int) aTag
{	
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");
	
	if( ! children )
		[self childrenAlloc];
	
	[self insertChild:child z:z];
	
	child.tag = aTag;
	
	[child setParent: self];
	
	if( isRunning )
		[child onEnter];
	return self;
}

-(id) addChild: (CocosNode*) child z:(int)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:z tag:child.tag];
}

-(id) addChild: (CocosNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:child.zOrder tag:child.tag];
}

/* "remove" logic MUST only be on this method
 * If a class want's to extend the 'removeChild' behavior it only needs
 * to override this method
 */
-(void) removeChild: (CocosNode*)child cleanup:(BOOL)cleanup
{
	// explicit nil handling
	if (child == nil)
		return;
	
	if ( [children containsObject:child] )
		[self detachChild:child cleanup:cleanup];
}

-(void) removeChildByTag:(int)aTag cleanup:(BOOL)cleanup
{
	NSAssert( aTag != kCocosNodeTagInvalid, @"Invalid tag");

	CocosNode *child = [self getChildByTag:aTag];
	
	if (child == nil)
		CCLOG(@"removeChildByTag: child not found!");
	else
		[self removeChild:child cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	// not using detachChild improves speed here
	for( CocosNode * c in children) {
		if( cleanup) {
			[c cleanup];
		}
		[c setParent: nil];
		if( isRunning )
			[c onExit];
	}
	
	[children removeAllObjects];
}

-(CocosNode*) getChildByTag:(int) aTag
{
	NSAssert( aTag != kCocosNodeTagInvalid, @"Invalid tag");
	
	for( CocosNode *node in children ) {
		if( node.tag == aTag )
			return node;
	}
	// not found
	return nil;
}

-(void) detachChild:(CocosNode *) child cleanup:(BOOL) doCleanup
{
	[child setParent: nil];
	
	// stop timers
	if( isRunning )
		[child onExit];
	
	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors dict will not get released!
	if (doCleanup)
		[child cleanup];
	
	[children removeObject: child];
}

// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(int) z
{
	zOrder = z;
}

// helper used by reorderChild & add
-(void) insertChild:(CocosNode*) child z:(int)z
{
	int index=0;
	BOOL added = NO;
	for( CocosNode *a in children ) {
		if ( a.zOrder > z ) {
			added = YES;
			[ children insertObject:child atIndex:index];
			break;
		}
		index++;
	}
	
	if( ! added )
		[children addObject:child];
	
	[child _setZOrder:z];
}

-(void) reorderChild:(CocosNode*) child z:(int)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	
	[child retain];
	[children removeObject:child];
	
	[self insertChild:child z:z];
	
	[child release];
}

#pragma mark CocosNode Draw

-(void) draw
{
	// override me
	// Only use this function to draw your staff.
	// DON'T draw your stuff outside this method
}

-(void) visit
{
	if (!visible)
		return;
	
	glPushMatrix();
	
	if ( grid && grid.active) {
		[grid beforeDraw];
		[self transformAncestors];
	}
	
	[self transform];
	
	for (CocosNode * child in children) {
		if ( child.zOrder < 0 )
			[child visit];
		else
			break;
	}
	
	[self draw];
	
	for (CocosNode * child in children) {		
		if ( child.zOrder >= 0 )
			[child visit];
	}
	
	if ( grid && grid.active)
		[grid afterDraw:self.camera];
	
	glPopMatrix();
}

#pragma mark CocosNode - Transformations

-(void) transformAncestors
{
	if( self.parent ) {
		[self.parent transformAncestors];
		[self.parent transform];
	}
}

-(void) transform
{
	if ( !(grid && grid.active) )
		[camera locate];
	
	// transformations
	
	// BEGIN original implementation
	// 
	// translate
	if ( relativeTransformAnchor_ && (transformAnchor_.x != 0 || transformAnchor_.y != 0 ) )
		glTranslatef( (int)(-transformAnchor_.x), (int)(-transformAnchor_.y), vertexZ_);
	
	if (transformAnchor_.x != 0 || transformAnchor_.y != 0 )
		glTranslatef( (int)(position_.x + transformAnchor_.x), (int)(position_.y + transformAnchor_.y), vertexZ_);
	else if ( position_.x !=0 || position_.y !=0)
		glTranslatef( (int)(position_.x), (int)(position_.y), vertexZ_ );
	
	// rotate
	if (rotation_ != 0.0f )
		glRotatef( -rotation_, 0.0f, 0.0f, 1.0f );
	
	// scale
	if (scaleX_ != 1.0f || scaleY_ != 1.0f)
		glScalef( scaleX_, scaleY_, 1.0f );
	
	// restore and re-position point
	if (transformAnchor_.x != 0.0f || transformAnchor_.y != 0.0f)
		glTranslatef((int)(-transformAnchor_.x), (int)(-transformAnchor_.y), vertexZ_);
	//
	// END original implementation
	
	/*
	// BEGIN alternative -- using cached transform
	//
	static GLfloat m[16];
	CGAffineTransform t = [self nodeToParentTransform];
	CGAffineToGL(&t, m);
	glMultMatrixf(m);
	glTranslatef(0, 0, vertexZ_);
	//
	// END alternative
	*/
}

#pragma mark CocosNode SceneManagement

-(void) onEnter
{
	for( id child in children )
		[child onEnter];
	
	[self activateTimers];

	isRunning = YES;
}

-(void) onEnterTransitionDidFinish
{
	for( id child in children )
		[child onEnterTransitionDidFinish];
}

-(void) onExit
{
	[self deactivateTimers];

	isRunning = NO;	
	
	for( id child in children )
		[child onExit];
}

#pragma mark CocosNode Actions

-(void) actionAlloc
{
	if( actions == nil )
		actions = ccArrayNew(4);
	else if( actions->num == actions->max )
		ccArrayDoubleCapacity(actions);
}

-(Action*) runAction:(Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
	
	// lazy alloc
	[self actionAlloc];
	
	NSAssert( !ccArrayContainsObject(actions, action), @"Action already running");
	
	ccArrayAppendObject(actions, action);
	
	action.target = self;
	[action start];
	
	[self schedule: @selector(step_:)];
	
	return action;
}

-(void) stopAllActions
{
	if( actions == nil )
		return;
	
	if( ccArrayContainsObject(actions, currentAction) && !currentActionSalvaged ) {
		[currentAction retain];
		currentActionSalvaged = YES;
	}
	
	ccArrayRemoveAllObjects(actions);
}

-(void) stopAction: (Action*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	if( actions != nil ) {
		NSUInteger i = ccArrayGetIndexOfObject(actions, action);
	
		if( i != NSNotFound ) {
			if( action == currentAction && !currentActionSalvaged ) {
				[currentAction retain];
				currentActionSalvaged = YES;
			}
			ccArrayRemoveObjectAtIndex(actions, i);
	
			// update actionIndex in case we are in step_, looping over the actions
			if( actionIndex >= (int) i )
				actionIndex--;
		}
	} else
		CCLOG(@"stopAction: Action not found!");
}

-(void) stopActionByTag:(int) aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	
	if( actions != nil ) {
		NSUInteger limit = actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			Action *a = actions->arr[i];
			
			if( a.tag == aTag ) {
				if( a == currentAction && !currentActionSalvaged ) {
					[currentAction retain];
					currentActionSalvaged = YES;
				}
				ccArrayRemoveObjectAtIndex(actions, i);
				
				// update actionIndex in case we are in step_, looping over the actions
				if (actionIndex >= (int) i)
					actionIndex--;
				return; 
			}
		}
	}
	
	CCLOG(@"stopActionByTag: Action not found!");
}

-(Action*) getActionByTag:(int) aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	
	if( actions != nil ) {
		NSUInteger limit = actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			Action *a = actions->arr[i];
		
			if( a.tag == aTag )
				return a; 
		}
	}

	CCLOG(@"getActionByTag: Action not found");
	return nil;
}

-(int) numberOfRunningActions
{
	return actions ? actions->num : 0;
}

-(void) step_: (ccTime) dt
{
	// !Running the actions may indirectly release the CocosNode, so we're
	// !retaining self to prevent deallocation.
	// ![self retain];
	
	// (!) UPDATE: Retaining isn't currently necessary because the Timer which runs 
	// step_ retains the node, keeping it alive. Even if an action indirectly calls
	// Scheduler#unscheduleTimer (i.e. CallFunc calls [parent removeChild:self] which
	// calls [self onExit] which calls [self deactivateTimers]), the Timer won't be
	// deallocated until the next Scheduler#tick.
	// Bottom line: Node doesn't run the risk of deallocating itself in step_ as
	// long as the implementation of Scheduler stays the same. We can ommit the
	// expensive retain/release.
		
	// call all actions
	
	// The 'actions' ccArray may change while inside this loop.
	for( actionIndex = 0; actionIndex < (int) actions->num; actionIndex++) {
		currentAction = actions->arr[actionIndex];
		currentActionSalvaged = NO;
		
		[currentAction step: dt];
		
		if( currentActionSalvaged ) {
			// The currentAction told the node to stop it. To prevent the action from
			// accidentally deallocating itself before finishing its step, we retained
			// it. Now that step is done, it's safe to release it.
			[currentAction release];
		}
		else if( [currentAction isDone] ) {
			[currentAction stop];
			
			Action *a = currentAction;
			// Make currentAction nil to prevent stopAction from salvaging it.
			currentAction = nil;
			[self stopAction:a];
		}
	}
	currentAction = nil;
	
	if( actions->num == 0 )
		[self unschedule: @selector(step_:)];
	
	// !And releasing self when done.
	// ![self release];
	// !If the node had a retain count of 1 before getting released, it's now
	// !deallocated. However, since we don't access any ivar, we're fine.
}

#pragma mark CocosNode Timers 

-(void) timerAlloc
{
	scheduledSelectors = [[NSMutableDictionary dictionaryWithCapacity: 2] retain];
}

-(void) schedule: (SEL) selector
{
	[self schedule:selector interval:0];
}

-(void) schedule: (SEL) selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	if( !scheduledSelectors )
		[self timerAlloc];
	
	// already scheduled ?
	if( [scheduledSelectors objectForKey: NSStringFromSelector(selector) ] ) {
		return;
	}
	
	Timer *timer = [Timer timerWithTarget:self selector:selector interval:interval];
	
	if( isRunning )
		[[Scheduler sharedScheduler] scheduleTimer:timer];
	
	[scheduledSelectors setObject:timer forKey:NSStringFromSelector(selector) ];
}

-(void) unschedule: (SEL) selector
{
	// explicit nil handling
	if (selector == nil)
		return;
	
	Timer *timer = nil;
	
	if( ! (timer = [scheduledSelectors objectForKey: NSStringFromSelector(selector)] ) )
	 {
		 CCLOG(@"CocosNode.unschedule: Selector not scheduled: %@",NSStringFromSelector(selector) );
		 return;
	 }
	
	[scheduledSelectors removeObjectForKey: NSStringFromSelector(selector) ];
	if( isRunning )
		[[Scheduler sharedScheduler] unscheduleTimer:timer];
}

- (void) activateTimers
{
	for( id key in scheduledSelectors )
		[[Scheduler sharedScheduler] scheduleTimer: [scheduledSelectors objectForKey:key]];
}

- (void) deactivateTimers
{
	for( id key in scheduledSelectors )
		[[Scheduler sharedScheduler] unscheduleTimer: [scheduledSelectors objectForKey:key]];
}


#pragma mark CocosNode Transform

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty_ ) {
		
		transform_ = CGAffineTransformIdentity;
		
		if ( !relativeTransformAnchor_ ) {
			transform_ = CGAffineTransformTranslate(transform_, (int)transformAnchor_.x, (int)transformAnchor_.y);
		}
		
		transform_ = CGAffineTransformTranslate(transform_, (int)position_.x, (int)position_.y);
		transform_ = CGAffineTransformRotate(transform_, -CC_DEGREES_TO_RADIANS(rotation_));
		transform_ = CGAffineTransformScale(transform_, scaleX_, scaleY_);
		
		transform_ = CGAffineTransformTranslate(transform_, -(int)transformAnchor_.x, -(int)transformAnchor_.y);
		
		isTransformDirty_ = NO;
	}
	
	return transform_;
}

- (CGAffineTransform)parentToNodeTransform
{
	if ( isInverseDirty_ ) {
		inverse_ = CGAffineTransformInvert([self nodeToParentTransform]);
		isInverseDirty_ = NO;
	}
	
	return inverse_;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
	
	for (CocosNode *p = parent; p != nil; p = p.parent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
	
	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	return CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return ccpSub(nodePoint, transformAnchor_);
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint = ccpAdd(nodePoint, transformAnchor_);
	return [self convertToWorldSpace:nodePoint];
}

// convenience methods which take a UITouch instead of CGPoint

- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpaceAR:point];
}

@end
