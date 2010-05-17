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



#import <OpenGLES/ES1/gl.h>
#import <stdarg.h>

#import "CCLayer.h"
#import "CCDirector.h"
#import "CCTouchDispatcher.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

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

		isTouchEnabled = NO;
		isAccelerometerEnabled = NO;
	}
	
	return self;
}

#pragma mark Layer - Touch and Accelerometer related

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
}

-(BOOL) isAccelerometerEnabled
{
	return isAccelerometerEnabled;
}

-(void) setIsAccelerometerEnabled:(BOOL)enabled
{
	if( enabled != isAccelerometerEnabled ) {
		isAccelerometerEnabled = enabled;
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
	return isTouchEnabled;
}

-(void) setIsTouchEnabled:(BOOL)enabled
{
	if( isTouchEnabled != enabled ) {
		isTouchEnabled = enabled;
		if( isRunning_ ) {
			if( enabled )
				[self registerWithTouchDispatcher];
			else
				[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		}
	}
}

#pragma mark Layer - Callbacks
-(void) onEnter
{
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (isTouchEnabled)
		[self registerWithTouchDispatcher];
	
	// then iterate over all the children
	[super onEnter];

	if( isAccelerometerEnabled )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void) onExit
{
	if( isTouchEnabled )
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	if( isAccelerometerEnabled )
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
	[super onExit];
}
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(NO, @"Layer#ccTouchBegan override me");
	return YES;
}
@end

#pragma mark -
#pragma mark ColorLayer

@interface CCColorLayer (Private)
-(void) updateColor;
@end

@implementation CCColorLayer

// Opacity and RGB color protocol
@synthesize opacity=opacity_, color=color_;
@synthesize blendFunc=blendFunc_;


+ (id) layerWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	return [[[self alloc] initWithColor:color width:w height:h] autorelease];
}

+ (id) layerWithColor:(ccColor4B)color
{
	return [[[self alloc] initWithColor:color] autorelease];
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
		
		for (NSUInteger i=0; i<sizeof(squareVertices) / sizeof( squareVertices[0]); i++ )
			squareVertices[i] = 0.0f;
				
		[self updateColor];
		[self setContentSize:CGSizeMake(w,h)];
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
	squareVertices[2] = size.width;
	squareVertices[5] = size.height;
	squareVertices[6] = size.width;
	squareVertices[7] = size.height;
	
	[super setContentSize:size];
}

- (void) changeWidth: (GLfloat) w height:(GLfloat) h
{
	[self setContentSize:CGSizeMake(w,h)];
}

-(void) changeWidth: (GLfloat) w
{
	[self setContentSize:CGSizeMake(w,contentSize_.height)];
}

-(void) changeHeight: (GLfloat) h
{
	[self setContentSize:CGSizeMake(contentSize_.width,h)];
}

- (void) updateColor
{
	for( NSUInteger i=0; i < sizeof(squareColors) / sizeof(squareColors[0]);i++ )
	{
		if( i % 4 == 0 )
			squareColors[i] = color_.r;
		else if( i % 4 == 1)
			squareColors[i] = color_.g;
		else if( i % 4 ==2  )
			squareColors[i] = color_.b;
		else
			squareColors[i] = opacity_;
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
	
	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc(blendFunc_.src, blendFunc_.dst);
	}
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
