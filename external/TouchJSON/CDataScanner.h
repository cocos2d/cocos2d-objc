//
//  CDataScanner.h
//  TouchJSON
//
//  Created by Jonathan Wight on 04/16/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSScanner

@interface CDataScanner : NSObject {
	NSData *data;

	u_int8_t *start;
	u_int8_t *end;
	u_int8_t *current;
	NSUInteger length;
	
	NSCharacterSet *doubleCharacters;
}

@property (readwrite, nonatomic, retain) NSData *data;
@property (readwrite, nonatomic, assign) NSUInteger scanLocation;
@property (readonly, nonatomic, assign) BOOL isAtEnd;

+ (id)scannerWithData:(NSData *)inData;

- (unichar)currentCharacter;
- (unichar)scanCharacter;
- (BOOL)scanCharacter:(unichar)inCharacter;

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue;
- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)outValue;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

- (BOOL)scanNumber:(NSNumber **)outValue;

- (void)skipWhitespace;

- (NSString *)remainingString;

@end
