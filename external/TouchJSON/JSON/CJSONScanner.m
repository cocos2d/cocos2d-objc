//
//  CJSONScanner.m
//  TouchJSON
//
//  Created by Jonathan Wight on 12/07/2005.
//  Copyright (c) 2005 Jonathan Wight
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CJSONScanner.h"

#import "NSCharacterSet_Extensions.h"
#import "CDataScanner_Extensions.h"

#if !defined(TREAT_COMMENTS_AS_WHITESPACE)
#define TREAT_COMMENTS_AS_WHITESPACE 0
#endif // !defined(TREAT_COMMENTS_AS_WHITESPACE)

NSString *const kJSONScannerErrorDomain = @"CJSONScannerErrorDomain";

inline static int HexToInt(char inCharacter)
{
int theValues[] = { 0x0 /* 48 '0' */, 0x1 /* 49 '1' */, 0x2 /* 50 '2' */, 0x3 /* 51 '3' */, 0x4 /* 52 '4' */, 0x5 /* 53 '5' */, 0x6 /* 54 '6' */, 0x7 /* 55 '7' */, 0x8 /* 56 '8' */, 0x9 /* 57 '9' */, -1 /* 58 ':' */, -1 /* 59 ';' */, -1 /* 60 '<' */, -1 /* 61 '=' */, -1 /* 62 '>' */, -1 /* 63 '?' */, -1 /* 64 '@' */, 0xa /* 65 'A' */, 0xb /* 66 'B' */, 0xc /* 67 'C' */, 0xd /* 68 'D' */, 0xe /* 69 'E' */, 0xf /* 70 'F' */, -1 /* 71 'G' */, -1 /* 72 'H' */, -1 /* 73 'I' */, -1 /* 74 'J' */, -1 /* 75 'K' */, -1 /* 76 'L' */, -1 /* 77 'M' */, -1 /* 78 'N' */, -1 /* 79 'O' */, -1 /* 80 'P' */, -1 /* 81 'Q' */, -1 /* 82 'R' */, -1 /* 83 'S' */, -1 /* 84 'T' */, -1 /* 85 'U' */, -1 /* 86 'V' */, -1 /* 87 'W' */, -1 /* 88 'X' */, -1 /* 89 'Y' */, -1 /* 90 'Z' */, -1 /* 91 '[' */, -1 /* 92 '\' */, -1 /* 93 ']' */, -1 /* 94 '^' */, -1 /* 95 '_' */, -1 /* 96 '`' */, 0xa /* 97 'a' */, 0xb /* 98 'b' */, 0xc /* 99 'c' */, 0xd /* 100 'd' */, 0xe /* 101 'e' */, 0xf /* 102 'f' */, };
if (inCharacter >= '0' && inCharacter <= 'f')
	return(theValues[inCharacter - '0']);
else
	return(-1);
}

@interface CJSONScanner ()
- (BOOL)scanNotQuoteCharactersIntoString:(NSString **)outValue;
@end

#pragma mark -

@implementation CJSONScanner

- (id)init
{
if ((self = [super init]) != nil)
	{
	}
return(self);
}

- (void)dealloc
{
//
[super dealloc];
}

#pragma mark -

- (void)setData:(NSData *)inData
{
NSData *theData = inData;
if (theData && theData.length >= 4)
	{
	// This code is lame, but it works. Because the first character of any JSON string will always be a (ascii) control character we can work out the Unicode encoding by the bit pattern. See section 3 of http://www.ietf.org/rfc/rfc4627.txt
	const char *theChars = theData.bytes;
	NSStringEncoding theEncoding = NSUTF8StringEncoding;
	if (theChars[0] != 0 && theChars[1] == 0)
		{
		if (theChars[2] != 0 && theChars[3] == 0)
			theEncoding = NSUTF16LittleEndianStringEncoding;
		else if (theChars[2] == 0 && theChars[3] == 0)
			theEncoding = NSUTF32LittleEndianStringEncoding;
		}
	else if (theChars[0] == 0 && theChars[2] == 0 && theChars[3] != 0)
		{
		if (theChars[1] == 0)
			theEncoding = NSUTF32BigEndianStringEncoding;
		else if (theChars[1] != 0)
			theEncoding = NSUTF16BigEndianStringEncoding;
		}
		
	if (theEncoding != NSUTF8StringEncoding)
		{
		NSString *theString = [[NSString alloc] initWithData:theData encoding:theEncoding];
		theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
		[theString release];
		}
	}
[super setData:theData];
}

#pragma mark -

- (BOOL)scanJSONObject:(id *)outObject error:(NSError **)outError
{
[self skipWhitespace];

id theObject = NULL;

const unichar C = [self currentCharacter];
switch (C)
	{
	case 't':
		if ([self scanUTF8String:"true" intoString:NULL])
			{
			theObject = [NSNumber numberWithBool:YES];
			}
		break;
	case 'f':
		if ([self scanUTF8String:"false" intoString:NULL])
			{
			theObject = [NSNumber numberWithBool:NO];
			}
		break;
	case 'n':
		if ([self scanUTF8String:"null" intoString:NULL])
			{
			theObject = [NSNull null];
			}
		break;
	case '\"':
	case '\'':
		[self scanJSONStringConstant:&theObject error:outError];
		break;
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	case '-':
		[self scanJSONNumberConstant:&theObject error:outError];
		break;
	case '{':
		[self scanJSONDictionary:&theObject error:outError];
		break;
	case '[':
		[self scanJSONArray:&theObject error:outError];
		break;
	default:
		
		break;
	}

if (outObject != NULL)
	*outObject = theObject;
return(YES);
}

- (BOOL)scanJSONDictionary:(NSDictionary **)outDictionary error:(NSError **)outError
{
NSUInteger theScanLocation = [self scanLocation];

if ([self scanCharacter:'{'] == NO)
	{
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan dictionary. Dictionary that does not start with '{' character.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-1 userInfo:theUserInfo];
		}
	return(NO);
	}

NSMutableDictionary *theDictionary = [[NSMutableDictionary alloc] init];

while ([self currentCharacter] != '}')
	{
	[self skipWhitespace];
	
	if ([self currentCharacter] == '}')
		break;

	NSString *theKey = NULL;
	if ([self scanJSONStringConstant:&theKey error:outError] == NO)
		{
		[self setScanLocation:theScanLocation];
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Could not scan dictionary. Failed to scan a key.", NSLocalizedDescriptionKey,
				NULL];
			*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-2 userInfo:theUserInfo];
			}
		[theDictionary release];
		return(NO);
		}

	[self skipWhitespace];

	if ([self scanCharacter:':'] == NO)
		{
		[self setScanLocation:theScanLocation];
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Could not scan dictionary. Key was not terminated with a ':' character.", NSLocalizedDescriptionKey,
				NULL];
			*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-3 userInfo:theUserInfo];
			}
		[theDictionary release];
		return(NO);
		}

	id theValue = NULL;
	if ([self scanJSONObject:&theValue error:outError] == NO)
		{
		[self setScanLocation:theScanLocation];
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Could not scan dictionary. Failed to scan a value.", NSLocalizedDescriptionKey,
				NULL];
			*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-4 userInfo:theUserInfo];
			}
		[theDictionary release];
		return(NO);
		}

	[theDictionary setValue:theValue forKey:theKey];

	[self skipWhitespace];
	if ([self scanCharacter:','] == NO)
		{
		if ([self currentCharacter] != '}')
			{
			[self setScanLocation:theScanLocation];
			if (outError)
				{
				NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Could not scan dictionary. Key value pairs not delimited with a ',' character.", NSLocalizedDescriptionKey,
					NULL];
				*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-5 userInfo:theUserInfo];
				}
			[theDictionary release];
			return(NO);
			}
		break;
		}
	else
		{
		[self skipWhitespace];
		if ([self currentCharacter] == '}')
			break;
		}
	}

if ([self scanCharacter:'}'] == NO)
	{
	[self setScanLocation:theScanLocation];
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan dictionary. Dictionary not terminated by a '}' character.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-6 userInfo:theUserInfo];
		}
	[theDictionary release];
	return(NO);
	}

if (outDictionary != NULL)
	*outDictionary = [[theDictionary copy] autorelease];

[theDictionary release];

return(YES);
}

- (BOOL)scanJSONArray:(NSArray **)outArray error:(NSError **)outError
{
NSUInteger theScanLocation = [self scanLocation];

if ([self scanCharacter:'['] == NO)
	{
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan array. Array not started by a '{' character.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-7 userInfo:theUserInfo];
		}
	return(NO);
	}

NSMutableArray *theArray = [[NSMutableArray alloc] init];

[self skipWhitespace];
while ([self currentCharacter] != ']')
	{
	NSString *theValue = NULL;
	if ([self scanJSONObject:&theValue error:outError] == NO)
		{
		[self setScanLocation:theScanLocation];
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Could not scan array. Could not scan a value.", NSLocalizedDescriptionKey,
				NULL];
			*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-8 userInfo:theUserInfo];
			}
		[theArray release];
		return(NO);
		}

	[theArray addObject:theValue];
	
	[self skipWhitespace];
	if ([self scanCharacter:','] == NO)
		{
		[self skipWhitespace];
		if ([self currentCharacter] != ']')
			{
			[self setScanLocation:theScanLocation];
			if (outError)
				{
				NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Could not scan array. Array not terminated by a ']' character.", NSLocalizedDescriptionKey,
					NULL];
				*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-9 userInfo:theUserInfo];
				}
			[theArray release];
			return(NO);
			}
		
		break;
		}
	[self skipWhitespace];
	}

[self skipWhitespace];

if ([self scanCharacter:']'] == NO)
	{
	[self setScanLocation:theScanLocation];
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan array. Array not terminated by a ']' character.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-10 userInfo:theUserInfo];
		}
	[theArray release];
	return(NO);
	}

if (outArray != NULL)
	*outArray = [[theArray copy] autorelease];

[theArray release];

return(YES);
}

- (BOOL)scanJSONStringConstant:(NSString **)outStringConstant error:(NSError **)outError
{
NSUInteger theScanLocation = [self scanLocation];

[self skipWhitespace]; //  TODO - i want to remove this method. But breaks unit tests.

NSMutableString *theString = [[NSMutableString alloc] init];

if ([self scanCharacter:'"'] == NO)
	{
	[self setScanLocation:theScanLocation];
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan string constant. String not started by a '\"' character.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-11 userInfo:theUserInfo];
		}
	[theString release];
	return(NO);
	}

while ([self scanCharacter:'"'] == NO)
	{
	NSString *theStringChunk = NULL;
	if ([self scanNotQuoteCharactersIntoString:&theStringChunk])
		{
		[theString appendString:theStringChunk];
		}
	
	if ([self scanCharacter:'\\'] == YES)
		{
		unichar theCharacter = [self scanCharacter];
		switch (theCharacter)
			{
			case '"':
			case '\\':
			case '/':
				break;
			case 'b':
				theCharacter = '\b';
				break;
			case 'f':
				theCharacter = '\f';
				break;
			case 'n':
				theCharacter = '\n';
				break;
			case 'r':
				theCharacter = '\r';
				break;
			case 't':
				theCharacter = '\t';
				break;
			case 'u':
				{
				theCharacter = 0;

				int theShift;
				for (theShift = 12; theShift >= 0; theShift -= 4)
					{
					const int theDigit = HexToInt([self scanCharacter]);
					if (theDigit == -1)
						{
						[self setScanLocation:theScanLocation];
						if (outError)
							{
							NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								@"Could not scan string constant. Unicode character could not be decoded.", NSLocalizedDescriptionKey,
								NULL];
							*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-12 userInfo:theUserInfo];
							}
						[theString release];
						return(NO);
						}
					theCharacter |= (theDigit << theShift);
					}
				}
				break;
			default:
				{
				[self setScanLocation:theScanLocation];
				if (outError)
					{
					NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						@"Could not scan string constant. Unknown escape code.", NSLocalizedDescriptionKey,
						NULL];
					*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-13 userInfo:theUserInfo];
					}
				[theString release];
				return(NO);
				}
				break;
			}
		CFStringAppendCharacters((CFMutableStringRef)theString, &theCharacter, 1);
		}
	}
	
if (outStringConstant != NULL)
	*outStringConstant = [[theString copy] autorelease];

[theString release];

return(YES);
}

- (BOOL)scanJSONNumberConstant:(NSNumber **)outNumberConstant error:(NSError **)outError
{
NSNumber *theNumber = NULL;
if ([self scanNumber:&theNumber] == YES)
	{
	if (outNumberConstant != NULL)
		*outNumberConstant = theNumber;
	return(YES);
	}
else
	{
	if (outError)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Could not scan number constant.", NSLocalizedDescriptionKey,
			NULL];
		*outError = [NSError errorWithDomain:kJSONScannerErrorDomain code:-14 userInfo:theUserInfo];
		}
	return(NO);
	}
}

#if TREAT_COMMENTS_AS_WHITESPACE
- (void)skipWhitespace
{
[super skipWhitespace];
[self scanCStyleComment:NULL];
[self scanCPlusPlusStyleComment:NULL];
[super skipWhitespace];
}
#endif // TREAT_COMMENTS_AS_WHITESPACE

#pragma mark -

- (BOOL)scanNotQuoteCharactersIntoString:(NSString **)outValue
{
u_int8_t *P;
for (P = current; P < end && *P != '\"' && *P != '\\'; ++P)
	;

if (P == current)
	{
	return(NO);
	}

if (outValue)
	{
	*outValue = [[[NSString alloc] initWithBytes:current length:P - current encoding:NSUTF8StringEncoding] autorelease];
	}
	
current = P;

return(YES);
}

@end
