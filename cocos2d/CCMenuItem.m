/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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

#import "CCMenuItem.h"
#import "CCLabelTTF.h"
#import "CCLabelAtlas.h"
#import "CCActionInterval.h"
#import "CCSprite.h"
#import "Support/CGPointExtension.h"
#import <objc/message.h>
#import "CCMenu.h"

static NSUInteger _globalFontSize = kCCItemSize;
static NSString *_globalFontName = @"Marker Felt";
static BOOL _globalFontNameRelease = NO;


const NSInteger	kCCCurrentItemTag = 0xc0c05001;
const NSInteger	kCCZoomActionTag = 0xc0c05002;


#pragma mark -
#pragma mark CCMenuItem

@implementation CCMenuItem

@synthesize isSelected=_isSelected;
@synthesize releaseBlockAtCleanup=_releaseBlockAtCleanup;
@synthesize activeArea=_activeArea;

+(id) itemWithTarget:(id) r selector:(SEL) s
{
	return [[self alloc] initWithTarget:r selector:s];
}

+(id) itemWithBlock:(void(^)(id sender))block {
	return [[self alloc] initWithBlock:block];
}

-(id) init
{
	return [self initWithBlock:nil];
}

-(id) initWithTarget:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;
	return [self initWithBlock:^(id sender) {
        
        objc_msgSend(t, selector, sender);
	}];

}


// Designated initializer
-(id) initWithBlock:(void (^)(id))block {
    
    self = [ super init ];
    NSAssert( self != nil, @"Unable to create class" );
    
    if( block )
        _block = [block copy];
    
    self.anchorPoint = ccp(0.5f, 0.5f);
    _isEnabled = YES;
    _isSelected = NO;
    
    // enable touch handling for all menu items
    self.userInteractionEnabled = YES;
    
    // WARNING: Will be disabled in v2.2
    _releaseBlockAtCleanup = YES;

	
	return( self );
}

-(void) setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    
    // Reset touch area to match the outside box
    _activeArea = CGRectMake(0, 0, contentSize.width, contentSize.height);
}



-(void) cleanup
{
	if( _releaseBlockAtCleanup ) {
		_block = nil;
	}

	[super cleanup];
}

-(void) selected
{
	_isSelected = YES;
}

-(void) unselected
{
	_isSelected = NO;
}

-(void) activate
{
	if(_isEnabled && _block )
		_block(self);
}

-(void) setIsEnabled: (BOOL)enabled
{
    _isEnabled = enabled;
}

-(BOOL) isEnabled
{
    return _isEnabled;
}

-(void) setBlock:(void(^)(id sender))block
{
    _block = [block copy];
}

-(void) setTarget:(id)target selector:(SEL)selector
{
   __unsafe_unretained id weakTarget = target; // avoid retain cycle
   [self setBlock:^(id sender) {
       objc_msgSend(weakTarget, selector, sender);
	}];
}

// -----------------------------------------------------------------
#pragma mark - iOS touch functionality -
// -----------------------------------------------------------------

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

/** touch protocol implementation
 @since v2.5
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if menu item is child of a menu, notify the menu that a child has been pressed
    if ([self.parent isMemberOfClass:[CCMenu class]] == YES) [((CCMenu*)self.parent) menuItemPressed:self];
  
    // perform pressed selector
    [self selected];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if menu item is child of a menu, notify the menu that a child has been released
    if ([self.parent isMemberOfClass:[CCMenu class]] == YES) [((CCMenu*)self.parent) menuItemReleased:self];

    // perform released selector
    [self unselected];
    [self activate];
}

#else

// -----------------------------------------------------------------
#pragma mark - Mac mouse functionality -
// -----------------------------------------------------------------

/** mouse protocol implementation
 @since v2.5
 */

- (void)mouseDown:(NSEvent *)theEvent
{
    // if menu item is child of a menu, notify the menu that a child has been pressed
    if ([self.parent isMemberOfClass:[CCMenu class]] == YES) [((CCMenu*)self.parent) menuItemPressed:self];
    
    // perform pressed selector
    [self selected];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    // if menu item is child of a menu, notify the menu that a child has been released
    if ([self.parent isMemberOfClass:[CCMenu class]] == YES) [((CCMenu*)self.parent) menuItemReleased:self];
    
    // perform released selector
    [self unselected];
    [self activate];
}

#endif

// -----------------------------------------------------------------

@end


#pragma mark -
#pragma mark CCMenuItemLabel

@implementation CCMenuItemLabel

@synthesize disabledColor = _disabledColor;

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label
{
	return [[self alloc] initWithLabel:label block:nil];
}

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	return [[self alloc] initWithLabel:label target:target selector:selector];
}

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block {
	return [[self alloc] initWithLabel:label block:block];
}


-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;

	self = [self initWithLabel:label block: ^(id sender) {
        objc_msgSend(t, selector, sender);
	}
			];
	return self;
}

//
// Designated initializer
//
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label block:(void (^)(id))block
{
	if( (self=[self initWithBlock:block]) ) {
		_originalScale = 1;
		_colorBackup = ccWHITE;
		self.disabledColor = ccc3( 126,126,126);
		self.label = label;
		
		self.cascadeColorEnabled = YES;
		self.cascadeOpacityEnabled = YES;
	}

	return self;
}

-(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	return _label;
}
-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	if( label != _label ) {
		[self removeChild:_label cleanup:YES];
		[self addChild:label];

		_label = label;
		_label.anchorPoint = ccp(0,0);

		[self setContentSize:[_label contentSize]];
	}
}

-(void) setString:(NSString *)string
{
	[_label setString:string];
	[self setContentSize: [_label contentSize]];
}

-(void) activate {
	if(_isEnabled) {
		[self stopAllActions];

		self.scale = _originalScale;

		[super activate];
	}
}

-(void) selected
{
	// subclass to change the default action
	if(_isEnabled) {
		[super selected];

		CCAction *action = [self getActionByTag:kCCZoomActionTag];
		if( action )
			[self stopAction:action];
		else
			_originalScale = self.scale;

		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:_originalScale * 1.2f];
		zoomAction.tag = kCCZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(_isEnabled) {
		[super unselected];
		[self stopActionByTag:kCCZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:_originalScale];
		zoomAction.tag = kCCZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) setIsEnabled: (BOOL)enabled
{
	if( _isEnabled != enabled ) {
		if(enabled == NO) {
			_colorBackup = [_label color];
			[_label setColor: _disabledColor];
		}
		else
			[_label setColor:_colorBackup];
	}

	[super setIsEnabled:enabled];
}
@end

#pragma mark  - CCMenuItemAtlasFont

@implementation CCMenuItemAtlasFont

+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return [CCMenuItemAtlasFont itemWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:nil selector:nil];
}

+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector
{
	return [[self alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:target selector:selector];
}

+(id) itemWithString:(NSString*)value charMapFile:(NSString*)charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block
{
	return [[self alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:block];
}

-(id) initWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;

	return [self initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:^(id sender) {
        objc_msgSend(t, selector, sender);
	} ];
}

//
// Designated initializer
//
-(id) initWithString:(NSString*)value charMapFile:(NSString*)charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block
{
	NSAssert( [value length] > 0, @"value length must be greater than 0");

	CCLabelAtlas *label = [[CCLabelAtlas alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap];

	id ret = [self initWithLabel:label block:block];


	return ret;

}

@end


#pragma mark - CCMenuItemFont

@implementation CCMenuItemFont

+(void) setFontSize: (NSUInteger) s
{
	_globalFontSize = s;
}

+(NSUInteger) fontSize
{
	return _globalFontSize;
}

+(void) setFontName: (NSString*) n
{

	_globalFontName = n;
	_globalFontNameRelease = YES;
}

+(NSString*) fontName
{
	return _globalFontName;
}

+(id) itemWithString: (NSString*) value target:(id) r selector:(SEL) s
{
	return [[self alloc] initWithString: value target:r selector:s];
}

+(id) itemWithString: (NSString*) value
{
	return [[self alloc] initWithString: value target:nil selector:nil];
}

+(id) itemWithString: (NSString*) value block:(void(^)(id sender))block
{
	return [[self alloc] initWithString:value block:block];
}

-(id) initWithString: (NSString*) value target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;

	return [self initWithString:value block:^(id sender) {
        objc_msgSend(t, selector, sender);
	}];
}

//
// Designated initializer
//
-(id) initWithString: (NSString*)string block:(void(^)(id sender))block
{
	NSAssert( [string length] > 0, @"Value length must be greater than 0");

	_fontName = [_globalFontName copy];
	_fontSize = _globalFontSize;

	CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:_fontName fontSize:_fontSize];

	if((self=[super initWithLabel:label block:block]) ) {
		// do something ?
	}

	return self;
}

-(void) recreateLabel
{
	CCLabelTTF *label = [[CCLabelTTF alloc] initWithString:[_label string] fontName:_fontName fontSize:_fontSize];
	self.label = label;
}

-(void) setFontSize: (NSUInteger) size
{
	_fontSize = size;
	[self recreateLabel];
}

-(NSUInteger) fontSize
{
	return _fontSize;
}

-(void) setFontName: (NSString*) fontName
{

	_fontName = [fontName copy];
	[self recreateLabel];
}

-(NSString*) fontName
{
	return _fontName;
}
@end

#pragma mark - CCMenuItemSprite

@interface CCMenuItemSprite()
-(void) updateImagesVisibility;
@end

@implementation CCMenuItemSprite

@synthesize normalImage=_normalImage, selectedImage=_selectedImage, disabledImage=_disabledImage;

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:nil selector:nil];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	return [[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil block:block];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	return [[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block];
}

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;

	return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:^(id sender) {
        objc_msgSend(t, selector, sender);
	} ];
}

//
// Designated initializer
//
-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	if ( (self = [super initWithBlock:block] ) ) {

		self.normalImage = normalSprite;
		self.selectedImage = selectedSprite;
		self.disabledImage = disabledSprite;

		[self setContentSize: [_normalImage contentSize]];
		
		self.cascadeColorEnabled = YES;
		self.cascadeOpacityEnabled = YES;
	}
	return self;
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != _normalImage ) {
		image.anchorPoint = ccp(0,0);

		[self removeChild:_normalImage cleanup:YES];
		[self addChild:image];

		_normalImage = image;
        
        [self setContentSize: [_normalImage contentSize]];
		
		[self updateImagesVisibility];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != _selectedImage ) {
		image.anchorPoint = ccp(0,0);

		[self removeChild:_selectedImage cleanup:YES];
		[self addChild:image];

		_selectedImage = image;
		
		[self updateImagesVisibility];
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != _disabledImage ) {
		image.anchorPoint = ccp(0,0);

		[self removeChild:_disabledImage cleanup:YES];
		[self addChild:image];

		_disabledImage = image;
		
		[self updateImagesVisibility];
	}
}

-(void) selected
{
	[super selected];

	if( _selectedImage ) {
		[_normalImage setVisible:NO];
		[_selectedImage setVisible:YES];
		[_disabledImage setVisible:NO];

	} else { // there is not selected image

		[_normalImage setVisible:YES];
		[_selectedImage setVisible:NO];
		[_disabledImage setVisible:NO];
	}
}

-(void) unselected
{
	[super unselected];
	[_normalImage setVisible:YES];
	[_selectedImage setVisible:NO];
	[_disabledImage setVisible:NO];
}

-(void) setIsEnabled:(BOOL)enabled
{
	if( _isEnabled != enabled ) {
		[super setIsEnabled:enabled];

		[self updateImagesVisibility];
	}
}


// Helper 
-(void) updateImagesVisibility
{
	if( _isEnabled ) {
		[_normalImage setVisible:YES];
		[_selectedImage setVisible:NO];
		[_disabledImage setVisible:NO];
		
	} else {
		if( _disabledImage ) {
			[_normalImage setVisible:NO];
			[_selectedImage setVisible:NO];
			[_disabledImage setVisible:YES];
		} else {
			[_normalImage setVisible:YES];
			[_selectedImage setVisible:NO];
			[_disabledImage setVisible:NO];
		}
	}
}

@end

#pragma mark - CCMenuItemImage

@implementation CCMenuItemImage

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage: nil target:nil selector:nil];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage: nil target:t selector:s];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3
{
	return [[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 target:nil selector:nil];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3 target:(id) t selector:(SEL) s
{
	return [[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 target:t selector:s];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage:nil block:block];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
	return [[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 block:block];
}

-(id) initWithNormalImage: (NSString*) normalI selectedImage:(NSString*)selectedI disabledImage: (NSString*) disabledI target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__unsafe_unretained id t = target;

	return [self initWithNormalImage:normalI selectedImage:selectedI disabledImage:disabledI block:^(id sender) {
        objc_msgSend(t, selector, sender);
	}];
}


//
// Designated initializer
//
-(id) initWithNormalImage:(NSString*)normalI selectedImage:(NSString*)selectedI disabledImage:(NSString*)disabledI block:(void(^)(id sender))block
{
	CCNode<CCRGBAProtocol> *normalImage = [CCSprite spriteWithFile:normalI];
	CCNode<CCRGBAProtocol> *selectedImage = nil;
	CCNode<CCRGBAProtocol> *disabledImage = nil;

	if( selectedI )
		selectedImage = [CCSprite spriteWithFile:selectedI];
	if(disabledI)
		disabledImage = [CCSprite spriteWithFile:disabledI];

	return [super initWithNormalSprite:normalImage selectedSprite:selectedImage disabledSprite:disabledImage block:block];
}

//
// Setter of sprite frames
//
-(void) setNormalSpriteFrame:(CCSpriteFrame *)frame
{
    [self setNormalImage:[CCSprite spriteWithSpriteFrame:frame]];
}

-(void) setSelectedSpriteFrame:(CCSpriteFrame *)frame
{
    [self setSelectedImage:[CCSprite spriteWithSpriteFrame:frame]];
}

-(void) setDisabledSpriteFrame:(CCSpriteFrame *)frame
{
    [self setDisabledImage:[CCSprite spriteWithSpriteFrame:frame]];
}

@end

#pragma mark - CCMenuItemToggle

//
// MenuItemToggle
//
@interface CCMenuItemToggle ()
/**
 Reference to the current display item.
 */
@property (nonatomic, unsafe_unretained) CCMenuItem *currentItem;
@end

@implementation CCMenuItemToggle
@synthesize currentItem = _currentItem;
@synthesize subItems = _subItems;

+(id) itemWithTarget: (id)t selector: (SEL)sel items: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args, item);
	
	id s = [self itemWithTarget: t selector:sel items: item vaList:args];
	
	va_end(args);
	return s;
}

+(id) itemWithTarget:(id)target selector:(SEL)selector items:(CCMenuItem*) item vaList: (va_list) args
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
	
	int z = 0;
	CCMenuItem *i = item;
	while(i) {
		z++;
		[array addObject:i];
		i = va_arg(args, CCMenuItem*);
	}
	
	// avoid retain cycle
	__unsafe_unretained id t = target;
	
	return [[self alloc] initWithItems:array block:^(id sender) {
        objc_msgSend(t, selector, sender);
	}
			 ];
}


+(id) itemWithItems:(NSArray*)arrayOfItems
{
	return [[self alloc] initWithItems:arrayOfItems block:NULL];
}

+(id) itemWithItems:(NSArray*)arrayOfItems block:(void(^)(id))block
{
	return [[self alloc] initWithItems:arrayOfItems block:block];
}

-(id) initWithItems:(NSArray*)arrayOfItems block:(void(^)(id sender))block
{
	if( (self=[super initWithBlock:block] ) ) {

		self.subItems = [NSMutableArray arrayWithArray:arrayOfItems];

        _currentItem = nil;
		_selectedIndex = NSUIntegerMax;
		[self setSelectedIndex:0];
		
		self.cascadeColorEnabled = YES;
		self.cascadeOpacityEnabled = YES;
	}

	return self;
}


-(void)setSelectedIndex:(NSUInteger)index
{
	if( index != _selectedIndex ) {
		_selectedIndex=index;
        
		if( _currentItem )
			[_currentItem removeFromParentAndCleanup:NO];
		
		CCMenuItem *item = [_subItems objectAtIndex:_selectedIndex];
		[self addChild:item z:0];
        self.currentItem = item;

		CGSize s = [item contentSize];
		[self setContentSize: s];
		item.position = ccp( s.width/2, s.height/2 );
	}
}

-(NSUInteger) selectedIndex
{
	return _selectedIndex;
}


-(void) selected
{
	[super selected];
	[[_subItems objectAtIndex:_selectedIndex] selected];
}

-(void) unselected
{
	[super unselected];
	[[_subItems objectAtIndex:_selectedIndex] unselected];
}

-(void) activate
{
	// update index
	if( _isEnabled ) {
		NSUInteger newIndex = (_selectedIndex + 1) % [_subItems count];
		[self setSelectedIndex:newIndex];

	}

	[super activate];
}

-(void) setIsEnabled: (BOOL)enabled
{
	if( _isEnabled != enabled ) {
		[super setIsEnabled:enabled];
		for(CCMenuItem* item in _subItems)
			[item setIsEnabled:enabled];
	}
}

-(CCMenuItem*) selectedItem
{
	return [_subItems objectAtIndex:_selectedIndex];
}

@end
