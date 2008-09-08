/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import "CocosNode.h"
#import "Camera.h"
#import "Scheduler.h"


@interface CocosNode (Private)
-(void) step_: (ccTime) dt;
// activate all scheduled timers
-(void) activateTimers;
// deactivate all scheduled timers
-(void) deactivateTimers;
@end

@implementation CocosNode

@synthesize rotation, scale, position;
@synthesize visible;
@synthesize transformAnchor, relativeTransformAnchor;
#if USING_CHILDREN_ANCHOR
	@synthesize childrenAnchor;
#endif
@synthesize parent;
@synthesize camera;
@synthesize zOrder;

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if (![super init])
		return nil;

	isRunning = NO;
	
	position = cpvzero;
	
	rotation = 0.0f;		// 0 degrees	
	scale = 1.0f;			// scale factor

	camera = [[Camera alloc] init];
	
	visible = YES;

#if USING_CHILDREN_ANCHOR
	childrenAnchor = cpvzero;
#endif
	transformAnchor = cpvzero;
	
	// children
	children = [[NSMutableArray arrayWithCapacity:4] retain];
	childrenNames = [[NSMutableDictionary dictionaryWithCapacity:4] retain];

	// actions
	actions = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToRemove = [[NSMutableArray arrayWithCapacity:4] retain];
	actionsToAdd = [[NSMutableArray arrayWithCapacity:4] retain];
	
	// scheduled selectors
	scheduledSelectors = [[NSMutableDictionary dictionaryWithCapacity: 2] retain];
	
	// default.
	// "whole screen" objects should set it to NO, like Scenes and Layers
	relativeTransformAnchor = YES;
	
	return self;
}

- (void) dealloc
{
#if DEBUG
	NSLog( @"deallocing %@", self);
#endif
	
	// attributes
	[camera release];
	
	// children
	[children release];
	[childrenNames release];
	
	// timers
	[scheduledSelectors release];
	
	// actions
	[actions release];
	[actionsToRemove release];
	[actionsToAdd release];
	
	[super dealloc];
}
@end


@implementation CocosNode (Composition)

-(id) add: (CocosNode*) child z:(int)z name:(NSString*)name
{	
	NSAssert( child != nil, @"Argument must be non-nil");
	
	child.zOrder=z;
	
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
	
	if( name )
		[childrenNames setObject:child forKey:name];
	
	[child setParent: self];
	
	if( isRunning )
		[child onEnter];
	return self;
}

// add a node to the array
-(id) add: (CocosNode*) child z:(int)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self add: child z:z name:nil];
}

-(id) add: (CocosNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self add: child z:0 name:nil];
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

-(void) removeByName: (NSString*) name
{
	NSAssert( name != nil, @"Argument must be non-nil");
	
	id child = [childrenNames objectForKey: name];
	[self remove: child];
	[childrenNames removeObjectForKey: name];
}

-(void) removeAll {
	for( CocosNode * c in children) {
		[c setParent: nil];
		if( isRunning )
			[c onExit];
	}	
	[children removeAllObjects];
	[childrenNames removeAllObjects];
}

-(CocosNode*) get: (NSString*) name
{
	NSAssert( name != nil, @"Argument must be non-nil");
	return [childrenNames objectForKey:name];
}
@end


@implementation CocosNode (Draw)

-(void) draw
{
	// override me
}

-(void) transform
{
	
	[camera locate];
	
	// transformations
	if ( relativeTransformAnchor && (transformAnchor.x != 0 || transformAnchor.y != 0 ) )
		glTranslatef( -transformAnchor.x, -transformAnchor.y, 0);
	
	if (transformAnchor.x != 0 || transformAnchor.y != 0 )
		glTranslatef( position.x + transformAnchor.x, position.y + transformAnchor.y, 0);
	else if ( position.x !=0 || position.y !=0 )
		glTranslatef( position.x, position.y, 0 );
		
	if (scale != 1.0f)
		glScalef( scale, scale, 1.0f );
		
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );

	// restore and re-position point
	if (transformAnchor.x != 0.0f || transformAnchor.y != 0.0f)
#if USING_CHILDREN_ANCHOR
	{
		if ( !( transformAnchor.x == childrenAnchor.x && transformAnchor.y == childrenAnchor.y) )
			glTranslatef( childrenAnchor.x - transformAnchor.x, childrenAnchor.y - transformAnchor.y, 0);
	}
	else if (childrenAnchor.x != 0 || childrenAnchor.y !=0 )
		glTranslatef( childrenAnchor.x, childrenAnchor.y, 0 );
#else
		glTranslatef(-transformAnchor.x, -transformAnchor.y, 0);
#endif
}

-(void) visit
{
	if (!visible)
		return;

	glPushMatrix();
	
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
	
	glPopMatrix();

}
@end


@implementation CocosNode (SceneManagement)

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
@end


@implementation CocosNode (Actions)

-(Action*) do: (Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");

	action.target = self;
	[action start];

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
	} else if( [actions containsObject:actions] ) {
		[actionsToRemove addObject:action];
	}
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
		
	// unschedule if it is no longer necesary
	if ( [actions count] == 0 ) {
		[self unschedule: @selector(step_:)];
		return;
	}
	
	// call all actions
	for( Action *action in actions ) {
		[action step: dt];
		if( [action isDone] ) {
			[action stop];
			[actionsToRemove addObject: action];
		}
	}
}
@end

@implementation CocosNode (Timers)

-(void) schedule: (SEL) selector
{
	[self schedule:selector interval:0];
}

-(void) schedule: (SEL) selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	if( [scheduledSelectors objectForKey: NSStringFromSelector(selector) ] ) {
#ifdef DEBUG
		NSLog(@"CocosNode.schedule: Selector already scheduled");
#endif
		return;
	}

	Timer *timer = [Timer timerWithTarget:self selector:selector interval:interval];

	if( isRunning )
		[[Scheduler sharedScheduler] scheduleTimer:timer];
	
	[scheduledSelectors setObject: timer forKey: NSStringFromSelector(selector) ];
}

-(void) unschedule: (SEL) selector
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	
	Timer *timer = nil;
	
	if( ! (timer = [scheduledSelectors objectForKey: NSStringFromSelector(selector)] ) )
	{
		NSLog(@"selector not scheduled");
		NSException* myException = [NSException
									exceptionWithName:@"SelectorNotScheduled"
									reason:@"Selector not scheduled"
									userInfo:nil];
		@throw myException;
	}

	[scheduledSelectors removeObjectForKey: NSStringFromSelector(selector) ];
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
