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


#import <UIKit/UIKit.h>

#import "Support/Texture2D.h"

#import "TextureNode.h"

/** an Animation object used within Sprites to perform animations */
@interface Animation : NSObject
{
	NSString *name;
	float	delay;
	NSMutableArray *frames;
}

@property (readwrite,assign) NSString * name;
@property (readwrite,assign) float delay;
@property (readwrite,assign) NSMutableArray *frames;

/** creates an Animation with name, delay and frames */
+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,... NS_REQUIRES_NIL_TERMINATION;
/** initializes an Animation with name, delay and frames */
-(id) initWithName: (NSString*) name delay:(float)delay firstImage:(NSString*)filename vaList:(va_list) args;
/** initializes an Animation with name and delay */
-(id) initWithName: (NSString*) name delay:(float)delay;
/** adds a frame to an Animation */
-(void) addFrame: (NSString*) filename;
@end


/** a 2D sprite */
@interface Sprite : TextureNode
{
	NSMutableDictionary *animations;	
}

/** creates an sprite from a filepath */
+ (id) spriteFromFile:(NSString *)path;
/** initializes the sprite from a filepath */
- (id) initFromFile:(NSString *)path;

/** adds an Animation to the Sprite */
-(void) addAnimation: (Animation*) animation;
/** changes the display frame based on an animation and an index */
-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex;

@end
