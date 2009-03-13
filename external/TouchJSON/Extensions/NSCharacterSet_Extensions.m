//
//  NSCharacterSet_Extensions.m
//  TouchJSON
//
//  Created by Jonathan Wight on 12/08/2005.
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

#import "NSCharacterSet_Extensions.h"

@implementation NSCharacterSet (NSCharacterSet_Extensions)

#define LF 0x000a // Line Feed
#define FF 0x000c // Form Feed
#define CR 0x000d // Carriage Return
#define NEL 0x0085 // Next Line
#define LS 0x2028 // Line Separator
#define PS 0x2029 // Paragraph Separator

+ (NSCharacterSet *)linebreaksCharacterSet
{
unichar theCharacters[] = { LF, FF, CR, NEL, LS, PS, };

return([NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:theCharacters length:sizeof(theCharacters) / sizeof(*theCharacters)]]);
}

@end
