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

#import <OpenGLES/ES1/gl.h>
#import <math.h>
#import <stdlib.h>
#import <string.h>

void drawPoint( float x, float y )
{
	GLfloat vertices[1 * 2];
	
	vertices[0] = x;
	vertices[1] = y;
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_POINTS, 0, 1);
	
	glDisableClientState(GL_VERTEX_ARRAY);	
}

void drawLine(float x1, float y1, float x2, float y2)
{
	GLfloat vertices[2 * 2];
	
	vertices[0] = x1;
	vertices[1] = y1;
	vertices[2] = x2;
	vertices[3] = y2;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINES, 0, 2);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

void drawPoly( float *poli, int points )
{
	glVertexPointer(2, GL_FLOAT, 0, poli);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINES, 0, points);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

void drawCircle( float x, float y, float r, int segs)
{
	const float coef = 2.0*M_PI/(float)segs;
	float a = 0;
	
	float *vertices = malloc( sizeof(float)*2*segs);
	if( ! vertices )
		return;
	
	memset( vertices,0, sizeof(float)*2*segs);
	
	for(int i=0;i<segs;i++)
	{
		float rads = i*coef;
		float j = r*cos(rads + a) + x;
		float k = r*sin(rads + a) + y;

		vertices[i*2] = j;
		vertices[i*2+1] =k;
	}
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_LOOP, 0, segs);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	
	free( vertices );
}