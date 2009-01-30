//
//  CJSONDeserializer.h
//  TouchJSON
//
//  Created by Jonathan Wight on 12/15/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kJSONDeserializerErrorDomain /* = @"CJSONDeserializerErrorDomain" */;

@protocol CDeserializerProtocol <NSObject>

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;

@end

#pragma mark -

@interface CJSONDeserializer : NSObject <CDeserializerProtocol> {

}

+ (id)deserializer;

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;

@end

#pragma mark -

@interface CJSONDeserializer (CJSONDeserializer_Deprecated)

/// You should switch to using deserializeAsDictionary:error: instead.
- (id)deserialize:(NSData *)inData error:(NSError **)outError;

@end
