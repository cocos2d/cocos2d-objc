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

#ifdef __CC_PLATFORM_IOS
enum {
	kCCiPhone,
	kCCiPhoneRetinaDisplay,
	kCCiPad,
	kCCiPadRetinaDisplay,
};
#elif __CC_PLATFORM_MAC
enum {
	kCCMac,
	kCCMacRetinaDisplay,
};
#endif

#pragma mark - Helper free functions

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

#pragma mark - CCCacheValue

@interface CCCacheValue : NSObject
{
	NSString			*fullpath_;
	ccResolutionType	resolutionType_;
}
@property (nonatomic, readwrite, retain) NSString *fullpath;
@property (nonatomic, readwrite ) ccResolutionType resolutionType;
@end

@implementation CCCacheValue
@synthesize fullpath = fullpath_, resolutionType = resolutionType_;
-(id) initWithFullPath:(NSString*)path resolutionType:(ccResolutionType)resolutionType
{
	if( (self=[super init]) )
	{
		self.fullpath = path;
		self.resolutionType = resolutionType;
	}
	
	return self;
}

- (void)dealloc
{
    [fullpath_ release];

    [super dealloc];
}
@end

#pragma mark - CCFileUtils

@interface CCFileUtils()
-(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path;
-(BOOL) fileExistsAtPath:(NSString*)string withSuffix:(NSString*)suffix;
-(NSInteger) runningDevice;
@end

@implementation CCFileUtils

@synthesize fileManager=fileManager_, bundle=bundle_;
@synthesize enableFallbackSuffixes = enableFallbackSuffixes_;

#ifdef __CC_PLATFORM_IOS
@synthesize iPhoneRetinaDisplaySuffix = iPhoneRetinaDisplaySuffix_;
@synthesize iPadSuffix = iPadSuffix_;
@synthesize iPadRetinaDisplaySuffix = iPadRetinaDisplaySuffix_;
#elif defined(__CC_PLATFORM_MAC)
@synthesize macSuffix = macSuffix_;
@synthesize macRetinaDisplaySuffix = macRetinaDisplaySuffix_;
#endif // __CC_PLATFORM_IOS

+ (id)sharedFileUtils
{
	static dispatch_once_t pred;
	static CCFileUtils *fileUtils = nil;
	dispatch_once(&pred, ^{
		fileUtils = [[self alloc] init];
	});
	return fileUtils;
}

-(id) init
{
	if( (self=[super init])) {
		fileManager_ = [[NSFileManager alloc] init];

		fullPathCache_ = [[NSMutableDictionary alloc] initWithCapacity:30];
		removeSuffixCache_ = [[NSMutableDictionary alloc] initWithCapacity:30];
		
		bundle_ = [[NSBundle mainBundle] retain];

		enableFallbackSuffixes_ = NO;

#ifdef __CC_PLATFORM_IOS
		iPhoneRetinaDisplaySuffix_ = @"-hd";
		iPadSuffix_ = @"-ipad";
		iPadRetinaDisplaySuffix_ = @"-ipadhd";		
#elif defined(__CC_PLATFORM_MAC)
		macRetinaDisplaySuffix_ = @"-machd";
		macSuffix_ = @"-mac";
#endif // __CC_PLATFORM_IOS

	}
	
	return self;
}

-(void) purgeCachedEntries
{
	[fullPathCache_ removeAllObjects];	
	[removeSuffixCache_ removeAllObjects];
}

- (void)dealloc
{
    [fileManager_ release];
	[bundle_ release];
	[fullPathCache_ release];
	[removeSuffixCache_ release];
	
#ifdef __CC_PLATFORM_IOS	
	[iPhoneRetinaDisplaySuffix_ release];
	[iPadSuffix_ release];
	[iPadRetinaDisplaySuffix_ release];
	
#elif defined(__CC_PLATFORM_MAC)
	[macRetinaDisplaySuffix_ release];
	[macSuffix_ release];

#endif // __CC_PLATFORM_MAC
	
    [super dealloc];
}

-(NSString*) pathForResource:(NSString*)resource ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    return [bundle_ pathForResource:resource
                             ofType:ext
                        inDirectory:subpath];
}

-(NSString*) getPath:(NSString*)path forSuffix:(NSString*)suffix
{
	NSString *newName = path;
	
	// only recreate filename if suffix is valid
	if( suffix && [suffix length] > 0)
	{
		NSString *pathWithoutExtension = [path stringByDeletingPathExtension];
		NSString *name = [pathWithoutExtension lastPathComponent];

		// check if path already has the suffix.
		if( [name rangeOfString:suffix].location == NSNotFound ) {
			

			NSString *extension = [path pathExtension];

			if( [extension isEqualToString:@"ccz"] || [extension isEqualToString:@"gz"] )
			{
				// All ccz / gz files should be in the format filename.xxx.ccz
				// so we need to pull off the .xxx part of the extension as well
				extension = [NSString stringWithFormat:@"%@.%@", [pathWithoutExtension pathExtension], extension];
				pathWithoutExtension = [pathWithoutExtension stringByDeletingPathExtension];
			}


			newName = [pathWithoutExtension stringByAppendingString:suffix];
			newName = [newName stringByAppendingPathExtension:extension];
		} else
			CCLOGWARN(@"cocos2d: WARNING Filename(%@) already has the suffix %@. Using it.", name, suffix);
	}

	NSString *ret = nil;
	// only if it is not an absolute path
	if( ! [path isAbsolutePath] ) {
		
		// pathForResource also searches in .lproj directories. issue #1230
		NSString *imageDirectory = [path stringByDeletingLastPathComponent];
		
		// If the file does not exist it will return nil.
		ret = [self pathForResource:[newName lastPathComponent]
												   ofType:nil
											  inDirectory:imageDirectory];
	}
	else if( [fileManager_ fileExistsAtPath:newName] )
		ret = newName;

	if( ! ret )
		CCLOGINFO(@"cocos2d: CCFileUtils: file not found: %@", [newName lastPathComponent] );

	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	CCCacheValue *value = [fullPathCache_ objectForKey:relPath];
	if( value ) {
		*resolutionType = value.resolutionType;
		return value.fullpath;
	}

	// Initialize to non-nil
	NSString *ret = @"";

	NSInteger device = [self runningDevice];

#ifdef __CC_PLATFORM_IOS
	
	// iPad HD ?
	if( device == kCCiPadRetinaDisplay ) {
		ret = [self getPath:relPath forSuffix:iPadRetinaDisplaySuffix_];
		*resolutionType = kCCResolutioniPadRetinaDisplay;
	}

	// iPad ?
	if( device == kCCiPad || (enableFallbackSuffixes_ && !ret) ) {
		ret = [self getPath:relPath forSuffix:iPadSuffix_];
		*resolutionType = kCCResolutioniPad;
	}
	
	// iPhone HD ?
	if( device == kCCiPhoneRetinaDisplay || (enableFallbackSuffixes_ && !ret) ) {
		ret = [self getPath:relPath forSuffix:iPhoneRetinaDisplaySuffix_];
		*resolutionType = kCCResolutioniPhoneRetinaDisplay;
	}

	// If it is not Phone HD, or if the previous "getPath" failed, then use iPhone images.
	if( device == kCCiPhone || !ret )
	{
		ret = [self getPath:relPath forSuffix:@""];
		*resolutionType = kCCResolutioniPhone;
	}
	
#elif defined(__CC_PLATFORM_MAC)

	if( device == kCCMacRetinaDisplay ) {
		ret = [self getPath:relPath forSuffix:macRetinaDisplaySuffix_];
		*resolutionType = kCCResolutionMacRetinaDisplay;
	}

	if( device == kCCMac || (enableFallbackSuffixes_ && !ret) ) {
		ret = [self getPath:relPath forSuffix:macSuffix_];
		*resolutionType = kCCResolutionMac;
	}

	// Not found ? Try with empty "" suffix.
	if( !ret )
	{
		ret = [self getPath:relPath forSuffix:@""];
		*resolutionType = kCCResolutionMac;
	}

#endif // __CC_PLATFORM_MAC
	
	if( ! ret ) {
		CCLOGWARN(@"cocos2d: Warning: File not found: %@", relPath);
		ret = relPath;
	}
		
	value = [[CCCacheValue alloc] initWithFullPath:ret resolutionType:*resolutionType];
	[fullPathCache_ setObject:value forKey:relPath];
	[value release];
	
	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	ccResolutionType ignore;
	return [self fullPathFromRelativePath:relPath resolutionType:&ignore];
}

#pragma mark CCFileUtils - Suffix

// XXX: Optimization: This should be called only once
-(NSInteger) runningDevice
{
	NSInteger ret=-1;

#ifdef __CC_PLATFORM_IOS
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			ret = kCCiPadRetinaDisplay;
		else
			ret = kCCiPad;
	}
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			ret = kCCiPhoneRetinaDisplay;
		else
			ret = kCCiPhone;
	}

#elif defined(__CC_PLATFORM_MAC)

	// XXX: Add here support for Mac Retina Display
	ret = kCCMac;

#endif // __CC_PLATFORM_MAC
	
	return ret;
}

-(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path
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
	
	// suffix was not removed
	return nil;
}

-(NSString*) removeSuffixFromFile:(NSString*) path
{
	NSString *withoutSuffix = [removeSuffixCache_ objectForKey:path];
	if( withoutSuffix )
		return withoutSuffix;
	
	// Initial value should be non-nil
	NSString *ret = @"";
	
	NSInteger device = [self runningDevice];
	
#ifdef __CC_PLATFORM_IOS
	if( device == kCCiPadRetinaDisplay )
		ret = [self removeSuffix:iPadRetinaDisplaySuffix_ fromPath:path];
	
	if( device == kCCiPad || (enableFallbackSuffixes_ && !ret) )
		ret = [self removeSuffix:iPadSuffix_ fromPath:path];
	
	if( device == kCCiPhoneRetinaDisplay || (enableFallbackSuffixes_ && !ret) )
		ret = [self removeSuffix:iPhoneRetinaDisplaySuffix_ fromPath:path];
	
	if( device == kCCiPhone || !ret )
		ret = path;	

#elif defined(__CC_PLATFORM_MAC)
	if( device == kCCMacRetinaDisplay )
		ret = [self removeSuffix:macRetinaDisplaySuffix_ fromPath:path];

	if( device == kCCMac|| !ret )
		ret = [self removeSuffix:macSuffix_ fromPath:path];

#endif // __CC_PLATFORM_MAC
	
	if( ret )
		[removeSuffixCache_ setObject:ret forKey:path];
	
	return ret;
}

-(BOOL) fileExistsAtPath:(NSString*)relPath withSuffix:(NSString*)suffix
{
	NSString *fullpath = nil;
	
	// only if it is not an absolute path
	if( ! [relPath isAbsolutePath] ) {
		// pathForResource also searches in .lproj directories. issue #1230
		NSString *file = [relPath lastPathComponent];
		NSString *imageDirectory = [relPath stringByDeletingLastPathComponent];
		
		fullpath = [bundle_ pathForResource:file
									 ofType:nil
								inDirectory:imageDirectory];
		
	}
	
	if (fullpath == nil)
		fullpath = relPath;
	
	NSString *path = [self getPath:fullpath forSuffix:suffix];
	
	return ( path != nil );
}

#ifdef __CC_PLATFORM_IOS

-(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:iPhoneRetinaDisplaySuffix_];
}

-(BOOL) iPadFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:iPadSuffix_];
}

-(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:iPadRetinaDisplaySuffix_];
}

#elif defined(__CC_PLATFORM_MAC)

-(BOOL) macRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:macRetinaDisplaySuffix_];
}

-(BOOL) macFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:macSuffix_];
}

#endif // __CC_PLATFORM_MAC


@end
