/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
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
	
	glDrawArrays(GL_LINE_LOOP, 0, points);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

void drawCircle( float x, float y, float r, float a, int segs)
{
	const float coef = 2.0f * (float)M_PI/segs;
	
	float *vertices = malloc( sizeof(float)*2*(segs+2));
	if( ! vertices )
		return;
	
	memset( vertices,0, sizeof(float)*2*(segs+2));
	
	for(int i=0;i<=segs;i++)
	{
		float rads = i*coef;
		float j = r * cosf(rads + a) + x;
		float k = r * sinf(rads + a) + y;

		vertices[i*2] = j;
		vertices[i*2+1] =k;
	}
	vertices[(segs+1)*2] = x;
	vertices[(segs+1)*2+1] = y;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_STRIP, 0, segs+2);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	
	free( vertices );
}
