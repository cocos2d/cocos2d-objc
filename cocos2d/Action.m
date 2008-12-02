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


#import "Action.h"
#import "CocosNode.h"

#import "IntervalAction.h"

//
// Action Base Class
//
@implementation Action

@synthesize target;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( !(self=[super init]) )
		return nil;
	
	target = nil;
	return self;
}

-(void) dealloc
{
#if DEBUG
	NSLog(@"deallocing %@", self);
#endif
	if( target ) {
		[target release];
		target = nil;
	}
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] init];
					 	
    [copy setTarget:[self target]];
    return copy;
}

-(void) start
{
	// override me
}

-(void) stop
{
	// override me
}

-(BOOL) isDone
{
	return YES;
}

-(void) step: (ccTime) dt
{
	NSLog(@"[Action step]. override me");
}

-(void) update: (ccTime) time
{
	NSLog(@"[Action update]. override me");
}
@end

//
// RepeatForever
//
@implementation RepeatForever
+(id) actionWithAction: (IntervalAction*) action
{
	return [[[self alloc] initWithAction: action] autorelease];
}

-(id) initWithAction: (IntervalAction*) action
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction: [other copy] ];
    return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) step:(ccTime) dt
{
	[other step: dt];
	if( [other isDone] ) {
		[other start];
	}
}


-(BOOL) isDone
{
	return NO;
}

- (IntervalAction *) reverse
{
	return [RepeatForever actionWithAction:[other reverse]];
}

@end



