/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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


@interface CocosNode (Private)
-(void) step_: (ccTime) dt;
// activate all scheduled timers
-(void) activateTimers;
// deactivate all scheduled timers
-(void) deactivateTimers;
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

@synthesize rotation, scaleX, scaleY, position;
@synthesize visible;
@synthesize transformAnchor, relativeTransformAnchor;
@synthesize parent, children;
@synthesize grid;
@synthesize zOrder;
@synthesize tag;
@synthesize vertexZ = vertexZ_;

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if (!(self=[super init]) )
		return nil;
	
	isRunning = NO;
	
	position = CGPointZero;
	
	rotation = 0.0f;		// 0 degrees	
	scaleX = 1.0f;			// scale factor
	scaleY = 1.0f;
	vertexZ_ = 0;

	grid = nil;
	
	visible = YES;

	transformAnchor = CGPointZero;
	
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
	
	// default.
	// "whole screen" objects should set it to NO, like Scenes and Layers
	relativeTransformAnchor = YES;

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

-(CGPoint) absolutePosition
{
	CGPoint ret = position;
	
	CocosNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}
	
	return ret;
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
	
	// transalte
	if ( relativeTransformAnchor && (transformAnchor.x != 0 || transformAnchor.y != 0 ) )
		glTranslatef( (int)(-transformAnchor.x), (int)(-transformAnchor.y), vertexZ_);
	
	if (transformAnchor.x != 0 || transformAnchor.y != 0 )
		glTranslatef( (int)(position.x + transformAnchor.x), (int)(position.y + transformAnchor.y), vertexZ_);
	else if ( position.x !=0 || position.y !=0)
		glTranslatef( (int)(position.x), (int)(position.y), vertexZ_ );
	
	// rotate
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
	
	// scale
	if (scaleX != 1.0f || scaleY != 1.0f)
		glScalef( scaleX, scaleY, 1.0f );
	
	// restore and re-position point
	if (transformAnchor.x != 0.0f || transformAnchor.y != 0.0f)
		glTranslatef((int)(-transformAnchor.x), (int)(-transformAnchor.y), vertexZ_);
}

-(float) scale
{
	if( scaleX == scaleY)
		return scaleX;
	else
		[NSException raise:@"CocosNode scale:" format:@"scaleX is different from scaleY"];
	
	return 0;
}

-(void) setScale:(float) s
{
	scaleX = scaleY = s;
}

#pragma mark CocosNode SceneManagement

-(void) onEnter
{
	for( id child in children )
		[child onEnter];
	
	[self activateTimers];

	isRunning = YES;
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
	ccArrayRemoveAllObjects(actions);
}

-(void) stopAction: (Action*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	if( actions != nil ) {
		NSUInteger i = ccArrayGetIndexOfObject(actions, action);
	
		if (i != NSNotFound) {
			ccArrayRemoveObjectAtIndex(actions, i);
	
			// update actionIndex in case we are in step_, looping over the actions
			if (actionIndex >= (int) i)
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
			Action *a = (Action *) actions->arr[i];
			
			if( a.tag == aTag ) {
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
			Action *a = (Action *) actions->arr[i];
		
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
	// Running the actions may indirectly release the CocosNode, so we're
	// retaining self to prevent deallocation.
	[self retain];
	
	// call all actions
	
	// The 'actions' ccArray may change while inside this loop.
	for( actionIndex = 0; actionIndex < (int) actions->num; actionIndex++) {
		Action *a = (Action *) actions->arr[actionIndex];

		[a retain];
		[a step: dt];
		
		if( [a isDone] ) {
			[a stop];
			[self stopAction:a];
		}
		[a release];
	}
	
	if( actions->num == 0 )
		[self unschedule: @selector(step_:)];
	
	// And releasing self when done.
	[self release];
	// If the node had a retain count of 1 before getting released, it's now
	// deallocated. However, since we don't access any ivar, we're fine.
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
	
	if( [scheduledSelectors objectForKey: NSStringFromSelector(selector) ] ) {
		CCLOG(@"CocosNode.schedule: Selector already scheduled: %@",NSStringFromSelector(selector) );
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

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = CGAffineTransformIdentity;
	
	if (parent != nil) {
		t = [parent nodeToWorldTransform];
	}
	
	if (!relativeTransformAnchor) {
		t = CGAffineTransformTranslate(t, transformAnchor.x, transformAnchor.y);
	}
	
	t = CGAffineTransformTranslate(t, position.x, position.y);
	t = CGAffineTransformRotate(t, -CC_DEGREES_TO_RADIANS(rotation));
	t = CGAffineTransformScale(t, scaleX, scaleY);
	
	t = CGAffineTransformTranslate(t, -transformAnchor.x, -transformAnchor.y);
	
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
	nodePoint.x -= transformAnchor.x;
	nodePoint.y -= transformAnchor.y;
	return nodePoint;
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint.x += transformAnchor.x;
	nodePoint.y += transformAnchor.y;
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
