/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "CCLabelBMFont_Private.h"

#import "CCDeviceInfo.h"
#import "CCTexture.h"
#import "CCTextureCache.h"
#import "CCFileUtils.h"
#import "CCColor.h"
#import "ccUtils.h"
#import "CCDrawNode.h"
#import "CCNS.h"

#pragma mark -
#pragma mark CCBMFontCharacter 

@implementation CCBMFontCharacter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setCharacterValue:-1];
        [self setControlFollowing:NoControlFollows];
    }
    return self;
}

- (NSString *)description
{
    NSString *controlChar = @"";
    if (_controlFollowing & WordBreakFollows)
    {
        controlChar = [NSString stringWithFormat:@"%@ wb", controlChar];
    }
    if (_controlFollowing & HardLineBreakFollows)
    {
        controlChar = [NSString stringWithFormat:@"%@ lf", controlChar];
    }
    if (_controlFollowing & SoftLineBreakFollows)
    {
        controlChar = [NSString stringWithFormat:@"%@ cr", controlChar];
    }
    controlChar = [controlChar stringByPaddingToLength:9 withString:@" " startingAtIndex:0];
    CGPoint pos = [self position];
    CGSize sz = [self contentSize];
    return [NSString stringWithFormat:@"\'%C\' %@ {%0.1f, %0.1f} %0.1fx%0.1f", _characterValue, controlChar, pos.x, pos.y, sz.width, sz.height];
}

@end

@implementation CCBMFontCharacterSequence
{
    CCBMFontCharacter *_firstRemovedCharacter;
    CCBMFontCharacter *_lastCharacter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commonHeight = 0.0f;
        _firstCharacter = nil;
        _lastCharacter = nil;
    }
    return self;
}

- (NSString *)description
{
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"CCBMFontCharacterSequence - commonHeight: %0.2f", _commonHeight]];
    for (CCBMFontCharacter *fc = [self firstCharacter]; fc; fc = [fc nextCharacter])
    {
        [lines addObject:[NSString stringWithFormat:@"> %@", fc]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

- (NSArray *)characterSpritesForRange:(NSRange)range
{
    NSMutableArray *results = [NSMutableArray array];
    NSUInteger stopIndex = range.location + range.length;
    NSUInteger index = 0;
    for (CCBMFontCharacter *fc = _firstCharacter; fc; fc = [fc nextCharacter])
    {
        if (index >= range.location)
        {
            [results addObject:fc];
        }
        if ([fc controlFollowing] & HardLineBreakFollows)
        {
            // White spaces ARE included as actual character sprites.
            // Soft line breaks should NOT be included as they were not
            // in the original string.
            // There is no actual character sprite in the sequence for the
            // "\n" hard line break - so account for it here
            ++index;
        }
        if (++index >= stopIndex) break;
    }
    return [results copy];
}

- (NSString *)stringForSequence
{
    NSMutableString *stringResult = [NSMutableString string];
    for (CCBMFontCharacter *fc = _firstCharacter; fc; fc = [fc nextCharacter])
    {
        [stringResult appendFormat:@"%C", [fc characterValue]];
        if ([fc controlFollowing] == HardLineBreakFollows)
        {
            [stringResult appendString:@"\n"];
        }
    }
    return [stringResult copy];
}

- (void)removeAllCharacters
{
    // Hide all characters
    for (CCBMFontCharacter *fc = _firstCharacter; fc; fc = [fc nextCharacter])
    {
        [fc setVisible:NO];
    }

    // walk to the end of the (possibly empty) list of removed characters and add the current
    // characters to the list of removed characters
    CCBMFontCharacter *lastRemoved = _firstRemovedCharacter;
    for ( ; lastRemoved; lastRemoved = [lastRemoved nextCharacter]) { }
    if (lastRemoved == nil)
    {
        _firstRemovedCharacter = _firstCharacter;
    }
    else
    {
        [lastRemoved setNextCharacter:_firstCharacter];
    }
    
    // make the list of characters empty
    _firstCharacter = nil;
    _lastCharacter = nil;
}

- (CCBMFontCharacter *)createNewCharacterForSequenceWithParent:(CCNode *)parent
{
    CCBMFontCharacter *newChar = nil;
    if (_firstRemovedCharacter == nil)
    {
        newChar = [[CCBMFontCharacter alloc] init];
        [parent addChild:newChar];
    }
    else
    {
        newChar = _firstRemovedCharacter;
        _firstRemovedCharacter = [_firstRemovedCharacter nextCharacter];
        [newChar setNextCharacter:nil];
        [newChar setCharacterValue:0];
        [newChar setControlFollowing:NoControlFollows];
        [newChar setVisible:YES];
        if ([newChar parent] != parent) // highly irregular but lets handle it
        {
            [newChar removeFromParent];
            [parent addChild:newChar];
        }
    }
    if (_firstCharacter == nil)
    {
        _firstCharacter = newChar;
    }
    else
    {
        [_lastCharacter setNextCharacter:newChar];
    }
    _lastCharacter = newChar;
    return newChar;
}

- (void)setAlignment:(CCTextAlignment)alignment
{
    [self align:alignment];
}

- (void)align:(CCTextAlignment)alignment
{
    CCLabelBMFont *lbl = (CCLabelBMFont *)[_firstCharacter parent];
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    CCBMFontCharacter *lineStart = _firstCharacter;
    CGSize sz = [lbl contentSize];
    BOOL isLineStart = YES;
    while (lineStart != nil)
    {
        // when aligning ignore whitespace characters at the start of the line
        // walk to the first non-whitespace character on the line
        while ([ws characterIsMember:[lineStart characterValue]])
        {
            lineStart = [lineStart nextCharacter];
            if (lineStart == nil) break;
        }
        CCBMFontCharacter *fontChar = _lastCharacter;
        float lineLHS = [lineStart position].x - [lineStart contentSize].width / 2.0f;
        for (CCBMFontCharacter *fc = lineStart; fc; fc = [fc nextCharacter])
        {
            if ([fc controlFollowing] & LineBreakFollows)
            {
                fontChar = fc;
                break;
            }
        }
        float lineRHS = [fontChar position].x + [fontChar contentSize].width/2;
        float lineWidth = lineRHS - lineLHS;
        
        //Figure out how much to shift each character in this line horizontally
        float shift = 0;
        switch (alignment) {
            case CCTextAlignmentCenter:
                shift = sz.width/2.0f - lineWidth/2.0f;
                break;
            case CCTextAlignmentRight:
                shift = sz.width - lineWidth;
            default:
                break;
        }
        shift -= lineLHS;
        
        if (shift != 0)
        {
            for (CCBMFontCharacter *fc = lineStart; fc; fc = [fc nextCharacter])
            {
                CGPoint fcPos = [fc position];
                fcPos.x += shift;
                [fc setPosition:fcPos];
                if (fc == fontChar) break;
            }
        }
        lineStart = [fontChar nextCharacter];
    }
}

- (void)fitToWidth:(float)width
{
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    BOOL expectingWordBoundary = NO;
    BOOL isNewLine = YES;
    float lineLHS = 0.0f;
    CCBMFontCharacter *wordBoundary = nil;
    CCBMFontCharacter *wordEnd = nil;
    CCBMFontCharacter *prevCharacter = _firstCharacter;
    for (CCBMFontCharacter *fc = _firstCharacter; fc; fc = [fc nextCharacter])
    {
        if ([ws characterIsMember:[fc characterValue]]) continue;
        float charLHS = [fc position].x - [fc contentSize].width / 2.0f;
        if (isNewLine)
        {
            lineLHS = charLHS;
            isNewLine = NO;
        }
        if ([fc controlFollowing] & WordBreakFollows)
        {
            expectingWordBoundary = YES;
        }
        else if (expectingWordBoundary)
        {
            wordBoundary = fc;
            expectingWordBoundary = NO;
        }
        float charRHS = [fc position].x + [fc contentSize].width / 2.0f;
        if (charRHS - lineLHS > width)
        {
            if (wordBoundary != nil)
            {
                [self insertLineBreakAtCharacter:wordBoundary];
                wordBoundary = nil;
                [wordEnd setControlFollowing:(WordBreakFollows | SoftLineBreakFollows)];
            }
            else
            {
                [self insertLineBreakAtCharacter:fc];
                [prevCharacter setControlFollowing:SoftLineBreakFollows];
            }
            expectingWordBoundary = NO;
            lineLHS = 0.0f;
        }
        if ([fc controlFollowing] & WordBreakFollows)
        {
            wordEnd = fc;
        }
        else if ([fc controlFollowing] & HardLineBreakFollows)
        {
            isNewLine = YES;
        }
        prevCharacter = fc;
    }
}

- (void)insertLineBreakAtCharacter:(CCBMFontCharacter *)character
{
    if (_commonHeight == 0.0f) return;
    
    float leftShift = [character position].x - [character contentSize].width/2.0f;
    for (CCBMFontCharacter *fc = character; fc; fc = [fc nextCharacter])
    {
        CGPoint newPos = [fc position];
        newPos.x = newPos.x - leftShift;
        newPos.y = newPos.y - _commonHeight;
        [fc setPosition:newPos];
        if ([fc controlFollowing] == LineBreakFollows)
        {
            leftShift = 0.0f;
        }
    }
}

- (CGSize)boundSize
{
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    CGSize result = CGSizeZero;
    float top = 0.0f, bottom = 0.0f, lhs = 0.0f, rhs = 0.0f;
    for (CCBMFontCharacter *fc = _firstCharacter; fc; fc = [fc nextCharacter])
    {
        if ([ws characterIsMember:[fc characterValue]]) continue;
        CGPoint charPos = [fc position];
        CGSize charSz = [fc contentSize];
        float charRHS = charPos.x + charSz.width / 2.0f;
        float charLHS = charPos.x - charSz.width / 2.0f;
        float charTop = charPos.y + charSz.height / 2.0f;
        float charBottom = charPos.y - charSz.height / 2.0f;
        if (fc == _firstCharacter)
        {
            top = charTop;
            bottom = charBottom;
            lhs = charLHS;
            rhs = charRHS;
        }
        else
        {
            top =    MAX(charTop, top);
            bottom = MIN(charBottom, bottom);
            lhs =    MIN(charLHS, lhs);
            rhs =    MAX(charRHS, rhs);
        }
    }
    result.width = rhs - lhs;
    result.height = top - bottom;
    return result;
}

@end

#pragma mark -
#pragma mark FNTConfig Cache - free functions

NSMutableDictionary *configurations = nil;
CCBMFontConfiguration* FNTConfigLoadFile( NSString *fntFile)
{
	CCBMFontConfiguration *ret = nil;
    
	if( configurations == nil )
		configurations = [NSMutableDictionary dictionaryWithCapacity:3];
    
	ret = [configurations objectForKey:fntFile];
	if( ret == nil ) {
		ret = [CCBMFontConfiguration configurationWithFNTFile:fntFile];
		if( ret )
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

@interface CCBMFontConfiguration ()
-(NSMutableString *) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition;
-(void) parseInfoArguments:(NSString*)line;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile;
-(void) parseKerningEntry:(NSString*)line;
-(void) purgeKerningDictionary;
-(void) purgeFontDefDictionary;
@end

#pragma mark -
#pragma mark CCBMFontConfiguration

@implementation CCBMFontConfiguration
@synthesize characterSet=_characterSet;
@synthesize atlasName=_atlasName;

+(instancetype) configurationWithFNTFile:(NSString*)FNTfile
{
	return [[self alloc] initWithFNTfile:FNTfile];
}

-(id) initWithFNTfile:(NSString*)fntFile
{
	if((self=[super init])) {
        
		_kerningDictionary = NULL;
		_fontDefDictionary = NULL;
    
		NSMutableString *validCharsString = [self parseConfigFile:fntFile];
		  
		if( ! validCharsString ) {
			return nil;
		}
    
		_characterSet = [NSCharacterSet characterSetWithCharactersInString:validCharsString];
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	[self purgeFontDefDictionary];
	[self purgeKerningDictionary];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Glphys:%d Kernings:%d | Image = %@>", [self class], self,
			HASH_COUNT(_fontDefDictionary),
			HASH_COUNT(_kerningDictionary),
			_atlasName];
}


-(void) purgeFontDefDictionary
{	
	tCCFontDefHashElement *current;
    tCCFontDefHashElement *tmp;
	
	HASH_ITER(hh, _fontDefDictionary, current, tmp) {
		HASH_DEL(_fontDefDictionary, current);
		free(current);
	}
}

-(void) purgeKerningDictionary
{
	tCCKerningHashElement *current;
    
	while(_kerningDictionary) {
		current = _kerningDictionary;
		HASH_DEL(_kerningDictionary,current);
		free(current);
	}
}

- (NSMutableString *)parseConfigFile:(NSString*)fntFile
{
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathForFilename:fntFile];
	NSError *error;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:&error];
  
	NSMutableString *validCharsString = [[NSMutableString alloc] initWithCapacity:512];
    
	if( ! contents ) {
		CCLOGWARN(@"cocos2d: Error parsing FNTfile %@: %@", fntFile, error);
		return nil;
	}
    
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
		else if([line hasPrefix:@"page id"]) {
			[self parseImageFileName:line fntFile:fntFile];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			tCCFontDefHashElement *element = malloc( sizeof(*element) );
			
			[self parseCharacterDefinition:line charDef:&element->fontDef];
			
			element->key = element->fontDef.charID;
			HASH_ADD_INT(_fontDefDictionary, key, element);
      
            [validCharsString appendFormat:@"%C", element->fontDef.charID];
		}
//		else if([line hasPrefix:@"kernings count"]) {
//			[self parseKerningCapacity:line];
//		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	
	return validCharsString;
}

-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile
{
	NSString *propertyValue = nil;
    
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
    
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// page ID. Sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 0, @"XXX: LabelBMFont only supports 1 page");
    
	// file
	propertyValue = [nse nextObject];
	NSArray *array = [propertyValue componentsSeparatedByString:@"\""];
	propertyValue = [array objectAtIndex:1];
	NSAssert(propertyValue,@"LabelBMFont file could not be found");
    
	// Supports subdirectories
	NSString *dir = [fntFile stringByDeletingLastPathComponent];
	_atlasName = [dir stringByAppendingPathComponent:propertyValue];
    
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
		_padding.top = [propertyValue intValue];
        
		// padding right
		propertyValue = [paddingEnum nextObject];
		_padding.right = [propertyValue intValue];
        
		// padding bottom
		propertyValue = [paddingEnum nextObject];
		_padding.bottom = [propertyValue intValue];
        
		// padding left
		propertyValue = [paddingEnum nextObject];
		_padding.left = [propertyValue intValue];
        
		CCLOG(@"cocos2d: padding: %d,%d,%d,%d", _padding.left, _padding.top, _padding.right, _padding.bottom);
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
	_commonHeight = [propertyValue intValue];
    
	// base (ignore)
	[nse nextObject];
    
    
	// scaleW. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCDeviceInfo sharedDeviceInfo] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
	// scaleH. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCDeviceInfo sharedDeviceInfo] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
	// pages. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 1, @"CCBitfontAtlas: only supports 1 page");
    
	// packed (ignore) What does this mean ??
}
- (void)parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition
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
    
	tCCKerningHashElement *element = calloc( sizeof( *element ), 1 );
	element->amount = amount;
	element->key = (first<<16) | (second&0xffff);
	HASH_ADD_INT(_kerningDictionary,key, element);
}

@end

#pragma mark -
#pragma mark CCLabelBMFont

@interface CCLabelBMFont ()

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second;
-(void) updateLabel;

@end

#pragma mark -
#pragma mark CCLabelBMFont

@implementation CCLabelBMFont {
    
	// The text displayed by the label.
	NSString *_string;
    
	// The font file of the text.
	NSString *_fntFile;

	// The maximum width allowed before a line break will be inserted.
	float _width;
	
	// The technique used for horizontal aligning of the text.
	CCTextAlignment _alignment;
	
	// Parsed configuration of the font file.
	CCBMFontConfiguration	*_configuration;
    
	// Offset of the texture atlas.
	CGPoint _imageOffset;
	
    CCTexture *_texture;
    
    CCBMFontCharacterSequence *_characterSprites;
}

@synthesize alignment = _alignment;

#pragma mark LabelBMFont - Purge Cache
+(void) purgeCachedData
{
	FNTConfigRemoveCache();
}

#pragma mark LabelBMFont - Creation & Init

+(instancetype) labelWithString:(NSString *)string fntFile:(NSString *)fntFile
{
	return [[self alloc] initWithString:string fntFile:fntFile width:kCCLabelAutomaticWidth alignment:CCTextAlignmentLeft imageOffset:CGPointZero];
}

+(instancetype) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
    return [[self alloc] initWithString:string fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero];
}

+(instancetype) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
    return [[self alloc] initWithString:string fntFile:fntFile width:width alignment:alignment imageOffset:offset];
}

-(id) init
{
	return [self initWithString:nil fntFile:nil width:kCCLabelAutomaticWidth alignment:CCTextAlignmentLeft imageOffset:CGPointZero];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile
{
    return [self initWithString:theString fntFile:fntFile width:kCCLabelAutomaticWidth alignment:CCTextAlignmentLeft];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
	return [self initWithString:theString fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero];
}

// designated initializer
-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
	NSAssert(!_configuration, @"re-init is no longer supported");
	
	// if theString && fntfile are both nil, then it is OK
	NSAssert( (theString && fntFile) || (theString==nil && fntFile==nil), @"Invalid params for CCLabelBMFont");
	
	CCTexture *texture = nil;
    CCBMFontConfiguration *newConf = nil;
    
	if( fntFile ) {
		newConf = FNTConfigLoadFile(fntFile);
		if(!newConf) {
			CCLOGWARN(@"cocos2d: WARNING. CCLabelBMFont: Impossible to create font. Please check file: '%@'", fntFile );
			return nil;
		}
        
		texture = [[CCTextureCache sharedTextureCache] addImage:newConf.atlasName];
	} else {
		texture = [[CCTexture alloc] init];
	}
    
	if((self = [super init])){
		if (fntFile){
			_configuration = newConf;
			_fntFile = [fntFile copy];
		}
		
		_texture = texture;
		_width = width;
		_alignment = alignment;
        _characterSprites = [[CCBMFontCharacterSequence alloc] init];
		
		self.color = [CCColor whiteColor];
		self.cascadeOpacityEnabled = YES;
		self.cascadeColorEnabled = YES;
		
		self.contentSize = CGSizeZero;
		
		self.anchorPoint = ccp(0.5f, 0.5f);
        
		_imageOffset = offset;
        
		[self setString:theString];
	}
    
	return self;
}

- (void)setEnableDebugDrawing:(BOOL)enableDebugDrawing
{
    _enableDebugDrawing = enableDebugDrawing;
    if (enableDebugDrawing)
    {
        [self debugDraw];
    }
    else
    {
        CCDrawNode *drawNode = (CCDrawNode *)[self getChildByName:@"debugDraw" recursively:NO];
        if (drawNode != nil)
        {
            [drawNode removeFromParent];
        }
    }
}


#pragma mark LabelBMFont - Alignment

- (void)updateLabel
{
    if (_width > 0)
    {
        [_characterSprites fitToWidth:_width];
    }
    [self setContentSize:[_characterSprites boundSize]];
    
    [_characterSprites setAlignment:[self alignment]];
    [self setContentSize:[_characterSprites boundSize]];
    
    float top = 0.0f;
    for (CCBMFontCharacter *fc = [_characterSprites firstCharacter]; fc; fc = [fc nextCharacter])
    {
        float charTop = [fc position].y + [fc contentSize].height / 2.0f;
        top = MAX(charTop, top);
    }
    float yShift = [self contentSize].height - top;
    if (yShift != 0.0f)
    {
        for (CCBMFontCharacter *fc = [_characterSprites firstCharacter] ; fc; fc = [fc nextCharacter])
        {
            CGPoint pos = [fc position];
            pos.y += yShift;
            [fc setPosition:pos];
        }
    }

    if ([self enableDebugDrawing])
    {
        [self debugDraw];
    }
}

- (NSArray *)characterSpritesForRange:(NSRange)range
{
    return [_characterSprites characterSpritesForRange:range];
}

#pragma mark LabelBMFont - Atlas generation

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second
{
	int ret = 0;
	unsigned int key = (first<<16) | (second & 0xffff);
    
	if( _configuration->_kerningDictionary ) {
		tCCKerningHashElement *element = NULL;
		HASH_FIND_INT(_configuration->_kerningDictionary, &key, element);
		if(element)
			ret = element->amount;
	}
    
	return ret;
}

-(void) createFontChars
{
	NSInteger nextFontPositionX = 0;
	NSInteger nextFontPositionY = 0;
	unichar prev = -1;
	NSInteger kerningAmount = 0;
	NSUInteger quantityOfLines = 1;
	NSCharacterSet *charSet	= _configuration.characterSet;
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    NSCharacterSet *nl = [NSCharacterSet newlineCharacterSet];
	NSUInteger stringLen = [_string length];
	if( ! stringLen )
		return;
    
	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(NSUInteger i=0; i < stringLen-1;i++) {
		unichar c = [_string characterAtIndex:i];
		if([[NSCharacterSet newlineCharacterSet] characterIsMember:c])
			quantityOfLines++;
	}
    
	nextFontPositionY = -(_configuration->_commonHeight - _configuration->_commonHeight*quantityOfLines);
    CGRect rect;
    ccBMFontDef fontDef = (ccBMFontDef){};
	
	CGFloat contentScale = 1.0/_texture.contentScale;
    [_characterSprites setCommonHeight:contentScale * _configuration->_commonHeight];
    CCBMFontCharacter *previousChar = nil;
	for(NSUInteger i = 0; i<stringLen; i++)
    {
		unichar c = [_string characterAtIndex:i];
        
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
			nextFontPositionX = 0;
			nextFontPositionY -= _configuration->_commonHeight;
            [previousChar setControlFollowing:HardLineBreakFollows];
			continue;
		}
    
		if(![charSet characterIsMember:c]){
			CCLOGWARN(@"cocos2d: CCLabelBMFont: Attempted to use character not defined in this bitmap: %C", c);
			continue;
		}
        
		kerningAmount = [self kerningAmountForFirst:prev second:c];
		
		tCCFontDefHashElement *element = NULL;
		
		// unichar is a short, and an int is needed on HASH_FIND_INT
		NSUInteger key = (NSUInteger)c;
		HASH_FIND_INT(_configuration->_fontDefDictionary , &key, element);
		if( ! element ) {
			CCLOGWARN(@"cocos2d: CCLabelBMFont: characer not found %c", c);
			continue;
		}
		
		fontDef = element->fontDef;
		
		rect = CC_RECT_SCALE(fontDef.rect, contentScale);
		
		rect.origin.x += _imageOffset.x;
		rect.origin.y += _imageOffset.y;
        
        CCBMFontCharacter *fontChar = [_characterSprites createNewCharacterForSequenceWithParent:self];
        [fontChar setTexture:_texture];
        [fontChar setTextureRect:rect];
        [fontChar updateDisplayedColor:_displayColor];
        [fontChar updateDisplayedOpacity:_displayColor.a];
        [fontChar setCharacterValue:c];
        if ([ws characterIsMember:c])
        {
            [previousChar setControlFollowing:WordBreakFollows];
        }
        
		// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
		NSInteger yOffset = _configuration->_commonHeight - fontDef.yOffset;
		CGPoint fontPos = ccp( (CGFloat)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
							  (CGFloat)nextFontPositionY + yOffset - rect.size.height*0.5f * _texture.contentScale );
		fontChar.position = ccpMult(fontPos, contentScale);
		
		// update kerning
		nextFontPositionX += fontDef.xAdvance + kerningAmount;
		prev = c;
        
        previousChar = fontChar;
	}
    
	[self setContentSize:CC_SIZE_SCALE([_characterSprites boundSize], contentScale)];
    
    if ([self enableDebugDrawing])
    {
        [self debugDraw];
    }
}

#pragma mark LabelBMFont - CCLabelProtocol protocol
-(NSString*) string
{
	return _string;
}

-(void) setCString:(char*)label
{
	[self setString:[NSString stringWithUTF8String:label] ];
}

- (void) setString:(NSString*)newString
{
    if (![_string isEqualToString:newString])
    {
        _string = [newString copy];
        
        [_characterSprites removeAllCharacters];
        
        [self createFontChars];
        [self updateLabel];
    }
}

#pragma mark LabelBMFont - AnchorPoint
-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, self.anchorPoint) )
    {
		[super setAnchorPoint:point];
		[self updateLabel];
	}
}

#pragma mark LabelBMFont - Alignment
- (void)setWidth:(float)width {
    float oldWidth = _width;
    _width = width;
    if (_width != oldWidth)
    {
        [_characterSprites removeAllCharacters];
        [self createFontChars];
    }
    [self updateLabel];
}

- (void)setAlignment:(CCTextAlignment)alignment {
    _alignment = alignment;
    [self updateLabel];
}

#pragma mark LabelBMFont - FntFile
- (void) setFntFile:(NSString*) fntFile
{
	if( fntFile != _fntFile ) {

		CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);

        // Always throw this exception instead of NSAssert to let a consumer handle
        // errors gracefully in environments with disabled assertions(e.g. release builds).
        // Otherwise createFontChars can crash with a nasty segmentation fault.
        if (!newConf)
        {
            [NSException raise:@"Invalid font file" format:@"CCLabelBMFont: Impossible to create font. Please check file: '%@'", fntFile];
        }

		_fntFile = fntFile;

		_configuration = newConf;

		_texture = [CCTexture textureWithFile:_configuration.atlasName];
		[self createFontChars];
	}
}

- (NSString*) fntFile
{
    return _fntFile;
}

#pragma mark LabelBMFont - Debug draw
-(void)debugDraw
{
    [[self getChildByName:@"debugDraw" recursively:NO] removeFromParent];
    CCDrawNode *drawNode = [[CCDrawNode alloc] init];
    [self addChild:drawNode];
    [drawNode setName:@"debugDraw"];
    CGSize s = [self contentSize];
    CGPoint vertices[4]={
        ccp(0,0),ccp(s.width,0),
        ccp(s.width,s.height),ccp(0,s.height),
    };
    CCColor *fill = [CCColor colorWithGLKVector4:GLKVector4Make(0.0f, 0.9f, 0.2f, 0.1f)];
    CCColor *border = [CCColor colorWithGLKVector4:GLKVector4Make(0.0f, 0.9f, 0.2f, 1.0f)];
    [drawNode drawPolyWithVerts:vertices count:4 fillColor:fill borderWidth:1.0f borderColor:border];
    
    if (_width > 0)
    {
        CGPoint vertWraps[4]={
            ccp(1,1),ccp(_width,1),
            ccp(_width,s.height-1),ccp(1,s.height-1),
        };
        CCColor *wrapFill = [CCColor colorWithGLKVector4:GLKVector4Make(0.9f, 0.2f, 0.0f, 0.1f)];
        CCColor *wrapBorder = [CCColor colorWithGLKVector4:GLKVector4Make(0.9f, 0.2f, 0.0f, 1.0f)];
        [drawNode drawPolyWithVerts:vertWraps count:4 fillColor:wrapFill borderWidth:1.0f borderColor:wrapBorder];
    }
    
    for (CCBMFontCharacter *fc = [_characterSprites firstCharacter]; fc; fc = [fc nextCharacter])
    {
        CGSize sz = [fc contentSize];
        CGPoint pos = [fc position];
        float ht = sz.height / 2.0f;
        float wd = sz.width / 2.0f;
        CGPoint vertFC[4]={
            ccp(pos.x - wd, pos.y - ht),ccp(pos.x + wd, pos.y - ht),
            ccp(pos.x + wd,pos.y + ht),ccp(pos.x - wd, pos.y + ht),
        };
        CCColor *wrapFill = [CCColor colorWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 0.1f)];
        CCColor *wrapBorder = [CCColor colorWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 0.9f)];
        [drawNode drawPolyWithVerts:vertFC count:4 fillColor:wrapFill borderWidth:0.5f borderColor:wrapBorder];
    }
}
@end
