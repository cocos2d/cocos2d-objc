//
//  CJSONSerializer.m
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

#import "CJSONSerializer.h"

@implementation CJSONSerializer

+ (id)serializer
{
return([[[self alloc] init] autorelease]);
}

- (NSString *)serializeObject:(id)inObject;
{
NSString *theResult = @"";

if ([inObject isKindOfClass:[NSNull class]])
	{
	theResult = [self serializeNull:inObject];
	}
else if ([inObject isKindOfClass:[NSNumber class]])
	{
	theResult = [self serializeNumber:inObject];
	}
else if ([inObject isKindOfClass:[NSString class]])
	{
	theResult = [self serializeString:inObject];
	}
else if ([inObject isKindOfClass:[NSArray class]])
	{
	theResult = [self serializeArray:inObject];
	}
else if ([inObject isKindOfClass:[NSDictionary class]])
	{
	theResult = [self serializeDictionary:inObject];
	}
else if ([inObject isKindOfClass:[NSData class]])
	{
	NSString *theString = [[[NSString alloc] initWithData:inObject encoding:NSUTF8StringEncoding] autorelease];
	theResult = [self serializeString:theString];
	}
else
	{
	[NSException raise:NSGenericException format:@"Cannot serialize data of type '%@'", NSStringFromClass([inObject class])];
	}
if (theResult == NULL)
	[NSException raise:NSGenericException format:@"Could not serialize object '%@'", inObject];
return(theResult);
}

- (NSString *)serializeNull:(NSNull *)inNull
{
#pragma unused (inNull)
return(@"null");
}

- (NSString *)serializeNumber:(NSNumber *)inNumber
{
NSString *theResult = NULL;
switch (CFNumberGetType((CFNumberRef)inNumber))
	{
	case kCFNumberCharType:
		{
		int theValue = [inNumber intValue];
		if (theValue == 0)
			theResult = @"false";
		else if (theValue == 1)
			theResult = @"true";
		else
			theResult = [inNumber stringValue];
		}
		break;
	case kCFNumberSInt8Type:
	case kCFNumberSInt16Type:
	case kCFNumberSInt32Type:
	case kCFNumberSInt64Type:
	case kCFNumberFloat32Type:
	case kCFNumberFloat64Type:
	case kCFNumberShortType:
	case kCFNumberIntType:
	case kCFNumberLongType:
	case kCFNumberLongLongType:
	case kCFNumberFloatType:
	case kCFNumberDoubleType:
	case kCFNumberCFIndexType:
	default:
		theResult = [inNumber stringValue];
		break;
	}
return(theResult);
}

- (NSString *)serializeString:(NSString *)inString
{
NSMutableString *theMutableCopy = [[inString mutableCopy] autorelease];
[theMutableCopy replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"/" withString:@"\\/" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\b" withString:@"\\b" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\f" withString:@"\\f" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, [theMutableCopy length])];
[theMutableCopy replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, [theMutableCopy length])];
/*
			case 'u':
				{
				theCharacter = 0;

				int theShift;
				for (theShift = 12; theShift >= 0; theShift -= 4)
					{
					int theDigit = HexToInt([self scanCharacter]);
					if (theDigit == -1)
						{
						[self setScanLocation:theScanLocation];
						return(NO);
						}
					theCharacter |= (theDigit << theShift);
					}
				}
*/
return([NSString stringWithFormat:@"\"%@\"", theMutableCopy]);
}

- (NSString *)serializeArray:(NSArray *)inArray
{
NSMutableString *theString = [NSMutableString string];

NSEnumerator *theEnumerator = [inArray objectEnumerator];
id theValue = NULL;
while ((theValue = [theEnumerator nextObject]) != NULL)
	{
	[theString appendString:[self serializeObject:theValue]];
	if (theValue != [inArray lastObject])
		[theString appendString:@","];
	}
return([NSString stringWithFormat:@"[%@]", theString]);
}

- (NSString *)serializeDictionary:(NSDictionary *)inDictionary
{
NSMutableString *theString = [NSMutableString string];

NSArray *theKeys = [inDictionary allKeys];
NSEnumerator *theEnumerator = [theKeys objectEnumerator];
NSString *theKey = NULL;
while ((theKey = [theEnumerator nextObject]) != NULL)
	{
	id theValue = [inDictionary objectForKey:theKey];
	
	[theString appendFormat:@"%@:%@", [self serializeString:theKey], [self serializeObject:theValue]];
	if (theKey != [theKeys lastObject])
		[theString appendString:@","];
	}
return([NSString stringWithFormat:@"{%@}", theString]);
}

@end
