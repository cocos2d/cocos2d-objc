/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 *
 */


#import <Foundation/Foundation.h>


/** Helper class to handle file operations */
@interface CCFileUtils : NSObject
{
}

/** Returns the fullpath of an filename.
 
 If this method is when Retina Display is enabled, then the
 Retina Display suffix will be appended to the file (See ccConfig.h).
 
 If the Retina Display image doesn't exist, then it will return the "non-Retina Display" image
 
 */
+(NSString*) fullPathFromRelativePath:(NSString*) relPath;
@end

/** loads a file into memory.
 the caller should release the allocated buffer.
 
 @returns the size of the allocated buffer
 @since v0.99.5
 */
NSInteger ccLoadFileIntoMemory(const char *filename, unsigned char **out);


/** removes the HD suffix from a path
 
 @returns NSString * without the HD suffix
 @since v0.99.5
 */
NSString *ccRemoveHDSuffixFromFile( NSString *path );

