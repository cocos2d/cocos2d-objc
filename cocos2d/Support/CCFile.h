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
#import <ImageIO/CGImageSource.h>


/**
 Abstract file handling class. Files may reference local or remote files, such as files on an HTTP or FTP server.
 If a file is compressed with gzip (must end in .gz) it will be transparently decompressed.
 
 TODO Instances of this class are created using CCFileUtils, but that code hasn't been written yet.
 
 @see CCFileUtils

 @since 4.0
 */
@interface CCFile : NSObject

/**
 Name of the original file requested from CCFileUtils. (Ex: "Sprites/Hero.png")
 This may not exactly match the path of the file CCFileUtils actually finds if the file on disk is aliased or tagged with a resolution.

 @since 4.0
 */
@property(nonatomic, readonly) NSString *name;

/**
 URL of the file found by CCFileUtils.

 @since 4.0
 */
@property(nonatomic, readonly) NSURL *url;

/**
 The absolute path of the file if it is a local file. `nil` if the file is a remote file.

 @since 4.0
 */
@property(nonatomic, readonly) NSString *absoluteFilePath;

/**
 Content scale the file should be interpreted as.
 
 @see CCFileUtils for more information on about asset content scales. (TODO CCFiles not implemented yet)

 @since 4.0
 */
@property(nonatomic, readonly) CGFloat contentScale;

/**
 Assume the file is a plist and read it's contents.

 @param error If an error occurs, upon return contains an NSError object that describes the problem.

 @return The plist file's contents, or nil if there is an error.

 @since 4.0
 */
-(id)loadPlist:(NSError **)error;

/**
 Load the file's contents into a data object.
 
 @param error If an error occurs, upon return contains an NSError object that describes the problem.

 @return The file's complete contents in a data object.

 @since 4.0
 */
-(NSData *)loadData:(NSError **)error;

/**
 Opens an input stream to the file so it can be read sequentially.

 @return An opened stream object.

 @since 4.0
 */
-(NSInputStream *)openInputStream;

#warning TODO What to do about these since we will be using metadata to store them?
//@property(nonatomic, readonly) NSString *language;
//@property(nonatomic, readonly) NSString *deviceFamily;
@property (nonatomic, copy) NSDictionary *metaData;

@end
