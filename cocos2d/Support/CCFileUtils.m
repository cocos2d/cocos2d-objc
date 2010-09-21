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


#import <Availability.h>
#import "CCFileUtils.h"
#import "../CCConfiguration.h"
#import "../ccMacros.h"
#import "../ccConfig.h"

static NSFileManager *__localFileManager=nil;

@implementation CCFileUtils

+(NSString*) getDoubleResolutionImage:(NSString*)path
{
	if( CC_CONTENT_SCALE_FACTOR() == 2 )
	{
		
		NSString *pathWithoutExtension = [path stringByDeletingPathExtension];
		NSString *name = [pathWithoutExtension lastPathComponent];
		
		// check if path already has the suffix. If so, ignore it.			
		if( [name rangeOfString:CC_RETINA_DISPLAY_FILENAME_SUFFIX].location != NSNotFound ) {
		
			CCLOG(@"cocos2d: CCFileUtils: FileName(%@) with %@. Using it.", name, CC_RETINA_DISPLAY_FILENAME_SUFFIX);			
			return path;
		}

		
		NSString *extension = [path pathExtension];
		NSString *retinaName = [pathWithoutExtension stringByAppendingString:CC_RETINA_DISPLAY_FILENAME_SUFFIX];
		retinaName = [retinaName stringByAppendingPathExtension:extension];

		if( ! __localFileManager ) 
			__localFileManager = [[NSFileManager alloc] init];
		
		if( [__localFileManager fileExistsAtPath:retinaName] )
			return retinaName;

		CCLOG(@"cocos2d: CCFileUtils: Warning HD file not found: %@", [retinaName lastPathComponent] );
	}
	
	return path;
}

+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	NSString *fullpath = nil;
	
	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] )
	{
		NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[relPath pathComponents]];
		NSString *file = [imagePathComponents lastObject];
		
		[imagePathComponents removeLastObject];
		NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
		
		fullpath = [[CCConfiguration sharedConfiguration].loadingBundle pathForResource:file
															 ofType:nil
														inDirectory:imageDirectory];
	}
	
	if (fullpath == nil)
		fullpath = relPath;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	fullpath = [self getDoubleResolutionImage:fullpath];
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
	
	return fullpath;	
}

@end
