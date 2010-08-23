/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008, 2009 Jason Booth
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
 *
 */


#import "CCNode.h"
#import "CCTexture2D.h"
#import "CCProtocols.h"
#import "Platforms/CCGL.h"

/**
 * A CCRibbon is a dynamically generated list of polygons drawn as a single or series
 * of triangle strips. The primary use of CCRibbon is as the drawing class of Motion Streak,
 * but it is quite useful on it's own. When manually drawing a ribbon, you can call addPointAt
 * and pass in the parameters for the next location in the ribbon. The system will automatically
 * generate new polygons, texture them accourding to your texture width, etc, etc.
 *
 * CCRibbon data is stored in a CCRibbonSegment class. This class statically allocates enough verticies and
 * texture coordinates for 50 locations (100 verts or 48 triangles). The ribbon class will allocate
 * new segments when they are needed, and reuse old ones if available. The idea is to avoid constantly
 * allocating new memory and prefer a more static method. However, since there is no way to determine
 * the maximum size of some ribbons (motion streaks), a truely static allocation is not possible.
 *
 * @since v0.8.1
 */
@interface CCRibbon : CCNode <CCTextureProtocol>
{
	NSMutableArray*	segments_;
	NSMutableArray*	deletedSegments_;

	CGPoint			lastPoint1_;
	CGPoint			lastPoint2_;
	CGPoint			lastLocation_;
	int					vertCount_;
	float				texVPos_;
	float				curTime_;
	float				fadeTime_;
	float				delta_;
	float				lastWidth_;
	float				lastSign_;
	BOOL				pastFirstPoint_;

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
	GLfloat	verts[50*6];
	GLfloat	coords[50*4];
	GLubyte	colors[50*8];
	float		creationTime[50];
	BOOL		finished;
	uint		end;
	uint		begin;
}
-(id)init;
-(void)reset;
-(void)draw:(float)curTime fadeTime:(float)fadeTime color:(ccColor4B)color;
@end
