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


#import "cocos2d.h"

@interface ParallaxNode : CocosNode {
	NSMutableArray *parallaxChildren;
}

/** Adds a child to the ParallaxNode with z order, tag and parallax ratio
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z tag:(int)tag parallaxRatio:(cpVect)p;

/** Adds a child to the ParallaxNode with z order and parallax ratio
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z parallaxRatio:(cpVect)p;
@end
