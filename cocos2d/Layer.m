/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <OpenGLES/ES1/gl.h>
#import <stdarg.h>

#import "Layer.h"
#import "Director.h"
#import "TouchDispatcher.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark Layer

@implementation Layer

#pragma mark Layer - Init
-(id) init
{
	if( (self=[super init]) ) {
	
		CGSize s = [[Director sharedDirector] winSize];
		anchorPoint_ = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		self.relativeAnchorPoint = NO;

		isTouchEnabled = NO;
		isAccelerometerEnabled = NO;
	}
	
	return self;
}

#pragma mark Layer - Touch and Accelerometer related

-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
}

-(BOOL) isAccelerometerEnabled
{
	return isAccelerometerEnabled;
}

-(void) setIsAccelerometerEnabled:(BOOL)enabled
{
	if( enabled != isAccelerometerEnabled ) {
		isAccelerometerEnabled = enabled;
		if( isRunning ) {
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
		if( isRunning ) {
			if( enabled )
				[self registerWithTouchDispatcher];
			else
				[[TouchDispatcher sharedDispatcher] removeDelegate:self];
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
		[[TouchDispatcher sharedDispatcher] removeDelegate:self];
	
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

@interface ColorLayer (Private)
-(void) updateColor;
@end

@implementation ColorLayer

// Opacity and RGB color protocol
@synthesize opacity=opacity_, color=color_;


- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"ColorLayerInit"
								reason:@"Use ColorLayer initWithColor instead"
								userInfo:nil];
	@throw myException;	
}

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
	CGSize s = [[Director sharedDirector] winSize];
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
	CGSize s = self.contentSize;
	[self setContentSize:CGSizeMake(w,s.height)];
}

-(void) changeHeight: (GLfloat) h
{
	CGSize s = self.contentSize;
	[self setContentSize:CGSizeMake(s.width,h)];
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
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	if( opacity_ != 255 )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	if( opacity_ != 255 )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}

#pragma mark Protocols
// Color Protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	[self updateColor];
}
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}

-(void) setOpacity: (GLubyte) o
{
	opacity_ = o;
	[self updateColor];
}
@end

#pragma mark -
#pragma mark MultiplexLayer

@implementation MultiplexLayer
+(id) layerWithLayers: (Layer*) layer, ... 
{
	va_list args;
	va_start(args,layer);
	
	id s = [[[self alloc] initWithLayers: layer vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithLayers: (Layer*) layer vaList:(va_list) params
{
	if( (self=[super init]) ) {
	
		layers = [[NSMutableArray array] retain];
		
		[layers addObject: layer];
		
		Layer *l = va_arg(params,Layer*);
		while( l ) {
			[layers addObject: l];
			l = va_arg(params,Layer*);
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
	if( n >= [layers count] ) {
		NSException* myException = [NSException
									exceptionWithName:@"MultiplexLayerInvalidIndex"
									reason:@"Invalid index in MultiplexLayer switchTo message"
									userInfo:nil];
		@throw myException;		
	}
		
	[self removeChild: [layers objectAtIndex:enabledLayer] cleanup:NO];
	
	enabledLayer = n;
	
	[self addChild: [layers objectAtIndex:n]];		
}

-(void) switchToAndReleaseMe: (unsigned int) n
{
	if( n >= [layers count] ) {
		NSException* myException = [NSException
									exceptionWithName:@"MultiplexLayerInvalidIndex"
									reason:@"Invalid index in MultiplexLayer switchTo message"
									userInfo:nil];
		@throw myException;		
	}
	
	[self removeChild: [layers objectAtIndex:enabledLayer] cleanup:NO];
	
	[layers replaceObjectAtIndex:enabledLayer withObject:[NSNull null]];
	
	enabledLayer = n;
	
	[self addChild: [layers objectAtIndex:n]];		
}

@end
