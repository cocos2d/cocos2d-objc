//
//  Label.m
//  cocos2d
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Label.h"

@implementation Label
// Sets up an array of values to use as the sprite vertices.

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

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*) font
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment font:font] autorelease];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
{
	if (![super init])
		return nil;

	texture = [[Texture2D alloc] initWithString:string dimensions:dimensions alignment:alignment fontName:name fontSize:size];
	
	[self initAnchors];
	return self;
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*) font
{
	if (![super init])
		return nil;
	
	texture = [[Texture2D alloc] initWithString:string dimensions:dimensions alignment:alignment font:font];
	
	[self initAnchors];
	return self;
}

- (void) dealloc
{
	NSLog( @"deallocing %@", self);
	[texture release];
	[super dealloc];
}

- (void) initAnchors
{
//	CGSize size = [texture contentSize];
//	transform_anchor_x = size.width  / 2;
//	transform_anchor_y = size.height / 2;
}

- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D);

	[texture drawAtPoint: CGPointZero];

	glDisable( GL_TEXTURE_2D);

	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

@end
