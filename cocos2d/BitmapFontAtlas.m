/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

@interface BitmapFontAtlas (Private)
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile;

-(void) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBitmapFontDef*)characterDefinition;
-(void) parseCommonArguments:(NSString*)line;
@end

@implementation BitmapFontAtlas

@synthesize atlas = textureAtlas_;

#pragma mark BitmapFontAtlas - Creation & Init
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile alignment:(UITextAlignment)alignment
{
	return [[[self alloc] initWithString:string fntFile:fntFile alignment:alignment] autorelease];
}


-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile alignment:(UITextAlignment)alignment
{
	NSString *textureAtlasName = [self atlasNameFromFntFile:fntFile];
	
	if ((self=[super initWithFile:textureAtlasName capacity:[theString length]])) {

		alignment_ = alignment;

		[self parseConfigFile:fntFile];
		
		[self setString:theString];

	}

	return self;
}

-(void) dealloc
{
	[string_ release];
	[super dealloc];
}

//
// obtain the texture atlas image
//
-(NSString*) atlasNameFromFntFile:(NSString*)fntFile
{
	NSString *fullpath = [FileUtils fullPathFromRelativePath:fntFile];
	NSString *contents = [NSString stringWithContentsOfFile:fullpath];
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	NSEnumerator *nse = [lines objectEnumerator];
	NSString *line;		
	NSString *propertyValue; // ret value
	
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
			
			// page ID (ignore)
			propertyValue = [nse nextObject];
			
			// file 
			propertyValue = [nse nextObject];
			NSArray *array = [propertyValue componentsSeparatedByString:@"\""];
			propertyValue = [array objectAtIndex:1];
			break;
		}		
	}
	// Finished with lines so release it
	[lines release];	
	
	return propertyValue;
}

#pragma mark BitmapFontAtlas - FNT parser
- (void)parseConfigFile:(NSString*)fntFile
{	
	NSString *fullpath = [FileUtils fullPathFromRelativePath:fntFile];
	NSString *contents = [NSString stringWithContentsOfFile:fullpath];
	
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
			
		}		
	}
	// Finished with lines so release it
	[lines release];	
}

-(void) parseCommonArguments:(NSString*)line
{
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Character ID
	propertyValue = [nse nextObject];
	commonHeight = [propertyValue intValue];
	
	// ignore the rest parameters
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

#pragma mark BitmapFontAtlas - Atlas generation

-(void) createFontChars
{
	int nextFontPositionX = 0;

	NSUInteger l = [string_ length];
	for(NSUInteger i=0; i<l; i++) {
		unichar c = [string_ characterAtIndex:i];
		
		ccBitmapFontDef fontDef = bitmapFontArray[c];
		
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
		
		if( alignment_ == UITextAlignmentCenter ) {

			// center aligned ?
			fontChar.position = ccp( nextFontPositionX + fontDef.xOffset + fontDef.xAdvance/2.0f, (commonHeight/2.0f - fontDef.yOffset) - rect.size.height/2.0f );
			[fontChar setAutoCenterFrames:YES];

		} else if (alignment_ == UITextAlignmentLeft ) {
			// left aligned
			fontChar.transformAnchor = CGPointZero;
			fontChar.position = ccp( nextFontPositionX + fontDef.xOffset, (commonHeight - fontDef.yOffset) - rect.size.height );

		} else if( alignment_ == UITextAlignmentRight ) {
			// left aligned
			fontChar.transformAnchor = CGPointZero;
			fontChar.position = ccp( nextFontPositionX + fontDef.xOffset, (commonHeight - fontDef.yOffset) - rect.size.height );			
		}
		
		nextFontPositionX += bitmapFontArray[c].xAdvance;
	}
	
	if( alignment_ == UITextAlignmentCenter ) {
		for(CocosNode *node in children)
			node.position = ccpSub( node.position, ccp( nextFontPositionX/2.0f,0) );
	} else if( alignment_ == UITextAlignmentRight) {
		for(CocosNode *node in children)
			node.position = ccpSub( node.position, ccp( nextFontPositionX,0) );
	}
}

- (void) setString:(NSString*) newString
{	
	[string_ release];
	string_ = [newString retain];

	for( CocosNode *child in children )
		child.visible = NO;

	[self createFontChars];
}

@end
