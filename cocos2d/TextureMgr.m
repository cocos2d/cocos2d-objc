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

#import "Texture2D.h"
#import "TextureMgr.h"

@implementation TextureMgr
//
// singleton stuff
//
static TextureMgr *sharedTextureMgr;

+ (TextureMgr *)sharedTextureMgr
{
	@synchronized(self)
	{
		if (!sharedTextureMgr)
			[[TextureMgr alloc] init];
		
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedTextureMgr == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedTextureMgr = [super alloc];
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	textures = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	return self;
}

-(void) dealloc
{
	[textures release];
	[super dealloc];
}

-(Texture2D*) addImage: (NSString*) fileimage
{
	NSAssert(fileimage != nil, @"TextureMgr: fileimage MUST not be nill");

	Texture2D * tex;
	
	if( (tex=[textures objectForKey: fileimage] ) ) {
		return tex;
	}
	
	tex = [[Texture2D alloc] initWithImage: [UIImage imageNamed:fileimage]];
	[textures setObject: tex forKey:fileimage];
	
	return [tex autorelease];
}

-(Texture2D*) addPVRTCImage: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	NSAssert(fileimage != nil, @"TextureMgr: fileimage MUST not be nill");
	NSAssert( bpp==2 || bpp==4, @"TextureMgr: bpp must be either 2 or 4");
	
	Texture2D * tex;
	
	if( (tex=[textures objectForKey: fileimage] ) ) {
		return tex;
	}
	
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)  {
		NSString *imagePath = [bundle pathForResource:fileimage ofType:nil];
		if (imagePath) {
			NSData *nsdata = [[NSData alloc] initWithContentsOfFile:imagePath];
			tex = [[Texture2D alloc] initWithPVRTCData:[nsdata bytes] level:0 bpp:bpp hasAlpha:alpha length:w];
			[textures setObject: tex forKey:fileimage];
			[nsdata release];
		}
	}

	return [tex autorelease];
}

-(Texture2D*) addCGImage: (CGImageRef) image
{
	NSAssert(image != nil, @"TextureMgr: image MUST not be nill");
	
	Texture2D * tex;
	NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
	
	if( (tex=[textures objectForKey: key] ) ) {
		return tex;
	}
	
	tex = [[Texture2D alloc] initWithImage: [UIImage imageWithCGImage:image]];
	[textures setObject: tex forKey:key];
	
	return [tex autorelease];
}

-(void) removeAllTextures
{
	[textures removeAllObjects];
}

-(void) removeTexture: (Texture2D*) tex
{
	NSAssert(tex != nil, @"TextureMgr: tex MUST not be nill");
	
	NSArray *keys = [textures allKeysForObject:tex];
	
	for( int i = 0; i < [keys count]; i++ )
		[textures removeObjectForKey:[keys objectAtIndex:i]];
}
@end
