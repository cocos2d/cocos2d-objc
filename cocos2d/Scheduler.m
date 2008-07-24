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


#import "Scheduler.h"


@implementation Scheduler

//
// singleton stuff
//
static Scheduler *sharedScheduler;

+ (Scheduler *)sharedScheduler
{
	@synchronized(self)
	{
		if (!sharedScheduler)
			[[Scheduler alloc] init];
		
		return sharedScheduler;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedScheduler == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedScheduler = [super alloc];
		return sharedScheduler;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{
	if( ! [super init] )
		return nil;
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) schedule: (id) receiver msg:(SEL)msg
{
}

-(void) unschedule:(id) receiver msg:(SEL)msg
{
}

-(void) tick 
{
}
@end