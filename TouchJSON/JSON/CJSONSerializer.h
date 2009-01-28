//
//  CJSONSerializer.h
//  TouchJSON
//
//  Created by Jonathan Wight on 12/07/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJSONSerializer : NSObject {
}

+ (id)serializer;

- (NSString *)serializeObject:(id)inObject;

- (NSString *)serializeNull:(NSNull *)inNull;
- (NSString *)serializeNumber:(NSNumber *)inNumber;
- (NSString *)serializeString:(NSString *)inString;
- (NSString *)serializeArray:(NSArray *)inArray;
- (NSString *)serializeDictionary:(NSDictionary *)inDictionary;

@end
