/* OC3D
 *
 * Copyright (C) 2008 Boris Stock
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

#import "UIColor-OpenGL.h"

@implementation UIColor(OpenGL)

- (void)setOpenGLClearColor
{
	CGColorRef color = self.CGColor;
	int numComponents = CGColorGetNumberOfComponents(color);
	if (numComponents == 2)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat all = components[0];
		CGFloat alpha = components[1];
		glClearColor(all,all, all, alpha);
	}
	else
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat alpha = components[3];
		glClearColor(red,green, blue, alpha);
	}
}

- (void)setOpenGLColor
{
	CGColorRef color = self.CGColor;
	int numComponents = CGColorGetNumberOfComponents(color);
	if (numComponents == 2)
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat all = components[0];
		CGFloat alpha = components[1];
		glColor4f(all,all, all, alpha);
	}
	else
	{
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat alpha = components[3];
		glColor4f(red,green, blue, alpha);
	}
}

@end
