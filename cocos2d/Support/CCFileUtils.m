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

NSString *kCCFileUtilsDefault = @"default";

NSString *kCCFileUtilsiPad = @"ipad";
NSString *kCCFileUtilsiPadHD = @"ipadhd";
NSString *kCCFileUtilsiPhone = @"iphone";
NSString *kCCFileUtilsiPhoneHD = @"iphonehd";
NSString *kCCFileUtilsiPhone5 = @"iphone5";
NSString *kCCFileUtilsiPhone5HD = @"iphone5hd";
NSString *kCCFileUtilsMac = @"mac";
NSString *kCCFileUtilsMacHD = @"machd";

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
{
	NSString			*_fullpath;
	ccResolutionType	_resolutionType;
}
@property (nonatomic, readwrite, retain) NSString *fullpath;
@property (nonatomic, readwrite ) ccResolutionType resolutionType;
@end

@implementation CCCacheValue
@synthesize fullpath = _fullpath, resolutionType = _resolutionType;
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
	[_fullpath release];

	[super dealloc];
}
@end

#pragma mark - CCFileUtils

@interface CCFileUtils()
-(NSString *) removeSuffix:(NSString*)suffix fromPath:(NSString*)path;
-(BOOL) fileExistsAtPath:(NSString*)string withSuffix:(NSString*)suffix;
-(void) buildSearchResolutionsOrder;
@end

@implementation CCFileUtils

@synthesize fileManager=_fileManager, bundle=_bundle;
@synthesize enableiPhoneResourcesOniPad = _enableiPhoneResourcesOniPad;
@synthesize searchResolutionsOrder = _searchResolutionsOrder;
@synthesize suffixesDict = _suffixesDict, directoriesDict = _directoriesDict;
@synthesize searchMode = _searchMode;

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
		_fileManager = [[NSFileManager alloc] init];

		_fullPathCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		_fullPathNoResolutionsCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		_removeSuffixCache = [[NSMutableDictionary alloc] initWithCapacity:30];
		
		_bundle = [[NSBundle mainBundle] retain];

		_enableiPhoneResourcesOniPad = NO;
		
		_searchResolutionsOrder = [[NSMutableArray alloc] initWithCapacity:5];
		
		_searchPath = [[NSMutableArray alloc] initWithObjects:@"", nil];
								  
		
#ifdef __CC_PLATFORM_IOS
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"-ipad", kCCFileUtilsiPad,
						 @"-ipadhd", kCCFileUtilsiPadHD,
						 @"", kCCFileUtilsiPhone,
						 @"-hd", kCCFileUtilsiPhoneHD,
						 @"-wide", kCCFileUtilsiPhone5,
						 @"-widehd", kCCFileUtilsiPhone5HD,
						 @"", kCCFileUtilsDefault,
						 nil];

		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"resources-ipad", kCCFileUtilsiPad,
							@"resources-ipadhd", kCCFileUtilsiPadHD,
							@"resources-iphone", kCCFileUtilsiPhone,
							@"resources-iphonehd", kCCFileUtilsiPhoneHD,
							@"resources-iphone5", kCCFileUtilsiPhone5,
							@"resources-iphone5hd", kCCFileUtilsiPhone5HD,
							@"", kCCFileUtilsDefault,
							nil];

#elif defined(__CC_PLATFORM_MAC)
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"", kCCFileUtilsMac,
						 @"-machd", kCCFileUtilsMacHD,
						 @"", kCCFileUtilsDefault,
						 nil];
		
		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"resources-mac", kCCFileUtilsMac,
							@"resources-machd", kCCFileUtilsMacHD,
							@"", kCCFileUtilsDefault,
							nil];

#endif // __CC_PLATFORM_IOS

		_searchMode = kCCFileUtilsSearchSuffix;
		
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

- (void)dealloc
{
	[_fileManager release];
	[_bundle release];

	[_fullPathCache release];
	[_fullPathNoResolutionsCache release];
	[_removeSuffixCache release];
	
	[_suffixesDict release];
	[_directoriesDict release];
	[_searchResolutionsOrder release];
	[_searchPath release];
	
	[super dealloc];
}

- (void) buildSearchResolutionsOrder
{
	NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];

	[_searchResolutionsOrder removeAllObjects];
	
#ifdef __CC_PLATFORM_IOS
	if (device == kCCDeviceiPadRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPadHD];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPad];
		if( _enableiPhoneResourcesOniPad ) {
			[_searchResolutionsOrder addObject:kCCFileUtilsiPhone5HD];
			[_searchResolutionsOrder addObject:kCCFileUtilsiPhoneHD];
		}
	}
	else if (device == kCCDeviceiPad)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPad];
		if( _enableiPhoneResourcesOniPad ) {
			[_searchResolutionsOrder addObject:kCCFileUtilsiPhone5HD];
			[_searchResolutionsOrder addObject:kCCFileUtilsiPhoneHD];
		}
	}
	else if (device == kCCDeviceiPhone5RetinaDisplay)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone5HD];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhoneHD];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone5];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone];
	}
	else if (device == kCCDeviceiPhoneRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhoneHD];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone];
	}
	else if (device == kCCDeviceiPhone5)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone5];
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone];
	}
	else if (device == kCCDeviceiPhone)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsiPhone];
	}
	
#elif defined(__CC_PLATFORM_MAC)
	if (device == kCCDeviceMacRetinaDisplay)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsMacHD];
		[_searchResolutionsOrder addObject:kCCFileUtilsMac];
	}
	else if (device == kCCDeviceMac)
	{
		[_searchResolutionsOrder addObject:kCCFileUtilsMac];
	}
#endif	
	
	[_searchResolutionsOrder addObject:kCCFileUtilsDefault];
}

-(NSString*) pathForResource:(NSString*)resource ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
	// Default to normal resource directory
	return [_bundle pathForResource:resource
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

-(NSString*) getPath:(NSString*)path forDirectory:(NSString*)directory
{	
	NSString *ret = nil;
	// only if it is not an absolute path
	if( ! [path isAbsolutePath] ) {
		
		// pathForResource also searches in .lproj directories. issue #1230
		// If the file does not exist it will return nil.
		NSString *filename = [path lastPathComponent];
		NSString *imageDirectory = [directory stringByAppendingPathComponent: [path stringByDeletingLastPathComponent]];
		
		// on iOS it is OK to pass inDirector=nil and pass a path in "Resources",
		// but on OS X it doesn't work.
		ret = [self pathForResource:filename
							 ofType:nil
						inDirectory:imageDirectory];
	}
	else
	{
		NSString* newDir = [path stringByDeletingLastPathComponent];
		NSString* newFile = [path lastPathComponent];
		NSString *newName = [[newDir stringByAppendingPathComponent:directory] stringByAppendingPathComponent:newFile];
		if ([_fileManager fileExistsAtPath:newName])
			ret = newName;
	}
	
	return ret;
}

-(ccResolutionType) resolutionTypeForKey:(NSString*)k inDictionary:dictionary
{
	// XXX XXX Super Slow
	for( NSString *key in dictionary) {
		NSString *value = [dictionary objectForKey:key];
		if( [value isEqualToString:k] ) {
			
#ifdef __CC_PLATFORM_IOS
			// XXX Add this in a Dictionary
			if( [key isEqualToString:kCCFileUtilsiPad] )
				return kCCResolutioniPad;
			if( [key isEqualToString:kCCFileUtilsiPadHD] )
				return kCCResolutioniPadRetinaDisplay;
			if( [key isEqualToString:kCCFileUtilsiPhone] )
				return kCCResolutioniPhone;
			if( [key isEqualToString:kCCFileUtilsiPhoneHD] )
				return kCCResolutioniPhoneRetinaDisplay;
			if( [key isEqualToString:kCCFileUtilsiPhone5HD] )
				return kCCResolutioniPhone5RetinaDisplay;
			if( [key isEqualToString:kCCFileUtilsiPhone5] )
				return kCCResolutioniPhone5;
			if( [key isEqualToString:kCCFileUtilsDefault] )
				return kCCResolutionUnknown;
#elif defined(__CC_PLATFORM_MAC)
			if( [key isEqualToString:kCCFileUtilsMacHD] )
				return kCCResolutionMacRetinaDisplay;
			if( [key isEqualToString:kCCFileUtilsMac] )
				return kCCResolutionMac;
			if( [key isEqualToString:kCCFileUtilsDefault] )
				return kCCResolutionUnknown;
#endif // __CC_PLATFORM_MAC
		}
	}
//	NSAssert(NO, @"Should not reach here");
	return kCCResolutionUnknown;
}


-(NSString*) fullPathFromRelativePathIgnoringResolutions:(NSString*)relPath
{
	if ([relPath isAbsolutePath])
		return relPath;
	
	NSString* ret = [_fullPathNoResolutionsCache objectForKey:relPath];
	if (ret)
		return ret;
	
	for( NSString *path in _searchPath ) {
		
		ret = [path stringByAppendingPathComponent:relPath];

		if ([_fileManager fileExistsAtPath:ret])
			break;
		
		NSString *fileName = [relPath lastPathComponent];
		NSString *filePath = [relPath stringByDeletingLastPathComponent];
		// Default to normal resource directory
		ret = [_bundle pathForResource:fileName
								 ofType:nil
						   inDirectory:filePath];
		if(ret)
			break;
	}
	
	// Save in cache
	if (ret)
		[_fullPathNoResolutionsCache setObject:ret forKey:relPath];
	else
		CCLOGINFO(@"cocos2d: CCFileUtils: file not found: %@", relPath );
	
	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");
	
	CCCacheValue *value = [_fullPathCache objectForKey:relPath];
	if( value ) {
		*resolutionType = value.resolutionType;
		return value.fullpath;
	}
	BOOL found = NO;
	NSString *ret = @"";

	for( NSString *path in _searchPath ) {

		NSString *fileWithPath = [path stringByAppendingPathComponent:relPath];
		
		// Search with Suffixes
		for( NSString *device in _searchResolutionsOrder ) {

			if( _searchMode == kCCFileUtilsSearchSuffix ) {
				// Search using suffixes
				NSString *suffix = [_suffixesDict objectForKey:device];
				ret = [self getPath:fileWithPath forSuffix:suffix];
				*resolutionType = [self resolutionTypeForKey:suffix inDictionary:_suffixesDict];
			} else {
				// Search in subdirectories
				NSString *directory = [_directoriesDict objectForKey:device];
				ret = [self getPath:fileWithPath forDirectory:directory];
				*resolutionType = [self resolutionTypeForKey:directory inDictionary:_directoriesDict];
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
	
	if( ! found ) {
		CCLOGWARN(@"cocos2d: Warning: File not found: %@", relPath);
		ret = relPath;
	}
	
	value = [[CCCacheValue alloc] initWithFullPath:ret resolutionType:*resolutionType];
	[_fullPathCache setObject:value forKey:relPath];
	[value release];
	
	return ret;
}

-(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	ccResolutionType ignore;
	return [self fullPathFromRelativePath:relPath resolutionType:&ignore];
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
	[_suffixesDict setObject:suffix forKey:kCCFileUtilsiPadHD];
}

-(void) setiPadSuffix:(NSString *)suffix
{
	[_suffixesDict setObject:suffix forKey:kCCFileUtilsiPad];
}

-(void) setiPhoneRetinaDisplaySuffix:(NSString *)suffix
{
	[_suffixesDict setObject:suffix forKey:kCCFileUtilsiPhoneHD];
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

	NSString *path = [self getPath:fullpath forSuffix:suffix];

	return ( path != nil );
}

#pragma mark CCFileUtils - deprecated

// XXX deprecated
-(void) setEnableFallbackSuffixes:(BOOL)enableFallbackSuffixes
{
	[self setEnableiPhoneResourcesOniPad:enableFallbackSuffixes];
}

#ifdef __CC_PLATFORM_IOS

-(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPhoneHD]];
}

-(BOOL) iPadFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPad]];
}

-(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPadHD]];
}

#endif // __CC_PLATFORM_IOS

@end
