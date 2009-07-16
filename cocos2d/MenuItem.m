/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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
#import "AtlasSprite.h"
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
	if((self=[super init]) ) {
	
		anchorPoint_ = ccp(0.5f, 0.5f);
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
	}
	
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
	return CGRectMake( self.position.x - contentSize_.width*anchorPoint_.x, self.position.y-
					  contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);
}
@end


#pragma mark -
#pragma mark MenuItemLabel

@implementation MenuItemLabel

@synthesize disabledColor = disabledColor_;

+(id) itemWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA>*)label target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithLabel:label target:target selector:selector] autorelease];
}

-(id) initWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA>*)label target:(id)target selector:(SEL)selector
{
	if( (self=[super initWithTarget:target selector:selector]) ) {
		self.label = label;
		colorBackup = ccWHITE;
		disabledColor_ = ccc3( 126,126,126);
	}
	return self;
}

-(CocosNode<CocosNodeLabel, CocosNodeRGBA>*) label
{
	return label_;
}
-(void) setLabel:(CocosNode<CocosNodeLabel, CocosNodeRGBA>*) label
{
	[label_ release];
	label_ = [label retain];
	[self setContentSize:[label_ contentSize]];
}

- (void) dealloc
{
	[label_ release];
	[super dealloc];
}

-(void) setString:(NSString *)string
{
	[label_ setString:string];
	[self setContentSize: [label_ contentSize]];
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
	if( isEnabled != enabled ) {
		if(enabled == NO) {
			colorBackup = [label_ color];
			[label_ setColor: disabledColor_];
		}
		else
			[label_ setColor:colorBackup];
	}
    
	[super setIsEnabled:enabled];
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
	[label_ setColor: ccc3(r,g,b)];
}
-(void) setColor:(ccColor3B)color
{
	[label_ setColor:color];
}
-(ccColor3B) color
{
	return [label_ color];
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

#pragma mark -
#pragma mark MenuItemSprite
@implementation MenuItemSprite

@synthesize normalImage=normalImage_, selectedImage=selectedImage_, disabledImage=disabledImage_;

+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite
{
	return [self itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:nil selector:nil];
}
+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite target:(id)target selector:(SEL)selector
{
	return [self itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}
+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite disabledSprite:(CocosNode<CocosNodeRGBA>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}
-(id) initFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite disabledSprite:(CocosNode<CocosNodeRGBA>*)disabledSprite target:(id)target selector:(SEL)selector
{
	if( (self=[super initWithTarget:target selector:selector]) ) {
		
		self.normalImage = normalSprite;
		self.selectedImage = selectedSprite;
		self.disabledImage = disabledSprite;
		
		[self setContentSize: [normalImage_ contentSize]];
	}
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

#pragma mark MenuItemImage - CocosNodeRGBA protocol
- (void) setOpacity: (GLubyte)opacity
{
	[normalImage_ setOpacity:opacity];
	[selectedImage_ setOpacity:opacity];
	[disabledImage_ setOpacity:opacity];
}

-(void) setColor:(ccColor3B)color
{
	[normalImage_ setColor:color];
	[selectedImage_ setColor:color];
	[disabledImage_ setColor:color];	
}
- (void) setRGB:(GLubyte)r:(GLubyte)g:(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}
-(GLubyte) opacity
{
	return [normalImage_ opacity];
}
-(ccColor3B) color
{
	return [normalImage_ color];
}
@end

#pragma mark -
#pragma mark MenuItemAtlasSprite
@implementation MenuItemAtlasSprite

-(id) initFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite disabledSprite:(CocosNode<CocosNodeRGBA>*)disabledSprite target:(id)target selector:(SEL)selector
{
	if( (self=[super initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector]) ) {
		
		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];
	}
	return self;	
}

- (void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	[normalImage_ setPosition:pos];
	[selectedImage_ setPosition:pos];
	[disabledImage_ setPosition:pos];	
}

- (void)setRotation:(float)angle
{
	[super setRotation:angle];
	[normalImage_ setRotation:angle];
	[selectedImage_ setRotation:angle];
	[disabledImage_ setRotation:angle];
}

- (void)setScale:(float)scale
{
	[super setScale:scale];
	[normalImage_ setScale:scale];
	[selectedImage_ setScale:scale];
	[disabledImage_ setScale:scale];
}

- (void)selected
{
	if( isEnabled ) {
		[super selected];
		[normalImage_ setVisible:NO];
		[selectedImage_ setVisible:YES];
		[disabledImage_ setVisible:NO];
	}
}

- (void)unselected
{
	if( isEnabled ) {
		[super unselected];
		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];
	}
}

- (void)setIsEnabled:(BOOL)enabled
{
	[super setIsEnabled:enabled];
	if(enabled) {
		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];

	} else {
		[normalImage_ setVisible:NO];
		[selectedImage_ setVisible:NO];
		if( disabledImage_ )
			[disabledImage_ setVisible:YES];
		else
			[normalImage_ setVisible:YES];
	}
}

-(void) draw
{
	// override parent draw
	// since AtlasSpriteManager is the one that draws all the AtlasSprite objects
}
@end


#pragma mark -
#pragma mark MenuItemImage

@implementation MenuItemImage

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

-(id) initFromNormalImage: (NSString*) normalI selectedImage:(NSString*)selectedI disabledImage: (NSString*) disabledI target:(id)t selector:(SEL)sel
{
	CocosNode<CocosNodeRGBA> *normalImage = [Sprite spriteWithFile:normalI];
	CocosNode<CocosNodeRGBA> *selectedImage = [Sprite spriteWithFile:selectedI]; 
	CocosNode<CocosNodeRGBA> *disabledImage = nil;

	if(disabledI)
		disabledImage = [Sprite spriteWithFile:disabledI];

	return [self initFromNormalSprite:normalImage selectedSprite:selectedImage disabledSprite:disabledImage target:t selector:sel];
}
@end

#pragma mark -
#pragma mark MenuItemToggle

//
// MenuItemToggle
//
@implementation MenuItemToggle

@synthesize subItems = subItems_;
@synthesize opacity=opacity_, color=color_;

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
		[self setContentSize: s];
		item.position = ccp( s.width/2, s.height/2 );
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

	}

	[super activate];
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

#pragma mark MenuItemToggle - CocosNodeRGBA protocol

- (void) setOpacity: (GLubyte)opacity
{
	opacity_ = opacity;
	for(MenuItem<CocosNodeRGBA>* item in subItems_)
		[item setOpacity:opacity];
}

- (void) setColor:(ccColor3B)color
{
	color_ = color;
	for(MenuItem<CocosNodeRGBA>* item in subItems_)
		[item setColor:color];
}

- (void) setRGB:(GLubyte)r:(GLubyte)g:(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}
@end
