//
//  CCLabelBMFont_Private.h
//  cocos2d-osx
//
//  Created by Viktor on 10/28/13.
//
//

#import "CCLabelBMFont.h"

enum {
	kCCLabelAutomaticWidth = -1,
};

/** @struct ccBMFontDef
 BMFont definition
 */
typedef struct _BMFontDef {
	//! ID of the character
	unichar charID;
	//! origin and size of the font
	CGRect rect;
	//! The X amount the image should be offset when drawing the image (in pixels)
	short xOffset;
	//! The Y amount the image should be offset when drawing the image (in pixels)
	short yOffset;
	//! The amount to move the current position after drawing the character (in pixels)
	short xAdvance;
} ccBMFontDef;

/** @struct ccBMFontPadding
 BMFont padding
 @since v0.8.2
 */
typedef struct _BMFontPadding {
	/// padding left
	int	left;
	/// padding top
	int top;
	/// padding right
	int right;
	/// padding bottom
	int bottom;
} ccBMFontPadding;

#pragma mark - Hash Element
typedef struct _FontDefHashElement
{
	NSUInteger		key;		// key. Font Unicode value
	ccBMFontDef		fontDef;	// font definition
	UT_hash_handle	hh;
} tCCFontDefHashElement;

// Equal function for targetSet.
typedef struct _KerningHashElement
{
	int				key;		// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	int				amount;
	UT_hash_handle	hh;
} tCCKerningHashElement;
#pragma mark -

/** CCBMFontConfiguration has parsed configuration of the the .fnt file
 @since v0.8
 */
@interface CCBMFontConfiguration : NSObject
{
	// Character Set defines the letters that actually exist in the font
	NSCharacterSet *_characterSet;
    
	// atlas name
	NSString		*_atlasName;
    
    // XXX: Creating a public interface so that the bitmapFontArray[] is accessible
@public
    
	// BMFont definitions
	tCCFontDefHashElement	*_fontDefDictionary;
    
	// FNTConfig: Common Height. Should be signed (issue #1343)
	NSInteger		_commonHeight;
    
	// Padding
	ccBMFontPadding	_padding;
    
	// values for kerning
	tCCKerningHashElement	*_kerningDictionary;
}

// Character set
@property (nonatomic, strong, readonly) NSCharacterSet *characterSet;

// atlasName
@property (nonatomic, readwrite, strong) NSString *atlasName;

/** allocates a CCBMFontConfiguration with a FNT file */
+(id) configurationWithFNTFile:(NSString*)FNTfile;
/** initializes a CCBMFontConfiguration with a FNT file */
-(id) initWithFNTfile:(NSString*)FNTfile;
@end


/** Free function that parses a FNT file a place it on the cache
 */
CCBMFontConfiguration * FNTConfigLoadFile( NSString *file );
/** Purges the FNT config cache
 */
void FNTConfigRemoveCache( void );


@interface CCLabelBMFont ()

@end
