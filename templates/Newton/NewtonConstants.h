//
//  NewtonConstants.h
//  Template
//
//  Created by Lars Birkemose on 08/01/14.
//  Copyright (c) 2014 Lars Birkemose. All rights reserved.
//
// Create some statics, to easen up the creation of newton spheres

static const int NewtonLetterCount = 7;
static const NSString *NewtonLetter[] = { @"c", @"o", @"c", @"o", @"s", @"2", @"d" };
static const CGPoint NewtonLetterPosition[] = {{-2,0}, {-1,0}, {0,0}, {1,0}, {2,0}, {1.8,-2}, {2.8,-2}};
static const BOOL NewtonLetterHasRope[] = {YES, YES, YES, YES, YES, NO, NO};

static const CGPoint NewtonGravity = (CGPoint){0, -980.665};

static const float NewtonSphereNormalMass = 1;
static const float NewtonSphereSwingingMass = 0.25;
static const float NewtonSphereMovingMass = 100;
static const float NewtonRopeNormalMass = 1;

static const BOOL NewtonRealRope = NO;
static const int NewtonRopeSegments = 6;

// Added because the image of the sprite doesnt fill the image 100%
// A transparent blended margin is kept, to make the image looks good then it rotates.
static const float NewtonSphereMargin = 3;
static const float NewtonSphereSpacing = 3;

static const NSString *NewtonSphereCollisionSphere = @"sphere";
static const NSString *NewtonSphereCollisionOutline = @"outline";
static const NSString *NewtonSphereCollisionRope = @"rope";

#define CCNewtonRopeColor [CCColor colorWithRed:0.2 green:0.2 blue:0.2]

