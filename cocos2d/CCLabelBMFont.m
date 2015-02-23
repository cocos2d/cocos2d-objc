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

#import "ccConfig.h"
#import "ccMacros.h"
#import "CCLabelBMFont.h"
#import "CCSprite.h"
#import "CCConfiguration.h"
#import "CCTexture.h"
#import "CCTextureCache.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/uthash.h"
#import "CCLabelBMFont_Private.h"
#import "CCSprite_Private.h"

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
		NSLog(@"cocos2d: Error parsing FNTfile %@: %@", fntFile, error);
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
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
	// scaleH. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
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
-(void) setString:(NSString*) newString updateLabel:(BOOL)update;

@end

#pragma mark -
#pragma mark CCLabelBMFont

@implementation CCLabelBMFont {
    
	// The text displayed by the label.
	NSString *_string;
    
	// The font file of the text.
	NSString *_fntFile;
	
	// The original text excluding line breaks.
	NSString *_initialString;
	
	// The maximum width allowed before a line break will be inserted.
	float _width;
	
	// The technique used for horizontal aligning of the text.
	CCTextAlignment _alignment;
	
	// Parsed configuration of the font file.
	CCBMFontConfiguration	*_configuration;
    
	// Offset of the texture atlas.
	CGPoint _imageOffset;
	
	// Reused char.
	CCSprite *_reusedChar;
	
	// Replacement for the old CCNode.tag property which was
	// used heavily in the original code.
	NSMutableArray *_childForTag;
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
		
		self.texture = texture;
		_width = width;
		_alignment = alignment;
		
		_displayColor = _color = [CCColor whiteColor].ccColor4f;
		_cascadeOpacityEnabled = YES;
		_cascadeColorEnabled = YES;
		
		_contentSize = CGSizeZero;
		
		_anchorPoint = ccp(0.5f, 0.5f);
        
		_imageOffset = offset;
        
		_reusedChar = [[CCSprite alloc] initWithTexture:self.texture rect:CGRectMake(0, 0, 0, 0) rotated:NO];
		_childForTag = [NSMutableArray array];
		
		[self setString:theString updateLabel:YES];
	}
    
	return self;
}

-(CCSprite *)childForTag:(NSUInteger)tag
{
	if(tag < _childForTag.count){
		id child = _childForTag[tag];
		return (child == [NSNull null] ? nil : child);
	} else {
		return nil;
	}
}

-(void)setTag:(NSUInteger)tag forChild:(CCSprite *)child
{
	if(tag < _childForTag.count){
		// Replace the value normally.
		[_childForTag replaceObjectAtIndex:tag withObject:child];
	} else {
		// The array is expanding.
		// Insert NSNull to fill holes if necessary since NSArray cannot be sparse.
		while(_childForTag.count < tag) [_childForTag addObject:[NSNull null]];
		[_childForTag addObject:child];
	}
}


#pragma mark LabelBMFont - Alignment

- (void)updateLabel
{	
    [self setString:_initialString updateLabel:NO];
	
    if (_width > 0){
        //Step 1: Make multiline
		
        NSString *multilineString = @"", *lastWord = @"";
        int line = 1, i = 0;
        NSUInteger stringLength = [self.string length];
        float startOfLine = -1, startOfWord = -1;
        int skip = 0;
        //Go through each character and insert line breaks as necessary
        for (int j = 0; j < [_children count]; j++) {
            CCSprite *characterSprite;
            int justSkipped = 0;
            while(!(characterSprite = [self childForTag:j+skip+justSkipped]))
                justSkipped++;
            skip += justSkipped;
			
            if (!characterSprite.visible)
				continue;
			
            if (i >= stringLength || i < 0)
                break;
			
            unichar character = [self.string characterAtIndex:i];
			
            if (startOfWord == -1)
                startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
            if (startOfLine == -1)
                startOfLine = startOfWord;
			
            //Character is a line break
            //Put lastWord on the current line and start a new line
            //Reset lastWord
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) {
                lastWord = [lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                lastWord = [lastWord stringByPaddingToLength:[lastWord length] + justSkipped withString:[NSString stringWithFormat:@"%C", character] startingAtIndex:0];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                line++;
                startOfLine = -1;
                i+=justSkipped;
				
                //CCLabelBMFont do not have a character for new lines, so do NOT "continue;" in the for loop. Process the next character
                if (i >= stringLength || i < 0)
                    break;
                character = [self.string characterAtIndex:i];
				
                if (startOfWord == -1)
                    startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
                if (startOfLine == -1)
                    startOfLine = startOfWord;
            }
			
            //Character is a whitespace
            //Put lastWord on current line and continue on current line
            //Reset lastWord
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:character]) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                i++;
                continue;
            }
			
            //Character is out of bounds
            //Do not put lastWord on current line. Add "\n" to current line to start a new line
            //Append to lastWord
            if (characterSprite.position.x + characterSprite.contentSize.width/2 - startOfLine >  _width) {
                NSString *trimmedString = [lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                lastWord = [[trimmedString stringByAppendingString:@"\n"] stringByAppendingFormat:@"%C", character];
                line++;
                startOfLine = -1;
                startOfWord = -1;
                i++;
                continue;
            } else {
                //Character is normal
                //Append to lastWord
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                i++;
                continue;
            }
        }
		
        multilineString = [multilineString stringByAppendingFormat:@"%@", lastWord];
		
        [self setString:multilineString updateLabel:NO];
    }
	
    //Step 2: Make alignment
	
    if (self.alignment != CCTextAlignmentLeft) {
		
        int i = 0;
        //Number of spaces skipped
        int lineNumber = 0;
        //Go through line by line
        for (NSString *lineString in [_string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            int lineWidth = 0;
			
            //Find index of last character in this line
            NSInteger index = i + [lineString length] - 1 + lineNumber;
            if (index < 0)
                continue;
			
            //Find position of last character on the line
            CCSprite *lastChar = [self childForTag:index];
			
            lineWidth = lastChar.position.x + lastChar.contentSize.width/2;
			
            //Figure out how much to shift each character in this line horizontally
            float shift = 0;
            switch (self.alignment) {
                case CCTextAlignmentCenter:
                    shift = self.contentSize.width/2 - lineWidth/2;
                    break;
                case CCTextAlignmentRight:
                    shift = self.contentSize.width - lineWidth;
                default:
                    break;
            }
			
            if (shift != 0) {
                int j = 0;
                //For each character, shift it so that the line is center aligned
                for (j = 0; j < [lineString length]; j++) {
                    index = i + j + lineNumber;
                    if (index < 0)
                        continue;
                    CCSprite *characterSprite = [self childForTag:index];
                    characterSprite.position = ccpAdd(characterSprite.position, ccp(shift, 0));
                }
            }
            i += [lineString length];
            lineNumber++;
        }
    }
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
    
	CGSize tmpSize = CGSizeZero;
    
	NSInteger longestLine = 0;
	NSUInteger totalHeight = 0;
    
	NSUInteger quantityOfLines = 1;
  
	NSCharacterSet *charSet	= _configuration.characterSet;
    
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
    
	totalHeight = _configuration->_commonHeight * quantityOfLines;
	nextFontPositionY = -(_configuration->_commonHeight - _configuration->_commonHeight*quantityOfLines);
    CGRect rect;
    ccBMFontDef fontDef = (ccBMFontDef){};
	
	CGFloat contentScale = 1.0/self.texture.contentScale;
	
	for(NSUInteger i = 0; i<stringLen; i++) {
		unichar c = [_string characterAtIndex:i];
        
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
			nextFontPositionX = 0;
			nextFontPositionY -= _configuration->_commonHeight;
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
        
		BOOL hasSprite = YES;
		CCSprite *fontChar = [self childForTag:i];
		if( fontChar )
		{
			// Reusing previous Sprite
			fontChar.visible = YES;
		}
		else
		{
			// New Sprite ? Set correct color, opacity, etc...
//			if( 0 ) {
//				/* WIP: Doesn't support many features yet.
//				 But this code is super fast. It doesn't create any sprite.
//				 Ideal for big labels.
//				 */
//				fontChar = _reusedChar;
//				hasSprite = NO;
//			} else {
				fontChar = [[CCSprite alloc] initWithTexture:self.texture rect:rect];
				[self addChild:fontChar z:i];
				[self setTag:i forChild:fontChar];
//			}
			
			// Color MUST be set before opacity due to premultiplied alpha.
			[fontChar updateDisplayedColor:_displayColor];
			[fontChar updateDisplayedOpacity:_displayColor.a];
		}

		// updating previous sprite
		[fontChar setTextureRect:rect rotated:NO untrimmedSize:rect.size];
	
        
		// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
		NSInteger yOffset = _configuration->_commonHeight - fontDef.yOffset;
		CGPoint fontPos = ccp( (CGFloat)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
							  (CGFloat)nextFontPositionY + yOffset - rect.size.height*0.5f * self.texture.contentScale );
		fontChar.position = ccpMult(fontPos, contentScale);
		
		// update kerning
		nextFontPositionX += fontDef.xAdvance + kerningAmount;
		prev = c;
        

		if (longestLine < nextFontPositionX)
			longestLine = nextFontPositionX;
	}
    
    // If the last character processed has an xAdvance which is less that the width of the characters image, then we need
    // to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
    // box
    if (fontDef.xAdvance < fontDef.rect.size.width) {
        tmpSize.width = longestLine + fontDef.rect.size.width - fontDef.xAdvance;
    } else {
        tmpSize.width = longestLine;
    }
    tmpSize.height = totalHeight;
    
	[self setContentSize:CC_SIZE_SCALE(tmpSize, contentScale)];
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
	[self setString:newString updateLabel:YES];
}

- (void) setString:(NSString*) newString updateLabel:(BOOL)update
{
    if( !update ) {
        _string = [newString copy];
    } else {
        _initialString = [newString copy];
    }
    
    for (CCSprite* child in _children)
        child.visible = NO;
	
	[self createFontChars];
	
    if (update)
        [self updateLabel];
}

#pragma mark LabelBMFont - AnchorPoint
-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) ) {
		[super setAnchorPoint:point];
		[self createFontChars];
	}
}

#pragma mark LabelBMFont - Alignment
- (void)setWidth:(float)width {
    _width = width;
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
        
        _childForTag = [NSMutableArray array];

		self.texture = [CCTexture textureWithFile:_configuration.atlasName];
		[self createFontChars];
	}
}

- (NSString*) fntFile
{
    return _fntFile;
}

#pragma mark LabelBMFont - Debug draw
#if CC_LABELBMFONT_DEBUG_DRAW
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
#endif // CC_LABELBMFONT_DEBUG_DRAW
@end
