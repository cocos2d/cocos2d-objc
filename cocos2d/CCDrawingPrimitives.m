/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#import "CCDrawingPrimitives.h"

void ccDrawPoint( CGPoint point )
{
	glVertexPointer(2, GL_FLOAT, 0, &point);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_POINTS, 0, 1);
	
	glDisableClientState(GL_VERTEX_ARRAY);	
}

void ccDrawPoints( CGPoint *points, unsigned int numberOfPoints )
{
	glVertexPointer(2, GL_FLOAT, 0, points);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_POINTS, 0, numberOfPoints);
	
	glDisableClientState(GL_VERTEX_ARRAY);	
}


void ccDrawLine( CGPoint origin, CGPoint destination )
{
	CGPoint vertices[2];
	
	vertices[0] = origin;
	vertices[1] = destination;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINES, 0, 2);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}


void ccDrawPoly( CGPoint *poli, int points, BOOL closePolygon )
{
	glVertexPointer(2, GL_FLOAT, 0, poli);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	if( closePolygon )
		glDrawArrays(GL_LINE_LOOP, 0, points);
	else
		glDrawArrays(GL_LINE_STRIP, 0, points);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

void ccDrawCircle( CGPoint center, float r, float a, int segs, BOOL drawLineToCenter)
{
	int additionalSegment = 1;
	if (drawLineToCenter)
		additionalSegment++;

	const float coef = 2.0f * (float)M_PI/segs;
	
	float *vertices = malloc( sizeof(float)*2*(segs+2));
	if( ! vertices )
		return;
	
	memset( vertices,0, sizeof(float)*2*(segs+2));
	
	for(int i=0;i<=segs;i++)
	{
		float rads = i*coef;
		float j = r * cosf(rads + a) + center.x;
		float k = r * sinf(rads + a) + center.y;
		
		vertices[i*2] = j;
		vertices[i*2+1] =k;
	}
	vertices[(segs+1)*2] = center.x;
	vertices[(segs+1)*2+1] = center.y;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_STRIP, 0, segs+additionalSegment);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	
	free( vertices );
}

void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, int segments)
{
	CGPoint vertices[segments + 1];
	
	float t = 0.0f;
	for(int i = 0; i < segments; i++)
	{
		float x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
		float y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
		vertices[i] = CGPointMake(x, y);
		t += 1.0f / segments;
	}
	vertices[segments] = destination;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_STRIP, 0, segments + 1);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, int segments)
{
	CGPoint vertices[segments + 1];
	
	float t = 0;
	for(int i = 0; i < segments; i++)
	{
		float x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		float y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		vertices[i] = CGPointMake(x, y);
		t += 1.0f / segments;
	}
	vertices[segments] = destination;
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_STRIP, 0, segments + 1);
	
	glDisableClientState(GL_VERTEX_ARRAY);  
}
