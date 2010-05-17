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

#import "CCMenuItem.h"
#import "CCLabel.h"
#import "CCLabelAtlas.h"
#import "CCIntervalAction.h"
#import "CCSprite.h"
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
#pragma mark CCMenuItem

@implementation CCMenuItem

@synthesize isSelected=isSelected_;
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
#if NS_BLOCKS_AVAILABLE
			if ([sig numberOfArguments] == 3) 
#endif
			[invocation setArgument:&self atIndex:2];
			
			[invocation retain];
		}
		
		isEnabled_ = YES;
		isSelected_ = NO;
	}
	
	return self;
}

#if NS_BLOCKS_AVAILABLE

+(id) itemWithBlock:(void(^)(id sender))block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

-(id) initWithBlock:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initWithTarget:block_ selector:@selector(ccCallbackBlockWithSender:)];
}

#endif // NS_BLOCKS_AVAILABLE

-(void) dealloc
{
	[invocation release];

#if NS_BLOCKS_AVAILABLE
	[block_ release];
#endif
	
	[super dealloc];
}

-(void) selected
{
	isSelected_ = YES;
}

-(void) unselected
{
	isSelected_ = NO;
}

-(void) activate
{
	if(isEnabled_)
        [invocation invoke];
}

-(void) setIsEnabled: (BOOL)enabled
{
    isEnabled_ = enabled;
}

-(BOOL) isEnabled
{
    return isEnabled_;
}

-(CGRect) rect
{
	return CGRectMake( self.position.x - contentSize_.width*anchorPoint_.x, self.position.y-
					  contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);
}
@end


#pragma mark -
#pragma mark CCMenuItemLabel

@implementation CCMenuItemLabel

@synthesize disabledColor = disabledColor_;

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithLabel:label target:target selector:selector] autorelease];
}

-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	if( (self=[super initWithTarget:target selector:selector]) ) {
		originalScale_ = 1;
		colorBackup = ccWHITE;
		disabledColor_ = ccc3( 126,126,126);
		self.label = label;
	}
	return self;
}

#if NS_BLOCKS_AVAILABLE

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block {
	return [[[self alloc] initWithLabel:label block:block] autorelease];
}

-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initWithLabel:label target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}

#endif // NS_BLOCKS_AVAILABLE

-(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	return label_;
}
-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
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
	if(isEnabled_) {
		[self stopAllActions];
        
		self.scale = originalScale_;
        
		[super activate];
	}
}

-(void) selected
{
	// subclass to change the default action
	if(isEnabled_) {	
		[super selected];
		[self stopActionByTag:kZoomActionTag];
		originalScale_ = self.scale;
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_ * 1.2f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled_) {
		[super unselected];
		[self stopActionByTag:kZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	if( isEnabled_ != enabled ) {
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
#pragma mark CCMenuItemAtlasFont

@implementation CCMenuItemAtlasFont

+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return [CCMenuItemAtlasFont itemFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:nil selector:nil];
}

+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	return [[[self alloc] initFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:rec selector:cb] autorelease];
}

-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb
{
	NSAssert( [value length] != 0, @"value lenght must be greater than 0");
	
	CCLabelAtlas *label = [[CCLabelAtlas alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap];
	[label autorelease];

	if((self=[super initWithLabel:label target:rec selector:cb]) ) {
		// do something ?
	}
	
	return self;
}

#if NS_BLOCKS_AVAILABLE
+(id) itemFromString:(NSString*)value charMapFile:(NSString*)charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block {
	return [[[self alloc] initFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:block] autorelease];
}

-(id) initFromString:(NSString*)value charMapFile:(NSString*)charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initFromString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}
#endif // NS_BLOCKS_AVAILABLE

-(void) dealloc
{
	[super dealloc];
}
@end


#pragma mark -
#pragma mark CCMenuItemFont

@implementation CCMenuItemFont

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
	
	CCLabel *label = [CCLabel labelWithString:value fontName:_fontName fontSize:_fontSize];

	if((self=[super initWithLabel:label target:rec selector:cb]) ) {
		// do something ?
	}
	
	return self;
}

#if NS_BLOCKS_AVAILABLE
+(id) itemFromString: (NSString*) value block:(void(^)(id sender))block {
	return [[[self alloc] initFromString:value block:block] autorelease];
}

-(id) initFromString: (NSString*) value block:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initFromString:value target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}
#endif // NS_BLOCKS_AVAILABLE

-(void) dealloc
{
	[super dealloc];
}
@end

#pragma mark -
#pragma mark CCMenuItemSprite
@implementation CCMenuItemSprite

@synthesize normalImage=normalImage_, selectedImage=selectedImage_, disabledImage=disabledImage_;

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite
{
	return [self itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:nil selector:nil];
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector
{
	return [self itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	if( (self=[super initWithTarget:target selector:selector]) ) {
		
		self.normalImage = normalSprite;
		self.selectedImage = selectedSprite;
		self.disabledImage = disabledSprite;
		
		[self setContentSize: [normalImage_ contentSize]];
	}
	return self;	
}

#if NS_BLOCKS_AVAILABLE
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block {
	return [self itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil block:block];
}

+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block {
	return [[[self alloc] initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block] autorelease];
}

-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}
#endif // NS_BLOCKS_AVAILABLE


-(void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];
	
	[super dealloc];
}

-(void) draw
{
	if(isEnabled_) {
		if( isSelected_ )
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

#pragma mark CCMenuItemImage - CCRGBAProtocol protocol
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
#pragma mark CCMenuItemImage

@implementation CCMenuItemImage

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
	CCNode<CCRGBAProtocol> *normalImage = [CCSprite spriteWithFile:normalI];
	CCNode<CCRGBAProtocol> *selectedImage = [CCSprite spriteWithFile:selectedI]; 
	CCNode<CCRGBAProtocol> *disabledImage = nil;

	if(disabledI)
		disabledImage = [CCSprite spriteWithFile:disabledI];

	return [self initFromNormalSprite:normalImage selectedSprite:selectedImage disabledSprite:disabledImage target:t selector:sel];
}

#if NS_BLOCKS_AVAILABLE

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block {
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage:nil block:block];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block {
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 disabledImage:value3 block:block] autorelease];
}

-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block {
	block_ = BLOCK_RETAIN(block);
	return [self initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:block_ selector:@selector(ccCallbackBlockWithSender:)];
}

#endif // NS_BLOCKS_AVAILABLE

@end

#pragma mark -
#pragma mark CCMenuItemToggle

//
// MenuItemToggle
//
@implementation CCMenuItemToggle

@synthesize subItems = subItems_;
@synthesize opacity=opacity_, color=color_;

+(id) itemWithTarget: (id)t selector: (SEL)sel items: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args, item);
	
	id s = [[[self alloc] initWithTarget: t selector:sel items: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithTarget: (id)t selector: (SEL)sel items:(CCMenuItem*) item vaList: (va_list) args
{
	if( (self=[super initWithTarget:t selector:sel]) ) {
	
		self.subItems = [NSMutableArray arrayWithCapacity:2];
		
		int z = 0;
		CCMenuItem *i = item;
		while(i) {
			z++;
			[subItems_ addObject:i];
			i = va_arg(args, CCMenuItem*);
		}

		selectedIndex_ = NSUIntegerMax;
		[self setSelectedIndex:0];
	}
	
	return self;
}

#if NS_BLOCKS_AVAILABLE
								  
+(id) itemWithBlock:(void(^)(id sender))block items:(CCMenuItem*)item, ... {
	va_list args;
	va_start(args, item);
	
	id s = [[[self alloc] initWithBlock:block items:item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithBlock:(void (^)(id))block items:(CCMenuItem*)item vaList:(va_list)args {
	block_ = BLOCK_RETAIN(block);
	return [self initWithTarget:block_ selector:@selector(ccCallbackBlockWithSender:) items:item vaList:args];
}

#endif // NS_BLOCKS_AVAILABLE

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
		
		CCMenuItem *item = [subItems_ objectAtIndex:selectedIndex_];
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
	[super selected];
	[[subItems_ objectAtIndex:selectedIndex_] selected];
}

-(void) unselected
{
	[super unselected];
	[[subItems_ objectAtIndex:selectedIndex_] unselected];
}

-(void) activate
{
	// update index
	if( isEnabled_ ) {
		NSUInteger newIndex = (selectedIndex_ + 1) % [subItems_ count];
		[self setSelectedIndex:newIndex];

	}

	[super activate];
}

-(void) setIsEnabled: (BOOL)enabled
{
	[super setIsEnabled:enabled];
	for(CCMenuItem* item in subItems_)
		[item setIsEnabled:enabled];
}

-(CCMenuItem*) selectedItem
{
	return [subItems_ objectAtIndex:selectedIndex_];
}

#pragma mark CCMenuItemToggle - CCRGBAProtocol protocol

- (void) setOpacity: (GLubyte)opacity
{
	opacity_ = opacity;
	for(CCMenuItem<CCRGBAProtocol>* item in subItems_)
		[item setOpacity:opacity];
}

- (void) setColor:(ccColor3B)color
{
	color_ = color;
	for(CCMenuItem<CCRGBAProtocol>* item in subItems_)
		[item setColor:color];
}

@end
