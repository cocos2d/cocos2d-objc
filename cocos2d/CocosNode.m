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

@implementation CocosNode

@synthesize rotation;
@synthesize scale;
@synthesize position;
@synthesize visible;
@synthesize transformAnchor;
@synthesize childrenAnchor;
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

	childrenAnchor = cpvzero;
	transformAnchor = cpvzero;
	
	// children
	children = [[NSMutableArray alloc] init];
	childrenNames = [[NSMutableDictionary alloc] init];

	// actions
	actions = [[NSMutableArray alloc] init];
	actionsToRemove = [[NSMutableArray alloc] init];
	
	// scheduled selectors
	scheduledSelectors = [[NSMutableDictionary dictionaryWithCapacity: 2] retain];
	
	return self;
}
- (void) dealloc
{
	NSLog( @"deallocing %@", self);
	
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
	if (transformAnchor.x != 0 || transformAnchor.y != 0 )
		glTranslatef( position.x + transformAnchor.x, position.y + transformAnchor.y, 0);
	else if ( position.x !=0 || position.y !=0 )
		glTranslatef( position.x, position.y, 0 );
		
	if (scale != 1.0f)
		glScalef( scale, scale, 1.0f );
		
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );

	// restore and re-position point
	if (transformAnchor.x != 0 || transformAnchor.y != 0)	{
		if ( !( transformAnchor.x == childrenAnchor.x && transformAnchor.y == childrenAnchor.y) )
			glTranslatef( childrenAnchor.x - transformAnchor.x, childrenAnchor.y - transformAnchor.y, 0);
	}
	else if (childrenAnchor.x != 0 || childrenAnchor.y !=0 )
		glTranslatef( childrenAnchor.x, childrenAnchor.y, 0 );
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

	Action *copy = [[action copy] autorelease];
	
	copy.target = self;
	[copy start];
	
	[self schedule: @selector(step_)];
	[actions addObject: copy];
		
	return action;
}

-(void) stop
{
	for( Action* action in actions)
		[actionsToRemove addObject: action];
}

-(void) step_
{
	// remove 'removed' actions
	if( [actionsToRemove count] > 0 ) {
		for( Action* action in actionsToRemove )
			[actions removeObject: action];
		[actionsToRemove removeAllObjects];
	}
		
	// unschedule if it is no longer necesary
	if ( [actions count] == 0 ) {
		[self unschedule: @selector(step_)];
		return;
	}
	
	// call all actions
	for( Action *action in actions ) {
		[action step];
		if( [action isDone] ) {
			[action stop];
			[actionsToRemove addObject: action];
		}
	}
}

-(void) schedule: (SEL) method
{
	NSAssert( method != nil, @"Argument must be non-nil");
	
	if( [scheduledSelectors objectForKey: NSStringFromSelector(method) ] ) {
		NSLog(@"Selector already scheduled");
		return;
	}
	[self activateTimer: method];	
}

- (void) activateTimer: (SEL) method
{
	if( isRunning ) {
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:method userInfo:nil repeats:YES];
		[scheduledSelectors setObject: timer forKey: NSStringFromSelector(method) ];
	} else
		[scheduledSelectors setObject: [NSNull null] forKey: NSStringFromSelector(method) ];
}

-(void) unschedule: (SEL) method
{
	NSAssert( method != nil, @"Argument must be non-nil");
	
	NSTimer *timer = nil;
	
	if( ! (timer = [scheduledSelectors objectForKey: NSStringFromSelector(method)] ) )
	{
		NSLog(@"selector not scheduled");
		NSException* myException = [NSException
									exceptionWithName:@"SelectorNotScheduled"
									reason:@"Selector not scheduled"
									userInfo:nil];
		@throw myException;
	}

	[scheduledSelectors removeObjectForKey: NSStringFromSelector(method) ];
	[timer invalidate];
	timer = nil;
}

- (void) activateTimers
{
	NSArray *keys = [scheduledSelectors allKeys];
	for( NSString *key in keys ) {
		SEL sel = NSSelectorFromString( key );
		[self activateTimer: sel];
	}
}

- (void) deactivateTimers
{
	NSArray *keys = [scheduledSelectors allKeys];
	for( NSString *key in keys ) {
		NSTimer *timer =[ scheduledSelectors objectForKey: key];
		[timer invalidate];
		timer = nil;
		[scheduledSelectors setObject: [NSNull null] forKey: key];
	}	
}

@end
