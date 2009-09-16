//
//  FontLabelStringDrawing.m
//  FontLabel
//
//  Created by Kevin Ballard on 5/5/09.
//  Copyright © 2009 Zynga Game Networks
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "FontLabelStringDrawing.h"
#import "ZFont.h"

@interface ZFont (ZFontPrivate)
@property (nonatomic, readonly) CGFloat ratio;
@end

#define kUnicodeHighSurrogateStart 0xD800
#define kUnicodeHighSurrogateEnd 0xDBFF
#define kUnicodeLowSurrogateStart 0xDC00
#define kUnicodeLowSurrogateEnd 0xDFFF
#define UnicharIsHighSurrogate(c) (c >= kUnicodeHighSurrogateStart && c <= kUnicodeHighSurrogateEnd)
#define UnicharIsLowSurrogate(c) (c >= kUnicodeLowSurrogateStart && c <= kUnicodeLowSurrogateEnd)
#define ConvertSurrogatePairToUTF32(high, low) ((UInt32)((high - 0xD800) * 0x400 + (low - 0xDC00) + 0x10000))

typedef enum {
	kFontTableFormat4 = 4,
	kFontTableFormat12 = 12,
} FontTableFormat;

typedef struct fontTable {
	CFDataRef cmapTable;
	FontTableFormat format;
	union {
		struct {
			UInt16 segCountX2;
			UInt16 *endCodes;
			UInt16 *startCodes;
			UInt16 *idDeltas;
			UInt16 *idRangeOffsets;
		} format4;
		struct {
			UInt32 nGroups;
			struct {
				UInt32 startCharCode;
				UInt32 endCharCode;
				UInt32 startGlyphCode;
			} *groups;
		} format12;
	} cmap;
} fontTable;

static FontTableFormat supportedFormats[] = { kFontTableFormat4, kFontTableFormat12 };
static size_t supportedFormatsCount = sizeof(supportedFormats) / sizeof(FontTableFormat);

static fontTable *newFontTable(CFDataRef cmapTable, FontTableFormat format) {
	fontTable *table = (struct fontTable *)malloc(sizeof(struct fontTable));
	table->cmapTable = CFRetain(cmapTable);
	table->format = format;
	return table;
}

static void freeFontTable(fontTable *table) {
	if (table != NULL) {
		CFRelease(table->cmapTable);
		free(table);
	}
}

// read the cmap table from the font
// we only know how to understand some of the table formats at the moment
static fontTable *readFontTableFromCGFont(CGFontRef font) {
	CFDataRef cmapTable = CGFontCopyTableForTag(font, 'cmap');
	NSCAssert1(cmapTable != NULL, @"CGFontCopyTableForTag returned NULL for 'cmap' tag in font %@",
			   (font ? [(id)CFCopyDescription(font) autorelease] : @"(null)"));
	const UInt8 * const bytes = CFDataGetBytePtr(cmapTable);
	NSCAssert1(OSReadBigInt16(bytes, 0) == 0, @"cmap table for font %@ has bad version number",
			   (font ? [(id)CFCopyDescription(font) autorelease] : @"(null)"));
	UInt16 numberOfSubtables = OSReadBigInt16(bytes, 2);
	const UInt8 *unicodeSubtable = NULL;
	//UInt16 unicodeSubtablePlatformID;
	UInt16 unicodeSubtablePlatformSpecificID;
	FontTableFormat unicodeSubtableFormat;
	const UInt8 * const encodingSubtables = &bytes[4];
	for (UInt16 i = 0; i < numberOfSubtables; i++) {
		const UInt8 * const encodingSubtable = &encodingSubtables[8 * i];
		UInt16 platformID = OSReadBigInt16(encodingSubtable, 0);
		UInt16 platformSpecificID = OSReadBigInt16(encodingSubtable, 2);
		// find the best subtable
		// best is defined by a combination of encoding and format
		// At the moment we only support format 4, so ignore all other format tables
		// We prefer platformID == 0, but we will also accept Microsoft's unicode format
		if (platformID == 0 || (platformID == 3 && platformSpecificID == 1)) {
			BOOL preferred = NO;
			if (unicodeSubtable == NULL) {
				preferred = YES;
			} else if (platformID == 0 && platformSpecificID > unicodeSubtablePlatformSpecificID) {
				preferred = YES;
			}
			if (preferred) {
				UInt32 offset = OSReadBigInt32(encodingSubtable, 4);
				const UInt8 *subtable = &bytes[offset];
				UInt16 format = OSReadBigInt16(subtable, 0);
				for (int i = 0; i < supportedFormatsCount; i++) {
					if (format == supportedFormats[i]) {
						if (format >= 8) {
							// the version is a fixed-point
							UInt16 formatFrac = OSReadBigInt16(subtable, 2);
							if (formatFrac != 0) {
								// all the current formats with a Fixed version are always *.0
								continue;
							}
						}
						unicodeSubtable = subtable;
						//unicodeSubtablePlatformID = platformID;
						unicodeSubtablePlatformSpecificID = platformSpecificID;
						unicodeSubtableFormat = format;
						break;
					}
				}
			}
		}
	}
	fontTable *table = NULL;
	if (unicodeSubtable != NULL) {
		table = newFontTable(cmapTable, unicodeSubtableFormat);
		switch (unicodeSubtableFormat) {
			case kFontTableFormat4:
				// subtable format 4
				//UInt16 length = OSReadBigInt16(unicodeSubtable, 2);
				//UInt16 language = OSReadBigInt16(unicodeSubtable, 4);
				table->cmap.format4.segCountX2 = OSReadBigInt16(unicodeSubtable, 6);
				//UInt16 searchRange = OSReadBigInt16(unicodeSubtable, 8);
				//UInt16 entrySelector = OSReadBigInt16(unicodeSubtable, 10);
				//UInt16 rangeShift = OSReadBigInt16(unicodeSubtable, 12);
				table->cmap.format4.endCodes = (UInt16*)&unicodeSubtable[14];
				table->cmap.format4.startCodes = (UInt16*)&((UInt8*)table->cmap.format4.endCodes)[table->cmap.format4.segCountX2+2];
				table->cmap.format4.idDeltas = (UInt16*)&((UInt8*)table->cmap.format4.startCodes)[table->cmap.format4.segCountX2];
				table->cmap.format4.idRangeOffsets = (UInt16*)&((UInt8*)table->cmap.format4.idDeltas)[table->cmap.format4.segCountX2];
				//UInt16 *glyphIndexArray = &idRangeOffsets[segCountX2];
				break;
			case kFontTableFormat12:
				table->cmap.format12.nGroups = OSReadBigInt32(unicodeSubtable, 12);
				table->cmap.format12.groups = (void *)&unicodeSubtable[16];
				break;
			default:
				freeFontTable(table);
				table = NULL;
		}
	}
	CFRelease(cmapTable);
	return table;
}

// outGlyphs must be at least size n
static void mapCharactersToGlyphsInFont(const fontTable *table, unichar characters[], size_t charLen, CGGlyph outGlyphs[], size_t *outGlyphLen) {
	if (table != NULL) {
		NSUInteger j = 0;
		for (NSUInteger i = 0; i < charLen; i++, j++) {
			unichar c = characters[i];
			switch (table->format) {
				case kFontTableFormat4: {
					UInt16 segOffset;
					BOOL foundSegment = NO;
					for (segOffset = 0; segOffset < table->cmap.format4.segCountX2; segOffset += 2) {
						UInt16 endCode = OSReadBigInt16(table->cmap.format4.endCodes, segOffset);
						if (endCode >= c) {
							foundSegment = YES;
							break;
						}
					}
					if (!foundSegment) {
						// no segment
						// this is an invalid font
						outGlyphs[j] = 0;
					} else {
						UInt16 startCode = OSReadBigInt16(table->cmap.format4.startCodes, segOffset);
						if (!(startCode <= c)) {
							// the code falls in a hole between segments
							outGlyphs[j] = 0;
						} else {
							UInt16 idRangeOffset = OSReadBigInt16(table->cmap.format4.idRangeOffsets, segOffset);
							if (idRangeOffset == 0) {
								UInt16 idDelta = OSReadBigInt16(table->cmap.format4.idDeltas, segOffset);
								outGlyphs[j] = (c + idDelta) % 65536;
							} else {
								// use the glyphIndexArray
								UInt16 glyphOffset = idRangeOffset + 2 * (c - startCode);
								outGlyphs[j] = OSReadBigInt16(&((UInt8*)table->cmap.format4.idRangeOffsets)[segOffset], glyphOffset);
							}
						}
					}
					break;
				}
				case kFontTableFormat12: {
					UInt32 c32 = c;
					if (UnicharIsHighSurrogate(c)) {
						if (i+1 < charLen) { // do we have another character after this one?
							unichar cc = characters[i+1];
							if (UnicharIsLowSurrogate(cc)) {
								c32 = ConvertSurrogatePairToUTF32(c, cc);
								i++;
							}
						}
					}
					for (UInt32 idx = 0;; idx++) {
						if (idx >= table->cmap.format12.nGroups) {
							outGlyphs[j] = 0;
							break;
						}
						__typeof__(table->cmap.format12.groups[idx]) group = table->cmap.format12.groups[idx];
						if (c32 >= OSSwapBigToHostInt32(group.startCharCode) && c32 <= OSSwapBigToHostInt32(group.endCharCode)) {
							outGlyphs[j] = (CGGlyph)(OSSwapBigToHostInt32(group.startGlyphCode) + (c32 - OSSwapBigToHostInt32(group.startCharCode)));
							break;
						}
					}
					break;
				}
			}
		}
		if (outGlyphLen != NULL) *outGlyphLen = j;
	} else {
		// we have no table, so just null out the glyphs
		bzero(outGlyphs, charLen*sizeof(CGGlyph));
		if (outGlyphLen != NULL) *outGlyphLen = 0;
	}
}

static CGSize mapGlyphsToAdvancesInFont(ZFont *font, size_t n, CGGlyph glyphs[], int outAdvances[], CGFloat outWidths[]) {
	CGSize retVal = CGSizeMake(0, font.leading);
	if (CGFontGetGlyphAdvances(font.cgFont, glyphs, n, outAdvances)) {
		CGFloat ratio = font.ratio;
		
		int width = 0;
		for (int i = 0; i < n; i++) {
			width += outAdvances[i];
			if (outWidths != NULL) outWidths[i] = outAdvances[i]*ratio;
		}
		
		retVal.width = width*ratio;
	}
	return retVal;
}

static CGSize drawOrSizeTextConstrainedToSize(BOOL performDraw, NSString *string, ZFont *font, CGSize constrainedSize,
											  UILineBreakMode lineBreakMode, UITextAlignment alignment, BOOL convertNewlines) {
	NSUInteger len = [string length];
	CGPoint drawPoint = CGPointZero;
	CGContextRef ctx = (performDraw ? UIGraphicsGetCurrentContext() : NULL);
	
	// Map the characters to glyphs
	// split on hard newlines and calculate each run separately
	// convert newlines to spaces if convertNewlines is specified
	unichar characters[len];
	{
		// convert newlines to spaces
		NSRange range = NSMakeRange(0, [string length]);
		NSCharacterSet *charset = [NSCharacterSet newlineCharacterSet];
		NSUInteger idx = 0;
		while (range.length > 0) {
			NSRange needle = [string rangeOfCharacterFromSet:charset options:0 range:range];
			if (needle.location == NSNotFound) {
				// we're done here
				[string getCharacters:&characters[idx] range:range];
				idx += range.length;
				break;
			} else {
				// suck out the characters up to the needle
				// squash CRLF sequences down to a single newline, and convert non-newline line breaks to a newline
				// if convertNewlines is specified, convert line breaks to a space instead
				// We can safely ignore the size of needle as we're only testing the first character
				// Granted, needle should always have length 1 anyway as line breaks cannot be composed characters
				NSRange charRange = NSMakeRange(range.location, (needle.location + 1) - range.location);
				[string getCharacters:&characters[idx] range:charRange];
				idx += charRange.length;
				range = NSMakeRange(NSMaxRange(needle), NSMaxRange(range) - NSMaxRange(needle));
				unichar *cPtr = &characters[idx - 1];
				if (range.length > 0 && *cPtr == (unichar)'\r') {
					// is this CRLF?
					if ([string characterAtIndex:range.location] == (unichar)'\n') {
						// yes. Skip the \n
						range.location++, range.length--;
					}
				}
				if (convertNewlines) {
					*cPtr = (unichar)' ';
				} else if (*cPtr != '\n') {
					*cPtr = (unichar)'\n';
				}
			}
		}
		len = idx;
	}
		
	fontTable *table = readFontTableFromCGFont(font.cgFont);
	CGSize retVal = CGSizeZero;
	CGFloat ascender = font.ascender;
	NSUInteger idx = 0;
	BOOL lastLine = NO;
	while (idx < len && !lastLine) {
		unichar *charPtr = &characters[idx];
		NSUInteger i;
		for (i = idx; i < len && characters[i] != (unichar)'\n'; i++);
		size_t rowLen = i - idx;
		idx = i + 1;
		CGGlyph glyphs[(rowLen ?: 1)]; // 0-sized arrays are undefined, so ensure we declare at least 1 elt
		size_t glyphLen;
		mapCharactersToGlyphsInFont(table, charPtr, rowLen, glyphs, &glyphLen);
		// Get the advances for the glyphs
		int advances[(glyphLen ?: 1)];
		CGFloat widths[(glyphLen ?: 1)];
		CGSize rowSize = mapGlyphsToAdvancesInFont(font, glyphLen, glyphs, advances, widths);
		NSUInteger glyphIdx = 0;
		NSUInteger rowIdx = 0;
		do {
			NSUInteger softGlyphLen = glyphLen - glyphIdx;
			NSUInteger skipGlyphIdx = 0;
			NSUInteger softRowLen = rowLen - rowIdx;
			NSUInteger skipRowIdx = 0;
			CGFloat curWidth = rowSize.width;
			retVal.height += rowSize.height;
			if (retVal.height + ascender > constrainedSize.height) {
				lastLine = YES;
				// UILineBreakModeClip appears to behave like UILineBreakModeCharacterWrap
				// on the last line of rendered text. This should be researched more fully
				// (as it doesn't seem to match the documentation), but for the time being
				// we should follow the same behavior.
				if (lineBreakMode == UILineBreakModeClip) {
					lineBreakMode = UILineBreakModeCharacterWrap;
				}
			}
			if (curWidth > constrainedSize.width) {
				// wrap to a new line
				CGFloat skipWidth = 0;
				NSUInteger lastRowSpace = 0;
				NSUInteger lastGlyphSpace = 0;
				CGFloat lastSpaceWidth = 0;
				curWidth = 0;
				for (NSUInteger j = glyphIdx, cj = rowIdx; j < glyphLen; j++, cj++) {
					CGFloat newWidth = curWidth + widths[j];
					// if we're at the start of a surrogate pair, skip the high surrogate
					// any character-testing we do will never match any surrogate, so it doesn't matter
					// which of the pair we test against, and this keeps our character count in sync
					if (UnicharIsHighSurrogate(charPtr[cj]) && cj+1 < rowLen && UnicharIsLowSurrogate(charPtr[cj+1])) cj++;
					// never wrap if we haven't consumed at least 1 character
					if (newWidth > constrainedSize.width && j > glyphIdx) {
						// we've gone over the limit now
						if (charPtr[cj] == (unichar)' ') {
							// we're at a space already, just break here regardless of the line break mode
							// walk backwards to find the begnining of this run of spaces
							for (NSUInteger k = j-1, ck = cj-1; k >= glyphIdx && charPtr[ck] == (unichar)' '; k--, ck--) {
								curWidth -= widths[k];
								skipWidth += widths[k];
								j = k;
								cj = ck;
							}
							softGlyphLen = j - glyphIdx;
							softRowLen = cj - rowIdx;
						} else if (lastRowSpace == 0 || lineBreakMode == UILineBreakModeCharacterWrap ||
								   (lastLine && (lineBreakMode == UILineBreakModeTailTruncation ||
												 lineBreakMode == UILineBreakModeMiddleTruncation ||
												 lineBreakMode == UILineBreakModeHeadTruncation))) {
							// if this is the first word, fall back to character wrap instead
							softGlyphLen = j - glyphIdx;
							softRowLen = cj - rowIdx;
						} else {
							softGlyphLen = lastGlyphSpace - glyphIdx;
							softRowLen = lastRowSpace - rowIdx;
							curWidth = lastSpaceWidth;
						}
						while (glyphIdx + softGlyphLen + skipGlyphIdx < glyphLen && charPtr[rowIdx+softRowLen+skipRowIdx] == (unichar)' ') {
							skipWidth += widths[glyphIdx+softGlyphLen+skipGlyphIdx];
							skipGlyphIdx++;
							skipRowIdx++;
						}
						break;
					} else if (charPtr[cj] == (unichar)' ') {
						lastGlyphSpace = j;
						lastRowSpace = cj;
						lastSpaceWidth = curWidth;
					}
					curWidth = newWidth;
				}
				rowSize.width -= (curWidth + skipWidth);
			}
			if (lastLine) {
				// we're on the last line, check for truncation
				if (glyphIdx + softGlyphLen < glyphLen || idx < len) {
					// there's still remaining text
					if (lineBreakMode == UILineBreakModeTailTruncation ||
						lineBreakMode == UILineBreakModeMiddleTruncation ||
						lineBreakMode == UILineBreakModeHeadTruncation) {
						//softRowLen = truncationRowLen;
						unichar ellipsis = 0x2026; // ellipsis (…)
						CGGlyph ellipsisGlyph;
						mapCharactersToGlyphsInFont(table, &ellipsis, 1, &ellipsisGlyph, NULL);
						int ellipsisAdvance;
						CGFloat ellipsisWidth;
						mapGlyphsToAdvancesInFont(font, 1, &ellipsisGlyph, &ellipsisAdvance, &ellipsisWidth);
						switch (lineBreakMode) {
							case UILineBreakModeTailTruncation: {
								while (curWidth + ellipsisWidth > constrainedSize.width && softGlyphLen > 1) {
									softRowLen--;
									softGlyphLen--;
									curWidth -= widths[glyphIdx+softGlyphLen];
								}
								// keep going backwards if we've stopped at a space or just after the first letter
								// of a multi-letter word
								if (softGlyphLen > 1 && charPtr[rowIdx+softRowLen-1] != (unichar)' ') {
									// handle surrogate pairs properly
									NSUInteger offset = 2;
									if (UnicharIsHighSurrogate(charPtr[rowIdx+softRowLen-1]) &&
										UnicharIsLowSurrogate(charPtr[rowIdx+softRowLen-2])) {
										offset = 3;
									}
									if (softGlyphLen >= offset && charPtr[rowIdx+softRowLen-offset] == (unichar)' ') {
										// we're right after the first letter of a word. Is it a multi-letter word?
										NSCharacterSet *set = [NSCharacterSet alphanumericCharacterSet];
										if (rowIdx+softRowLen < rowLen && [set characterIsMember:charPtr[rowIdx+softRowLen]]) {
											softRowLen--;
											softGlyphLen--;
											curWidth -= widths[glyphIdx+softGlyphLen];
										}
									}
								}
								while (softRowLen > 1 && charPtr[rowIdx+softRowLen-1] == (unichar)' ') {
									softRowLen--;
									softGlyphLen--;
									curWidth -= widths[glyphIdx+softGlyphLen];
								}
								curWidth += ellipsisWidth;
								glyphs[glyphIdx+softGlyphLen] = ellipsisGlyph;
								softRowLen++;
								softGlyphLen++;
								break;
							}
							default:
								;// we don't support any other types at the moment
						}
					}
				}
			}
			retVal.width = MAX(retVal.width, curWidth);
			if (performDraw) {
				switch (alignment) {
					case UITextAlignmentLeft:
						drawPoint.x = 0;
						break;
					case UITextAlignmentCenter:
						drawPoint.x = (constrainedSize.width - curWidth) / 2.0f;
						break;
					case UITextAlignmentRight:
						drawPoint.x = constrainedSize.width - curWidth;
						break;
				}
				CGContextShowGlyphsAtPoint(ctx, drawPoint.x, drawPoint.y + ascender, &glyphs[glyphIdx], softGlyphLen);
				drawPoint.y += rowSize.height;
			}
			glyphIdx += softGlyphLen + skipGlyphIdx;
			rowIdx += softRowLen + skipRowIdx;
		} while (!lastLine && glyphIdx < glyphLen);
	}
	freeFontTable(table);
	
	return retVal;
}

static CGSize drawTextInRect(CGRect rect, NSString *text, ZFont *font, UILineBreakMode lineBreakMode,
							 UITextAlignment alignment, BOOL convertNewlines) {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(ctx);
	
	CGContextSetFont(ctx, font.cgFont);
	CGContextSetFontSize(ctx, font.pointSize);
	
	// flip it upside-down because our 0,0 is upper-left, whereas ttfs are for screens where 0,0 is lower-left
	CGAffineTransform textTransform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f);
	CGContextSetTextMatrix(ctx, textTransform);
	
	CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
	
	CGContextSetTextDrawingMode(ctx, kCGTextFill);
	CGSize size = drawOrSizeTextConstrainedToSize(YES, text, font, rect.size, lineBreakMode, alignment, convertNewlines);
	
	CGContextRestoreGState(ctx);
	
	return size;
}

@implementation NSString (FontLabelStringDrawing)
// CGFontRef-based methods
- (CGSize)sizeWithCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize {
	return [self sizeWithZFont:[ZFont fontWithCGFont:font size:pointSize]];
}

- (CGSize)sizeWithCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize constrainedToSize:(CGSize)size {
	return [self sizeWithZFont:[ZFont fontWithCGFont:font size:pointSize] constrainedToSize:size];
}

- (CGSize)sizeWithCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize constrainedToSize:(CGSize)size
		   lineBreakMode:(UILineBreakMode)lineBreakMode {
	return [self sizeWithZFont:[ZFont fontWithCGFont:font size:pointSize] constrainedToSize:size lineBreakMode:lineBreakMode];
}

- (CGSize)drawAtPoint:(CGPoint)point withCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize {
	return [self drawAtPoint:point withZFont:[ZFont fontWithCGFont:font size:pointSize]];
}

- (CGSize)drawInRect:(CGRect)rect withCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize {
	return [self drawInRect:rect withZFont:[ZFont fontWithCGFont:font size:pointSize]];
}

- (CGSize)drawInRect:(CGRect)rect withCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize lineBreakMode:(UILineBreakMode)lineBreakMode {
	return [self drawInRect:rect withZFont:[ZFont fontWithCGFont:font size:pointSize] lineBreakMode:lineBreakMode];
}

- (CGSize)drawInRect:(CGRect)rect withCGFont:(CGFontRef)font pointSize:(CGFloat)pointSize
	   lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment {
	return [self drawInRect:rect withZFont:[ZFont fontWithCGFont:font size:pointSize] lineBreakMode:lineBreakMode alignment:alignment];
}

// ZFont-based methods
- (CGSize)sizeWithZFont:(ZFont *)font {
	CGSize size = drawOrSizeTextConstrainedToSize(NO, self, font, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), UILineBreakModeClip, UITextAlignmentLeft, YES);
	return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (CGSize)sizeWithZFont:(ZFont *)font constrainedToSize:(CGSize)size {
	return [self sizeWithZFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
}

/*
 According to experimentation with UIStringDrawing, this can actually return a CGSize whose height is greater
 than the one passed in. The two cases are as follows:
 1. If the given size parameter's height is smaller than a single line, the returned value will
 be the height of one line.
 2. If the given size parameter's height falls between multiples of a line height, and the wrapped string
 actually extends past the size.height, and the difference between size.height and the previous multiple
 of a line height is >= the font's ascender, then the returned size's height is extended to the next line.
 To put it simply, if the baseline point of a given line falls in the given size, the entire line will
 be present in the output size.
 */
- (CGSize)sizeWithZFont:(ZFont *)font constrainedToSize:(CGSize)size lineBreakMode:(UILineBreakMode)lineBreakMode {
	size = drawOrSizeTextConstrainedToSize(NO, self, font, size, lineBreakMode, UITextAlignmentLeft, NO);
	return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (CGSize)drawAtPoint:(CGPoint)point withZFont:(ZFont *)font {
	return [self drawAtPoint:point forWidth:CGFLOAT_MAX withZFont:font lineBreakMode:UILineBreakModeClip];
}

- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withZFont:(ZFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode {
	return drawTextInRect((CGRect){ point, { width, font.leading } }, self, font, lineBreakMode, UITextAlignmentLeft, YES);
}

- (CGSize)drawInRect:(CGRect)rect withZFont:(ZFont *)font {
	return [self drawInRect:rect withZFont:font lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize)drawInRect:(CGRect)rect withZFont:(ZFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode {
	return [self drawInRect:rect withZFont:font lineBreakMode:lineBreakMode alignment:UITextAlignmentLeft];
}

- (CGSize)drawInRect:(CGRect)rect withZFont:(ZFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode
		   alignment:(UITextAlignment)alignment {
	return drawTextInRect(rect, self, font, lineBreakMode, alignment, NO);
}
@end
