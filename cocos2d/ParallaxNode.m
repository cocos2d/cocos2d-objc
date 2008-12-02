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

#import "ParallaxNode.h"

@interface VectAndNode: NSObject
{
	cpVect vect;
	CocosNode *node;
}
@property (readwrite,assign) cpVect vect;
@property (readwrite,retain) CocosNode* node;
@end

@implementation VectAndNode
@synthesize vect, node;
@end




@implementation ParallaxNode

-(id) init
{
	self = [super init];
	if( self ) {
		parallaxChildren = [[NSMutableArray arrayWithCapacity:5] retain];
	}

	return self;
}

-(void) dealloc
{
	[parallaxChildren release];
	[super dealloc];
}

// XXX: shall I update this on draw or on 'update' (scheduled selector) ?
// XXX: It seems that I can do this on draw.
-(void) draw
{
	for( VectAndNode *child in parallaxChildren ) {
		cpVect v2 = child.vect;
		cpVect v = position;
		v.x = v.x * v2.x;
		v.y = v.y * v2.y;
		child.node.position = v;		
	}
}

-(id) add: (CocosNode*)node z:(int)z tag:(int)t parallaxRatio:(cpVect)p
{
	[self add:node z:z tag:t];
	VectAndNode *vect = [VectAndNode new];
	vect.vect = p;
	vect.node = node;
	[parallaxChildren addObject:vect];
	
	return self;
}

-(id) add: (CocosNode*)node z:(int)z parallaxRatio:(cpVect)p
{
	return [self add:node z:z tag:kCocosNodeTagInvalid parallaxRatio:p];
}

-(void) removeByTag: (int) t
{
	[NSException raise:@"ParallaxNode: removeByTag Not supported yet" format:@"ParallaxNode removeByTag"];
}

-(void) remove:(CocosNode*) child
{
	[NSException raise:@"ParallaxNode: remove Not supported yet" format:@"ParallaxNode remove"];
}

@end
