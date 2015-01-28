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
#import "CCFileLocatorDatabaseProtocol.h"

/**
 A database to store metadata of assets used by CCFileLocator based on json files.
 Metdata is stored per filename and search path, see CCFileLocatorDatabaseProtocol.

 Example for a json file structure to store data for the CCFileMetaData class:
    {
        "images/foo.png" : {
            "filename" : "images/foo-en.png",
            "UIScale" : true,
            "localizations" : {
                "en" : "images/foo-en.png",
                "de" : "images/foo-de.png"
            }
        }
    }

 * Only filename is mandatory if you have an entry for a given asset.
 * UIScale, if not present will default to NO.
 * The localization dictionary uses languageIDs as keys and point to a file.

 If you don't want to alias a file without any localizations and the info to use UI scaling then just omit an entry in the database.

 @since 4.0
 */
@interface CCFileLocatorDatabase : NSObject <CCFileLocatorDatabaseProtocol>

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
