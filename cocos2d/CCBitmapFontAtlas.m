/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 *
 * Use any of these editors to generate bitmap font atlas:
 *   http://www.n4te.com/hiero/hiero.jnlp
 *   http://slick.cokeandcode.com/demos/hiero.jnlp
 *   http://www.angelcode.com/products/bmfont/
 *
 */

#import "ccConfig.h"
#import "CCBitmapFontAtlas.h"
#import "CCSprite.h"
#import "CCDrawingPrimitives.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/ccHashSet.h"

#pragma mark -
#pragma mark FNTConfig Cache - free functions

NSMutableDictionary *configurations = nil;
CCBitmapFontConfiguration* FNTConfigLoadFile( NSString *fntFile)
{
	CCBitmapFontConfiguration *ret = nil;
	
	if( configurations == nil )
		configurations = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
	
	ret = [configurations objectForKey:fntFile];
	if( ret == nil ) {
		ret = [CCBitmapFontConfiguration configurationWithFNTFile:fntFile];
		[configurations setObject:ret forKey:fntFile];
	}
	
	return ret;
}

void FNTConfigRemoveCache( void )
{
	[configurations removeAllObjects];
}

#pragma mark - Hash Element

// Equal function for targetSet.
typedef struct _KerningHashElement
{
	unichar			first;
	unichar			second;
	int				amount;
} tKerningHashElement;

static int
targetSetEql(void *ptr, void *elt)
{
	tKerningHashElement *one = (tKerningHashElement*) ptr;
	tKerningHashElement *two = (tKerningHashElement*) elt;
	return ( (one->first == two->first) && (one->second == two->second));
}

#pragma mark -
#pragma mark BitmapFontConfiguration


@interface CCBitmapFontConfiguration (Private)
-(void) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBitmapFontDef*)characterDefinition;
-(void) parseInfoArguments:(NSString*)line;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseKerningCapacity:(NSString*)line;
-(void) parseKerningEntry:(NSString*)line;
@end

@implementation CCBitmapFontConfiguration

+(id) configurationWithFNTFile:(NSString*)FNTfile
{
	return [[[self alloc] initWithFNTfile:FNTfile] autorelease];
}

-(id) initWithFNTfile:(NSString*)fntFile
{
	if((self=[super init])) {
		[self parseConfigFile:fntFile];
	}
	return self;
}

- (void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@", self);
	if(kerningDictionary)
		ccHashSetFree(kerningDictionary);
	[super dealloc];
}

- (void)parseConfigFile:(NSString*)fntFile
{	
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:fntFile];
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:nil];
	
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// parse spacing / padding
		if([line hasPrefix:@"info face"]) {
			// XXX: info parsing is incomplete
			// Not needed for the Hiero editors, but needed for the AngelCode editor
//			[self parseInfoArguments:line];
		}
		// Check to see if the start of the line is something we are interested in
		else if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			ccBitmapFontDef characterDefinition;
			[self parseCharacterDefinition:line charDef:&characterDefinition];

			// Add the CharDef returned to the charArray
			bitmapFontArray[ characterDefinition.charID ] = characterDefinition;
		}
		else if([line hasPrefix:@"kernings count"]) {
			[self parseKerningCapacity:line];
		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];	
}

-(void) parseInfoArguments:(NSString*)line
{
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue = nil;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// face (ignore)
	[nse nextObject];
	
	// size (ignore)
	[nse nextObject];

	// bold (ignore)
	[nse nextObject];

	// italic (ignore)
	[nse nextObject];
	
	// charset (ignore)
	[nse nextObject];

	// unicode (ignore)
	[nse nextObject];

	// strechH (ignore)
	[nse nextObject];

	// smooth (ignore)
	[nse nextObject];
	
	// aa (ignore)
	[nse nextObject];
	
	// padding (ignore)
	propertyValue = [nse nextObject];
	{
		
		NSArray *paddingValues = [propertyValue componentsSeparatedByString:@","];
		NSEnumerator *paddingEnum = [paddingValues objectEnumerator];
		// padding top
		propertyValue = [paddingEnum nextObject];
		padding.top = [propertyValue intValue];
		
		// padding right
		propertyValue = [paddingEnum nextObject];
		padding.right = [propertyValue intValue];

		// padding bottom
		propertyValue = [paddingEnum nextObject];
		padding.bottom = [propertyValue intValue];
		
		// padding left
		propertyValue = [paddingEnum nextObject];
		padding.left = [propertyValue intValue];
		
		CCLOG(@"cocos2d: padding: %d,%d,%d,%d", padding.left, padding.top, padding.right, padding.bottom);
	}

	// spacing (ignore)
	[nse nextObject];	
}

-(void) parseCommonArguments:(NSString*)line
{
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue = nil;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Character ID
	propertyValue = [nse nextObject];
	commonHeight = [propertyValue intValue];
	
	// base (ignore)
	[nse nextObject];
	
	// scaleW. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= 1024, @"BitmapFontAtlas: page can't be larger than 1024x1024");
	
	// scaleH. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= 1024, @"BitmapFontAtlas: page can't be larger than 1024x1024");
	
	// pages. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 1, @"BitfontAtlas: only supports 1 page");
	
	// packed (ignore) What does this mean ??
}
- (void)parseCharacterDefinition:(NSString*)line charDef:(ccBitmapFontDef*)characterDefinition
{	
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Character ID
	propertyValue = [nse nextObject];
	propertyValue = [propertyValue substringToIndex: [propertyValue rangeOfString: @" "].location];
	characterDefinition->charID = [propertyValue intValue];
	NSAssert(characterDefinition->charID < kBitmapFontAtlasMaxChars, @"BitmpaFontAtlas: CharID bigger than supported");

	// Character x
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.x = [propertyValue intValue];
	// Character y
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.y = [propertyValue intValue];
	// Character width
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.width = [propertyValue intValue];
	// Character height
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.height = [propertyValue intValue];
	// Character xoffset
	propertyValue = [nse nextObject];
	characterDefinition->xOffset = [propertyValue intValue];
	// Character yoffset
	propertyValue = [nse nextObject];
	characterDefinition->yOffset = [propertyValue intValue];
	// Character xadvance
	propertyValue = [nse nextObject];
	characterDefinition->xAdvance = [propertyValue intValue];
}

-(void) parseKerningCapacity:(NSString*) line
{
	NSAssert(!kerningDictionary, @"dictionary already initialized");
	
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// count
	propertyValue = [nse nextObject];
	int capacity = [propertyValue intValue];
	
	if( capacity != -1 )
		kerningDictionary = ccHashSetNew(capacity, targetSetEql);
}

-(void) parseKerningEntry:(NSString*) line
{
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// first
	propertyValue = [nse nextObject];
	int first = [propertyValue intValue];
	
	// second
	propertyValue = [nse nextObject];
	int second = [propertyValue intValue];
	
	// second
	propertyValue = [nse nextObject];
	int amount = [propertyValue intValue];

	tKerningHashElement *element = malloc( sizeof( *element ) );
	element->first = first;
	element->second = second;
	element->amount = amount;
	unsigned int key = (first<<16) | (second&0xffff);
	ccHashSetInsert(kerningDictionary, CC_HASH_INT(key), element, nil);	
}

@end

#pragma mark -
#pragma mark CCBitmapFontAtlas

@interface CCBitmapFontAtlas (Private)
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile;

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second;

@end

@implementation CCBitmapFontAtlas

@synthesize opacity=opacity_, color=color_;

#pragma mark BitmapFontAtlas - Creation & Init
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile
{
	return [[[self alloc] initWithString:string fntFile:fntFile] autorelease];
}


-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile
{
	NSString *textureAtlasName = [self atlasNameFromFntFile:fntFile];
	
	if ((self=[super initWithFile:textureAtlasName capacity:[theString length]])) {

		opacity_ = 255;
		color_ = ccWHITE;

		contentSize_ = CGSizeZero;
		
		opacityModifyRGB_ = [[textureAtlas_ texture] hasPremultipliedAlpha];

		anchorPoint_ = ccp(0.5f, 0.5f);

		configuration = FNTConfigLoadFile(fntFile);
		[configuration retain];
		[self setString:theString];
	}

	return self;
}

-(void) dealloc
{
	[string_ release];
	[configuration release];
	[super dealloc];
}

//
// obtain the texture atlas image
//
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile
{
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:fntFile];
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:nil];

	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	NSEnumerator *nse = [lines objectEnumerator];
	NSString *line;
	NSString *propertyValue = nil; // ret value
	
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// Check to see if the start of the line is something we are interested in
		if([line hasPrefix:@"page id="]) {
			
			// Break the values for this line up using =
			NSArray *values = [line componentsSeparatedByString:@"="];
			
			// Get the enumerator for the array of components which has been created
			NSEnumerator *nse = [values objectEnumerator];
			
			// We need to move past the first entry in the array before we start assigning values
			[nse nextObject];
			
			// page ID. Sanity check
			propertyValue = [nse nextObject];
			NSAssert( [propertyValue intValue] == 0, @"XXX: BitmapFontAtlas only supports 1 page");
			
			// file 
			propertyValue = [nse nextObject];
			NSArray *array = [propertyValue componentsSeparatedByString:@"\""];
			propertyValue = [array objectAtIndex:1];
			break;
		}
	}
	// Finished with lines so release it
	[lines release];	
	
	NSAssert(propertyValue,@"BitmapFontAtlas file could not be found");

	NSString *textureAtlasName = [CCFileUtils fullPathFromRelativePath:propertyValue];
	NSString *relDirPathOfTextureAtlas = [fntFile stringByDeletingLastPathComponent];
	return [relDirPathOfTextureAtlas stringByAppendingPathComponent:textureAtlasName];
}

#pragma mark BitmapFontAtlas - Atlas generation

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second
{
	int ret = 0;
	tKerningHashElement elementTmp;
	elementTmp.first = first;
	elementTmp.second = second;
	unsigned int key = (first<<16) | (second & 0xffff);
	
	if( configuration->kerningDictionary ) {
		tKerningHashElement *element = ccHashSetFind(configuration->kerningDictionary, CC_HASH_INT(key), &elementTmp);
		
		if(element)
			ret = element->amount;
	}
		
	return ret;
}

-(void) createFontChars
{
	int nextFontPositionX = 0;
	unichar prev = -1;
	int kerningAmount = 0;
	
	CGSize tmpSize = CGSizeZero;

	NSUInteger l = [string_ length];
	for(NSUInteger i=0; i<l; i++) {
		unichar c = [string_ characterAtIndex:i];
		NSAssert( c < kBitmapFontAtlasMaxChars, @"BitmapFontAtlas: character outside bounds");
		
		kerningAmount = [self kerningAmountForFirst:prev second:c];
		
		ccBitmapFontDef fontDef = configuration->bitmapFontArray[c];
		
		CGRect rect = fontDef.rect;
		
		CCSprite *fontChar;
		
		fontChar = (CCSprite*) [self getChildByTag:i];
		if( ! fontChar ) {
			fontChar = [[CCSprite alloc] initWithSpriteSheet:self rect:rect];
			[self addChild:fontChar z:0 tag:i];
			[fontChar release];
		}
		else {
			// reusing fonts
			[fontChar setTextureRect:rect];
			
			// restore to default in case they were modified
			fontChar.visible = YES;
			fontChar.opacity = 255;
		}

		fontChar.position = ccp( nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width / 2.0f ,
								(configuration->commonHeight - fontDef.yOffset) - rect.size.height/2.0f );		
		
//		NSLog(@"position.y: %f", fontChar.position.y);
		
		// update kerning
		fontChar.position = ccpAdd( fontChar.position, ccp(kerningAmount,0));
		nextFontPositionX += configuration->bitmapFontArray[c].xAdvance + kerningAmount;
		prev = c;
		
		tmpSize.width += configuration->bitmapFontArray[c].xAdvance + kerningAmount;
		tmpSize.height = configuration->commonHeight;
		
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:color_];

		// only apply opaccity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if( opacity_ != 255 )
			[fontChar setOpacity: opacity_];
	}
	
	[self setContentSize:tmpSize];
}

#pragma mark BitmapFontAtlas - CCLabelProtocol protocol
- (void) setString:(NSString*) newString
{	
	[string_ release];
	string_ = [newString retain];

	for( CCNode *child in children_ )
		child.visible = NO;

	[self createFontChars];
}

#pragma mark BitmapFontAtlas - CCRGBAProtocol protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	for( CCSprite* child in children_ )
		[child setColor:color_];
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;

 	for( id<CCRGBAProtocol> child in children_ )
		[child setOpacity:opacity_];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
 	for( id<CCRGBAProtocol> child in children_ )
		[child setOpacityModifyRGB:modify];
}
-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

#pragma mark BitmapFontAtlas - AnchorPoint
-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, anchorPoint_) ) {
		[super setAnchorPoint:point];
		[self createFontChars];
	}
}

#pragma mark BitmapFontAtlas - Debug draw
#if CC_BITMAPFONTATLAS_DEBUG_DRAW
-(void) draw
{
	[super draw];
	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}
#endif // CC_BITMAPFONTATLAS_DEBUG_DRAW
@end
