/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "MenuItem.h"
#import "Label.h"
#import "IntervalAction.h"
#import "Sprite.h"

static int _fontSize = kItemSize;
static NSString *_fontName = @"Marker Felt";
static BOOL _fontNameRelease = NO;

@implementation MenuItem

-(id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuItemInit"
								reason:@"Init not supported. Use InitFromString"
								userInfo:nil];
	@throw myException;	
}

+(id) itemWithTarget:(id) r selector:(SEL) s
{
	return [[[self alloc] initWithTarget:r selector:s] autorelease];
}

-(id) initWithTarget:(id) rec selector:(SEL) cb
{
	if(! [super init])
		return nil;
	
	NSMethodSignature * sig = nil;
	sig = [[rec class] instanceMethodSignatureForSelector:cb];
	
	invocation = nil;
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:rec];
	[invocation setSelector:cb];
	[invocation setArgument:&self atIndex:2];
	[invocation retain];
	
	return self;
}

-(void) dealloc
{
	[invocation release];
	[super dealloc];
}

-(void) selected
{
	NSAssert(1,@"MenuItem.selected must be overriden");
}

-(void) unselected
{
	NSAssert(1,@"MenuItem.unselected must be overriden");
}

-(void) activate
{
	[invocation invoke];
}

-(CGRect) rect
{
	NSAssert(1,@"MenuItem.rect must be overriden");
	
	// to make the compiler happy
	CGRect a;
	return a;
}

-(unsigned int) height
{
	NSAssert(1,@"MenuItem.height must be overriden");
	return 0;
}
@end


@implementation MenuItemFont

@synthesize label;

+(void) setFontSize: (int) s
{
	_fontSize = s;
}

+(int) fontSize
{
	return _fontSize;
}

+(void) setFontName: (NSString*) n
{
	if( _fontNameRelease )
		[_fontName release];
	
	_fontName = [n retain];
	_fontNameRelease = YES;
}

+(NSString*) fontName
{
	return _fontName;
}

+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s
{
	return [[[self alloc] initFromString: value target:r selector:s] autorelease];
}

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb
{
	if(! [super initWithTarget:rec selector:cb] )
		return nil;
	
	if( [value length] == 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"MenuItemInvalid"
									reason:@"Can't create a MenuItem without value"
									userInfo:nil];
		@throw myException;		
	}
	
	
	label = [Label labelWithString:value dimensions:CGSizeMake((_fontSize+2)*[value length], (_fontSize+5)) alignment:UITextAlignmentCenter fontName:_fontName fontSize:_fontSize];

	[label retain];	
	
	CGSize s = label.contentSize;
	transformAnchor = cpv( s.width/2, s.height/2 );
	
	return self;
}

-(void) dealloc
{
	[label release];
	[zoomAction release];
	[super dealloc];
}

-(CGRect) rect
{
	CGSize s = label.contentSize;
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(void) activate {
//	[self stopAction: zoomAction];
	[self stopAllActions];
	[zoomAction release];
	zoomAction = nil;

	self.scale = 1.0;

	[super activate];
}

-(void) selected
{
	// subclass to change the default action
	[self stopAction: zoomAction];
	[zoomAction release];
	zoomAction = [[ScaleTo actionWithDuration:0.1 scale:1.2] retain];
	[self do:zoomAction];
}

-(void) unselected
{
	// subclass to change the default action
	[self stopAction: zoomAction];
	[zoomAction release];
	zoomAction = [[ScaleTo actionWithDuration:0.1 scale:1.0] retain];
	[self do:zoomAction];
}

-(unsigned int) height
{
	return [label contentSize].height;
}

-(void) draw
{
	[label draw];
}
@end


@implementation MenuItemImage
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s
{
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 target:t selector:s] autorelease];
}

-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 target:(id) t selector:(SEL) sel
{
	if( ![super initWithTarget:t selector:sel] )
		return nil;

	normalImage = [[Sprite spriteWithFile:value] retain];
	selectedImage = [[Sprite spriteWithFile:value2] retain];
	
	CGSize s = [normalImage contentSize];
	transformAnchor = cpv( s.width/2, s.height/2 );

	return self;
}

-(void) dealloc
{
	[normalImage release];
	[selectedImage release];

	[super dealloc];
}

-(void) selected
{
	selected = YES;
}

-(void) unselected
{
	selected = NO;
}

-(CGRect) rect
{
	CGSize s = [normalImage contentSize];
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(unsigned int) height
{
	return [normalImage contentSize].height;
}

-(void) draw
{
	if( selected )
		[selectedImage draw];
	else
		[normalImage draw];
}
@end



