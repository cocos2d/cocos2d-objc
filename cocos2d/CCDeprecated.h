/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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


#import "ccTypes.h"

#import "CCColor.h"
#import "CCNode.h"
#import "CCTexture.h"
#import "CCAction.h"


/** RGB color composed of bytes 3 bytes
 */
typedef struct __attribute__((deprecated)) _ccColor3B
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
} ccColor3B __attribute__((deprecated));

//! helper macro that creates an ccColor3B type
__attribute__((deprecated)) static inline ccColor3B
ccc3(const uint8_t r, const uint8_t g, const uint8_t b)
{
	ccColor3B c = {r, g, b};
	return c;
}

	//ccColor3B predefined colors
//! White color (255,255,255)
__attribute__((deprecated)) static const ccColor3B ccWHITE = {255,255,255};
//! Yellow color (255,255,0)
__attribute__((deprecated)) static const ccColor3B ccYELLOW = {255,255,0};
//! Blue color (0,0,255)
__attribute__((deprecated)) static const ccColor3B ccBLUE = {0,0,255};
//! Green Color (0,255,0)
__attribute__((deprecated)) static const ccColor3B ccGREEN = {0,255,0};
//! Red Color (255,0,0,)
__attribute__((deprecated)) static const ccColor3B ccRED = {255,0,0};
//! Magenta Color (255,0,255)
__attribute__((deprecated)) static const ccColor3B ccMAGENTA = {255,0,255};
//! Black Color (0,0,0)
__attribute__((deprecated)) static const ccColor3B ccBLACK = {0,0,0};
//! Orange Color (255,127,0)
__attribute__((deprecated)) static const ccColor3B ccORANGE = {255,127,0};
//! Gray Color (166,166,166)
__attribute__((deprecated)) static const ccColor3B ccGRAY = {166,166,166};

/** RGBA color composed of 4 bytes
*/
typedef struct __attribute__((deprecated)) _ccColor4B
{
	uint8_t	r;
	uint8_t	g;
	uint8_t	b;
	uint8_t a;
} ccColor4B __attribute__((deprecated));

//! helper macro that creates an ccColor4B type
__attribute__((deprecated)) static inline ccColor4B
ccc4(const uint8_t r, const uint8_t g, const uint8_t b, const uint8_t o)
{
	ccColor4B c = {r, g, b, o};
	return c;
}

/** returns YES if both ccColor4F are equal. Otherwise it returns NO.
 */
__attribute__((deprecated)) static inline BOOL ccc4BEqual(ccColor4B a, ccColor4B b)
{
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}

/** RGBA color composed of 4 floats
*/
typedef struct __attribute__((deprecated)) _ccColor4F {
	float r;
	float g;
	float b;
	float a;
} ccColor4F __attribute__((deprecated));

//! helper that creates a ccColor4f type
__attribute__((deprecated)) static inline ccColor4F ccc4f(const float r, const float g, const float b, const float a)
{
	return (ccColor4F){r, g, b, a};
}

/** Returns a ccColor4F from a ccColor3B. Alpha will be 1.
 */
__attribute__((deprecated)) static inline ccColor4F ccc4FFromccc3B(ccColor3B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, 1.f};
}

/** Returns a ccColor4F from a ccColor4B.
 */
__attribute__((deprecated)) static inline ccColor4F ccc4FFromccc4B(ccColor4B c)
{
	return (ccColor4F){c.r/255.f, c.g/255.f, c.b/255.f, c.a/255.f};
}
	
/** returns YES if both ccColor4F are equal. Otherwise it returns NO.
 */
__attribute__((deprecated)) static inline BOOL ccc4FEqual(ccColor4F a, ccColor4F b)
{
	return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
}
	
/**
 * Returns a ccColor4B from a ccColor4F.
 */
__attribute__((deprecated)) static inline ccColor4B ccc4BFromccc4F(ccColor4F c)
{
	return (ccColor4B){
		(uint8_t)(clampf(c.r, 0, 1)*255),
		(uint8_t)(clampf(c.g, 0, 1)*255),
		(uint8_t)(clampf(c.b, 0, 1)*255),
		(uint8_t)(clampf(c.a, 0, 1)*255)
	};
}
	
/**
 * Returns a ccColor3B from a ccColor4F.
 */
__attribute__((deprecated)) static inline ccColor3B ccc3BFromccc4F(ccColor4F c)
{
	return (ccColor3B){
		(uint8_t)(clampf(c.r, 0, 1)*255),
		(uint8_t)(clampf(c.g, 0, 1)*255),
		(uint8_t)(clampf(c.b, 0, 1)*255),
	};
}

/**
 * Returns a ccColor3B from a ccColor4F.
 */
__attribute__((deprecated)) static inline ccColor4F ccc4FInterpolated(ccColor4F start, ccColor4F end, float t)
{
	end.r = start.r + (end.r - start.r ) * t;
	end.g = start.g	+ (end.g - start.g ) * t;
	end.b = start.b + (end.b - start.b ) * t;
	end.a = start.a	+ (end.a - start.a ) * t;
	return  end;
}

/** A vertex composed of 2 GLfloats: x, y
 */
typedef struct __attribute__((deprecated)) _ccVertex2F
{
	float x;
	float y;
} ccVertex2F __attribute__((deprecated));

/** A vertex composed of 2 floats: x, y
 */
typedef struct __attribute__((deprecated)) _ccVertex3F
{
	float x;
	float y;
	float z;
} ccVertex3F __attribute__((deprecated));

/** A texcoord composed of 2 floats: u, y
 */
typedef struct __attribute__((deprecated)) _ccTex2F {
	 float u;
	 float v;
} ccTex2F __attribute__((deprecated));


//! Point Sprite component
typedef struct __attribute__((deprecated)) _ccPointSprite
{
	ccVertex2F	pos;		// 8 bytes
	ccColor4B	color;		// 4 bytes
	float		size;		// 4 bytes
} ccPointSprite __attribute__((deprecated));

//!	A 2D Quad. 4 * 2 floats
typedef struct __attribute__((deprecated)) _ccQuad2 {
	ccVertex2F		tl;
	ccVertex2F		tr;
	ccVertex2F		bl;
	ccVertex2F		br;
} ccQuad2 __attribute__((deprecated));


//!	A 3D Quad. 4 * 3 floats
typedef struct __attribute__((deprecated)) _ccQuad3 {
	ccVertex3F		bl;
	ccVertex3F		br;
	ccVertex3F		tl;
	ccVertex3F		tr;
} ccQuad3 __attribute__((deprecated));

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct __attribute__((deprecated)) _ccV2F_C4B_T2F
{
	//! vertices (2F)
	ccVertex2F		vertices;
	//! colors (4B)
	ccColor4B		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4B_T2F __attribute__((deprecated));

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct __attribute__((deprecated)) _ccV2F_C4F_T2F
{
	//! vertices (2F)
	ccVertex2F		vertices;
	//! colors (4F)
	ccColor4F		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4F_T2F __attribute__((deprecated));

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct __attribute__((deprecated)) _ccV3F_C4F_T2F
{
	//! vertices (3F)
	ccVertex3F		vertices;
	//! colors (4F)
	ccColor4F		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV3F_C4F_T2F __attribute__((deprecated));

//! 4 ccV3F_C4F_T2F
typedef struct __attribute__((deprecated)) _ccV3F_C4F_T2F_Quad
{
	//! top left
	ccV3F_C4F_T2F	tl;
	//! bottom left
	ccV3F_C4F_T2F	bl;
	//! top right
	ccV3F_C4F_T2F	tr;
	//! bottom right
	ccV3F_C4F_T2F	br;
} ccV3F_C4F_T2F_Quad __attribute__((deprecated));

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct __attribute__((deprecated)) _ccV3F_C4B_T2F
{
	//! vertices (3F)
	ccVertex3F		vertices;			// 12 bytes
//	char __padding__[4];

	//! colors (4B)
	ccColor4B		colors;				// 4 bytes
//	char __padding2__[4];

	// tex coords (2F)
	ccTex2F			texCoords;			// 8 byts
} ccV3F_C4B_T2F __attribute__((deprecated));

	
//! A Triangle of ccV2F_C4B_T2F 
typedef struct __attribute__((deprecated)) _ccV2F_C4B_T2F_Triangle
{
	//! Point A
	ccV2F_C4B_T2F a;
	//! Point B
	ccV2F_C4B_T2F b;
	//! Point B
	ccV2F_C4B_T2F c;
} ccV2F_C4B_T2F_Triangle __attribute__((deprecated));
	
//! A Quad of ccV2F_C4B_T2F
typedef struct __attribute__((deprecated)) _ccV2F_C4B_T2F_Quad
{
	//! bottom left
	ccV2F_C4B_T2F	bl;
	//! bottom right
	ccV2F_C4B_T2F	br;
	//! top left
	ccV2F_C4B_T2F	tl;
	//! top right
	ccV2F_C4B_T2F	tr;
} ccV2F_C4B_T2F_Quad __attribute__((deprecated));

//! 4 ccVertex3FTex2FColor4B
typedef struct __attribute__((deprecated)) _ccV3F_C4B_T2F_Quad
{
	//! top left
	ccV3F_C4B_T2F	tl;
	//! bottom left
	ccV3F_C4B_T2F	bl;
	//! top right
	ccV3F_C4B_T2F	tr;
	//! bottom right
	ccV3F_C4B_T2F	br;
} ccV3F_C4B_T2F_Quad __attribute__((deprecated));

//! 4 ccVertex2FTex2FColor4F Quad
typedef struct __attribute__((deprecated)) _ccV2F_C4F_T2F_Quad
{
	//! bottom left
	ccV2F_C4F_T2F	bl;
	//! bottom right
	ccV2F_C4F_T2F	br;
	//! top left
	ccV2F_C4F_T2F	tl;
	//! top right
	ccV2F_C4F_T2F	tr;
} ccV2F_C4F_T2F_Quad __attribute__((deprecated));

//! Blend Function used for textures
typedef struct __attribute__((deprecated)) _ccBlendFunc
{
	//! source blend function
	int src;
	//! destination blend function
	int dst;
} ccBlendFunc __attribute__((deprecated));



@interface CCDirector(Deprecated)

// Use `[CCDirector currentDirector]` instead.
+(CCDirector*)sharedDirector __attribute__((deprecated));

@end


@interface CCColor(Deprecated)

+ (CCColor*)colorWithCcColor3b: (ccColor3B) c __attribute__((deprecated));
+ (CCColor*)colorWithCcColor4b: (ccColor4B) c __attribute__((deprecated));
+ (CCColor*)colorWithCcColor4f: (ccColor4F) c __attribute__((deprecated));

- (CCColor*)initWithCcColor3b: (ccColor3B) c __attribute__((deprecated));
- (CCColor*)initWithCcColor4b: (ccColor4B) c __attribute__((deprecated));
- (CCColor*) initWithCcColor4f: (ccColor4F) c __attribute__((deprecated));

@property (nonatomic, readonly) ccColor3B ccColor3b __attribute__((deprecated));
@property (nonatomic, readonly) ccColor4B ccColor4b __attribute__((deprecated));
@property (nonatomic, readonly) ccColor4F ccColor4f __attribute__((deprecated));

@end


@interface CCNode(Deprecated)

// Use [CCnode stopActionByName:] instead.
-(void)stopActionByTag:(NSInteger) tag;

// Use [CCNode getActionByName:] instead.
-(CCAction*)getActionByTag:(NSInteger) tag;

// Use CCNode.nodeToParentMatrix instead.
- (CGAffineTransform)nodeToParentTransform __attribute__((deprecated));

// Use CCNode.parentToNodeMatrix instead.
- (CGAffineTransform)parentToNodeTransform __attribute__((deprecated));

// Use CCNode.nodeToWorldMatrix instead.
- (CGAffineTransform)nodeToWorldTransform __attribute__((deprecated));

// Use CCNode.worldToNodeMatrix instead.
- (CGAffineTransform)worldToNodeTransform __attribute__((deprecated));

// Use CCNode.active instead
@property(nonatomic, readonly) BOOL isRunningInActiveScene __attribute__((deprecated));

/**
 Use "actions" instead.
 Returns the numbers of actions that are running plus the ones that are scheduled to run (actions in the internal actionsToAdd array).
 @note Composable actions are counted as 1 action. Example:
 - If you are running 2 Sequences each with 7 actions, it will return 2.
 - If you are running 7 Sequences each with 2 actions, it will return 7.
 */
-(NSUInteger) numberOfRunningActions __attribute__((deprecated));


@end


@interface CCTexture(Deprecated)

// Use CCTexture.spriteFrame instead.
-(CCSpriteFrame*)createSpriteFrame __attribute__((deprecated));

// Use CCTexture.sizeInPixels instead.
@property(nonatomic,readonly) NSUInteger pixelWidth __attribute__((deprecated));
// Use CCTexture.sizeInPixels instead.
@property(nonatomic,readonly) NSUInteger pixelHeight __attribute__((deprecated));

// Use CCTexture.contentSize and CCTexture.contentScale instead.
@property(nonatomic,readonly, nonatomic) CGSize contentSizeInPixels __attribute__((deprecated));

// TODO move this back to the regular header?
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha __attribute__((deprecated));

// Set up nearest/linear filtering options when creating your texture instead.
@property(nonatomic,assign,getter=isAntialiased) BOOL antialiased __attribute__((deprecated));

// Use [CCTexture -initWithImage:options:] instead.
- (id)initWithCGImage:(CGImageRef)cgImage contentScale:(CGFloat)contentScale;

@end


enum {
	//! Default tag
	kCCActionTagInvalid = -1,
};


@interface CCAction(Deprecated)

@property (nonatomic, readwrite, assign) NSInteger tag;

@end
