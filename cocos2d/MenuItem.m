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


#pragma mark -
#pragma mark MenuItemLabel

@implementation MenuItemLabel

@synthesize label = label_;
+(id) itemWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA,CocosNodeSize>*)label target:(id)target selector:(SEL)selector
{
	return [[[self class] alloc] initWithLabel:label target:target selector:selector];
}

-(id) initWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA,CocosNodeSize>*)label target:(id)target selector:(SEL)selector
{
	if( (self=[super initWithTarget:target selector:selector]) ) {
		self.label = label;
		
		CGSize s = [label_ contentSize];
		self.transformAnchor = ccp( s.width/2, s.height/2 );
	}
	return self;
}

- (void) dealloc
{
	[label_ release];
	[super dealloc];
}

-(void) setString:(NSString *)string
{
	[label_ setString:string];
	CGSize s = [label_ contentSize];
	self.transformAnchor = ccp( s.width/2, s.height/2 );
}

-(CGRect) rect
{
	CGSize s = [label_ contentSize];
	
	CGRect r = CGRectMake( self.position.x - s.width/2, self.position.y-s.height/2, s.width, s.height);
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
		[label_ setRGB:126 :126 :126];
	else
		[label_ setRGB:255 :255 :255];
    
	[super setIsEnabled:enabled];
}

-(CGSize) contentSize
{
	return [label_ contentSize];
}

-(void) draw
{
	[label_ draw];
}

- (void) setOpacity: (GLubyte)opacity
{
    [label_ setOpacity:opacity];
}
-(GLubyte) opacity
{
	return [label_ opacity];
}
- (void) setRGB:(GLubyte)r:(GLubyte)g:(GLubyte)b
{
	[label_ setRGB:r:g:b];
}
-(GLubyte)r
{
	return [label_ r];
}
-(GLubyte)g
{
	return [label_ g];
}
-(GLubyte)b
{
	return [label_ b];
}
@end

#pragma mark  -
#pragma mark MenuItemAtlasFont

@implementation MenuItemAtlasFont

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
	NSAssert( [value length] != 0, @"value lenght must be greater than 0");
	
	LabelAtlas *label = [[LabelAtlas alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap];
	[label autorelease];

	if((self=[super initWithLabel:label target:rec selector:cb]) ) {
		// do something ?
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}
@end


#pragma mark -
#pragma mark MenuItemFont

@implementation MenuItemFont

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
	NSAssert( [value length] != 0, @"Value lenght must be greater than 0");
	
	Label *label = [Label labelWithString:value fontName:_fontName fontSize:_fontSize];

	if((self=[super initWithLabel:label target:rec selector:cb]) ) {
		// do something ?
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}
@end

#pragma mark MenuItemImage

@implementation MenuItemImage

@synthesize selectedImage=selectedImage_, normalImage=normalImage_, disabledImage=disabledImage_;

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

	self.normalImage = [Sprite spriteWithFile:normalI];
	self.selectedImage = [Sprite spriteWithFile:selectedI];
    
	if(disabledI == nil)
		self.disabledImage = nil;
	else
		self.disabledImage = [Sprite spriteWithFile:disabledI];
  
//	[normalImage setOpacity:opacity_];
//	[normalImage setRGB:r_:g_:b_];
//	[selectedImage setOpacity:opacity_];
//	[selectedImage setRGB:r_:g_:b_];
//	[disabledImage setOpacity:opacity_];
//	[disabledImage setRGB:r_:g_:b_];
	
	CGSize s = [normalImage_ contentSize];
	self.transformAnchor = ccp( s.width/2, s.height/2 );

	return self;
}

-(void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];

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
	CGSize s = [normalImage_ contentSize];
	
	CGRect r = CGRectMake( self.position.x - s.width/2, self.position.y-s.height/2, s.width, s.height);
	return r;
}

-(CGSize) contentSize
{
	return [normalImage_ contentSize];
}

-(void) draw
{
	if(isEnabled) {
		if( selected )
			[selectedImage_ draw];
		else
			[normalImage_ draw];

	} else {
		if(disabledImage_ != nil)
			[disabledImage_ draw];
		
		// disabled image was not provided
		else
			[normalImage_ draw];
	}
}

- (void) setOpacity: (GLubyte)opacity
{
	[normalImage_ setOpacity:opacity];
	[selectedImage_ setOpacity:opacity];
	[disabledImage_ setOpacity:opacity];
}

- (void) setRGB:(GLubyte)r:(GLubyte)g:(GLubyte)b
{
	[normalImage_ setRGB:r:g:b];
	[selectedImage_ setRGB:r:g:b];
	[disabledImage_ setRGB:r:g:b];
}
-(GLubyte) opacity
{
	return [normalImage_ opacity];
}
-(GLubyte)r
{
	return [normalImage_ r];
}
-(GLubyte)g
{
	return [normalImage_ g];
}
-(GLubyte)b
{
	return [normalImage_ b];
}

@end

#pragma mark MenuItemToggle

//
// MenuItemToggle
//
@implementation MenuItemToggle

@synthesize subItems = subItems_;
@synthesize opacity=opacity_, r=r_, g=g_, b=b_;

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
	r.origin.x = self.position.x - r.size.width / 2;
	r.origin.y = self.position.y - r.size.height / 2;
	
	return r;
}

-(CGSize) contentSize
{
	MenuItem* selectedItem = [self selectedItem];
	return [selectedItem contentSize];
}

- (void) setOpacity: (GLubyte)opacity
{
	opacity_ = opacity;
	for(MenuItem<CocosNodeRGBA>* item in subItems_)
		[item setOpacity:opacity];
}

- (void) setRGB:(GLubyte)r:(GLubyte)g:(GLubyte)b
{
	r_ = r;
	g_ = g;
	b_ = b;
	for(MenuItem<CocosNodeRGBA>* item in subItems_)
		[item setRGB:r:g:b];
}
@end
