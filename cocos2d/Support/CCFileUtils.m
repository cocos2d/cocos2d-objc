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

static NSString *__suffixRetinaDisplay =@"-hd";
static NSString *__suffixiPad =@"-ipad";


NSString *ccRemoveSuffixFromPath( NSString *suffix, NSString *path);

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

NSString *ccRemoveSuffixFromPath( NSString *suffix, NSString *path)
{
	// quick return
	if( ! suffix || [suffix length] == 0 )
		return path;

	NSString *name = [path lastPathComponent];
	
	// check if path already has the suffix.
	if( [name rangeOfString:__suffixRetinaDisplay].location != NSNotFound ) {
		
		CCLOG(@"cocos2d: Filename(%@) contains %@ suffix. Removing it. See cocos2d issue #1040", path, suffix);
		
		NSString *newLastname = [name stringByReplacingOccurrencesOfString:suffix withString:@""];
		
		NSString *pathWithoutLastname = [path stringByDeletingLastPathComponent];
		return [pathWithoutLastname stringByAppendingPathComponent:newLastname];
	}

	return path;
}

NSString *ccRemoveDeviceSuffixFromFile( NSString *path )
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	
	NSString *ret = nil;
	if( CC_CONTENT_SCALE_FACTOR() == 2 )
		ret = ccRemoveSuffixFromPath( __suffixRetinaDisplay, path );
	
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		ret = ccRemoveSuffixFromPath( __suffixiPad, path );

	else 
		ret = path;

	return ret;
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	// Do nothing on Mac
	return path;
#endif

}


@implementation CCFileUtils

+(void) initialize
{
	if( self == [CCFileUtils class] )
		__localFileManager = [[NSFileManager alloc] init];
}

+(NSString*) getPath:(NSString*)path forSuffix:(NSString*)suffix
{
	// quick return
	if( ! suffix || [suffix length] == 0 )
		return path;
	
	NSString *pathWithoutExtension = [path stringByDeletingPathExtension];
	NSString *name = [pathWithoutExtension lastPathComponent];
	
	// check if path already has the suffix.
	if( [name rangeOfString:suffix].location != NSNotFound ) {
	
		CCLOG(@"cocos2d: WARNING Filename(%@) already has the suffix %@. Using it.", name, suffix);			
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
	
	
	NSString *newName = [pathWithoutExtension stringByAppendingString:suffix];
	newName = [newName stringByAppendingPathExtension:extension];

	if( [__localFileManager fileExistsAtPath:newName] )
		return newName;

	CCLOG(@"cocos2d: CCFileUtils: Warning file not found: %@", [newName lastPathComponent] );
	
	return path;
}

+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	NSString *fullpath = nil;
	
	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] )
		fullpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:relPath];
	
	if (fullpath == nil)
		fullpath = relPath;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// Retina Display ?
	if( CC_CONTENT_SCALE_FACTOR() == 2 )
		fullpath = [self getPath:fullpath forSuffix:__suffixRetinaDisplay];

	// iPad ?
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		fullpath = [self getPath:fullpath forSuffix:__suffixiPad];

	// It should be an iPhone in non Retina Display mode. So, do nothing
	else
		;
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
	
	return fullpath;	
}

@end
