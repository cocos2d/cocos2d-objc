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

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextureMgr.h"
#import "Sprite.h"

@implementation Sprite

@synthesize texture;

+ (id) spriteFromFile: (NSString*) filename
{
	return [[[self alloc] initFromFile:filename] autorelease];
}

- (id) initFromFile: (NSString*) filename
{
	if (![super init])
		return nil;

	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
	texture = [[[TextureMgr sharedTextureMgr] addImage: filename] retain];
	
	return self;
}

-(void) dealloc
{
	[texture release];
	[animations release];
	[super dealloc];
}

- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	[texture drawAtPoint: CGPointZero];

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

-(void) addAnimation: (Animation*) anim
{
	[animations setObject:anim forKey:[anim name]];
}
@end

@implementation Animation
@synthesize name, delay, frames;

+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,...
{
	va_list args;
	va_start(args,image1);
	
	id s = [[[self alloc] initWithName:name delay:delay vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName: (NSString*) name delay:(float)d vaList: (va_list) args
{
	if( ![super init] )
		return nil;
	
	frames = [[NSMutableArray array] retain];
	delay = d;
		
	NSString *filename = va_arg(args, NSString*);
	while(filename) {
		Texture2D *texture = [[TextureMgr sharedTextureMgr] addImage: filename];
		[frames addObject:texture];
		
		 filename = va_arg(args, NSString*);
	}	
	return self;
}

-(void) dealloc
{
	[frames release];
	[super dealloc];
}
@end

