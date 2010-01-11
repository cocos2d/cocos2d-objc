/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCLabel.h"
#import "Support/CGPointExtension.h"

@implementation CCLabel

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


- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {

		_dimensions = dimensions;
		_alignment = alignment;
		_fontName = [name retain];
		_fontSize = size;
		
		[self setString:string];
	}
	return self;
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {
		
		_dimensions = CGSizeZero;
		_fontName = [name retain];
		_fontSize = size;
		
		[self setString:string];
	}
	return self;
}

- (void) setString:(NSString*)string
{
	if( CGSizeEqualToSize( _dimensions, CGSizeZero ) )
		// WARNING: double retain
		self.texture = [[CCTexture2D alloc] initWithString:string fontName:_fontName fontSize:_fontSize];
	else
		// WARNING: double retain
		self.texture = [[CCTexture2D alloc] initWithString:string dimensions:_dimensions alignment:_alignment fontName:_fontName fontSize:_fontSize];
	
	// end of warning. 1 retain only
	[self.texture release];
}

- (void) dealloc
{
	[_fontName release];
	[super dealloc];
}
@end
