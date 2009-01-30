//
//  NSScanner_Extensions.m
//  CocoaJSON
//
//  Created by Jonathan Wight on 12/08/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "NSScanner_Extensions.h"

#import "NSCharacterSet_Extensions.h"

@implementation NSScanner (NSScanner_Extensions)

- (NSString *)remainingString
{
return([[self string] substringFromIndex:[self scanLocation]]);
}

- (unichar)currentCharacter
{
return([[self string] characterAtIndex:[self scanLocation]]);
}

- (unichar)scanCharacter
{
unsigned theScanLocation = [self scanLocation];
unichar theCharacter = [[self string] characterAtIndex:theScanLocation];
[self setScanLocation:theScanLocation + 1];
return(theCharacter);
}

- (BOOL)scanCharacter:(unichar)inCharacter
{
unsigned theScanLocation = [self scanLocation];
if ([[self string] characterAtIndex:theScanLocation] == inCharacter)
	{
	[self setScanLocation:theScanLocation + 1];
	return(YES);
	}
else
	return(NO);
}

- (void)backtrack:(unsigned)inCount
{
unsigned theScanLocation = [self scanLocation];
if (inCount > theScanLocation)
	[NSException raise:NSGenericException format:@"Backtracked too far."];
[self setScanLocation:theScanLocation - inCount];
}

- (BOOL)scanCStyleComment:(NSString **)outComment
{
if ([self scanString:@"/*" intoString:NULL] == YES)
	{
	NSString *theComment = NULL;
	if ([self scanUpToString:@"*/" intoString:&theComment] == NO)
		[NSException raise:NSGenericException format:@"Started to scan a C style comment but it wasn't terminated."];
		
	if ([theComment rangeOfString:@"/*"].location != NSNotFound)
		[NSException raise:NSGenericException format:@"C style comments should not be nested."];
	
	if ([self scanString:@"*/" intoString:NULL] == NO)
		[NSException raise:NSGenericException format:@"C style comment did not end correctly."];
		
	if (outComment != NULL)
		*outComment = theComment;

	return(YES);
	}
else
	{
	return(NO);
	}
}

- (BOOL)scanCPlusPlusStyleComment:(NSString **)outComment
{
if ([self scanString:@"//" intoString:NULL] == YES)
	{
	NSString *theComment = NULL;
	[self scanUpToCharactersFromSet:[NSCharacterSet linebreaksCharacterSet] intoString:&theComment];
	[self scanCharactersFromSet:[NSCharacterSet linebreaksCharacterSet] intoString:NULL];

	if (outComment != NULL)
		*outComment = theComment;

	return(YES);
	}
else
	{
	return(NO);
	}
}

@end
