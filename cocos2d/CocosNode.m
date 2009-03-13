/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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

@synthesize rotation, scaleX, scaleY, position, parallaxRatioX, parallaxRatioY;
@synthesize visible;
@synthesize transformAnchor, relativeTransformAnchor;
@synthesize parent, children;
@synthesize grid;
@synthesize zOrder;
@synthesize tag;

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if (!(self=[super init]) )
		return nil;
	
	isRunning = NO;
	
	position = cpvzero;
	
	rotation = 0.0f;		// 0 degrees	
	scaleX = 1.0f;			// scale factor
	scaleY = 1.0f;
	parallaxRatioX = 1.0f;
	parallaxRatioY = 1.0f;

	grid = nil;
	
	visible = YES;

	transformAnchor = cpvzero;
	
	tag = kCocosNodeTagInvalid;
	
	zOrder = 0;

	// lazy alloc
	camera = nil;

	// children (lazy allocs)
	children = nil;

	// actions (lazy allocs)
	actions = nil;
	actionsToRemove = nil;
	actionsToAdd = nil;
	
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
	[actions release];
	actions = nil;
	
	[actionsToRemove release];
	actionsToRemove = nil;
	
	[actionsToAdd release];
	actionsToAdd = nil;
	
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
	[children makeObjectsPerformSelector:@selector(cleanup)];
	[children release];
	
	// timers
	[scheduledSelectors release];
	
	// actions
	[actions release];
	[actionsToRemove release];
	[actionsToAdd release];
	
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

-(id) add: (CocosNode*) child z:(int)z tag:(int) aTag
{
	CCLOG(@"add:z:tag: is deprecated. Use addChild:z:tag:");
	return [self addChild:child z:z tag:aTag];
}
/* Add logic MUST only be on this selector
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

-(id) add: (CocosNode*) child z:(int)z parallaxRatio:(cpVect)c
{
	CCLOG(@"add:z:tag:parallaxRatio: is deprecated. Use addChild:z:parallaxRatio:");
	return [self addChild:child z:z parallaxRatio:c];
}
-(id) addChild: (CocosNode*) child z:(int)z parallaxRatio:(cpVect)c
{
	NSAssert( child != nil, @"Argument must be non-nil");
	child.parallaxRatioX = c.x;
	child.parallaxRatioY = c.y;
	return [self addChild: child z:z tag:child.tag];
}

// add a node to the array
-(id) add: (CocosNode*) child z:(int)z
{
	CCLOG(@"add:z: is deprecated. Use addChild:z:");
	return [self addChild:child z:z];
}
-(id) addChild: (CocosNode*) child z:(int)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:z tag:child.tag];
}

-(id) add: (CocosNode*) child
{
	CCLOG(@"add: is deprecated. Use addChild:");
	return [self addChild:child];
}
-(id) addChild: (CocosNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:child.zOrder tag:child.tag];
}


-(void) remove: (CocosNode*)child
{
	CCLOG(@"remove: is deprecated. Use removeChild:cleanup:");
	return [self removeChild:child cleanup:NO];
}
-(void) removeAndStop: (CocosNode*)child
{
	CCLOG(@"removeAndStop: is deprecated. Use removeChild:cleanup:");
	return [self removeChild:child cleanup:YES];
}
/* Remove logic MUST only be on this selector
 * If a class want's to extend the 'removeChild' behaviour it only needs
 * to override this selector
 */
-(void) removeChild: (CocosNode*)child cleanup:(BOOL)cleanup
{
	NSAssert( child != nil, @"Argument must be non-nil");
	
	if ( [children containsObject:child] )
		[self detachChild:child cleanup:cleanup];
}

-(void) removeByTag:(int) aTag
{
	CCLOG(@"removeByTag: is deprecated. Use removeChildByTag:cleanup:");
	return [self removeChildByTag:aTag cleanup:NO];
}
-(void) removeAndStopByTag:(int) aTag
{
	CCLOG(@"removeAndStopByTag: is deprecated. Use removeChildByTag:cleanup:");
	return [self removeChildByTag:aTag cleanup:YES];
}
-(void) removeChildByTag:(int)aTag cleanup:(BOOL)cleanup
{
	NSAssert( aTag != kCocosNodeTagInvalid, @"Invalid tag");

	CocosNode *child = [self getChildByTag:aTag];
	[self removeChild:child cleanup:cleanup];
}

-(void) removeAll

{
	CCLOG(@"removeAll is deprecated. Use removeAllChildrenWithCleanup:");
	return [self removeAllChildrenWithCleanup:NO];
}
-(void) removeAndStopAll
{
	CCLOG(@"removeAndStopAll is deprecated. Use removeAllChildrenCleanup:");
	return [self removeAllChildrenWithCleanup:YES];
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

-(CocosNode*) getByTag:(int) aTag
{
	CCLOG(@"getByTag: is deprecated. Use getChildByTag:");
	return [self getChildByTag:aTag];
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

-(cpVect) absolutePosition
{
	cpVect ret = position;
	
	CocosNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = cpvadd( ret,  cn.position );
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
}

-(void) visit
{
	if (!visible)
		return;
	
	glPushMatrix();
	
	if ( grid && grid.active)
		[grid beforeDraw];
	
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

-(void) transform
{
	if ( !(grid && grid.active) )
		[camera locate];
	
	float parallaxOffsetX = 0;
	float parallaxOffsetY = 0;
	
	// XXX: Parallax code should be moved to a ParallaxNode node
	if( (parallaxRatioX != 1.0f || parallaxRatioY != 1.0) && parent ) {
		parallaxOffsetX = -parent.position.x + parent.position.x * parallaxRatioX;
		parallaxOffsetY = -parent.position.y + parent.position.y * parallaxRatioY;		
	}
	
	// transformations
	
	// transalte
	if ( relativeTransformAnchor && (transformAnchor.x != 0 || transformAnchor.y != 0 ) )
		glTranslatef( -transformAnchor.x + parallaxOffsetX, -transformAnchor.y + parallaxOffsetY, 0);
	
	if (transformAnchor.x != 0 || transformAnchor.y != 0 )
		glTranslatef( position.x + transformAnchor.x + parallaxOffsetX, position.y + transformAnchor.y + parallaxOffsetY, 0);
	else if ( position.x !=0 || position.y !=0 || parallaxOffsetX != 0 || parallaxOffsetY != 0)
		glTranslatef( position.x + parallaxOffsetX, position.y + parallaxOffsetY, 0 );
	
	// rotate
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
	
	// scale
	if (scaleX != 1.0f || scaleY != 1.0f)
		glScalef( scaleX, scaleY, 1.0f );
	
	// restore and re-position point
	if (transformAnchor.x != 0.0f || transformAnchor.y != 0.0f)
		glTranslatef(-transformAnchor.x + parallaxOffsetX, -transformAnchor.y + parallaxOffsetY, 0);
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

-(float) parallaxRatio
{
	if( parallaxRatioX == parallaxRatioY)
		return parallaxRatioX;
	else
		[NSException raise:@"CocosNode parallaxRatio:" format:@"parallaxRatioX is different from parallaxRatioY"];
	
	return 0;
}

-(void) setParallaxRatio:(float) p
{
	parallaxRatioX = parallaxRatioY = p;
}


#pragma mark CocosNode SceneManagement

-(void) onEnter
{
	isRunning = YES;
	
	
	for( id child in children )
		[child onEnter];
	
	[self activateTimers];
}

-(void) onExit
{
	isRunning = NO;
	
	[self deactivateTimers];
	
	for( id child in children )
		[child onExit];
	
}

#pragma mark CocosNode Actions

-(void) actionAlloc
{
	// Reason for having actionsToAdd & actionsToRemove:
	// While iterating through the actions array it's possible that one of the
	// actions will call do or stopAction on current node. If these methods were
	// to alter the array directly (remember you're still inside the loop), you'd
	// get undefined behaviour. So instead these 2 arrays are used as buffers.
	//
	// Another solution would be to make a copy of actions on each step_ and
	// iterate over the copy, but that leads to other complications (you need to
	// manage a fast buffer in which to save the copy, and you need to accomodate
	// the possibility of actions accidentally releasing themselves, which leads
	// to retain/release hell and, ultimately, a slow loop).
	
	// actions
	actions = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToRemove = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToAdd = [[NSMutableArray arrayWithCapacity:4] retain];
}

-(Action*) do: (Action*) action
{
	CCLOG(@"do: is deprecated. Use runAction: instead");
	return [self runAction:action];
}
-(Action*) runAction:(Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
	
#ifdef DEBUG
	if ( [actions containsObject:action] || [actionsToAdd containsObject:action] ) {
		CCLOG(@"WARNING: action already scheduled.");
	}
#endif
	
	action.target = self;
	[action start];
	
	// lazy alloc
	if( !actionsToAdd )
		[self actionAlloc];
	
	[actionsToAdd addObject: action];
	[self schedule: @selector(step_:)];
	
	return action;
}

-(void) stopAllActions
{
	[actionsToAdd removeAllObjects];

	[actionsToRemove removeAllObjects];
	[actionsToRemove addObjectsFromArray:actions];
}

-(void) stopAction: (Action*) action
{
	if( [actions containsObject:action] )
		[actionsToRemove addObject:action];

	else if( [actionsToAdd containsObject:action] )
		[actionsToAdd removeObject:action];
	else
		CCLOG(@"stopAction: action not found!");
}

-(void) stopActionByTag:(int) aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	
	// is running ?
	for( Action *a in actions ) {
		if( a.tag == aTag ) {
			[actionsToRemove addObject:a];
			return; 
		}
	}
	// is going to be added ?
	for( Action *a in actionsToAdd ) {
		if( a.tag == aTag ) {
			[actionsToAdd removeObject:a];
			return;
		}
	}
	CCLOG(@"stopActionByTag: action not found!");
}

-(Action*) getActionByTag:(int) aTag
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	
	// is running ?
	for( Action *a in actions ) {
		if( a.tag == aTag )
			return a;
	}

	// is going to be added ?
	for( Action *a in actionsToAdd ) {
		if( a.tag == aTag )
			return a;
	}

	CCLOG(@"getActionByTag: action not found");
	return nil;
}

-(int) numberOfRunningActions
{
	return [actionsToAdd count]+[actions count];
}

-(void) step_: (ccTime) dt
{
	// remove 'removed' actions
	for( Action* action in actionsToRemove )
		[actions removeObject: action];
	[actionsToRemove removeAllObjects];
	
	// add actions that needs to be added
	for( Action* action in actionsToAdd )
		[actions addObject: action];
	[actionsToAdd removeAllObjects];
	
	// Unschedule if it is no longer necessary. Note that if step_ is still
	// scheduled onExit (this happens if the node has actions when it's
	// removed/removedAndStopped from its parent), it will get descheduled there.
	if ( [actions count] == 0 ) {
		[self unschedule: @selector(step_:)];
		return;
	}
 	
	// Assume the instructions inside [action step: dt] end up calling cleanup on
	// the current node. This could happen, for example, if the action is a CallFunc
	// which tells the current node's parent to removeAndStop our node.
	//
	// Cleanup releases and nullifies the actions array. As a result all the actions
	// inside the array get released, including the currently executing one. If
	// the action had a retain count of 1, it has now deallocated itself!
	// 
	// To prevent such accidental deallocs, we could:
	// a. Retain each action inside the loop before calling step, release it after step.
	// b. Retain actions array before loop, release it after loop. Only 1 retain,
	//    slightly better performance when there are many actions. Need to keep original
	//    value because actions might get nullified and you don't want [nil release].
	
	id actionsBackup = [actions retain];
	
	// call all actions
	for( Action *action in actions ) {
		[action step: dt];
		
		// Note: There's no danger of our node being deallocated inside the loop (because
		// the current action has retained it) so it's safe to access the actions ivar.
		if (actions == nil)
			break;
		
		if( [action isDone] ) {
			[action stop];
			[actionsToRemove addObject: action];
		}
	}
	
	[actionsBackup release];
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
	NSAssert( selector != nil, @"Argument must be non-nil");
	
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
@end
