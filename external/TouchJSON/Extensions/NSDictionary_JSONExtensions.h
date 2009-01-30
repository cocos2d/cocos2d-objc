//
//  NSDictionary_JSONExtensions.h
//  TouchJSON
//
//  Created by Jonathan Wight on 04/17/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_JSONExtensions)

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError;

@end
