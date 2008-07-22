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


#import "Director.h"
#import "Camera.h"

#import "glu.h"

@implementation Camera
-(id) init
{
	if( ! [super init] )
		return nil;

	[self restore];
	return self;
}

-(void) restore
{
	CGRect s = [[Director sharedDirector] displaySize];

	eyeX = s.size.width/2;
	eyeY = s.size.height/2;
	eyeZ = [Camera getZEye];
	
	centerX = s.size.width/2;
	centerY = s.size.height/2;
	centerZ = 0.0f;
	
	upX = 0.0f;
	upY = 1.0f;
	upZ = 0.0f;
	
	dirty = NO;
}

-(void) locate
{
	if( dirty ) {
		BOOL landscape = [[Director sharedDirector] landscape];

		glLoadIdentity();

		if( landscape )
			glRotatef(-90,0,0,1);
		
		gluLookAt( eyeX, eyeY, eyeZ,
				centerX, centerY, centerZ,
				upX, upY, upZ
				);
		
		if( landscape )
#if LANDSCAPE_LEFT
			glTranslatef(-80,80,0);
#else
#error "FIX ME"
#endif // LANDSCAPE_LEFT
	}
}

+(float) getZEye
{
	CGRect s = [[Director sharedDirector] displaySize];
	return ( s.size.height / 1.1566 );
}

-(void) setEyeX: (float)x eyeY:(float)y eyeZ:(float)z
{
	eyeX = x;
	eyeY = y;
	eyeZ = z;
	dirty = YES;
}

-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z
{
	centerX = x;
	centerY = y;
	centerZ = z;
	dirty = YES;
}

-(void) setUpX: (float)x upY:(float)y upZ:(float)z
{
	upX = x;
	upY = y;
	upZ = z;
	dirty = YES;
}

-(void) eyeX: (float*)x eyeY:(float*)y eyeZ:(float*)z
{
	*x = eyeX;
	*y = eyeY;
	*z = eyeZ;
}

-(void) centerX: (float*)x centerY:(float*)y centerZ:(float*)z
{
	*x = centerX;
	*y = centerY;
	*z = centerZ;
}

-(void) upX: (float*)x upY:(float*)y upZ:(float*)z
{
	*x = upX;
	*y = upY;
	*z = upZ;
}

@end
