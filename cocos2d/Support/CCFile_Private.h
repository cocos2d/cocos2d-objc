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


#import "CCFile.h"


// Abstract parent class for the compressed/encryted streams.
@interface CCWrappedInputStream : NSInputStream
-(instancetype)initWithInputStream:(NSInputStream *)inputStream;
-(NSData *)loadDataWithSizeHint:(NSUInteger)sizeHint error:(NSError **)error;
@end


// Read data from a gzip compressed stream.
@interface CCGZippedInputStream : CCWrappedInputStream
@end


// Read data from an encrypted .ccp file.
@interface CCEncryptedInputStream : CCWrappedInputStream
@end


// Return an opened input stream to read from.
// May be called more than once if the file is rewound.
typedef NSInputStream *(^CCStreamedImageSourceStreamBlock)();

// Adapter class that creates a CGImage source from an NSInputStream.
@interface CCStreamedImageSource : NSObject
-(instancetype)initWithStreamBlock:(CCStreamedImageSourceStreamBlock)streamBlock;
-(CGDataProviderRef)createCGDataProvider;
-(CGImageSourceRef)createCGImageSource;
@end


@interface CCFile()

@property (nonatomic, assign, readwrite) BOOL useUIScale;

@end


@interface CCFile(Private)

/**
 Set the key used on encrypted files the app will be loading.
 It's recommended to set this value only once in your app delegate.
 
 TODO where would a user find or create such a key.

 @param key A 32 digit hexadecimal number as a string.

 @since 4.0
 */
+(void)setEncryptionKey:(NSString *)key;

-(instancetype)initWithName:(NSString *)name url:(NSURL *)url contentScale:(CGFloat)contentScale;
-(CGImageSourceRef)createCGImageSource;


@end
