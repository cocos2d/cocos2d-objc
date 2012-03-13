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

static NSUInteger _fontSize = kCCItemSize;
static NSString *_fontName = @"Marker Felt";
static BOOL _fontNameRelease = NO;


const NSInteger	kCCCurrentItemTag = 0xc0c05001;
const NSInteger	kCCZoomActionTag = 0xc0c05002;


#pragma mark -
#pragma mark CCMenuItem

@implementation CCMenuItem

@synthesize isSelected=isSelected_;
+(id) itemWithTarget:(id) r selector:(SEL) s
{
	return [[[self alloc] initWithTarget:r selector:s] autorelease];
}

+(id) itemWithBlock:(void(^)(id sender))block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

-(id) init
{
	return [self initWithBlock:nil];
}

-(id) initWithTarget:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;
	return [self initWithBlock:^(id sender) {

		[t performSelector:selector withObject:sender];
	}];

}


// Designated initializer
-(id) initWithBlock:(void (^)(id))block
{
	if((self=[super init]) ) {

		if( block )
			block_ = [block copy];

		anchorPoint_ = ccp(0.5f, 0.5f);
		isEnabled_ = YES;
		isSelected_ = NO;

	}
	return self;
}

-(void) dealloc
{
	[block_ release];

	[super dealloc];
}

-(void) cleanup
{
	[block_ release];
	block_ = nil;

	[super cleanup];
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
	if(isEnabled_&& block_ )
		block_(self);
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
	return CGRectMake( position_.x - contentSize_.width*anchorPoint_.x,
					  position_.y - contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);
}

-(void) setBlock:(void(^)(id sender))block
{
    [block_ release];
    block_ = [block copy];
}

-(void) setTarget:(id)target selector:(SEL)selector
{
    [self setBlock:^(id sender) {
        
		[target performSelector:selector withObject:sender];
	}];
}

@end


#pragma mark -
#pragma mark CCMenuItemLabel

@implementation CCMenuItemLabel

@synthesize disabledColor = disabledColor_;

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label
{
	return [[[self alloc] initWithLabel:label block:nil] autorelease];
}

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithLabel:label target:target selector:selector] autorelease];
}

+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block {
	return [[[self alloc] initWithLabel:label block:block] autorelease];
}


-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;

	self = [self initWithLabel:label block: ^(id sender) {
		[t performSelector:selector withObject:sender];
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
		originalScale_ = 1;
		colorBackup = ccWHITE;
		disabledColor_ = ccc3( 126,126,126);
		self.label = label;
	}

	return self;
}

-(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	return label_;
}
-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	if( label != label_ ) {
		[self removeChild:label_ cleanup:YES];
		[self addChild:label];

		label_ = label;
		label_.anchorPoint = ccp(0,0);

		[self setContentSize:[label_ contentSize]];
	}
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

		CCAction *action = [self getActionByTag:kCCZoomActionTag];
		if( action )
			[self stopAction:action];
		else
			originalScale_ = self.scale;

		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_ * 1.2f];
		zoomAction.tag = kCCZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled_) {
		[super unselected];
		[self stopActionByTag:kCCZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_];
		zoomAction.tag = kCCZoomActionTag;
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

#pragma mark  - CCMenuItemAtlasFont

@implementation CCMenuItemAtlasFont

+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap
{
	return [CCMenuItemAtlasFont itemWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:nil selector:nil];
}

+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap target:target selector:selector] autorelease];
}

+(id) itemWithString:(NSString*)value charMapFile:(NSString*)charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block
{
	return [[[self alloc] initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:block] autorelease];
}

-(id) initWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;

	return [self initWithString:value charMapFile:charMapFile itemWidth:itemWidth itemHeight:itemHeight startCharMap:startCharMap block:^(id sender) {
		[t performSelector:selector withObject:sender];
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

	[label release];

	return ret;

}

-(void) dealloc
{
	[super dealloc];
}
@end


#pragma mark - CCMenuItemFont

@implementation CCMenuItemFont

+(void) setFontSize: (NSUInteger) s
{
	_fontSize = s;
}

+(NSUInteger) fontSize
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

+(id) itemWithString: (NSString*) value target:(id) r selector:(SEL) s
{
	return [[[self alloc] initWithString: value target:r selector:s] autorelease];
}

+(id) itemWithString: (NSString*) value
{
	return [[[self alloc] initWithString: value target:nil selector:nil] autorelease];
}

+(id) itemWithString: (NSString*) value block:(void(^)(id sender))block
{
	return [[[self alloc] initWithString:value block:block] autorelease];
}

-(id) initWithString: (NSString*) value target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;

	return [self initWithString:value block:^(id sender) {
		[t performSelector:selector withObject:sender];
	}];
}

//
// Designated initializer
//
-(id) initWithString: (NSString*)string block:(void(^)(id sender))block
{
	NSAssert( [string length] > 0, @"Value length must be greater than 0");

	fontName_ = [_fontName copy];
	fontSize_ = _fontSize;

	CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:fontName_ fontSize:fontSize_];

	if((self=[super initWithLabel:label block:block]) ) {
		// do something ?
	}

	return self;
}

-(void) recreateLabel
{
	CCLabelTTF *label = [[CCLabelTTF alloc] initWithString:[label_ string] fontName:fontName_ fontSize:fontSize_];
	self.label = label;
	[label release];
}

-(void) setFontSize: (NSUInteger) size
{
	fontSize_ = size;
	[self recreateLabel];
}

-(NSUInteger) fontSize
{
	return fontSize_;
}

-(void) setFontName: (NSString*) fontName
{
	if (fontName_)
		[fontName_ release];

	fontName_ = [fontName copy];
	[self recreateLabel];
}

-(NSString*) fontName
{
	return fontName_;
}
@end

#pragma mark - CCMenuItemSprite

@implementation CCMenuItemSprite

@synthesize normalImage=normalImage_, selectedImage=selectedImage_, disabledImage=disabledImage_;

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
	return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector] autorelease];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block
{
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil block:block];
}

+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block
{
	return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block] autorelease];
}

-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;

	return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:^(id sender) {
		[t performSelector:selector withObject:sender];
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

		[self setContentSize: [normalImage_ contentSize]];
	}
	return self;
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) {
		image.anchorPoint = ccp(0,0);
		image.visible = YES;

		[self removeChild:normalImage_ cleanup:YES];
		[self addChild:image];

		normalImage_ = image;
        
        [self setContentSize: [normalImage_ contentSize]];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ ) {
		image.anchorPoint = ccp(0,0);
		image.visible = NO;

		[self removeChild:selectedImage_ cleanup:YES];
		[self addChild:image];

		selectedImage_ = image;
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ ) {
		image.anchorPoint = ccp(0,0);
		image.visible = NO;

		[self removeChild:disabledImage_ cleanup:YES];
		[self addChild:image];

		disabledImage_ = image;
	}
}

#pragma mark CCMenuItemSprite - CCRGBAProtocol protocol

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

-(void) selected
{
	[super selected];

	if( selectedImage_ ) {
		[normalImage_ setVisible:NO];
		[selectedImage_ setVisible:YES];
		[disabledImage_ setVisible:NO];

	} else { // there is not selected image

		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];
	}
}

-(void) unselected
{
	[super unselected];
	[normalImage_ setVisible:YES];
	[selectedImage_ setVisible:NO];
	[disabledImage_ setVisible:NO];
}

-(void) setIsEnabled:(BOOL)enabled
{
	[super setIsEnabled:enabled];

	if( enabled ) {
		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];

	} else {
		if( disabledImage_ ) {
			[normalImage_ setVisible:NO];
			[selectedImage_ setVisible:NO];
			[disabledImage_ setVisible:YES];
		} else {
			[normalImage_ setVisible:YES];
			[selectedImage_ setVisible:NO];
			[disabledImage_ setVisible:NO];
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
	return [[[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 target:nil selector:nil] autorelease];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3 target:(id) t selector:(SEL) s
{
	return [[[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 target:t selector:s] autorelease];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block
{
	return [self itemWithNormalImage:value selectedImage:value2 disabledImage:nil block:block];
}

+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block
{
	return [[[self alloc] initWithNormalImage:value selectedImage:value2 disabledImage:value3 block:block] autorelease];
}

-(id) initWithNormalImage: (NSString*) normalI selectedImage:(NSString*)selectedI disabledImage: (NSString*) disabledI target:(id)target selector:(SEL)selector
{
	// avoid retain cycle
	__block id t = target;

	return [self initWithNormalImage:normalI selectedImage:selectedI disabledImage:disabledI block:^(id sender) {
		[t performSelector:selector withObject:sender];
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
@implementation CCMenuItemToggle

@synthesize subItems = subItems_;
@synthesize opacity = opacity_, color = color_;

+(id) itemWithTarget: (id)t selector: (SEL)sel items: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args, item);

	id s = [[[self alloc] initWithTarget: t selector:sel items: item vaList:args] autorelease];

	va_end(args);
	return s;
}

+(id) itemWithItems:(NSArray*)arrayOfItems block:(void(^)(id))block
{
	return [[[self alloc] initWithItems:arrayOfItems block:block] autorelease];
}

-(id) initWithTarget:(id)target selector:(SEL)selector items:(CCMenuItem*) item vaList: (va_list) args
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
	__block id t = target;

	return [self initWithItems:array block:^(id sender) {
		[t performSelector:selector withObject:sender];
	}
			];
}

-(id) initWithItems:(NSArray*)arrayOfItems block:(void(^)(id sender))block
{
	if( (self=[super initWithBlock:block] ) ) {

		self.subItems = [NSMutableArray arrayWithArray:arrayOfItems];

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
		CCMenuItem *currentItem = (CCMenuItem*)[self getChildByTag:kCCCurrentItemTag];
		if( currentItem )
			[currentItem removeFromParentAndCleanup:NO];
		
		CCMenuItem *item = [subItems_ objectAtIndex:selectedIndex_];
		[self addChild:item z:0 tag:kCCCurrentItemTag];

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
