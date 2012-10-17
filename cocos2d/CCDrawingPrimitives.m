/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

void ccDrawPoint( CGPoint point)
{
    ccDrawPointInPixels(point, NO);
}

void ccDrawPointInPixels( CGPoint point, BOOL inPixels )
{
	ccVertex2F p;
    if (inPixels)
         p = (ccVertex2F) {point.x, point.y};
	else
        p = (ccVertex2F) {point.x * CC_CONTENT_SCALE_FACTOR(), point.y * CC_CONTENT_SCALE_FACTOR() };

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

void ccDrawPoints( const CGPoint *points, NSUInteger numberOfPoints)
{
    ccDrawPointsInPixels(points, numberOfPoints, NO);
}

void ccDrawPointsInPixels( const CGPoint *points, NSUInteger numberOfPoints, BOOL inPixels)
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	ccVertex2F newPoints[numberOfPoints];

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) ) {
        if (!inPixels)
        {
            // points ?
            if( CC_CONTENT_SCALE_FACTOR() != 1 ) {
                for( NSUInteger i=0; i<numberOfPoints;i++)
                    newPoints[i] =	(ccVertex2F){ points[i].x * CC_CONTENT_SCALE_FACTOR(), points[i].y * CC_CONTENT_SCALE_FACTOR() };

                glVertexPointer(2, GL_FLOAT, 0, newPoints);

            } else
                glVertexPointer(2, GL_FLOAT, 0, points);
		}
        else
        {
            glVertexPointer(2, GL_FLOAT, 0, points);
        }


		glDrawArrays(GL_POINTS, 0, (GLsizei) numberOfPoints);

	} else {

		// Mac on 64-bit
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoints[i] = (ccVertex2F) { points[i].x, points[i].y };

		glVertexPointer(2, GL_FLOAT, 0, newPoints);
		glDrawArrays(GL_POINTS, 0, (GLsizei) numberOfPoints);

	}


	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

void ccDrawLine( CGPoint origin, CGPoint destination)
{
    ccDrawLineInPixels( origin, destination, NO);
}

void ccDrawLineInPixels( CGPoint origin, CGPoint destination, BOOL inPixels)
{
	ccVertex2F vertices[2];
    if (inPixels)
    {
        vertices[0] = (ccVertex2F) {origin.x, origin.y};
        vertices[1] = (ccVertex2F) {destination.x, destination.y};
    }
    else
    {
		vertices[0] = (ccVertex2F) {origin.x * CC_CONTENT_SCALE_FACTOR(), origin.y * CC_CONTENT_SCALE_FACTOR() };
        vertices[1] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };
	}

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

void ccDrawLines( CGPoint* points, NSUInteger numberOfPoints)
{
    ccDrawLinesInPixels(points, numberOfPoints, NO);
}

void ccDrawLinesInPixels( CGPoint* points, NSUInteger numberOfPoints, BOOL inPixels)
{
	//layout of points [0] = origin, [1] = destination and so on

	ccVertex2F vertices[numberOfPoints];

	// iPhone and 32-bit machines
	if( sizeof(CGPoint) == sizeof(ccVertex2F) )
	{
        if (!inPixels)
        {
            if (CC_CONTENT_SCALE_FACTOR() != 1 )
            {
                for (int i=0;i<numberOfPoints;i++)
                {
                    vertices[i].x=points[i].x * CC_CONTENT_SCALE_FACTOR();
                    vertices[i].y=points[i].y * CC_CONTENT_SCALE_FACTOR();
                }
                glVertexPointer(2, GL_FLOAT, 0, vertices);
            }
            else glVertexPointer(2, GL_FLOAT, 0, points);
        }
        else glVertexPointer(2, GL_FLOAT, 0, points);
	}
	else
	{
		for( NSUInteger i=0; i< numberOfPoints; i++)
			vertices[i] = (ccVertex2F) { points[i].x, points[i].y };

		glVertexPointer(2, GL_FLOAT, 0, vertices );

	}
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	glDrawArrays(GL_LINES, 0, (GLsizei) numberOfPoints);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

void ccDrawRect( CGPoint origin, CGPoint destination)
{
    ccDrawRectInPixels(origin, destination, NO);
}

void ccDrawRectInPixels( CGPoint origin, CGPoint destination, BOOL inPixels)
{
	ccDrawLineInPixels(CGPointMake(origin.x, origin.y), CGPointMake(destination.x, origin.y), inPixels);
	ccDrawLineInPixels(CGPointMake(destination.x, origin.y), CGPointMake(destination.x, destination.y), inPixels);
	ccDrawLineInPixels(CGPointMake(destination.x, destination.y), CGPointMake(origin.x, destination.y), inPixels);
	ccDrawLineInPixels(CGPointMake(origin.x, destination.y), CGPointMake(origin.x, origin.y), inPixels);
}

void ccDrawSolidRect( CGPoint origin, CGPoint destination)
{
    ccDrawSolidRectInPixels(origin, destination, NO);
}

void ccDrawSolidRectInPixels( CGPoint origin, CGPoint destination, BOOL inPixels)
{
	CGPoint vertices[] = {
		{origin.x, origin.y},
		{destination.x, origin.y},
		{destination.x, destination.y},
		{origin.x, destination.y}
	};

	ccDrawSolidPolyInPixels(vertices, 4, YES, inPixels);
}

void ccDrawPoly( const CGPoint *vertices, NSUInteger numberOfPoints, BOOL closePolygon)
{
    ccDrawPolyInPixels(vertices, numberOfPoints, closePolygon, NO);
}

void ccDrawPolyInPixels( const CGPoint *vertices, NSUInteger numberOfPoints, BOOL closePolygon, BOOL inPixels)
{
	ccVertex2F newPoint[numberOfPoints];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);


	// iPhone and 32-bit machines
	if( sizeof(CGPoint) == sizeof(ccVertex2F) ) {
        if (!inPixels)
        {

            // convert to pixels ?
            if( CC_CONTENT_SCALE_FACTOR() != 1 ) {
                memcpy( newPoint, vertices, numberOfPoints * sizeof(ccVertex2F) );
                for( NSUInteger i=0; i<numberOfPoints;i++)
                    newPoint[i] = (ccVertex2F) { vertices[i].x * CC_CONTENT_SCALE_FACTOR(), vertices[i].y * CC_CONTENT_SCALE_FACTOR() };

                glVertexPointer(2, GL_FLOAT, 0, newPoint);

            } else
                glVertexPointer(2, GL_FLOAT, 0, vertices);
        }
        else
        {
            glVertexPointer(2, GL_FLOAT, 0, vertices);
        }

	} else {
		// 64-bit machines (Mac)

		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoint[i] = (ccVertex2F) { vertices[i].x, vertices[i].y };

		glVertexPointer(2, GL_FLOAT, 0, newPoint );

	}

	if( closePolygon )
		glDrawArrays(GL_LINE_LOOP, 0, (GLsizei) numberOfPoints);
	else
		glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) numberOfPoints);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

void ccDrawSolidPoly(const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon)
{
    ccDrawSolidPolyInPixels(vertices, numOfVertices, closePolygon, NO);
}

void ccDrawSolidPolyInPixels(const CGPoint *vertices, NSUInteger numOfVertices, BOOL closePolygon, BOOL inPixels)
{
	ccVertex2F newPoint[numOfVertices];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY

	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);


	// iPhone and 32-bit machines
	if (sizeof(CGPoint) == sizeof(ccVertex2F))
	{
        if (!inPixels)
        {
            // convert to pixels ?
            if (CC_CONTENT_SCALE_FACTOR() != 1)
            {
                memcpy(newPoint, vertices, numOfVertices * sizeof(ccVertex2F));

                for (NSUInteger i = 0; i < numOfVertices; i++)
                {
                    newPoint[i] = (ccVertex2F) {
                        vertices[i].x * CC_CONTENT_SCALE_FACTOR(),
                        vertices[i].y * CC_CONTENT_SCALE_FACTOR()
                    };
                }

                glVertexPointer(2, GL_FLOAT, 0, newPoint);

            }
            else
            {
                glVertexPointer(2, GL_FLOAT, 0, vertices);
            }
        }
        else
        {
            glVertexPointer(2, GL_FLOAT, 0, vertices);
        }
	}
	else // 64-bit machines (Mac)
	{
		for (NSUInteger i = 0; i < numOfVertices; i++)
		{
			newPoint[i] = (ccVertex2F) {
				vertices[i].x,
				vertices[i].y
			};
		}
		glVertexPointer(2, GL_FLOAT, 0, newPoint );
	}

	if (closePolygon)
		glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei) numOfVertices);
	else
		glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) numOfVertices);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

void ccDrawCircle( CGPoint center, float r, float a, NSUInteger segs, BOOL drawLineToCenter)
{
    ccDrawCircleInPixels(center, r, a, segs, drawLineToCenter, NO);
}

void ccDrawCircleInPixels( CGPoint center, float r, float a, NSUInteger segs, BOOL drawLineToCenter, BOOL inPixels)
{
	int additionalSegment = 1;
	if (drawLineToCenter)
		additionalSegment++;

	const float coef = 2.0f * (float)M_PI/segs;

	GLfloat *vertices = calloc( sizeof(GLfloat)*2*(segs+2), 1);
	if( ! vertices )
		return;
    if (!inPixels)
    {
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
    }
    else
    {
        for(NSUInteger i=0;i<=segs;i++)
        {
            float rads = i*coef;
            GLfloat j = r * cosf(rads + a) + center.x;
            GLfloat k = r * sinf(rads + a) + center.y;

            vertices[i*2] = j;
            vertices[i*2+1] =k;
        }
        vertices[(segs+1)*2] = center.x;
        vertices[(segs+1)*2+1] = center.y;


    }
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segs+additionalSegment);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);

	free( vertices );
}

void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments)
{
    ccDrawQuadBezierInPixels(origin, control, destination, segments, NO);
}

void ccDrawQuadBezierInPixels(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments, BOOL inPixels)
{
	ccVertex2F vertices[segments + 1];

	float t = 0.0f;

    if (!inPixels)
    {
        for(NSUInteger i = 0; i < segments; i++)
        {
            GLfloat x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
            GLfloat y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
            vertices[i] = (ccVertex2F) {x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() };
            t += 1.0f / segments;
        }
        vertices[segments] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };
    }
    else
    {

        for(NSUInteger i = 0; i < segments; i++)
        {
            GLfloat x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
            GLfloat y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
            vertices[i] = (ccVertex2F) {x, y};
            t += 1.0f / segments;
        }
        vertices[segments] = (ccVertex2F) {destination.x, destination.y};
    }
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments)
{
    ccDrawCubicBezierInPixels(origin, control1, control2, destination, segments, NO);
}

void ccDrawCubicBezierInPixels(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments, BOOL inPixels)
{
	ccVertex2F vertices[segments + 1];

	float t = 0;

    if (!inPixels)
    {
        for(NSUInteger i = 0; i < segments; i++)
        {
            GLfloat x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
            GLfloat y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
            vertices[i] = (ccVertex2F) {x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() };
            t += 1.0f / segments;
        }
        vertices[segments] = (ccVertex2F) {destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR() };
    }
    else
    {
        for(NSUInteger i = 0; i < segments; i++)
        {
            GLfloat x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
            GLfloat y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
            vertices[i] = (ccVertex2F) {x, y};
            t += 1.0f / segments;
        }
        vertices[segments] = (ccVertex2F) {destination.x, destination.y};

    }
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);

	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}
