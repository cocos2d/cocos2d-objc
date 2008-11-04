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

+ (id) spriteWithFile: (NSString*) filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

+ (id) spriteWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	return [[[self alloc] initWithPVRTCFile:fileimage bpp:bpp hasAlpha:alpha width:w] autorelease];
}

- (id) initWithFile: (NSString*) filename
{
	if( ! (self=[super init]) )
		return nil;

	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];

	texture = [[[TextureMgr sharedTextureMgr] addImage: filename] retain];
	
	CGSize s = texture.contentSize;
	transformAnchor = cpv( s.width/2, s.height/2);
	
	return self;
}

- (id) initWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	if( ! (self=[super init]) )
		return nil;
	
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
	
	texture = [[[TextureMgr sharedTextureMgr] addPVRTCImage:fileimage bpp:bpp hasAlpha:alpha width:w] retain];
	
	CGSize s = texture.contentSize;
	transformAnchor = cpv( s.width/2, s.height/2);
	
	return self;
}

-(void) dealloc
{
	[texture release];
	[animations release];
	[super dealloc];
}

-(void) addAnimation: (Animation*) anim
{
	[animations setObject:anim forKey:[anim name]];
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	Animation *a = [animations objectForKey: animationName];
	Texture2D *tex = [[a frames] objectAtIndex:frameIndex];
	if( tex == texture )
		return;
	[texture release];
	texture = [tex retain];
}
@end

@implementation Animation
@synthesize name, delay, frames;

+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,...
{
	va_list args;
	va_start(args,image1);
	
	id s = [[[self alloc] initWithName:name delay:delay firstImage:image1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName: (NSString*) n delay:(float)d firstImage:(NSString*)image vaList: (va_list) args
{
	if( ! (self=[super init]) )
		return nil;
	
	name = [n retain];
	frames = [[NSMutableArray array] retain];
	delay = d;

	if( image ) {
		Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: image];
		[frames addObject:tex];

		NSString *filename = va_arg(args, NSString*);
		while(filename) {
			tex = [[TextureMgr sharedTextureMgr] addImage: filename];
			[frames addObject:tex];
		
			filename = va_arg(args, NSString*);
		}	
	}
	return self;
}

-(id) initWithName: (NSString*) n delay:(float)d
{
	return [self initWithName:n delay:d firstImage:nil vaList:nil];
}

-(void) dealloc
{
	[frames release];
	[super dealloc];
}

-(void) addFrame: (NSString*) filename
{
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: filename];
	[frames addObject:tex];
}
@end

