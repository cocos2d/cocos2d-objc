//
//  OpenAL.h
//  ObjectAL
//
//  Created by Karl Stenerud on 15/12/09.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//


#pragma mark Types

/**
 * Represents a 3-dimensional point for certain ObjectAL properties.
 */
typedef struct
{
	/** The "X" coordinate */
	float x;
	/** The "Y" coordinate */
	float y;
	/** The "Z" coordinate */
	float z;
} ALPoint;

/**
 * Represents a 3-dimensional vector for certain ObjectAL properties.
 * Properties are the same as for ALPoint.
 */
typedef struct
{
	/** The "X" coordinate */
	float x;
	/** The "Y" coordinate */
	float y;
	/** The "Z" coordinate */
	float z;
} ALVector;

/**
 * Represents an orientation, consisting of an "at" vector (representing the "forward" direction),
 * and the "up" vector (representing "up" for the subject).
 */
typedef struct
{
	/** The "at" vector, representing "forward" */
	ALVector at;
	/** The "up" vector, representing "up" */
	ALVector up;
} ALOrientation;


#pragma mark -
#pragma mark Convenience Methods

/** Convenience inline for creating an ALPoint.
 *
 * @param x The X coordinate.
 * @param y The Y coordinate.
 * @param z The Z coordinate.
 * @return An ALPoint.
 */
static inline ALPoint alpoint(const float x, const float y, const float z)
{
	ALPoint point = {x, y, z};
	return point;
}

/** Convenience inline for creating an ALVector.
 *
 * @param x The X component.
 * @param y The Y component.
 * @param z The Z component.
 * @return An ALVector.
 */
static inline ALVector alvector(const float x, const float y, const float z)
{
	ALVector vector = {x, y, z};
	return vector;
}

/** Convenience inline for creating an ALOrientation.
 *
 * @param atX The X component of "at".
 * @param atY The Y component of "at".
 * @param atZ The Z component of "at".
 * @param upX The X component of "up".
 * @param upY The Y component of "up".
 * @param upZ The Z component of "up".
 * @return An ALOrientation.
 */
static inline ALOrientation alorientation(const float atX,
										  const float atY,
										  const float atZ,
										  const float upX,
										  const float upY,
										  const float upZ)
{
	ALOrientation orientation = { {atX, atY, atZ}, {upX,upY,upZ} };
	return orientation;
}

static inline ALPoint ALPointMake(float x, float y, float z)
{
	ALPoint p;
	p.x = x;
	p.y = y;
	p.z = z;

	return p;
}
