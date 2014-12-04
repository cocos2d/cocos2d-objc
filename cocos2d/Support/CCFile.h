/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "ccTypes.h"


@interface CCFile : NSObject

#warning TODO Should this be public in the final API?
//Need to think about how to handle compressed/encrypted files transparently. Class cluster?
-(instancetype)initWithName:(NSString *)name url:(NSURL *)url contentScale:(CGFloat)contentScale;

// Normalized version of the originally requested name. (Ex: "Sprites/Hero.png")
@property(nonatomic, readonly) NSString *name;

// URL of the 
@property(nonatomic, readonly) NSURL *url;

// Returns an absolute path for the file or nil if the file is not local.
@property(nonatomic, readonly) NSString *absoluteFilePath;

// Content scale this file should be interpreted as.
@property(nonatomic, readonly) CGFloat contentScale;

#warning TODO What to do about these since we will be using metadata?
//@property(nonatomic, readonly) NSString *language;
//@property(nonatomic, readonly) NSString *deviceFamily;

// Load the file as a plist. Return nil on error.
-(id)loadPlist;

// Load the file as binary data. Returns nil on error.
-(NSData *)loadData;

// Open a file handle to the file. Returns nil on error.
-(NSInputStream *)openInputStream;

@end
