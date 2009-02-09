/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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
@end

@implementation CocosNode

@synthesize rotation, scaleX, scaleY, position, parallaxRatioX, parallaxRatioY;
@synthesize visible;
@synthesize transformAnchor, relativeTransformAnchor;
@synthesize parent, children;
@synthesize camera;
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

	camera = [[Camera alloc] init];
	grid = nil;
	
	visible = YES;

	transformAnchor = cpvzero;
	
	tag = kCocosNodeTagInvalid;
	
	zOrder = 0;

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
	
	[scheduledSelectors release];
	scheduledSelectors = nil;
}


- (void) dealloc
{
	CCLOG( @"deallocing %@", self);
	
	// attributes
	[camera release];

// XXX: Ask Ernesto if this is needed
//	if ( grid ) grid = nil;
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

-(id) add: (CocosNode*) child z:(int)z tag:(int) aTag
{	
	NSAssert( child != nil, @"Argument must be non-nil");
	
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
	NSAssert( child != nil, @"Argument must be non-nil");
	child.parallaxRatioX = c.x;
	child.parallaxRatioY = c.y;
	return [self add: child z:z tag:child.tag];
}

// add a node to the array
-(id) add: (CocosNode*) child z:(int)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self add: child z:z tag:child.tag];
}

-(id) add: (CocosNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self add: child z:child.zOrder tag:child.tag];
}

-(void) remove: (CocosNode*)child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	
	for( CocosNode * c in children) {
		if( [c isEqual: child] ) {
			[c setParent: nil];
			if( isRunning )
				[c onExit];

			[children removeObject: c];			
			break;
		}
	}
}

-(void) removeByTag:(int) aTag
{
	NSAssert( aTag != kCocosNodeTagInvalid, @"Invalid tag");

	CocosNode *toRemove = nil;
	for( CocosNode *node in children ) {
		if( node.tag == aTag ) {
			toRemove = node;
			break;
		}
	}
	if( toRemove )
		[self remove:toRemove];

}

-(void) removeAll {
	for( CocosNode * c in children) {
		[c setParent: nil];
		if( isRunning )
			[c onExit];
	}

	[children removeAllObjects];
}

-(void) removeAndStop: (CocosNode*)child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	
	for( CocosNode * c in children) {
		if( [c isEqual: child] ) {
			[c setParent: nil];

			if( isRunning )
				[c onExit];

			[c stopAllActions];
			[c cleanup];
			[children removeObject: c];

			break;
		}
	}
}

-(void) removeAndStopByTag:(int) aTag
{
	NSAssert( aTag != kCocosNodeTagInvalid, @"Invalid tag");
	
	CocosNode *toRemove = nil;
	for( CocosNode *node in children ) {
		if( node.tag == aTag ) {
			toRemove = node;
			break;
		}
	}
	if( toRemove )
		[self removeAndStop:toRemove];
	
}

-(void) removeAndStopAll {
	for( CocosNode * c in children) {
		[c setParent: nil];
		if( isRunning )
			[c onExit];
	}
	
	[children makeObjectsPerformSelector:@selector(cleanup)]; // issue #74
	
	[children removeAllObjects];
}

-(CocosNode*) getByTag:(int) aTag
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

	if( (parallaxRatioX != 1.0f || parallaxRatioY != 1.0) && parent ) {
		parallaxOffsetX = -parent.position.x + parent.position.x * parallaxRatioX;
		parallaxOffsetY = -parent.position.y + parent.position.y * parallaxRatioY;		
	}
	
	// transformations
	if ( relativeTransformAnchor && (transformAnchor.x != 0 || transformAnchor.y != 0 ) )
		glTranslatef( -transformAnchor.x + parallaxOffsetX, -transformAnchor.y + parallaxOffsetY, 0);
	
	if (transformAnchor.x != 0 || transformAnchor.y != 0 )
		glTranslatef( position.x + transformAnchor.x + parallaxOffsetX, position.y + transformAnchor.y + parallaxOffsetY, 0);
	else if ( position.x !=0 || position.y !=0 || parallaxOffsetX != 0 || parallaxOffsetY != 0)
		glTranslatef( position.x + parallaxOffsetX, position.y + parallaxOffsetY, 0 );
	
	if (scaleX != 1.0f || scaleY != 1.0f)
		glScalef( scaleX, scaleY, 1.0f );
	
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
	
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
	// actions
	actions = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToRemove = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToAdd = [[NSMutableArray arrayWithCapacity:4] retain];
}

-(Action*) do: (Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");

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
	
	for( Action* action in actions) {
		// prevents double release
		if( ! [actionsToRemove containsObject: action] )
			[actionsToRemove addObject: action];
	}
}

-(void) stopAction: (Action*) action
{
	if( [actionsToRemove containsObject:action] ) {
		// do nothing
	} else if( [actionsToAdd containsObject:action] ) {
		[actionsToAdd removeObject:action];
	} else if( [actions containsObject:action] ) {
		[actionsToRemove addObject:action];
	}
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
		
	// unschedule if it is no longer necessary
	if ( [actions count] == 0 ) {
		[self unschedule: @selector(step_:)];
		return;
	}
	
	// call all actions
	for( Action *action in actions ) {
        [[action retain] step: dt];
        if(actions == nil) {
            [action release];
            return;
        }
        
		if( [action isDone] ) {
			[action stop];
			[actionsToRemove addObject: action];
		}
        
        [action release];
	}
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
