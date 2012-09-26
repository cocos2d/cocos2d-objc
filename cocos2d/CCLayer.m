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
 *
 */


#import <stdarg.h>

#import "Platforms/CCGL.h"

#import "CCLayer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "Support/TransformUtils.h"
#import "Support/CGPointExtension.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCEventDispatcher.h"
#import "Platforms/Mac/CCDirectorMac.h"
#endif

// extern
#import "kazmath/GL/matrix.h"

#pragma mark -
#pragma mark Layer

@implementation CCLayer

#pragma mark Layer - Init
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		anchorPoint_ = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		self.ignoreAnchorPointForPosition = YES;

		isTouchEnabled_ = NO;

#ifdef __CC_PLATFORM_IOS
		isAccelerometerEnabled_ = NO;
#elif defined(__CC_PLATFORM_MAC)
		isMouseEnabled_ = NO;
		isKeyboardEnabled_ = NO;
#endif
	}

	return self;
}

#pragma mark Layer - Touch and Accelerometer related

#ifdef __CC_PLATFORM_IOS
-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addStandardDelegate:self priority:0];
}

-(BOOL) isAccelerometerEnabled
{
	return isAccelerometerEnabled_;
}

-(void) setIsAccelerometerEnabled:(BOOL)enabled
{
	if( enabled != isAccelerometerEnabled_ ) {
		isAccelerometerEnabled_ = enabled;
		if( isRunning_ ) {
			if( enabled )
				[[UIAccelerometer sharedAccelerometer] setDelegate:self];
			else
				[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
		}
	}
}

-(BOOL) isTouchEnabled
{
	return isTouchEnabled_;
}

-(void) setIsTouchEnabled:(BOOL)enabled
{
	if( isTouchEnabled_ != enabled ) {
		isTouchEnabled_ = enabled;
		if( isRunning_ ) {
			if( enabled )
				[self registerWithTouchDispatcher];
			else {
				CCDirector *director = [CCDirector sharedDirector];
				[[director touchDispatcher] removeDelegate:self];
			}
		}
	}
}

#elif defined(__CC_PLATFORM_MAC)

#pragma mark CCLayer - Mouse, Keyboard & Touch events

-(NSInteger) mouseDelegatePriority
{
	return 0;
}

-(BOOL) isMouseEnabled
{
	return isMouseEnabled_;
}

-(void) setIsMouseEnabled:(BOOL)enabled
{
	if( isMouseEnabled_ != enabled ) {
		isMouseEnabled_ = enabled;

		if( isRunning_ ) {
			CCDirector *director = [CCDirector sharedDirector];
			if( enabled )
				[[director eventDispatcher] addMouseDelegate:self priority:[self mouseDelegatePriority]];
			else
				[[director eventDispatcher] removeMouseDelegate:self];
		}
	}
}

-(NSInteger) keyboardDelegatePriority
{
	return 0;
}

-(BOOL) isKeyboardEnabled
{
	return isKeyboardEnabled_;
}

-(void) setIsKeyboardEnabled:(BOOL)enabled
{
	if( isKeyboardEnabled_ != enabled ) {
		isKeyboardEnabled_ = enabled;

		if( isRunning_ ) {
			CCDirector *director = [CCDirector sharedDirector];
			if( enabled )
				[[director eventDispatcher] addKeyboardDelegate:self priority:[self keyboardDelegatePriority] ];
			else
				[[director eventDispatcher] removeKeyboardDelegate:self];
		}
	}
}

-(NSInteger) touchDelegatePriority
{
	return 0;
}

-(BOOL) isTouchEnabled
{
	return isTouchEnabled_;
}

-(void) setIsTouchEnabled:(BOOL)enabled
{
	if( isTouchEnabled_ != enabled ) {
		isTouchEnabled_ = enabled;
		if( isRunning_ ) {
			CCDirector *director = [CCDirector sharedDirector];
			if( enabled )
				[[director eventDispatcher] addTouchDelegate:self priority:[self touchDelegatePriority]];
			else
				[[director eventDispatcher] removeTouchDelegate:self];
		}
	}
}


#endif // Mac


#pragma mark Layer - Callbacks
-(void) onEnter
{
#ifdef __CC_PLATFORM_IOS
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (isTouchEnabled_)
		[self registerWithTouchDispatcher];

#elif defined(__CC_PLATFORM_MAC)
	CCDirector *director = [CCDirector sharedDirector];
	CCEventDispatcher *eventDispatcher = [director eventDispatcher];

	if( isMouseEnabled_ )
		[eventDispatcher addMouseDelegate:self priority:[self mouseDelegatePriority]];

	if( isKeyboardEnabled_)
		[eventDispatcher addKeyboardDelegate:self priority:[self keyboardDelegatePriority]];

	if( isTouchEnabled_)
		[eventDispatcher addTouchDelegate:self priority:[self touchDelegatePriority]];

#endif

	// then iterate over all the children
	[super onEnter];
}

// issue #624.
// Can't register mouse, touches here because of #issue #1018, and #1021
-(void) onEnterTransitionDidFinish
{
#ifdef __CC_PLATFORM_IOS
	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif

	[super onEnterTransitionDidFinish];
}


-(void) onExit
{
	CCDirector *director = [CCDirector sharedDirector];

#ifdef __CC_PLATFORM_IOS
	if( isTouchEnabled_ )
		[[director touchDispatcher] removeDelegate:self];

	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];

#elif defined(__CC_PLATFORM_MAC)
	CCEventDispatcher *eventDispatcher = [director eventDispatcher];
	if( isMouseEnabled_ )
		[eventDispatcher removeMouseDelegate:self];

	if( isKeyboardEnabled_ )
		[eventDispatcher removeKeyboardDelegate:self];

	if( isTouchEnabled_ )
		[eventDispatcher removeTouchDelegate:self];

#endif

	[super onExit];
}

#ifdef __CC_PLATFORM_IOS
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(NO, @"Layer#ccTouchBegan override me");
	return YES;
}
#endif
@end

#pragma mark -
#pragma mark LayerColor

@interface CCLayerColor (Private)
-(void) updateColor;
@end

@implementation CCLayerColor

// Opacity and RGB color protocol
@synthesize opacity = opacity_, color = color_;
@synthesize blendFunc = blendFunc_;


+ (id) layerWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	return [[[self alloc] initWithColor:color width:w height:h] autorelease];
}

+ (id) layerWithColor:(ccColor4B)color
{
	return [[(CCLayerColor*)[self alloc] initWithColor:color] autorelease];
}

-(id) init
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [self initWithColor:ccc4(0,0,0,0) width:s.width height:s.height];
}

// Designated initializer
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	if( (self=[super init]) ) {

		// default blend function
		blendFunc_ = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };

		color_.r = color.r;
		color_.g = color.g;
		color_.b = color.b;
		opacity_ = color.a;

		for (NSUInteger i = 0; i<sizeof(squareVertices_) / sizeof( squareVertices_[0]); i++ ) {
			squareVertices_[i].x = 0.0f;
			squareVertices_[i].y = 0.0f;
		}

		[self updateColor];
		[self setContentSize:CGSizeMake(w, h) ];

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
	}
	return self;
}

- (id) initWithColor:(ccColor4B)color
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [self initWithColor:color width:s.width height:s.height];
}

// override contentSize
-(void) setContentSize: (CGSize) size
{
	squareVertices_[1].x = size.width;
	squareVertices_[2].y = size.height;
	squareVertices_[3].x = size.width;
	squareVertices_[3].y = size.height;

	[super setContentSize:size];
}

- (void) changeWidth: (GLfloat) w height:(GLfloat) h
{
	[self setContentSize:CGSizeMake(w, h)];
}

-(void) changeWidth: (GLfloat) w
{
	[self setContentSize:CGSizeMake(w, contentSize_.height)];
}

-(void) changeHeight: (GLfloat) h
{
	[self setContentSize:CGSizeMake(contentSize_.width, h)];
}

- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		squareColors_[i].r = color_.r / 255.0f;
		squareColors_[i].g = color_.g / 255.0f;
		squareColors_[i].b = color_.b / 255.0f;
		squareColors_[i].a = opacity_ / 255.0f;
	}
}

- (void) draw
{
	CC_NODE_DRAW_SETUP();

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );

	//
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, squareColors_);

	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}

#pragma mark Protocols
// Color Protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	[self updateColor];
}

-(void) setOpacity: (GLubyte) o
{
	opacity_ = o;
	[self updateColor];
}
@end


#pragma mark -
#pragma mark LayerGradient

@implementation CCLayerGradient

@synthesize startOpacity = startOpacity_;
@synthesize endColor = endColor_, endOpacity = endOpacity_;
@synthesize vector = vector_;

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end
{
    return [[[self alloc] initWithColor:start fadingTo:end] autorelease];
}

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v
{
    return [[[self alloc] initWithColor:start fadingTo:end alongVector:v] autorelease];
}

- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v
{
	endColor_.r = end.r;
	endColor_.g = end.g;
	endColor_.b = end.b;

	endOpacity_		= end.a;
	startOpacity_	= start.a;
	vector_ = v;

	start.a	= 255;
	compressedInterpolation_ = YES;

	return [super initWithColor:start];
}

- (void) updateColor
{
    [super updateColor];

	float h = ccpLength(vector_);
    if (h == 0)
		return;

	float c = sqrtf(2);
    CGPoint u = ccp(vector_.x / h, vector_.y / h);

	// Compressed Interpolation mode
	if( compressedInterpolation_ ) {
		float h2 = 1 / ( fabsf(u.x) + fabsf(u.y) );
		u = ccpMult(u, h2 * (float)c);
	}

	float opacityf = (float)opacity_/255.0f;

    ccColor4F S = {
		color_.r / 255.0f,
		color_.g / 255.0f,
		color_.b / 255.0f,
		startOpacity_*opacityf / 255.0f,
	};

    ccColor4F E = {
		endColor_.r / 255.0f,
		endColor_.g / 255.0f,
		endColor_.b / 255.0f,
		endOpacity_*opacityf / 255.0f,
	};


    // (-1, -1)
	squareColors_[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
	squareColors_[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
	// (-1, 1)
	squareColors_[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
	// (1, 1)
	squareColors_[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
}

-(ccColor3B) startColor
{
	return color_;
}

-(void) setStartColor:(ccColor3B)colors
{
	[self setColor:colors];
}

-(void) setEndColor:(ccColor3B)colors
{
    endColor_ = colors;
    [self updateColor];
}

-(void) setStartOpacity: (GLubyte) o
{
	startOpacity_ = o;
    [self updateColor];
}

-(void) setEndOpacity: (GLubyte) o
{
    endOpacity_ = o;
    [self updateColor];
}

-(void) setVector: (CGPoint) v
{
    vector_ = v;
    [self updateColor];
}

-(BOOL) compressedInterpolation
{
	return compressedInterpolation_;
}

-(void) setCompressedInterpolation:(BOOL)compress
{
	compressedInterpolation_ = compress;
	[self updateColor];
}
@end

#pragma mark -
#pragma mark MultiplexLayer

@implementation CCLayerMultiplex
+(id) layerWithLayers: (CCLayer*) layer, ...
{
	va_list args;
	va_start(args,layer);

	id s = [[[self alloc] initWithLayers: layer vaList:args] autorelease];

	va_end(args);
	return s;
}

-(id) initWithLayers: (CCLayer*) layer vaList:(va_list) params
{
	if( (self=[super init]) ) {

		layers_ = [[NSMutableArray arrayWithCapacity:5] retain];

		[layers_ addObject: layer];

		CCLayer *l = va_arg(params,CCLayer*);
		while( l ) {
			[layers_ addObject: l];
			l = va_arg(params,CCLayer*);
		}

		enabledLayer_ = 0;
		[self addChild: [layers_ objectAtIndex: enabledLayer_]];
	}

	return self;
}

-(void) dealloc
{
	[layers_ release];
	[super dealloc];
}

-(void) switchTo: (unsigned int) n
{
	NSAssert( n < [layers_ count], @"Invalid index in MultiplexLayer switchTo message" );

	[self removeChild: [layers_ objectAtIndex:enabledLayer_] cleanup:YES];

	enabledLayer_ = n;

	[self addChild: [layers_ objectAtIndex:n]];
}

-(void) switchToAndReleaseMe: (unsigned int) n
{
	NSAssert( n < [layers_ count], @"Invalid index in MultiplexLayer switchTo message" );

	[self removeChild: [layers_ objectAtIndex:enabledLayer_] cleanup:YES];

	[layers_ replaceObjectAtIndex:enabledLayer_ withObject:[NSNull null]];

	enabledLayer_ = n;

	[self addChild: [layers_ objectAtIndex:n]];
}
@end
