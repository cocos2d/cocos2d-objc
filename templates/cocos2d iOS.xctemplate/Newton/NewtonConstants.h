/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Lars Birkemose
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

static const int NewtonLetterCount = 7;
static const NSString *NewtonLetter[] = { @"c", @"o", @"c", @"o", @"s", @"2", @"d" };
static const CGPoint NewtonLetterPosition[] = {{-2,0}, {-1,0}, {0,0}, {1,0}, {2,0}, {1.8,-2}, {2.8,-2}};
static const BOOL NewtonLetterHasRope[] = {YES, YES, YES, YES, YES, NO, NO};

static const float NewtonBackgroundLuminance = 0.1f;

static const CGPoint NewtonButtonBackPosition = (CGPoint){0.10f, 0.90f};
static const CGPoint NewtonButtonFirePosition = (CGPoint){0.90f, 0.90f};
static const CGPoint NewtonButtonResetPosition = (CGPoint){0.90f, 0.80f};
static const CGPoint NewtonLightPosition = (CGPoint){0.75f, 0.35f};

static const CGPoint NewtonGravity = (CGPoint){0, -980.665};
static const float NewtonOutlineFriction = 1.0f;
static const float NewtonOutlineElasticity = 0.5f;
static const float NewtonSphereFriction = 0.5;
static const float NewtonSphereElasticity = 1.0;

static const float NewtonSphereNormalMass = 1;
static const float NewtonSphereSwingingMass = 0.25;
static const float NewtonSphereMovingMass = 100;
static const float NewtonRopeNormalMass = 1;

static const BOOL NewtonRealRope = NO;
static const int NewtonRopeSegments = 6;

static const float NewtonParticleScale = 0.8f;
static const float NewtonParticleDisplacement = 0.35f;

// Added because the image of the sprite doesnt fill the image 100%
// A transparent blended margin is kept, to make the image looks good then it rotates.
static const float NewtonSphereMargin = 3;
static const float NewtonSphereSpacing = 3;

static const NSString *NewtonSphereCollisionSphere = @"sphere";
static const NSString *NewtonSphereCollisionOutline = @"outline";
static const NSString *NewtonSphereCollisionRope = @"rope";

#define CCNewtonRopeColor [CCColor colorWithRed:0.2 green:0.2 blue:0.2]

