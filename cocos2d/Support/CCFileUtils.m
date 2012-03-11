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


#import "CCFileUtils.h"
#import "../CCConfiguration.h"
#import "../ccMacros.h"
#import "../ccConfig.h"
#import "../ccTypes.h"

static NSFileManager *__localFileManager=nil;

#ifdef __CC_PLATFORM_IOS

static NSString *__suffixiPhoneRetinaDisplay =@"-hd";
static NSString *__suffixiPad =@"-ipad";
static NSString *__suffixiPadRetinaDisplay =@"-ipadhd";

#endif // __CC_PLATFORM_IOS


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


#ifdef __CC_PLATFORM_IOS
@interface CCFileUtils()
+(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path;
+(BOOL) fileExistsAtPath:(NSString*)string withSuffix:(NSString*)suffix;
@end
#endif // __CC_PLATFORM_IOS

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

	return nil;
}

+(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	NSString *fullpath = nil;

	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] ) {

		// pathForResource also searches in .lproj directories. issue #1230
		NSString *file = [relPath lastPathComponent];
		NSString *imageDirectory = [relPath stringByDeletingLastPathComponent];

		fullpath = [[NSBundle mainBundle] pathForResource:file
												   ofType:nil
											  inDirectory:imageDirectory];


	}

	if (fullpath == nil)
		fullpath = relPath;

#ifdef __CC_PLATFORM_IOS

	NSString *ret = nil;

	// iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// Retina Display ?
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
			ret = [self getPath:fullpath forSuffix:__suffixiPadRetinaDisplay];
			*resolutionType = kCCResolutioniPadRetinaDisplay;
		}
		else
		{
			ret = [self getPath:fullpath forSuffix:__suffixiPad];
			*resolutionType = kCCResolutioniPad;
			
		}
	}
	// iPhone ?
	else
	{
		// Retina Display ?
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
			ret = [self getPath:fullpath forSuffix:__suffixiPhoneRetinaDisplay];
			*resolutionType = kCCResolutioniPhoneRetinaDisplay;
		}
	}
	
	// If it is iPhone Non RetinaDisplay, or if the previous "getPath" failed, then use iPhone images.
	if( ret == nil )
	{
		*resolutionType = kCCResolutioniPhone;
		ret = fullpath;
	}

	return ret;

#elif defined(__CC_PLATFORM_MAC)

	*resolutionType = kCCResolutioniPhone;

	return fullpath;

#endif // __CC_PLATFORM_MAC

}

+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	ccResolutionType ignore;
	return [self fullPathFromRelativePath:relPath resolutionType:&ignore];
}

#pragma mark CCFileUtils - Suffix (iOS only)


#ifdef __CC_PLATFORM_IOS

+(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path
{
	// quick return
	if( ! suffix || [suffix length] == 0 )
		return path;

	NSString *name = [path lastPathComponent];

	// check if path already has the suffix.
	if( [name rangeOfString:suffix].location != NSNotFound ) {

		CCLOGINFO(@"cocos2d: Filename(%@) contains %@ suffix. Removing it. See cocos2d issue #1040", path, suffix);

		NSString *newLastname = [name stringByReplacingOccurrencesOfString:suffix withString:@""];

		NSString *pathWithoutLastname = [path stringByDeletingLastPathComponent];
		return [pathWithoutLastname stringByAppendingPathComponent:newLastname];
	}

	return path;
}

+(NSString*) removeSuffixFromFile:(NSString*) path
{
	NSString *ret = nil;

	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			ret = [self removeSuffix:__suffixiPadRetinaDisplay fromPath:path];
		else
			ret = [self removeSuffix:__suffixiPad fromPath:path];		
	}
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			ret = [self removeSuffix:__suffixiPhoneRetinaDisplay fromPath:path];
		else
			ret = path;
	}
	
	return ret;
}

+(void) setiPhoneRetinaDisplaySuffix:(NSString*)suffix
{
	[__suffixiPhoneRetinaDisplay release];
	__suffixiPhoneRetinaDisplay = [suffix copy];
}

+(void) setiPadSuffix:(NSString*)suffix
{
	[__suffixiPad release];
	__suffixiPad = [suffix copy];
}

+(void) setiPadRetinaDisplaySuffix:(NSString*)suffix
{
	[__suffixiPadRetinaDisplay release];
	__suffixiPadRetinaDisplay = [suffix copy];
}

+(BOOL) fileExistsAtPath:(NSString*)relPath withSuffix:(NSString*)suffix
{
	NSString *fullpath = nil;

	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] ) {
		// pathForResource also searches in .lproj directories. issue #1230
		NSString *file = [relPath lastPathComponent];
		NSString *imageDirectory = [relPath stringByDeletingLastPathComponent];

		fullpath = [[NSBundle mainBundle] pathForResource:file
												   ofType:nil
											  inDirectory:imageDirectory];

	}

	if (fullpath == nil)
		fullpath = relPath;

	NSString *path = [self getPath:fullpath forSuffix:suffix];

	return ( path != nil );
}

+(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:__suffixiPhoneRetinaDisplay];
}

+(BOOL) iPadFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:__suffixiPad];
}

+(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:__suffixiPadRetinaDisplay];
}


#endif // __CC_PLATFORM_IOS


@end
