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


- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {

		dimensions_ = dimensions;
		alignment_ = alignment;
		fontName_ = [name retain];
		fontSize_ = size;
		
		[self setString:str];
	}
	return self;
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) ) {
		
		dimensions_ = CGSizeZero;
		fontName_ = [name retain];
		fontSize_ = size;
		
		[self setString:str];
	}
	return self;
}

- (void) setString:(NSString*)str
{
	CCTexture2D *tex;
	if( CGSizeEqualToSize( dimensions_, CGSizeZero ) )
		tex = [[CCTexture2D alloc] initWithString:str fontName:fontName_ fontSize:fontSize_];
	else
		tex = [[CCTexture2D alloc] initWithString:str dimensions:dimensions_ alignment:alignment_ fontName:fontName_ fontSize:fontSize_];


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
