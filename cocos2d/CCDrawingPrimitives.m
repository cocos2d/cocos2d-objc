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

/*
 *
 * IMPORTANT       IMPORTANT        IMPORTANT        IMPORTANT 
 *
 *
 * LEGACY FUNCTIONS
 *
 * USE CCDrawNode instead
 *
 */

#import <math.h>
#import <stdlib.h>
#import <string.h>

#import "CCDrawingPrimitives.h"
#import "ccMacros.h"
#import "Platforms/CCGL.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "CCActionCatmullRom.h"
#import "Support/OpenGL_Internal.h"


static BOOL initialized = NO;
static CCGLProgram *shader_ = nil;
static int colorLocation_ = -1;
static ccColor4F color_ = {1,1,1,1};
static int pointSizeLocation_ = -1;
static GLfloat pointSize_ = 1;

static void lazy_init( void )
{
	if( ! initialized ) {

		//
		// Position and 1 color passed as a uniform (to similate glColor4ub )
		//
		shader_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];

		colorLocation_ = glGetUniformLocation( shader_->program_, "u_color");
		pointSizeLocation_ = glGetUniformLocation( shader_->program_, "u_pointSize");

		initialized = YES;
	}

}

void ccDrawPoint( CGPoint point )
{
	lazy_init();

	ccVertex2F p = (ccVertex2F) {point.x, point.y};

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	[shader_ use];
	[shader_ setUniformsForBuiltins];

	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];
	[shader_ setUniformLocation:pointSizeLocation_ withF1:pointSize_];

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, &p);

	glDrawArrays(GL_POINTS, 0, 1);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawPoints( const CGPoint *points, NSUInteger numberOfPoints )
{
	lazy_init();

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	[shader_ use];
	[shader_ setUniformsForBuiltins];
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];
	[shader_ setUniformLocation:pointSizeLocation_ withF1:pointSize_];

	// XXX: Mac OpenGL error. arrays can't go out of scope before draw is executed
	ccVertex2F newPoints[numberOfPoints];

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) )
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, points);

	else
    {
		// Mac on 64-bit
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoints[i] = (ccVertex2F) { points[i].x, points[i].y };

		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, newPoints);
	}

    glDrawArrays(GL_POINTS, 0, (GLsizei) numberOfPoints);
	
	CC_INCREMENT_GL_DRAWS(1);
}


void ccDrawLine( CGPoint origin, CGPoint destination )
{
	lazy_init();

	ccVertex2F vertices[2] = {
		{origin.x, origin.y},
		{destination.x, destination.y}
	};

	[shader_ use];
	[shader_ setUniformsForBuiltins];
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_LINES, 0, 2);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawRect( CGPoint origin, CGPoint destination )
{
	ccDrawLine(CGPointMake(origin.x, origin.y), CGPointMake(destination.x, origin.y));
	ccDrawLine(CGPointMake(destination.x, origin.y), CGPointMake(destination.x, destination.y));
	ccDrawLine(CGPointMake(destination.x, destination.y), CGPointMake(origin.x, destination.y));
	ccDrawLine(CGPointMake(origin.x, destination.y), CGPointMake(origin.x, origin.y));
}

void ccDrawSolidRect( CGPoint origin, CGPoint destination, ccColor4F color )
{
	CGPoint vertices[] = {
		origin,
		{destination.x, origin.y},
		destination,
		{origin.x, destination.y},
	};
	
	ccDrawSolidPoly(vertices, 4, color );
}

void ccDrawPoly( const CGPoint *poli, NSUInteger numberOfPoints, BOOL closePolygon )
{
	lazy_init();

	[shader_ use];
	[shader_ setUniformsForBuiltins];
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	// XXX: Mac OpenGL error. arrays can't go out of scope before draw is executed
	ccVertex2F newPoli[numberOfPoints];

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) )
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, poli);

	else
    {
		// Mac on 64-bit
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoli[i] = (ccVertex2F) { poli[i].x, poli[i].y };

		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, newPoli);
	}

	if( closePolygon )
		glDrawArrays(GL_LINE_LOOP, 0, (GLsizei) numberOfPoints);
	else
		glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) numberOfPoints);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawSolidPoly( const CGPoint *poli, NSUInteger numberOfPoints, ccColor4F color )
{
	lazy_init();
    
	[shader_ use];
	[shader_ setUniformsForBuiltins];    
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	// XXX: Mac OpenGL error. arrays can't go out of scope before draw is executed
	ccVertex2F newPoli[numberOfPoints];

	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) )
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, poli);
	
	else
    {
		// Mac on 64-bit
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoli[i] = (ccVertex2F) { poli[i].x, poli[i].y };
		
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, newPoli);
	}    
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei) numberOfPoints);
}


void ccDrawCircle( CGPoint center, float r, float a, NSUInteger segs, BOOL drawLineToCenter)
{
	lazy_init();

	int additionalSegment = 1;
	if (drawLineToCenter)
		additionalSegment++;

	const float coef = 2.0f * (float)M_PI/segs;

	GLfloat *vertices = calloc( sizeof(GLfloat)*2*(segs+2), 1);
	if( ! vertices )
		return;

	for(NSUInteger i = 0;i <= segs; i++) {
		float rads = i*coef;
		GLfloat j = r * cosf(rads + a) + center.x;
		GLfloat k = r * sinf(rads + a) + center.y;

		vertices[i*2] = j;
		vertices[i*2+1] = k;
	}
	vertices[(segs+1)*2] = center.x;
	vertices[(segs+1)*2+1] = center.y;

	[shader_ use];
	[shader_ setUniformsForBuiltins];    
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segs+additionalSegment);

	free( vertices );
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments)
{
	lazy_init();

	ccVertex2F vertices[segments + 1];

	float t = 0.0f;
	for(NSUInteger i = 0; i < segments; i++)
	{
		vertices[i].x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
		vertices[i].y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
		t += 1.0f / segments;
	}
	vertices[segments] = (ccVertex2F) {destination.x, destination.y};

	[shader_ use];
	[shader_ setUniformsForBuiltins];    
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawCatmullRom( CCPointArray *points, NSUInteger segments )
{
	ccDrawCardinalSpline( points, 0.5f, segments );
}

void ccDrawCardinalSpline( CCPointArray *config, CGFloat tension,  NSUInteger segments )
{
	lazy_init();
	
	ccVertex2F vertices[segments + 1];

	NSUInteger p;
	CGFloat lt;
	CGFloat deltaT = 1.0 / [config count];
	
	for( NSUInteger i=0; i < segments+1;i++) {
		
		CGFloat dt = (CGFloat)i / segments;
	
		// border
		if( dt == 1 ) {
			p = [config count] - 1;
			lt = 1;
		} else {
			p = dt / deltaT;
			lt = (dt - deltaT * (CGFloat)p) / deltaT;
		}
		
		// Interpolate
		CGPoint pp0 = [config getControlPointAtIndex:p-1];
		CGPoint pp1 = [config getControlPointAtIndex:p+0];
		CGPoint pp2 = [config getControlPointAtIndex:p+1];
		CGPoint pp3 = [config getControlPointAtIndex:p+2];
		
		CGPoint newPos = ccCardinalSplineAt( pp0, pp1, pp2, pp3, tension, lt);
		vertices[i].x = newPos.x;
		vertices[i].y = newPos.y;
	}
	
	[shader_ use];
	[shader_ setUniformsForBuiltins];    
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments)
{
	lazy_init();

	ccVertex2F vertices[segments + 1];

	float t = 0;
	for(NSUInteger i = 0; i < segments; i++)
	{
		vertices[i].x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		vertices[i].y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		t += 1.0f / segments;
	}
	vertices[segments] = (ccVertex2F) {destination.x, destination.y};

	[shader_ use];
	[shader_ setUniformsForBuiltins];    
	[shader_ setUniformLocation:colorLocation_ with4fv:(GLfloat*) &color_.r count:1];

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void ccDrawColor4F( GLfloat r, GLfloat g, GLfloat b, GLfloat a )
{
	color_ = (ccColor4F) {r, g, b, a};
}

void ccPointSize( GLfloat pointSize )
{
	pointSize_ = pointSize * CC_CONTENT_SCALE_FACTOR();
#ifdef __CC_PLATFORM_IOS
#elif defined(__CC_PLATFORM_MAC)
	glPointSize( pointSize );
#endif
}
void ccDrawColor4B( GLubyte r, GLubyte g, GLubyte b, GLubyte a )
{
	color_ =  (ccColor4F) {r/255.0f, g/255.0f, b/255.0f, a/255.0f};
}
