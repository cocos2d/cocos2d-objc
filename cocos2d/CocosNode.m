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
@synthesize position_x;
@synthesize position_y;
@synthesize color;
@synthesize opacity;
@synthesize visible;
@synthesize transform_anchor_x;
@synthesize transform_anchor_y;
@synthesize children_anchor_x;
@synthesize children_anchor_y;
@synthesize parent;

-(id) init
{
	if (![super init])
		return nil;

	is_running = FALSE;
	
	position_x = 0;
	position_y = 0;

	rotation = 0.0f;		// 0 degrees	
	scale = 1.0f;			// scale factor

	color =0xffffffff;		// rgba (0-255 each color)	
	opacity = 255;
	visible = TRUE;

	children_anchor_x = 0;
	children_anchor_y = 0;
	
	transform_anchor_x = 0;
	transform_anchor_y = 0;
	
	children = [[NSMutableArray alloc] init];

	// actions
	actionTimer = nil;
	actions = [[NSMutableArray alloc] init];
	actionsToRemove = [[NSMutableArray alloc] init];
	
	return self;
}

// add a node to the array
-(void) add: (CocosNode*) child z:(int)z
{
	NSArray *entry;
	
	NSAssert( child != nil, @"Argument must be non-nil");
	
	NSNumber *index = [NSNumber numberWithInt:z];
	entry = [NSArray arrayWithObjects: index, child, nil];
	[children addObject:entry];
	
	[child setParent: self];
	
//	[children sortUsingSelector:@selector(compare:)];
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
	@throw @"Override me";
}

-(void) transform
{
	// transformations
	if (transform_anchor_x != 0 || transform_anchor_y != 0)
		glTranslatef( position_x + transform_anchor_x, position_y + transform_anchor_y, 0);
	else if ( position_x !=0 || position_y !=0 )
		glTranslatef( position_x, position_y, 0 );
		
	if (scale != 1.0f)
		glScalef( scale, scale, 1.0f );
		
	if (rotation != 0.0f )
		glRotatef( -rotation, 0.0f, 0.0f, 1.0f );

	// restore and re-position point
	if (transform_anchor_x != 0 || transform_anchor_y != 0)
	{
		if ( transform_anchor_x == children_anchor_x && transform_anchor_y == children_anchor_y)
			glTranslatef( -transform_anchor_x, -transform_anchor_y, 0);
		else
			glTranslatef( children_anchor_x - transform_anchor_x, children_anchor_y-transform_anchor_y, 0);
	}
	if (children_anchor_x != 0 || children_anchor_y !=0 )
		glTranslatef( children_anchor_x, children_anchor_y, 0 );
}

-(void) visit
{
	if (!visible)
		return;
		
	for (id child in children)
	{
		if ( [[child objectAtIndex:0] intValue] < 0 )
			[[child objectAtIndex:1] visit];
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
	is_running = TRUE;
	
	for( id child in children )
		[[child objectAtIndex:1] onEnter];
}

-(void) onExit
{
	is_running = FALSE;
	
	for( id child in children )
		[[child objectAtIndex:1] onExit];
}

-(Action*) do: (Action*) action
{
	[action setTarget: self];
	[action start];
	
	if (! is_scheduled )
		[self schedule: @selector(_step)];
	
	[actions addObject: action];
		
	return action;
}

-(void) schedule: (SEL) method
{
	if( actionTimer)
		return;
	actionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:method userInfo:nil repeats:YES];
}

-(void) unschedule
{
	if( ! actionTimer )
		return;
	[actionTimer invalidate];
	[actionTimer release];
	actionTimer = nil;
}

-(void) _step
{
	// remove 'removed' actions
	for( id action in actionsToRemove )
		[actions removeObject: action];
	[actionsToRemove removeAllObjects];

	// unschedule if it is no longer necesary
	if ( [actions count] == 0 ) {
		[self unschedule];
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
@end
