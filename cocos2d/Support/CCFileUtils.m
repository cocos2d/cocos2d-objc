/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

// 
NSInteger ccLoadFileIntoMemory(const char *filename, unsigned char **out) 
{ 
	NSCAssert( out, @"ccLoadFileIntoMemory: invalid 'out' parameter");
	NSCAssert( &*out, @"ccLoadFileIntoMemory: invalid 'out' parameter");

	size_t size = 0;
	FILE *f = fopen(filename, "rb");
	if( !f ) { 
		*out = NULL;
		return -1;
	} 
	
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	
	*out = malloc(size);
	size_t read = fread(*out, 1, size, f);
	if( read != size ) { 
		free(*out);
		*out = NULL;
		return -1;
	}
	
	fclose(f);
	
	return size;
}

NSString *ccRemoveHDSuffixFromFile( NSString *path )
{
#if CC_IS_RETINA_DISPLAY_SUPPORTED

	if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
				
		NSString *name = [path lastPathComponent];
		
		// check if path already has the suffix.
		if( [name rangeOfString:CC_RETINA_DISPLAY_FILENAME_SUFFIX].location != NSNotFound ) {
			
			CCLOG(@"cocos2d: Filename(%@) contains %@ suffix. Removing it. See cocos2d issue #1040", path, CC_RETINA_DISPLAY_FILENAME_SUFFIX);

			NSString *newLastname = [name stringByReplacingOccurrencesOfString:CC_RETINA_DISPLAY_FILENAME_SUFFIX withString:@""];
			
			NSString *pathWithoutLastname = [path stringByDeletingLastPathComponent];
			return [pathWithoutLastname stringByAppendingPathComponent:newLastname];
		}		
	}

#endif // CC_IS_RETINA_DISPLAY_SUPPORTED

	return path;

}


@implementation CCFileUtils

+(void) initialize
{
	if( self == [CCFileUtils class] )
		__localFileManager = [[NSFileManager alloc] init];
}

+(NSString*) getDoubleResolutionImage:(NSString*)path
{
#if CC_IS_RETINA_DISPLAY_SUPPORTED

	if( CC_CONTENT_SCALE_FACTOR() == 2 )
	{
		
		NSString *pathWithoutExtension = [path stringByDeletingPathExtension];
		NSString *name = [pathWithoutExtension lastPathComponent];
		
		// check if path already has the suffix.
		if( [name rangeOfString:CC_RETINA_DISPLAY_FILENAME_SUFFIX].location != NSNotFound ) {
		
			CCLOG(@"cocos2d: WARNING Filename(%@) already has the suffix %@. Using it.", name, CC_RETINA_DISPLAY_FILENAME_SUFFIX);			
			return path;
		}

		
		NSString *extension = [path pathExtension];
		
		if( [extension isEqualToString:@"ccz"] || [extension isEqualToString:@"gz"] )
		{
			// All ccz / gz files should be in the format filename.xxx.ccz
			// so we need to pull off the .xxx part of the extension as well
			extension = [NSString stringWithFormat:@"%@.%@", [pathWithoutExtension pathExtension], extension];
			pathWithoutExtension = [pathWithoutExtension stringByDeletingPathExtension];
		}
		
		
		NSString *retinaName = [pathWithoutExtension stringByAppendingString:CC_RETINA_DISPLAY_FILENAME_SUFFIX];
		retinaName = [retinaName stringByAppendingPathExtension:extension];

		if( [__localFileManager fileExistsAtPath:retinaName] )
			return retinaName;

		CCLOG(@"cocos2d: CCFileUtils: Warning HD file not found: %@", [retinaName lastPathComponent] );
	}
	
#endif // CC_IS_RETINA_DISPLAY_SUPPORTED
	
	return path;
}

+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	NSString *fullpath = nil;
	
	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] )
	{
		NSString *file = [relPath lastPathComponent];
		NSString *imageDirectory = [relPath stringByDeletingLastPathComponent];
		
		fullpath = [[NSBundle mainBundle] pathForResource:file
												   ofType:nil
											  inDirectory:imageDirectory];
	}
	
	if (fullpath == nil)
		fullpath = relPath;
	
	fullpath = [self getDoubleResolutionImage:fullpath];
	
	return fullpath;	
}

@end
