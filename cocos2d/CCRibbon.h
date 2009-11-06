/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008, 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 *
 */

#import "CCNode.h"
#import "CCTexture2D.h"
#import "CCProtocols.h"
#import <OpenGLES/ES1/gl.h>

/**
 * A CCRibbon is a dynamically generated list of polygons drawn as a single or series
 * of triangle strips. The primary use of Ribbon is as the drawing class of Motion Streak,
 * but it is quite useful on it's own. When manually drawing a ribbon, you can call addPointAt
 * and pass in the parameters for the next location in the ribbon. The system will automatically
 * generate new polygons, texture them accourding to your texture width, etc, etc.
 *
 * Ribbon data is stored in a RibbonSegment class. This class statically allocates enough verticies and
 * texture coordinates for 50 locations (100 verts or 48 triangles). The ribbon class will allocate
 * new segments when they are needed, and reuse old ones if available. The idea is to avoid constantly
 * allocating new memory and prefer a more static method. However, since there is no way to determine
 * the maximum size of some ribbons (motion streaks), a truely static allocation is not possible.
 *
 * @since v0.8.1
 */
@interface CCRibbon : CCNode <CCTextureProtocol>
{
	NSMutableArray* mSegments;
	NSMutableArray* dSegments;

	CGPoint			mLastPoint1;
	CGPoint			mLastPoint2;
	CGPoint			mLastLocation;
	int				mVertCount;
	float			mTexVPos;
	float			mCurTime;
	float			mFadeTime;
	float			mDelta;
	float			mLastWidth;
	float			mLastSign;
	BOOL			mPastFirstPoint;

	// Texture used
	CCTexture2D*		texture_;

	// texture lenght
	float			textureLength_;

	// RGBA protocol
	ccColor4B color_;

	// blend func
	ccBlendFunc		blendFunc_;
}

/** Texture used by the ribbon. Conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite,retain) CCTexture2D* texture;

/** Texture lenghts in pixels */
@property (nonatomic,readwrite) float textureLength;

/** GL blendind function */
@property (nonatomic,readwrite,assign) ccBlendFunc blendFunc;

/** color used by the Ribbon (RGBA) */
@property (nonatomic,readwrite) ccColor4B color;

/** creates the ribbon */
+(id)ribbonWithWidth:(float)w image:(NSString*)path length:(float)l color:(ccColor4B)color fade:(float)fade;
/** init the ribbon */
-(id)initWithWidth:(float)w image:(NSString*)path length:(float)l color:(ccColor4B)color fade:(float)fade;
/** add a point to the ribbon */
-(void)addPointAt:(CGPoint)location width:(float)w;
/** polling function */
-(void)update:(ccTime)delta;
/** determine side of line */
-(float)sideOfLine:(CGPoint)p l1:(CGPoint)l1 l2:(CGPoint)l2;

@end

/** object to hold ribbon segment data */
@interface CCRibbonSegment : NSObject
{
@public
	GLfloat verts[50*6];
	GLfloat coords[50*4];
	GLubyte colors[50*8];
	float creationTime[50];
	bool finished;
	uint end;
	uint begin;
}
-(id)init;
-(void)reset;
-(void)draw:(float)curTime fadeTime:(float)fadeTime color:(ccColor4B)color;
@end
