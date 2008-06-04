//
//  CocosNode.m
//  test-opengl2
//
//  Created by Ricardo Quesada on 29/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//



#import "CocosNode.h"


@implementation CocosNode

@synthesize rotation;
@synthesize scale;
@synthesize position;
@synthesize visible;
@synthesize transformAnchor;
@synthesize childrenAnchor;
@synthesize parent;

-(id) init
{
	if (![super init])
		return nil;

	isRunning = NO;
	
	position = CGPointZero;
	
	rotation = 0.0f;		// 0 degrees	
	scale = 1.0f;			// scale factor

	visible = YES;

	childrenAnchor = CGPointZero;
	transformAnchor = CGPointZero;
	
	children = [[NSMutableArray alloc] init];

	// actions
	actions = [[NSMutableArray alloc] init];
	actionsToRemove = [[NSMutableArray alloc] init];
	
	// scheduled selectors
	scheduledSelectors = [[NSMutableDictionary dictionaryWithCapacity: 2] retain];
	
	return self;
}

// add a node to the array
-(void) add: (CocosNode*) child z:(int)z
{
	NSArray *entry;
	
	NSAssert( child != nil, @"Argument must be non-nil");
	
	NSNumber *index = [NSNumber numberWithInt:z];
	entry = [NSArray arrayWithObjects: index, child, nil];

	int idx=0;
	BOOL added = NO;
	for( NSArray *a in children ) {
		if ( [[a objectAtIndex: 0] intValue] >= z ) {
			added = YES;
			[ children insertObject:entry atIndex:idx];
			break;
		}
		idx++;
	}
	if( ! added )
		[children addObject:entry];
	
	[child setParent: self];
}

-(void) add: (CocosNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self add: child z:0];
}

-(void) remove: (CocosNode*)child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	
	for( id entry in children)
	{
		if( [ [entry objectAtIndex:1] isEqual: child] )
		{
			[[entry objectAtIndex:1] setParent: nil];
			[children removeObject: entry];
			break;
		}
	}
}

-(void) draw
{
	NSException* myException = [NSException
								exceptionWithName:@"DrawNotImplemented"
								reason:@"CocosNode draw selector shall be overriden"
								userInfo:nil];
	@throw myException;
	
}

-(void) transform
{
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
		if ( transformAnchor.x == childrenAnchor.x && transformAnchor.y == childrenAnchor.y)
			glTranslatef( -transformAnchor.x, -transformAnchor.y, 0);
		else
			glTranslatef( childrenAnchor.x - transformAnchor.x, childrenAnchor.y - transformAnchor.y, 0);
	}
	else if (childrenAnchor.x != 0 || childrenAnchor.y !=0 )
		glTranslatef( childrenAnchor.x, childrenAnchor.y, 0 );
}

-(void) visit
{
	if (!visible)
		return;

	for (id child in children)
	{
		if ( [[child objectAtIndex:0] intValue] < 0 )
			[[child objectAtIndex:1] visit];
		else
			break;
	}	

	glPushMatrix();
	[self transform];		
	[self draw];
	glPopMatrix();

	for (id child in children)
	{		
		if ( [[child objectAtIndex:0] intValue] >= 0 )
			[[child objectAtIndex:1] visit];
	}
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

	[action setTarget: self];
	[action start];
	
	[self schedule: @selector(_step)];
	[actions addObject: action];
		
	return action;
}

-(void) _step
{
	// remove 'removed' actions
	if( [actionsToRemove count] > 0 ) {
		for( Action* action in actionsToRemove )
			[actions removeObject: action];
		[actionsToRemove removeAllObjects];
	}
		
	// unschedule if it is no longer necesary
	if ( [actions count] == 0 ) {
		[self unschedule: @selector(_step)];
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
	
	if( [scheduledSelectors valueForKey: NSStringFromSelector(method) ] ) {
		NSLog(@"Selector already scheduled");
		return;
	}
	[self activateTimer: method];	
}

- (void) activateTimer: (SEL) method
{
	if( isRunning ) {
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:method userInfo:nil repeats:YES];
		[scheduledSelectors setValue: timer forKey: NSStringFromSelector(method) ];
	} else
		[scheduledSelectors setValue: [NSNull null] forKey: NSStringFromSelector(method) ];
}

-(void) unschedule: (SEL) method
{
	NSAssert( method != nil, @"Argument must be non-nil");
	
	NSTimer *timer = nil;
	
	if( ! (timer = [scheduledSelectors valueForKey: NSStringFromSelector(method)] ) )
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
		NSTimer *timer =[ scheduledSelectors valueForKey: key];
		[timer invalidate];
		[timer release];
		timer = nil;
		[scheduledSelectors setValue: [NSNull null] forKey: key];
	}	
}

@end
