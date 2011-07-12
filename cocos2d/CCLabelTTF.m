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


#import <Availability.h>

#import "CCLabelTTF.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCDirectorIOS.h"
#endif

@implementation CCLabelTTF

- (id) init
{
	NSAssert(NO, @"CCLabelTTF: Init not supported. Use initWithString");
	[self release];
	return nil;
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size;
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment lineBreakMode:lineBreakMode fontName:name fontSize:size]autorelease];
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size]autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string fontName:name fontSize:size]autorelease];
}


- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {

		dimensions_ = CGSizeMake( dimensions.width * CC_CONTENT_SCALE_FACTOR(), dimensions.height * CC_CONTENT_SCALE_FACTOR() );
		alignment_ = alignment;
		fontName_ = [name retain];
		fontSize_ = size * CC_CONTENT_SCALE_FACTOR();
		lineBreakMode_ = lineBreakMode;
		
		[self setString:str];
	}
	return self;
}

- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:str dimensions:dimensions alignment:alignment lineBreakMode:CCLineBreakModeWordWrap fontName:name fontSize:size];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {
		
		dimensions_ = CGSizeZero;
		fontName_ = [name retain];
		fontSize_ = size * CC_CONTENT_SCALE_FACTOR();
		
		[self setString:str];
	}
	return self;
}

- (void) setString:(NSString*)str
{
	[string_ release];
	string_ = [str copy];

	CCTexture2D *tex;
	if( CGSizeEqualToSize( dimensions_, CGSizeZero ) )
		tex = [[CCTexture2D alloc] initWithString:str
										 fontName:fontName_
										 fontSize:fontSize_];
	else
		tex = [[CCTexture2D alloc] initWithString:str
									   dimensions:dimensions_
										alignment:alignment_
									lineBreakMode:lineBreakMode_
										 fontName:fontName_
										 fontSize:fontSize_];

	[self setTexture:tex];
	[tex release];

	CGRect rect = CGRectZero;
	rect.size = [texture_ contentSize];
	[self setTextureRect: rect];
}

-(NSString*) string
{
	return string_;
}

- (void) dealloc
{
	[string_ release];
	[fontName_ release];
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Label = %@, FontName = %@, FontSize = %.1f>", [self class], self, string_, fontName_, fontSize_];
}
@end
