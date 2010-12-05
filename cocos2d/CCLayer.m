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
 *
 */


#import <stdarg.h>

#import "Platforms/CCGL.h"

#import "CCLayer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/CCEventDispatcher.h"
#endif

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
		self.isRelativeAnchorPoint = NO;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		isTouchEnabled_ = NO;
		isAccelerometerEnabled_ = NO;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		isMouseEnabled_ = NO;
		isKeyboardEnabled_ = NO;
#endif
	}
	
	return self;
}

#pragma mark Layer - Touch and Accelerometer related

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
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
			else
				[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		}
	}
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark CCLayer - Mouse & Keyboard events

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
			if( enabled )
				[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:[self mouseDelegatePriority]];
			else
				[[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
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
			if( enabled )
				[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority:[self keyboardDelegatePriority] ];
			else
				[[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
		}
	}
}


#endif // Mac


#pragma mark Layer - Callbacks
-(void) onEnter
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (isTouchEnabled_)
		[self registerWithTouchDispatcher];

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	if( isMouseEnabled_ )
		[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:[self mouseDelegatePriority]];
	
	if( isKeyboardEnabled_)
		[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority:[self keyboardDelegatePriority]];
#endif
	
	// then iterate over all the children
	[super onEnter];
}

// issue #624.
// Can't register mouse, touches here because of #issue #1018, and #1021
-(void) onEnterTransitionDidFinish
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif
	
	[super onEnterTransitionDidFinish];
}


-(void) onExit
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if( isTouchEnabled_ )
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	if( isAccelerometerEnabled_ )
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	if( isMouseEnabled_ )
		[[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
	
	if( isKeyboardEnabled_ )
		[[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
#endif
	
	[super onExit];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
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

- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	if( (self=[super init]) ) {
		
		// default blend function
		blendFunc_ = (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST };

		color_.r = color.r;
		color_.g = color.g;
		color_.b = color.b;
		opacity_ = color.a;
		
		for (NSUInteger i = 0; i<sizeof(squareVertices) / sizeof( squareVertices[0]); i++ )
			squareVertices[i] = 0.0f;
				
		[self updateColor];
		[self setContentSize:CGSizeMake(w, h) ];
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
	squareVertices[2] = size.width * CC_CONTENT_SCALE_FACTOR();
	squareVertices[5] = size.height * CC_CONTENT_SCALE_FACTOR();
	squareVertices[6] = size.width * CC_CONTENT_SCALE_FACTOR();
	squareVertices[7] = size.height * CC_CONTENT_SCALE_FACTOR();
	
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
		squareColors[i*4]	= color_.r;
		squareColors[i*4+1] = color_.g;
		squareColors[i*4+2] = color_.b;
		squareColors[i*4+3] = opacity_;
	}
}

- (void)draw
{		
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, GL_COLOR_ARRAY
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	
	
	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	else if( opacity_ != 255 ) {
		newBlend = YES;
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
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

// XXX Deprecated
@implementation CCColorLayer
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
    return [self initWithColor:start];
}

- (void) updateColor
{
    [super updateColor];

	float h = sqrtf(vector_.x*vector_.x + vector_.y*vector_.y);
    if (h == 0)
		return;

    double c = sqrt(2);
    CGPoint u = ccp(vector_.x / h, vector_.y / h);

	float opacityf = (float)opacity_/255.0f;
	
    ccColor4B S = {
		color_.r,
		color_.g,
		color_.b,
		startOpacity_*opacityf
	};

    ccColor4B E = {
		endColor_.r,
		endColor_.g,
		endColor_.b,
		endOpacity_*opacityf
	};

    // (-1, -1)
	squareColors[0]  = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
	squareColors[1]  = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
	squareColors[2]  = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
	squareColors[3]  = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
	squareColors[4]  = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
	squareColors[5]  = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
	squareColors[6]  = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
	squareColors[7]  = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
	// (-1, 1)
	squareColors[8]  = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
	squareColors[9]  = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
	squareColors[10] = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
	squareColors[11] = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
	// (1, 1)
	squareColors[12] = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
	squareColors[13] = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
	squareColors[14] = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
	squareColors[15] = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
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

@end

#pragma mark -
#pragma mark MultiplexLayer

@implementation CCMultiplexLayer
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
	
		layers = [[NSMutableArray arrayWithCapacity:5] retain];
		
		[layers addObject: layer];
		
		CCLayer *l = va_arg(params,CCLayer*);
		while( l ) {
			[layers addObject: l];
			l = va_arg(params,CCLayer*);
		}
		
		enabledLayer = 0;
		[self addChild: [layers objectAtIndex: enabledLayer]];	
	}
	
	return self;
}

-(void) dealloc
{
	[layers release];
	[super dealloc];
}

-(void) switchTo: (unsigned int) n
{
	NSAssert( n < [layers count], @"Invalid index in MultiplexLayer switchTo message" );
		
	[self removeChild: [layers objectAtIndex:enabledLayer] cleanup:YES];
	
	enabledLayer = n;
	
	[self addChild: [layers objectAtIndex:n]];		
}

-(void) switchToAndReleaseMe: (unsigned int) n
{
	NSAssert( n < [layers count], @"Invalid index in MultiplexLayer switchTo message" );
	
	[self removeChild: [layers objectAtIndex:enabledLayer] cleanup:YES];
	
	[layers replaceObjectAtIndex:enabledLayer withObject:[NSNull null]];
	
	enabledLayer = n;
	
	[self addChild: [layers objectAtIndex:n]];		
}

@end
