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

+(id) itemFromString: (NSString*) value receiver:(id) r selector:(SEL) s
{
	return [[[self alloc] initFromString: value receiver:r selector:s] autorelease];
}

-(id) initFromString: (NSString*) value receiver:(id) rec selector:(SEL) cb
{
	if(! [super init])
		return nil;

	NSMethodSignature * sig = nil;
	sig = [[rec class] instanceMethodSignatureForSelector:cb];
	
	invocation = nil;
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:rec];
	[invocation setSelector:cb];
	[invocation retain];
	
	label = [Label labelWithString:value dimensions:CGSizeMake((_fontSize+2)*[value length], (_fontSize+2)) alignment:UITextAlignmentCenter fontName:_fontName fontSize:_fontSize];

	CGSize s = [[label texture] contentSize];
	transformAnchor = cpv( s.width/2, s.height/2 );
	
	[label retain];

	return self;
}

-(void) dealloc
{
	[invocation release];
	[label release];
	[super dealloc];
}

-(CGRect) rect
{
	CGSize s = [[label texture] contentSize];
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(void) selected
{
	[self stop];
	[self do: [ScaleTo actionWithDuration:0.1 scale:1.2]];
}

-(void) unselected
{
	[self stop];
	[self do: [ScaleTo actionWithDuration:0.1 scale:1.0]];

}

-(void) activate
{
	[invocation invoke];
}

-(unsigned int) height
{
	return [[label texture] contentSize].height;
}
-(void) draw
{
	[label draw];
}
@end


