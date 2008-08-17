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

@implementation CocosNode

@synthesize rotation, scale, position;
@synthesize visible;
@synthesize transformAnchor, relativeTransformAnchor;
#if USING_CHILDREN_ANCHOR
	@synthesize childrenAnchor;
#endif
@synthesize parent;
@synthesize camera;

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
	children = [[NSMutableArray arrayWithCapacity:10] retain];
	childrenNames = [[NSMutableDictionary dictionaryWithCapacity:5] retain];

	// actions
	actions = [[NSMutableArray arrayWithCapacity:10] retain];
	actionsToRemove = [[NSMutableArray arrayWithCapacity:10] retain];
	actionsToAdd = [[NSMutableArray arrayWithCapacity:10] retain];
	
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

-(id) add: (CocosNode*) child z:(int)z name:(NSString*)name
{
	NSArray *entry;
	
	NSAssert( child != nil, @"Argument must be non-nil");
	
	NSNumber *index = [NSNumber numberWithInt:z];
	entry = [NSArray arrayWithObjects: index, child, nil];
	
	int idx=0;
	BOOL added = NO;
	for( NSArray *a in children ) {
		if ( [[a objectAtIndex: 0] intValue] > z ) {
			added = YES;
			[ children insertObject:entry atIndex:idx];
			break;
		}
		idx++;
	}
	if( ! added )
		[children addObject:entry];
	
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
	
	for( id entry in children) {
		CocosNode *c;
		c = [entry objectAtIndex:1];
		if( [c isEqual: child] ) {
			[c setParent: nil];
			if( isRunning )
				[c onExit];
			
			[children removeObject: entry];
			
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

-(CocosNode*) get: (NSString*) name
{
	NSAssert( name != nil, @"Argument must be non-nil");
	return [childrenNames objectForKey:name];
}

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
	for (id child in children)
	{
		if ( [[child objectAtIndex:0] intValue] < 0 )
			[[child objectAtIndex:1] visit];
		else
			break;
	}	

	[self transform];
	[self draw];

	for (id child in children)
	{		
		if ( [[child objectAtIndex:0] intValue] >= 0 )
			[[child objectAtIndex:1] visit];
	}
	glPopMatrix();

}

-(void) onEnter
{
	isRunning = YES;
	
	
	for( id child in children )
		[[child objectAtIndex:1] onEnter];
	
	[self activateTimers];
}

-(void) onExit
{
	isRunning = NO;

	[self deactivateTimers];
	
	for( id child in children )
		[[child objectAtIndex:1] onExit];
	
}

-(Action*) do: (Action*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");

	action.target = self;
	[action start];

	[actionsToAdd addObject: action];
	[self schedule: @selector(step_:)];
		
	return action;
}

-(void) stop
{
	[actionsToAdd removeAllObjects];
	
	for( Action* action in actions)
		[actionsToRemove addObject: action];
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
