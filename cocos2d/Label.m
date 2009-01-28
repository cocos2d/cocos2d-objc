/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Label.h"

@implementation Label

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"LabelInit"
								reason:@"Use initWithString:dimensions:aligment:fontName:font instead"
								userInfo:nil];
	@throw myException;
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size]autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string fontName:name fontSize:size]autorelease];
}


- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
{
	if( ! (self=[super init]) )
		return nil;

	_dimensions = dimensions;
	_alignment = alignment;
	_fontName = [name retain];
	_fontSize = size;
	
	[self setString:string];
	return self;
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
{
	if( ! (self=[super init]) )
		return nil;
	
	_dimensions = CGSizeZero;
	_fontName = [name retain];
	_fontSize = size;
	
	[self setString:string];
	return self;
}

- (void) setString:(NSString*)string
{
	if (texture)
		[texture release];

	if( CGSizeEqualToSize( _dimensions, CGSizeZero ) )
		texture = [[Texture2D alloc] initWithString:string fontName:_fontName fontSize:_fontSize];
	else
		texture = [[Texture2D alloc] initWithString:string dimensions:_dimensions alignment:_alignment fontName:_fontName fontSize:_fontSize];
	CGSize s = texture.contentSize;
	transformAnchor = cpv( s.width/2, s.height/2);
}

- (void) dealloc
{
	[_fontName release];
	[texture release];
	[super dealloc];
}
@end
