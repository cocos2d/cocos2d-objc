//
//  CDataScanner.m
//  TouchJSON
//
//  Created by Jonathan Wight on 04/16/08.
//  Copyright (c) 2008 Jonathan Wight
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

#import "CDataScanner.h"

#import "CDataScanner_Extensions.h"

@interface CDataScanner ()
@property (readwrite, nonatomic, retain) NSCharacterSet *doubleCharacters;
@end

#pragma mark -

inline static unichar CharacterAtPointer(void *start, void *end)
{
#pragma unused(end)

const u_int8_t theByte = *(u_int8_t *)start;
if (theByte & 0x80)
	{
	// TODO -- UNICODE!!!! (well in theory nothing todo here)
	}
const unichar theCharacter = theByte;
return(theCharacter);
}

@implementation CDataScanner

@dynamic data;
@dynamic scanLocation;
@dynamic isAtEnd;
@synthesize doubleCharacters;

+ (id)scannerWithData:(NSData *)inData
{
CDataScanner *theScanner = [[[self alloc] init] autorelease];
theScanner.data = inData;
return(theScanner);
}

- (id)init
{
if ((self = [super init]) != nil)
	{
	self.doubleCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789eE-."];
	}
return(self);
}

- (void)dealloc
{
self.data = NULL;
self.doubleCharacters = NULL;
//
[super dealloc];
}

- (NSUInteger)scanLocation
{
return(current - start);
}

- (NSData *)data
{
return(data); 
}

- (void)setData:(NSData *)inData
{
if (data != inData)
	{
	if (data)
		{
		[data release];
		data = NULL;
		}
	
	if (inData)
		{
		data = [inData retain];
		//
		start = (u_int8_t *)data.bytes;
		end = start + data.length;
		current = start;
		length = data.length;
		}
    }
}

- (void)setScanLocation:(NSUInteger)inScanLocation
{
current = start + inScanLocation;
}

- (BOOL)isAtEnd
{
return(self.scanLocation >= length);
}

- (unichar)currentCharacter
{
return(CharacterAtPointer(current, end));
}

#pragma mark -

- (unichar)scanCharacter
{
const unichar theCharacter = CharacterAtPointer(current++, end);
return(theCharacter);
}

- (BOOL)scanCharacter:(unichar)inCharacter
{
unichar theCharacter = CharacterAtPointer(current, end);
if (theCharacter == inCharacter)
	{
	++current;
	return(YES);
	}
else
	return(NO);
}

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue;
{
const size_t theLength = strlen(inString);
if ((size_t)(end - current) < theLength)
	return(NO);
if (strncmp((char *)current, inString, theLength) == 0)
	{
	current += theLength;
	if (outValue)
		*outValue = [NSString stringWithUTF8String:inString];
	return(YES);
	}
return(NO);
}

- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue
{
if ((size_t)(end - current) < inString.length)
	return(NO);
if (strncmp((char *)current, [inString UTF8String], inString.length) == 0)
	{
	current += inString.length;
	if (outValue)
		*outValue = inString;
	return(YES);
	}
return(NO);
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
{
u_int8_t *P;
for (P = current; P < end && [inSet characterIsMember:*P] == YES; ++P)
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

- (BOOL)scanUpToString:(NSString *)inString intoString:(NSString **)outValue
{
const char *theToken = [inString UTF8String];
const char *theResult = strnstr((char *)current, theToken, end - current);
if (theResult == NULL)
	{
	return(NO);
	}

if (outValue)
	{
	*outValue = [[[NSString alloc] initWithBytes:current length:theResult - (char *)current encoding:NSUTF8StringEncoding] autorelease];
	}

current = (u_int8_t *)theResult;

return(YES);
}

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
{
u_int8_t *P;
for (P = current; P < end && [inSet characterIsMember:*P] == NO; ++P)
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

- (BOOL)scanNumber:(NSNumber **)outValue
{
// Replace all of this with a strtod call
NSString *theString = NULL;
if ([self scanCharactersFromSet:doubleCharacters intoString:&theString])
	{
	if (outValue)
		*outValue = [NSNumber numberWithDouble:[theString doubleValue]]; // TODO dont use doubleValue
	return(YES);
	}
return(NO);
}

- (void)skipWhitespace
{
u_int8_t *P;
for (P = current; P < end && (isspace(*P)); ++P)
	;

current = P;
}

- (NSString *)remainingString
{
NSData *theRemainingData = [NSData dataWithBytes:current length:end - current];
NSString *theString = [[[NSString alloc] initWithData:theRemainingData encoding:NSUTF8StringEncoding] autorelease];
return(theString);
}

@end
