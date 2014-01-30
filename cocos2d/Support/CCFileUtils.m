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

NSString *CCFileUtilsSuffixDefault = @"default";

NSString *CCFileUtilsSuffixiPad = @"ipad";
NSString *CCFileUtilsSuffixiPadHD = @"ipadhd";
NSString *CCFileUtilsSuffixiPhone = @"iphone";
NSString *CCFileUtilsSuffixiPhoneHD = @"iphonehd";
NSString *CCFileUtilsSuffixiPhone5 = @"iphone5";
NSString *CCFileUtilsSuffixiPhone5HD = @"iphone5hd";
NSString *CCFileUtilsSuffixMac = @"mac";
NSString *CCFileUtilsSuffixMacHD = @"machd";

NSString *kCCFileUtilsDefaultSearchPath = @"";

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
@property (nonatomic, readwrite, strong) NSString *fullpath;
@property (nonatomic, readwrite ) CGFloat contentScale;
@end

@implementation CCCacheValue
-(id) initWithFullPath:(NSString*)path contentScale:(CGFloat)contentScale;
{
	if( (self=[super init]) )
	{
		self.fullpath = path;
		self.contentScale = contentScale;
	}
	
	return self;
}

@end

#pragma mark - CCFileUtils

@interface CCFileUtils()
-(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path;
-(BOOL) fileExistsAtPath:(NSString*)string withSuffix:(NSString*)suffix;
-(void) buildSearchResolutionsOrder;
@end

@implementation CCFileUtils
{
	CGFloat _iPhoneContentScaleFactor;
	CGFloat _iPadContentScaleFactor;
	CGFloat _macContentScaleFactor;
}

@synthesize fileManager=_fileManager, bundle=_bundle;
@synthesize enableiPhoneResourcesOniPad = _enableiPhoneResourcesOniPad;
@synthesize searchResolutionsOrder = _searchResolutionsOrder;
@synthesize suffixesDict = _suffixesDict, directoriesDict = _directoriesDict;
@synthesize searchMode = _searchMode;
@synthesize searchPath = _searchPath;
@synthesize filenameLookup = _filenameLookup;

static CCFileUtils *fileUtils = nil;

// Private method to reset all the saved state that FileUtils holds on to. Useful for unit tests.
+(void) resetSingleton{
	fileUtils = nil;
}


+ (id)sharedFileUtils
{
	if(!fileUtils) {
		fileUtils = [[self alloc] init];
	}
	return fileUtils;
}

-(id) init
{
	if( (self=[super init])) {
		_fileManager = [[NSFileManager alloc] init];

		_fullPathCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		_fullPathNoResolutionsCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		_removeSuffixCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		
		_bundle = [NSBundle mainBundle];

		_enableiPhoneResourcesOniPad = YES;
		
		_searchResolutionsOrder = [[NSMutableArray alloc] initWithCapacity:5];
		
		_searchPath = [[NSMutableArray alloc] initWithObjects:@"", nil];
		
		_filenameLookup = [[NSMutableDictionary alloc] initWithCapacity:10];
								  
		
#ifdef __CC_PLATFORM_IOS
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"-ipad", CCFileUtilsSuffixiPad,
						 @"-ipadhd", CCFileUtilsSuffixiPadHD,
						 @"", CCFileUtilsSuffixiPhone,
						 @"-hd", CCFileUtilsSuffixiPhoneHD,
						 @"-iphone5", CCFileUtilsSuffixiPhone5,
						 @"-iphone5hd", CCFileUtilsSuffixiPhone5HD,
						 @"", CCFileUtilsSuffixDefault,
						 nil];

		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"resources-ipad", CCFileUtilsSuffixiPad,
							@"resources-ipadhd", CCFileUtilsSuffixiPadHD,
							@"resources-iphone", CCFileUtilsSuffixiPhone,
							@"resources-iphonehd", CCFileUtilsSuffixiPhoneHD,
							@"resources-iphone5", CCFileUtilsSuffixiPhone5,
							@"resources-iphone5hd", CCFileUtilsSuffixiPhone5HD,
							@"", CCFileUtilsSuffixDefault,
							nil];

#elif defined(__CC_PLATFORM_MAC)
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"", CCFileUtilsSuffixMac,
						 @"-machd", CCFileUtilsSuffixMacHD,
						 @"", CCFileUtilsSuffixDefault,
						 nil];
		
		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"resources-mac", CCFileUtilsSuffixMac,
							@"resources-machd", CCFileUtilsSuffixMacHD,
							@"", CCFileUtilsSuffixDefault,
							nil];

#endif // __CC_PLATFORM_IOS
		
		_iPhoneContentScaleFactor = 1.0;
		_iPadContentScaleFactor = 1.0;
		_macContentScaleFactor = 1.0;

		_searchMode = CCFileUtilsSearchModeSuffix;
		
		[self buildSearchResolutionsOrder];
	}
	
	return self;
}

-(void) purgeCachedEntries
{
	[_fullPathCache removeAllObjects];
	[_fullPathNoResolutionsCache removeAllObjects];
	[_removeSuffixCache removeAllObjects];
}


- (void) buildSearchResolutionsOrder
{
	NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];

	[_searchResolutionsOrder removeAllObjects];
	
#ifdef __CC_PLATFORM_IOS
	if (device == CCDeviceiPadRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPadHD];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPad];
		if( _enableiPhoneResourcesOniPad ) {
			[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone5HD];
			[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhoneHD];
		}
	}
	else if (device == CCDeviceiPad)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPad];
		if( _enableiPhoneResourcesOniPad ) {
			[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone5HD];
			[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhoneHD];
		}
	}
	else if (device == CCDeviceiPhone5RetinaDisplay)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone5HD];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhoneHD];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone5];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone];
	}
	else if (device == CCDeviceiPhoneRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhoneHD];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone];
	}
	else if (device == CCDeviceiPhone5)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone5];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone];
	}
	else if (device == CCDeviceiPhone)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixiPhone];
	}
	
#elif defined(__CC_PLATFORM_MAC)
	if (device == CCDeviceMacRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixMacHD];
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixMac];
	}
	else if (device == CCDeviceMac)
	{
		[_searchResolutionsOrder addObject:CCFileUtilsSuffixMac];
	}
#endif	
	
	[_searchResolutionsOrder addObject:CCFileUtilsSuffixDefault];
}

-(NSString*) pathForResource:(NSString*)resource ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    // An absolute path could be used if the searchPath contains absolute paths
    if( [subpath isAbsolutePath] ) {
        NSString *fullpath = [subpath stringByAppendingPathComponent:resource];
        if( ext )
            fullpath = [fullpath stringByAppendingPathExtension:ext];
        
        if( [_fileManager fileExistsAtPath:fullpath] )
            return fullpath;
        return nil;
    }
    
	// Default to normal resource directory
	return [_bundle pathForResource:resource
							 ofType:ext
						inDirectory:subpath];
}

-(NSString*) getPathForFilename:(NSString*)path withSuffix:(NSString*)suffix
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
		// If the file does not exist it will return nil.
		NSString *filename = [newName lastPathComponent];
		NSString *imageDirectory = [path stringByDeletingLastPathComponent];
		
		// on iOS it is OK to pass inDirector=nil and pass a path in "Resources",
		// but on OS X it doesn't work.
		ret = [self pathForResource:filename
							 ofType:nil
						inDirectory:imageDirectory];
	}
	else if( [_fileManager fileExistsAtPath:newName] )
		ret = newName;

	if( ! ret )
		CCLOGINFO(@"cocos2d: CCFileUtils: file not found: %@", [newName lastPathComponent] );

	return ret;
}

-(NSString*) getPathForFilename:(NSString*)filename withResourceDirectory:(NSString*)resourceDirectory withSearchPath:(NSString*)searchPath
{	
	NSString *ret = nil;
	
	NSString *file = [filename lastPathComponent];
	NSString *file_path = [filename stringByDeletingLastPathComponent];

	// searchPath + file_path + resourceDirectory
	NSString * path = [searchPath stringByAppendingPathComponent:file_path];
	path = [path stringByAppendingPathComponent:resourceDirectory];

	// only if it is not an absolute path
	if( ! [filename isAbsolutePath] ) {
		
		// pathForResource also searches in .lproj directories. issue #1230
		// If the file does not exist it will return nil.		
		// on iOS it is OK to pass inDirector=nil and pass a path in "Resources",
		// but on OS X it doesn't work.
		ret = [self pathForResource:file
							 ofType:nil
						inDirectory:path];
	}
	else
	{
		NSString *newName = [[file_path stringByAppendingPathComponent:path] stringByAppendingPathComponent:file];
		if ([_fileManager fileExistsAtPath:newName])
			ret = newName;
	}
	
	return ret;
}

-(CGFloat) contentScaleForKey:(NSString*)k inDictionary:(NSDictionary *)dictionary
{
	// XXX XXX Super Slow
	for( NSString *key in dictionary) {
		NSString *value = [dictionary objectForKey:key];
		if( [value isEqualToString:k] ) {
			
#ifdef __CC_PLATFORM_IOS
			// XXX Add this in a Dictionary
			if( [key isEqualToString:CCFileUtilsSuffixiPad] )
				return 1.0*_iPadContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixiPadHD] )
				return 2.0*_iPadContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixiPhone] )
				return 1.0*_iPhoneContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixiPhoneHD] )
				return 2.0*_iPhoneContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixiPhone5] )
				return 1.0*_iPhoneContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixiPhone5HD] )
				return 2.0*_iPhoneContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixDefault] )
				return 1.0;
#elif defined(__CC_PLATFORM_MAC)
			if( [key isEqualToString:CCFileUtilsSuffixMac] )
				return 1.0*_macContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixMacHD] )
				return 2.0*_macContentScaleFactor;
			if( [key isEqualToString:CCFileUtilsSuffixDefault] )
				return 1.0;
#endif // __CC_PLATFORM_MAC
		}
	}
//	NSAssert(NO, @"Should not reach here");
	return 1.0;
}


-(NSString*) fullPathForFilenameIgnoringResolutions:(NSString*)filename
{
	// fullpath? return it
	if ([filename isAbsolutePath])
		return filename;

	// Already cached ?
	NSString* ret = [_fullPathNoResolutionsCache objectForKey:filename];
	if (ret)
		return ret;
	
	// Lookup rules
	NSString *newfilename = [_filenameLookup objectForKey:filename];
	if( ! newfilename )
		newfilename = filename;

	
	for( NSString *path in _searchPath ) {
		
		ret = [path stringByAppendingPathComponent:newfilename];
		
		if ([_fileManager fileExistsAtPath:ret])
			break;
		
		NSString *file = [ret lastPathComponent];
		NSString *file_path = [ret stringByDeletingLastPathComponent];
		// Default to normal resource directory
		ret = [_bundle pathForResource:file
								ofType:nil
						   inDirectory:file_path];
		if(ret)
			break;
	}

	// Save in cache
	if( ret )
		[_fullPathNoResolutionsCache setObject:ret forKey:filename];
	else
		CCLOGINFO(@"cocos2d: CCFileUtils: file not found: %@", filename );
	
	return ret;
}

-(NSString*) fullPathFromRelativePathIgnoringResolutions:(NSString*)relPath
{
	NSString *ret = [self fullPathForFilenameIgnoringResolutions:relPath];

	if( !ret )
		ret = relPath;
	
	return ret;
}

-(NSString*) fullPathForFilename:(NSString*)filename
{
	return [self fullPathForFilename:filename contentScale:NULL];
}

-(NSString*) fullPathForFilename:(NSString*)filename contentScale:(CGFloat *)contentScale
{
	CGFloat _contentScale = 1.0;
	if(!contentScale) contentScale = &_contentScale;
	
	// fullpath? return it
//	if ([filename isAbsolutePath]) {
//		CCLOGWARN(@"cocos2d: WARNING fullPathForFilename:resolutionType: should not be called with absolute path. Instead call fullPathForFilenameIgnoringResolutions:");
//		*contentScale = 1.0;
//		NSLog(@"filename:%@, fullPath:%@, contentScale:%f", filename, filename, *contentScale);
//		return filename;
//	}

	// Already Cached ?
	CCCacheValue *value = [_fullPathCache objectForKey:filename];
	if( value ) {
		*contentScale = value.contentScale;
		return value.fullpath;
	}

	// in Lookup Filename dictionary ?
	NSString *newfilename = [_filenameLookup objectForKey:filename];
	if( ! newfilename )
		newfilename = filename;

	BOOL found = NO;
	NSString *ret = @"";
	
	for( NSString *path in _searchPath ) {
		
		// Search with Suffixes
		for( NSString *device in _searchResolutionsOrder ) {

			NSString *fileWithPath = [path stringByAppendingPathComponent:newfilename];
			
			if( _searchMode == CCFileUtilsSearchModeSuffix ) {
				// Search using suffixes
				NSString *suffix = [_suffixesDict objectForKey:device];
				ret = [self getPathForFilename:fileWithPath withSuffix:suffix];
				*contentScale = [self contentScaleForKey:suffix inDictionary:_suffixesDict];
			} else {
				// Search in subdirectories
				NSString *directory = [_directoriesDict objectForKey:device];
				ret = [self getPathForFilename:newfilename withResourceDirectory:directory withSearchPath:path];
				*contentScale = [self contentScaleForKey:directory inDictionary:_directoriesDict];
			}
			
			if( ret ) {
				found = YES;
				break;
			}
		}
		
		// there are 2 loops
		if(found)
			break;
	}

	if( found ) {
		value = [[CCCacheValue alloc] initWithFullPath:ret contentScale:*contentScale];
		[_fullPathCache setObject:value forKey:filename];
	}
	else
	{
    // TODO: NSAssert here instead? Seems like whatever happens next will fail because of this.
    // Better to stop now rather than later.
		CCLOGWARN(@"cocos2d: Warning: File not found: %@", filename);
		ret = nil;
	}
	
	
	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*)relPath contentScale:(CGFloat *)contentScale
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");

	NSString *ret = [self fullPathForFilename:relPath contentScale:contentScale];
	
	// The only difference is that it returns nil
	if( ! ret )
		ret = relPath;
	
	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	return [self fullPathFromRelativePath:relPath contentScale:NULL];
}

-(void) loadFilenameLookupDictionaryFromFile:(NSString*)filename
{
	NSString *fullpath = [self fullPathForFilenameIgnoringResolutions:filename];
	if( fullpath ) {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullpath];

		NSDictionary *metadata = [dict objectForKey:@"metadata"];
		NSInteger version = [[metadata objectForKey:@"version"] integerValue];
		if( version != 1) {
			CCLOG(@"cocos2d: ERROR: Invalid filenameLookup dictionary version: %ld. Filename: %@", (long)version, filename);
			return;
		}
		
		NSMutableDictionary *filenames = [dict objectForKey:@"filenames"];
		self.filenameLookup = filenames;
	}
}

#pragma mark Helpers

-(NSString*) standarizePath:(NSString*)path
{
	NSString *ret = [path stringByStandardizingPath];
	if( _searchMode == CCFileUtilsSearchModeSuffix )
		ret = [self removeSuffixFromFile:ret];
	
	return ret;
}

#pragma mark CCFileUtils - Suffix / Directory search chain

-(void) setEnableiPhoneResourcesOniPad:(BOOL)enable
{
	if( _enableiPhoneResourcesOniPad != enable ) {
		
		_enableiPhoneResourcesOniPad = enable;
		
		[self buildSearchResolutionsOrder];
	}
}

#ifdef __CC_PLATFORM_IOS

-(void) setiPadRetinaDisplaySuffix:(NSString *)suffix
{
	[_suffixesDict setObject:suffix forKey:CCFileUtilsSuffixiPadHD];
}

-(void) setiPadSuffix:(NSString *)suffix
{
	[_suffixesDict setObject:suffix forKey:CCFileUtilsSuffixiPad];
}

-(void) setiPhoneRetinaDisplaySuffix:(NSString *)suffix
{
	[_suffixesDict setObject:suffix forKey:CCFileUtilsSuffixiPhoneHD];
}

-(void)setiPhoneContentScaleFactor:(CGFloat)scale
{
	_iPhoneContentScaleFactor = scale;
}

-(void)setiPadContentScaleFactor:(CGFloat)scale
{
	_iPadContentScaleFactor = scale;
}

#elif defined(__CC_PLATFORM_MAC)

-(void)setMacContentScaleFactor:(CGFloat)scale
{
	_macContentScaleFactor = scale;
}

#endif // __CC_PLATFORM_IOS


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
	NSString *withoutSuffix = [_removeSuffixCache objectForKey:path];
	if( withoutSuffix )
		return withoutSuffix;
	
	// Initial value should be non-nil
	NSString *ret = @"";
		
	for( NSString *device in _searchResolutionsOrder ) {
		NSString *suffix = [_suffixesDict objectForKey:device];
		ret = [self removeSuffix:suffix fromPath:path];
		
		if( ret )
			break;
	}
	
	if( ! ret )
		ret = path;
	
    if (path)
        [_removeSuffixCache setObject:ret forKey:path];
	
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
		
		fullpath = [_bundle pathForResource:file
									 ofType:nil
								inDirectory:imageDirectory];
		
	}

	if (fullpath == nil)
		fullpath = relPath;

	NSString *path = [self getPathForFilename:fullpath withSuffix:suffix];

	return ( path != nil );
}

#ifdef __CC_PLATFORM_IOS

-(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:CCFileUtilsSuffixiPhoneHD]];
}

-(BOOL) iPadFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:CCFileUtilsSuffixiPad]];
}

-(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:CCFileUtilsSuffixiPadHD]];
}

#endif // __CC_PLATFORM_IOS

@end
