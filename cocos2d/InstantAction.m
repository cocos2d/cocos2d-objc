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


#import "InstantAction.h"
#import "CocosNode.h"

//
// InstantAction
//
@implementation InstantAction
@synthesize duration;

-(id) init
{
	if( ![super init] )
		return nil;
	
	duration = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] init];
	return copy;
}

- (BOOL) isDone
{
	return YES;
}
-(void) step: (ccTime) dt
{
	[self update: 1];
}
-(void) update: (ccTime) t
{
	// ignore
}
@end

//
// Show
//
@implementation Show
-(void) start
{
	[super start];
	target.visible = YES;
}
@end

//
// Hide
//
@implementation Hide
-(void) start
{
	[super start];
	target.visible = NO;
}
@end

//
// ToggleVisibility
//
@implementation ToggleVisibility
-(void) start
{
	[super start];
	target.visible = ! target.visible;
}
@end

//
// Place
//
@implementation Place
+(id) actionWithPosition: (cpVect) pos
{
	return [[[self alloc]initWithPosition:pos]autorelease];
}

-(id) initWithPosition: (cpVect) pos
{
	if( ! [super init] )
		return nil;
	position = pos;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithPosition: position];
	return copy;
}

-(void) start
{
	[super start];
	target.position = position;
}
@end

//
// CallFunc
//
@implementation CallFunc
+(id) actionWithTarget: (id) t selector:(SEL) s
{
	return [[[self alloc] initWithTarget: t selector: s] autorelease];
}

-(id) initWithTarget: (id) t selector:(SEL) s
{
	if( ! [super init] )
		return nil;
	
	targetCallback = t;
	selector = s;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector];
	return copy;
}


-(void) start
{
	[super start];
	[self execute];
}

-(void) execute
{
	[targetCallback performSelector:selector];
}
@end

//
// CallFuncN
//
@implementation CallFuncN

-(void) execute
{
	[targetCallback performSelector:selector withObject:target];
}
@end
