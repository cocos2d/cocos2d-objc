//
//  CJSONDeserializer.m
//  TouchJSON
//
//  Created by Jonathan Wight on 12/15/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CJSONDeserializer.h"

#import "CJSONScanner.h"
#import "CDataScanner.h"

NSString *const kJSONDeserializerErrorDomain /* = @"CJSONDeserializerErrorDomain" */;

@implementation CJSONDeserializer

+ (id)deserializer
{
return([[[self alloc] init] autorelease]);
}

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError && *outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
CJSONScanner *theScanner = [CJSONScanner scannerWithData:inData];
NSDictionary *theDictionary = NULL;
if ([theScanner scanJSONDictionary:&theDictionary error:outError] == YES)
	return(theDictionary);
else
	return(NULL);
}

@end

#pragma mark -

@implementation CJSONDeserializer (CJSONDeserializer_Deprecated)

- (id)deserialize:(NSData *)inData error:(NSError **)outError
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError && *outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
CJSONScanner *theScanner = [CJSONScanner scannerWithData:inData];
id theObject = NULL;
if ([theScanner scanJSONObject:&theObject error:outError] == YES)
	return(theObject);
else
	return(NULL);
}

@end
