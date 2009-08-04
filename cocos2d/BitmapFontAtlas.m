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
 * Use this editor to generate bitmap font atlas:
 *  http://slick.cokeandcode.com/demos/hiero.jnlp
 */

#import "BitmapFontAtlas.h"
#import "AtlasSprite.h"
#import "Support/FileUtils.h"
#import "Support/CGPointExtension.h"


#pragma mark -
#pragma mark FNTConfig Cache - free functions

NSMutableDictionary *configurations = nil;
BitmapFontConfiguration* FNTConfigLoadFile( NSString *fntFile)
{
	BitmapFontConfiguration *ret = nil;
	
	if( configurations == nil )
		configurations = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
	
	ret = [configurations objectForKey:fntFile];
	if( ret == nil ) {
		ret = [BitmapFontConfiguration configurationWithFNTFile:fntFile];
		[configurations setObject:ret forKey:fntFile];
	}
	
	return ret;
}

void FNTConfigRemoveCache( void )
{
	[configurations removeAllObjects];
}

#pragma mark -
#pragma mark BitmapFontConfiguration


@interface BitmapFontConfiguration (Private)
-(void) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBitmapFontDef*)characterDefinition;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseKerningCapacity:(NSString*)line;
-(void) parseKerningEntry:(NSString*)line;
@end

@implementation BitmapFontConfiguration

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
	CCLOG( @"deallocing %@", self);
	[kerningDictionary release];
	[super dealloc];
}

- (void)parseConfigFile:(NSString*)fntFile
{	
	NSString *fullpath = [FileUtils fullPathFromRelativePath:fntFile];
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:nil];
	
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// Check to see if the start of the line is something we are interested in
		if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		} else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			ccBitmapFontDef characterDefinition;
			[self parseCharacterDefinition:line charDef:&characterDefinition];
			
			// Add the CharDef returned to the charArray
			bitmapFontArray[ characterDefinition.charID ] = characterDefinition;
		}	else if([line hasPrefix:@"kernings count"]) {
			[self parseKerningCapacity:line];
		} else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];	
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
	
	// pages
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
	characterDefinition->charID = [propertyValue intValue];
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
		kerningDictionary = [[NSMutableDictionary dictionaryWithCapacity: [propertyValue intValue]] retain];
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
	int ammount = [propertyValue intValue];
	
	NSString *key = [NSString stringWithFormat:@"%d,%d", first, second];
	NSNumber *value = [NSNumber numberWithInt:ammount];
	
	[kerningDictionary setObject:value forKey:key];
}

@end

#pragma mark -
#pragma mark BitmapFontAtlas

@interface BitmapFontAtlas (Private)
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile;

-(int) kerningAmmountForFirst:(unichar)first second:(unichar)second;

@end

@implementation BitmapFontAtlas

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
	NSString *fullpath = [FileUtils fullPathFromRelativePath:fntFile];
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
	
	return [FileUtils fullPathFromRelativePath:propertyValue];
}

#pragma mark BitmapFontAtlas - FNT parser


#pragma mark BitmapFontAtlas - Atlas generation

-(int) kerningAmmountForFirst:(unichar)first second:(unichar)second
{
	int ret = 0;
	NSString *key = [NSString stringWithFormat:@"%d,%d", first, second];
	NSNumber *value = [configuration->kerningDictionary objectForKey:key];
	if(value)
		ret = [value intValue];
		
	return ret;
}

-(void) createFontChars
{
	int nextFontPositionX = 0;
	unichar prev = -1;
	int kerningAmmount = 0;
	
	CGSize tmpSize = CGSizeZero;

	NSUInteger l = [string_ length];
	for(NSUInteger i=0; i<l; i++) {
		unichar c = [string_ characterAtIndex:i];
		
		kerningAmmount = [self kerningAmmountForFirst:prev second:c];
		
		ccBitmapFontDef fontDef = configuration->bitmapFontArray[c];
		
		CGRect rect = fontDef.rect;
		
		AtlasSprite *fontChar;
		
		fontChar = (AtlasSprite*) [self getChildByTag:i];
		if( ! fontChar ) {
			fontChar = [AtlasSprite spriteWithRect:rect spriteManager:self];
			[self addChild:fontChar z:0 tag:i];
		}
		else
			[fontChar setTextureRect:rect];

		fontChar.visible = YES;

		fontChar.position = ccp( nextFontPositionX + fontDef.xOffset + fontDef.xAdvance/2.0f, (configuration->commonHeight - fontDef.yOffset) - rect.size.height/2.0f );
		
//		NSLog(@"position.y: %f", fontChar.position.y);
		
		// update kerning
		fontChar.position = ccpAdd( fontChar.position, ccp(kerningAmmount,0));
		nextFontPositionX += configuration->bitmapFontArray[c].xAdvance + kerningAmmount;
		prev = c;
		
		tmpSize.width += configuration->bitmapFontArray[c].xAdvance + kerningAmmount;
		tmpSize.height = MAX( rect.size.height, contentSize_.height);
		
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:color_];
		[fontChar setOpacity: opacity_];
	}
	
	[self setContentSize:tmpSize];
}

#pragma mark BitmapFontAtlas - CocosNodeLabel protocol
- (void) setString:(NSString*) newString
{	
	[string_ release];
	string_ = [newString retain];

	for( CocosNode *child in children )
		child.visible = NO;

	[self createFontChars];
}

#pragma mark BitmapFontAtlas - CocosNodeRGBA protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	for( AtlasSprite* child in children )
		[child setColor:color_];
}

-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b
{
	[self setColor:ccc3(r,g,b)];
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;

	for( id child in children )
		[child setOpacity:opacity_];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
	for( id child in children)
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
@end
