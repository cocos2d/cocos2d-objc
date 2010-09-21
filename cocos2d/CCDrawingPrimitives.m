/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <math.h>
#import <stdlib.h>
#import <string.h>

#import "CCDrawingPrimitives.h"
#import "ccTypes.h"
#import "ccMacros.h"
#import "Platforms/CCGL.h"

void ccDrawPoint( CGPoint point )
{
	ccVertex2F p = (ccVertex2F) {point.x * CC_CONTENT_SCALE_FACTOR(), point.y * CC_CONTENT_SCALE_FACTOR() };
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, &p);	
	glDrawArrays(GL_POINTS, 0, 1);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}

void ccDrawPoints( CGPoint *points, NSUInteger numberOfPoints )
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) ) {

		// convert to pixels
		for( NSUInteger i=0; i<numberOfPoints;i++)
			points[i] =  (CGPoint){ points[i].x * CC_CONTENT_SCALE_FACTOR(), points[i].y * CC_CONTENT_SCALE_FACTOR() };

		glVertexPointer(2, GL_FLOAT, 0, points);
		glDrawArrays(GL_POINTS, 0, numberOfPoints);

		
	} else {
		
		// Mac on 64-bit
		ccVertex2F p[numberOfPoints];
		for( NSUInteger i=0; i<numberOfPoints;i++)
			p[i] = (ccVertex2F) { points[i].x * CC_CONTENT_SCALE_FACTOR(), points[i].y * CC_CONTENT_SCALE_FACTOR() };
			
		glVertexPointer(2, GL_FLOAT, 0, p);
		glDrawArrays(GL_POINTS, 0, numberOfPoints);

	}

	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}


void ccDrawLine( CGPoint origin, CGPoint destination )
{
	ccVertex2F vertices[2];
	
	vertices[0] = (ccVertex2F) {origin.x * CC_CONTENT_SCALE_FACTOR(), origin.y * CC_CONTENT_SCALE_FACTOR() };
	vertices[1] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_LINES, 0, 2);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);		
}


void ccDrawPoly( CGPoint *poli, NSUInteger numberOfPoints, BOOL closePolygon )
{
	ccVertex2F newPoint[numberOfPoints];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	if( sizeof(CGPoint) == sizeof(ccVertex2F) ) {

		// convert to pixels
		for( NSUInteger i=0; i<numberOfPoints;i++)
			poli[i] = (CGPoint) { poli[i].x * CC_CONTENT_SCALE_FACTOR(), poli[i].y * CC_CONTENT_SCALE_FACTOR()};

		// iPhone and 32-bit machines
		glVertexPointer(2, GL_FLOAT, 0, poli);
		
	} else {
		// 64-bit machines (Mac)
		
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoint[i] = (ccVertex2F) { poli[i].x * CC_CONTENT_SCALE_FACTOR(), poli[i].y * CC_CONTENT_SCALE_FACTOR()};

		glVertexPointer(2, GL_FLOAT, 0, newPoint );

	}
		
	if( closePolygon )
		glDrawArrays(GL_LINE_LOOP, 0, numberOfPoints);
	else
		glDrawArrays(GL_LINE_STRIP, 0, numberOfPoints);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}

void ccDrawCircle( CGPoint center, float r, float a, NSUInteger segs, BOOL drawLineToCenter)
{
	int additionalSegment = 1;
	if (drawLineToCenter)
		additionalSegment++;

	const float coef = 2.0f * (float)M_PI/segs;
	
	GLfloat *vertices = calloc( sizeof(GLfloat)*2*(segs+2), 1);
	if( ! vertices )
		return;

	for(NSUInteger i=0;i<=segs;i++)
	{
		float rads = i*coef;
		GLfloat j = r * cosf(rads + a) + center.x;
		GLfloat k = r * sinf(rads + a) + center.y;
		
		vertices[i*2] = j * CC_CONTENT_SCALE_FACTOR();
		vertices[i*2+1] =k * CC_CONTENT_SCALE_FACTOR();
	}
	vertices[(segs+1)*2] = center.x * CC_CONTENT_SCALE_FACTOR();
	vertices[(segs+1)*2+1] = center.y * CC_CONTENT_SCALE_FACTOR();
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_LINE_STRIP, 0, segs+additionalSegment);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
	free( vertices );
}

void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments)
{
	ccVertex2F vertices[segments + 1];
	
	float t = 0.0f;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
		GLfloat y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
		vertices[i] = (ccVertex2F) {x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() };
		t += 1.0f / segments;
	}
	vertices[segments] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_LINE_STRIP, 0, segments + 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}

void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments)
{
	ccVertex2F vertices[segments + 1];
	
	float t = 0;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		GLfloat y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		vertices[i] = (ccVertex2F) {x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() };
		t += 1.0f / segments;
	}
	vertices[segments] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_LINE_STRIP, 0, segments + 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}
