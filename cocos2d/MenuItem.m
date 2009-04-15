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

#import "MenuItem.h"
#import "Label.h"
#import "LabelAtlas.h"
#import "IntervalAction.h"
#import "Sprite.h"
#import "Support/CGPointExtension.h"

static int _fontSize = kItemSize;
static NSString *_fontName = @"Marker Felt";
static BOOL _fontNameRelease = NO;

enum {
	kCurrentItem = 0xc0c05001,
};

enum {
	kZoomActionTag = 0xc0c05002,
};



#pragma mark -
#pragma mark MenuItem

@implementation MenuItem

@synthesize opacity;

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
	if(!(self=[super init]) )
		return nil;
	
	NSMethodSignature * sig = nil;
	
	if( rec && cb ) {
		sig = [[rec class] instanceMethodSignatureForSelector:cb];
		
		invocation = nil;
		invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setTarget:rec];
		[invocation setSelector:cb];
		[invocation setArgument:&self atIndex:2];
		[invocation retain];
	}
    
	isEnabled = YES;
	opacity = 255;
	
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
	if(isEnabled)
        [invocation invoke];
}

-(void) setIsEnabled: (BOOL)enabled
{
    isEnabled = enabled;
}

-(BOOL) isEnabled
{
    return isEnabled;
}

-(CGRect) rect
{
	NSAssert(1,@"MenuItem.rect must be overriden");

	return CGRectNull;
}

-(CGSize) contentSize
{
	NSAssert(1,@"MenuItem.contentSize must be overriden");
	return CGSizeMake(0,0);
}

@end


#pragma mark  -
#pragma mark MenuItemAtlasFont


@implementation MenuItemAtlasFont

@synthesize label;

+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return [MenuItemAtlasFont itemFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:nil selector:nil];
}

+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	return [[[self alloc] initFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:rec selector:cb] autorelease];
}

-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	if(!(self=[super initWithTarget:rec selector:cb]) )
		return nil;
	
	if( [value length] == 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"MenuItemInvalid"
									reason:@"Can't create a MenuItem without value"
									userInfo:nil];
		@throw myException;
	}
	
	
	label = [[LabelAtlas alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap];
	[label setOpacity:opacity];
	
	CGSize s = label.contentSize;
	transformAnchor = ccp( s.width/2, s.height/2 );
	
	return self;
}

-(void) setString:(NSString *)string
{
    [label setString:string];
	CGSize s = label.contentSize;
    transformAnchor = ccp( s.width/2, s.height/2 );
}

-(void) dealloc
{
	[label release];
	[super dealloc];
}

-(CGRect) rect
{
	CGSize s = label.contentSize;
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(void) activate {
	if(isEnabled) {
		[self stopAllActions];
        
		self.scale = 1.0f;
        
		[super activate];
	}
}

-(void) selected
{
	// subclass to change the default action
	if(isEnabled) {		
		[self stopActionByTag:kZoomActionTag];
		Action *zoomAction = [ScaleTo actionWithDuration:0.1f scale:1.2f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled) {
		[self stopActionByTag:kZoomActionTag];
		Action *zoomAction = [ScaleTo actionWithDuration:0.1f scale:1.0f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	if(enabled == NO)
		[label setRGB:126 :126 :126];
	else
		[label setRGB:255 :255 :255];
    
	[super setIsEnabled:enabled];
}

-(CGSize) contentSize
{
	return [label contentSize];
}

-(void) draw
{
	[label draw];
}

- (void) setOpacity: (GLubyte)newOpacity
{
    opacity = newOpacity;
    [label setOpacity:opacity];
}

@end


#pragma mark -
#pragma mark MenuItemFont

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

+(id) itemFromString: (NSString*) value
{
	return [[[self alloc] initFromString: value target:nil selector:nil] autorelease];
}

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb
{
	if(!(self=[super initWithTarget:rec selector:cb]) )
		return nil;
	
	if( [value length] == 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"MenuItemInvalid"
									reason:@"Can't create a MenuItem without value"
									userInfo:nil];
		@throw myException;
	}
	
	
	label = [Label labelWithString:value fontName:_fontName fontSize:_fontSize];

	[label retain];
	[label setOpacity:opacity];
	
	CGSize s = label.contentSize;
	transformAnchor = ccp( s.width/2, s.height/2 );
	
	return self;
}

-(void) setString:(NSString *)string
{
	[label setString:string];
	CGSize s = label.contentSize;
	transformAnchor = ccp( s.width/2, s.height/2 );
}

-(void) dealloc
{
	[label release];
	[super dealloc];
}

-(CGRect) rect
{
	CGSize s = label.contentSize;
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(void) activate {
	if(isEnabled) {
		[self stopAllActions];
		self.scale = 1.0f;
		[super activate];
	}
}

-(void) selected
{
	// subclass to change the default action
	if(isEnabled) {
		[self stopActionByTag:kZoomActionTag];
		Action *zoomAction = [ScaleTo actionWithDuration:0.1f scale:1.2f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled) {
		[self stopActionByTag:kZoomActionTag];

		Action *zoomAction = [ScaleTo actionWithDuration:0.1f scale:1.0f];
		zoomAction.tag = kZoomActionTag;

		[self runAction:zoomAction];
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	if(enabled == NO)
		[label setRGB:126 :126 :126];
	else
		[label setRGB:255 :255 :255];

	[super setIsEnabled:enabled];
}

-(CGSize) contentSize
{
	return [label contentSize];
}

-(void) draw
{
	[label draw];
}

- (void) setOpacity: (GLubyte)newOpacity
{
  opacity = newOpacity;
  [label setOpacity:opacity];
}

@end

#pragma mark MenuItemImage

@implementation MenuItemImage

@synthesize selectedImage, normalImage, disabledImage;

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage: nil target:nil selector:nil];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage: nil target:t selector:s];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3
{
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:nil selector:nil] autorelease];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3 target:(id) t selector:(SEL) s
{
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:t selector:s] autorelease];
}

-(id) initFromNormalImage: (NSString*) normalI selectedImage:(NSString*)selectedI disabledImage: (NSString*) disabledI target:(id) t selector:(SEL) sel
{
	if( !(self=[super initWithTarget:t selector:sel]) )
		return nil;

	normalImage = [[Sprite spriteWithFile:normalI] retain];
	selectedImage = [[Sprite spriteWithFile:selectedI] retain];
    
	if(disabledI == nil)
		disabledImage = nil;
	else
		disabledImage = [[Sprite spriteWithFile:disabledI] retain];
  
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
	
	CGSize s = [normalImage contentSize];
	transformAnchor = ccp( s.width/2, s.height/2 );

	return self;
}

-(void) dealloc
{
	[normalImage release];
	[selectedImage release];
	[disabledImage release];

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

-(CGSize) contentSize
{
	return [normalImage contentSize];
}

-(void) draw
{
	if(isEnabled) {
		if( selected )
			[selectedImage draw];
		else
			[normalImage draw];

	} else {
		if(disabledImage != nil)
			[disabledImage draw];
		
		// disabled image was not provided
		else
			[normalImage draw];
	}
}

- (void) setOpacity: (GLubyte)newOpacity
{
	opacity = newOpacity;
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
}

@end

#pragma mark MenuItemToggle

//
// MenuItemToggle
//
@implementation MenuItemToggle

@synthesize subItems = subItems_;

+(id) itemWithTarget: (id)t selector: (SEL)sel items: (MenuItem*) item, ...
{
	va_list args;
	va_start(args, item);
	
	id s = [[[self alloc] initWithTarget: t selector:sel items: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithTarget: (id)t selector: (SEL)sel items:(MenuItem*) item vaList: (va_list) args
{
	if( (self=[super initWithTarget:t selector:sel]) ) {
	
		self.subItems = [NSMutableArray arrayWithCapacity:2];
		
		int z = 0;
		MenuItem *i = item;
		while(i) {
			z++;
			[subItems_ addObject:i];
			i = va_arg(args, MenuItem*);
		}

		selectedIndex_ = NSUIntegerMax;
		[self setSelectedIndex:0];
	}
	
	return self;
}

-(void) dealloc
{
	[subItems_ release];
	[super dealloc];
}

-(void)setSelectedIndex:(NSUInteger)index
{
	if( index != selectedIndex_ ) {
		selectedIndex_=index;
		[self removeChildByTag:kCurrentItem cleanup:NO];
		
		MenuItem *item = [subItems_ objectAtIndex:selectedIndex_];
		[self addChild:item z:0 tag:kCurrentItem];
		
		CGSize s = [item contentSize];
		item.position = self.transformAnchor = ccp( s.width/2, s.height/2 );
	}
}

-(NSUInteger) selectedIndex
{
	return selectedIndex_;
}


-(void) selected
{
	[[subItems_ objectAtIndex:selectedIndex_] selected];
}

-(void) unselected
{
	[[subItems_ objectAtIndex:selectedIndex_] unselected];
}

-(void) activate
{
	// update index
	
	if( isEnabled ) {
		NSUInteger newIndex = (selectedIndex_ + 1) % [subItems_ count];
		[self setSelectedIndex:newIndex];

		[invocation invoke];
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	[super setIsEnabled:enabled];
	for(MenuItem* item in subItems_)
		[item setIsEnabled:enabled];
}

-(MenuItem*) selectedItem
{
	return [subItems_ objectAtIndex:selectedIndex_];
}

-(CGRect) rect
{
	MenuItem* selectedItem = [self selectedItem];

	CGRect r = [selectedItem rect];
	r.origin.x = position.x - r.size.width / 2;
	r.origin.y = position.y - r.size.height / 2;
	
	return r;
}

-(CGSize) contentSize
{
	MenuItem* selectedItem = [self selectedItem];
	return [selectedItem contentSize];
}

- (void) setOpacity: (GLubyte)newOpacity
{
	[super setOpacity:newOpacity];
	for(MenuItem* item in subItems_)
		[item setOpacity:newOpacity];
}
@end
