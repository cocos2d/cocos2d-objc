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

		dimensions_ = dimensions;
		alignment_ = alignment;
		fontName_ = [name retain];
		fontSize_ = size;
		
		[self setString:string];
	}
	return self;
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {
		
		dimensions_ = CGSizeZero;
		fontName_ = [name retain];
		fontSize_ = size;
		
		[self setString:string];
	}
	return self;
}

- (void) setString:(NSString*)string
{
	CCTexture2D *tex;
	if( CGSizeEqualToSize( dimensions_, CGSizeZero ) )
		tex = [[CCTexture2D alloc] initWithString:string fontName:fontName_ fontSize:fontSize_];
	else
		tex = [[CCTexture2D alloc] initWithString:string dimensions:dimensions_ alignment:alignment_ fontName:fontName_ fontSize:fontSize_];


	[self setTexture:tex];
	[tex release];

	CGSize size = [texture_ contentSize];
	[self setTextureRect: CGRectMake(0, 0, size.width, size.height)];
}

- (void) dealloc
{
	[fontName_ release];
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | FontName = %@, FontSize = %.1f>", [self class], self, fontName_, fontSize_];
}
@end
