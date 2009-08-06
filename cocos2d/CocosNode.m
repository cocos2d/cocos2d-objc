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
#import "ActionManager.h"
#import "Support/CGPointExtension.h"
#import "Support/ccArray.h"
#import "Support/TransformUtils.h"


#if 1
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (int)
#endif

@interface CocosNode (Private)
// lazy allocs
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
@synthesize parent;
@synthesize grid;
@synthesize zOrder;
@synthesize tag;
@synthesize vertexZ = vertexZ_;

#pragma mark CocosNode - Transform related properties

@synthesize rotation=rotation_, scaleX=scaleX_, scaleY=scaleY_, position=position_;
@synthesize transformAnchor=transformAnchor_, relativeAnchorPoint=relativeAnchorPoint_;
@synthesize userData;

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

-(void) setRelativeAnchorPoint: (BOOL)newValue
{
	relativeAnchorPoint_ = newValue;
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

		// "whole screen" objects. like Scenes and Layers, should set relativeAnchorPoint to NO
		relativeAnchorPoint_ = YES; 
		
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
		
		// scheduled selectors (lazy allocs)
		scheduledSelectors = nil;
		
		// userData is always inited as nil
		userData = nil;
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

- (NSArray *)children
{
	return (NSArray *) children;
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
	for (CocosNode *c in children)
	{
		// IMPORTANT:
		//  -1st do onExit
		//  -2nd cleanup
		if (isRunning)
			[c onExit];

		if (cleanup)
			[c cleanup];

		// set parent nil at the end (issue #476)
		[c setParent:nil];
	}

	[children removeAllObjects];
}

-(void) detachChild:(CocosNode *)child cleanup:(BOOL)doCleanup
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if (isRunning)
		[child onExit];

	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors dict will not get released!
	if (doCleanup)
		[child cleanup];

	// set parent nil at the end (issue #476)
	[child setParent:nil];

	[children removeObject:child];
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
	if ( relativeAnchorPoint_ && (transformAnchor_.x != 0 || transformAnchor_.y != 0 ) )
		glTranslatef( RENDER_IN_SUBPIXEL(-transformAnchor_.x), RENDER_IN_SUBPIXEL(-transformAnchor_.y), vertexZ_);
	
	if (transformAnchor_.x != 0 || transformAnchor_.y != 0 )
		glTranslatef( RENDER_IN_SUBPIXEL(position_.x + transformAnchor_.x), RENDER_IN_SUBPIXEL(position_.y + transformAnchor_.y), vertexZ_);
	else if ( position_.x !=0 || position_.y !=0)
		glTranslatef( RENDER_IN_SUBPIXEL(position_.x), RENDER_IN_SUBPIXEL(position_.y), vertexZ_ );
	
	// rotate
	if (rotation_ != 0.0f )
		glRotatef( -rotation_, 0.0f, 0.0f, 1.0f );
	
	// scale
	if (scaleX_ != 1.0f || scaleY_ != 1.0f)
		glScalef( scaleX_, scaleY_, 1.0f );
	
	// restore and re-position point
	if (transformAnchor_.x != 0.0f || transformAnchor_.y != 0.0f)
		glTranslatef(RENDER_IN_SUBPIXEL(-transformAnchor_.x), RENDER_IN_SUBPIXEL(-transformAnchor_.y), vertexZ_);
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

-(Action*) runAction:(Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
	
	[[ActionManager sharedManager] addAction:action target:self paused:!isRunning];
	return action;
}

-(void) stopAllActions
{
	[[ActionManager sharedManager] removeAllActionsFromTarget:self];
}

-(void) stopAction: (Action*) action
{
	[[ActionManager sharedManager] removeAction:action];
}

-(void) stopActionByTag:(int)aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	[[ActionManager sharedManager] removeActionByTag:aTag target:self];
}

-(Action*) getActionByTag:(int) aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");

	return [[ActionManager sharedManager] getActionByTag:aTag target:self];
}

-(int) numberOfRunningActions
{
	return [[ActionManager sharedManager] numberOfRunningActionsInTarget:self];
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
	
	[[ActionManager sharedManager] resumeAllActionsForTarget:self];
}

- (void) deactivateTimers
{
	for( id key in scheduledSelectors )
		[[Scheduler sharedScheduler] unscheduleTimer: [scheduledSelectors objectForKey:key]];

	[[ActionManager sharedManager] pauseAllActionsForTarget:self];
}


#pragma mark CocosNode Transform

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty_ ) {
		
		transform_ = CGAffineTransformIdentity;
		
		if ( !relativeAnchorPoint_ ) {
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
