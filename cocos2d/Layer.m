/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

@implementation Layer

@synthesize isTouchEnabled, isAccelerometerEnabled;

-(id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	CGSize s = [[Director sharedDirector] winSize];
	relativeTransformAnchor = NO;

	transformAnchor.x = s.width / 2;
	transformAnchor.y = s.height / 2;
	
	isTouchEnabled = NO;
	isAccelerometerEnabled = NO;
	
	return self;
}

-(void) onEnter
{

	// register 'parent' nodes first
	// since events are propagated in reverse order
	if( isTouchEnabled )
		[[Director sharedDirector] addEventHandler:self];

	// the iterate over all the children
	[super onEnter];

	if( isAccelerometerEnabled )
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void) onExit
{
	if( isTouchEnabled )
		[[Director sharedDirector] removeEventHandler:self];

	if( isAccelerometerEnabled )
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
	[super onExit];
}
@end

@implementation ColorLayer

@synthesize color;

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"ColorLayerInit"
								reason:@"Use ColorLayer initWithColor instead"
								userInfo:nil];
	@throw myException;	
}

+ (id) layerWithColor: (GLuint) aColor width:(GLfloat)w  height:(GLfloat) h
{
	return [[[self alloc] initWithColor: aColor width:w height:h] autorelease];
}

+ (id) layerWithColor: (GLuint) aColor
{
	return [[[self alloc] initWithColor: aColor] autorelease];
}

- (id) initWithColor: (GLuint) aColor width:(GLint)w  height:(GLint) h
{
	if( ! (self=[super init]) )
		return nil;

	[self changeColor: aColor];
	[self initWidth:w height:h];
	return self;
}

- (id) initWithColor: (GLuint) aColor
{
	CGSize s = [[Director sharedDirector] winSize];
	
	return [self initWithColor: aColor width:s.width height:s.height];
}

-(void) changeWidth: (GLfloat) w
{
	squareVertices[2] = w;
	squareVertices[6] = w;
}

-(void) changeHeight: (GLfloat) h
{
	squareVertices[5] = h;
	squareVertices[7] = h;
}


- (void) changeColor: (GLuint) aColor
{
	GLubyte r, g, b, a;
	
	color = aColor;
	
	r = (color>>24) & 0xff;
	g = (color>>16) & 0xff;
	b = (color>>8) & 0xff;
	a = (color) & 0xff;

	for( NSUInteger i=0; i < sizeof(squareColors) / sizeof(squareColors[0]);i++ )
	{
		if( i % 4 == 0 )
			squareColors[i] = r;
		else if( i % 4 == 1)
			squareColors[i] = g;
		else if( i % 4 ==2  )
			squareColors[i] = b;
		else
			squareColors[i] = a;
	}
}

-(void) setOpacity: (GLubyte) o
{
	GLuint c = (color & 0xffffff00) | o;
	[self changeColor:c];
}

-(GLubyte) opacity
{
	return (color & 0xff);
}

- (void) initWidth: (GLfloat) w height:(GLfloat) h
{
	for (NSUInteger i=0; i<sizeof(squareVertices) / sizeof( squareVertices[0]); i++ )
		squareVertices[i] = 0.0f;
	
	squareVertices[2] = w;
	squareVertices[5] = h;
	squareVertices[6] = w;
	squareVertices[7] = h;
	
}

- (void)draw
{		
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}
@end

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
	if( ! (self=[super init]) )
		return nil;
	
	layers = [[NSMutableArray array] retain];
	
	[layers addObject: layer];
	
	Layer *l = va_arg(params,Layer*);
	while( l ) {
		[layers addObject: l];
		l = va_arg(params,Layer*);
	}
	
	enabledLayer = 0;
	[self addChild: [layers objectAtIndex: enabledLayer]];		
	
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
