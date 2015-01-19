/*
 * cocos2d for iPhone: http://www.cocos2d-swift.org
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

#import <Foundation/Foundation.h>
#import "CCFileUtilsDatabaseProtocol.h"

/**
 A database to store metadata of assets used by CCFileUtils based on json files.
 Metdata is stored for a filename and search path.
 
 @since 4.0
 */
@interface CCFileUtilsDatabase : NSObject <CCFileUtilsDatabaseProtocol>

/**
 Loads, parses and adds the provided json file to the database for a given search path.
  
 @param filePath   A full path to the json file.
 @param searchPath The search path to associate the file's data with.
 @param error      On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return Returns YES if the operation was successful. If an error occurs, this method returns NO and assigns an appropriate error object to the error parameter.
 
 @since 4.0
 */
- (BOOL)addJSONWithFilePath:(NSString *)filePath forSearchPath:(NSString *)searchPath error:(NSError **)error;

/**
 Removes entris of the database associated with a given search path.
 
 @param searchPath The search path to remove database entries for.
 
 @since 4.0
 */
- (void)removeEntriesForSearchPath:(NSString *)searchPath;

@end
