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
#ifdef __CC_PLATFORM_IOS
NSString *kCCFileUtilsiPad = @"ipad";
NSString *kCCFileUtilsiPadHD = @"ipadhd";
NSString *kCCFileUtilsiPhone = @"iphone";
NSString *kCCFileUtilsiPhoneHD = @"iphonehd";
NSString *kCCFileUtilsiPhone5 = @"iphone5";
NSString *kCCFileUtilsiPhone5HD = @"iphone5hd";
#elif __CC_PLATFORM_MAC
NSString *kCCFileUtilsMac = @"";
NSString *kCCFileUtilsMacHD = @"machd";
#endif

#ifdef __CC_PLATFORM_IOS
enum {
	kCCiPhone,
	kCCiPhoneRetinaDisplay,
	kCCiPhone5,
	kCCiPhone5RetinaDisplay,
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
-(NSInteger) runningDevice;
-(void) buildSearchChain;
@end

@implementation CCFileUtils

@synthesize fileManager=_fileManager, bundle=_bundle;
@synthesize enableFallbackChain = _enableFallbackChain;
@synthesize searchChain = _searchChain;
@synthesize suffixesDict = _suffixesDict, directoriesDict = _directoriesDict;

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

		_enableFallbackChain = NO;
		
		_searchChain = [[NSMutableArray alloc] initWithCapacity:5];
		
#ifdef __CC_PLATFORM_IOS
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"-ipadhd", kCCFileUtilsiPadHD,
						 @"-ipad", kCCFileUtilsiPad,
						 @"", kCCFileUtilsiPhone,
						 @"-hd", kCCFileUtilsiPhoneHD,
						 @"-wide", kCCFileUtilsiPhone5,
						 @"-widehd", kCCFileUtilsiPhone5HD,
						 @"", kCCFileUtilsDefault,
						 nil];

		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"ipadhd", kCCFileUtilsiPadHD,
							@"ipad", kCCFileUtilsiPad,
							@"iphone", kCCFileUtilsiPhone,
							@"iphonehd", kCCFileUtilsiPhoneHD,
							@"iphone5", kCCFileUtilsiPhone5,
							@"iphone5hd", kCCFileUtilsiPhone5HD,
							@"", kCCFileUtilsDefault,
							nil];

#elif defined(__CC_PLATFORM_MAC)
		_suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 @"-mac", kCCFileUtilsMac,
						 @"-machd", kCCFileUtilsMacHD,
						 @"", kCCFileUtilsDefault,
						 nil];
		
		_directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							@"mac", kCCFileUtilsMac,
							@"machd", kCCFileUtilsMacHD,
							@"", kCCFileUtilsDefault,
							nil];

#endif // __CC_PLATFORM_IOS

		_searchMode = kCCFileUtilsSearchSuffix;
		
		[self buildSearchChain];
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
	[_searchChain release];
	
	[super dealloc];
}

- (void) buildSearchChain
{
	[self buildSearchChainWithFallbacks: _enableFallbackChain];
}

- (void) buildSearchChainWithFallbacks:(BOOL)useFallbacks
{
	NSInteger device = [self runningDevice];

	[_searchChain removeAllObjects];
	
#ifdef __CC_PLATFORM_IOS
	if (device == kCCiPadRetinaDisplay)
	{
		[_searchChain addObject:kCCFileUtilsiPadHD];
		[_searchChain addObject:kCCFileUtilsiPad];
		if( useFallbacks ) {
			[_searchChain addObject:kCCFileUtilsiPhone5HD];
			[_searchChain addObject:kCCFileUtilsiPhoneHD];
		}
	}
	else if (device == kCCiPad)
	{
		[_searchChain addObject:kCCFileUtilsiPad];
		if( useFallbacks ) {
			[_searchChain addObject:kCCFileUtilsiPhone5HD];
			[_searchChain addObject:kCCFileUtilsiPhoneHD];
		}
	}
	else if (device == kCCiPhone5RetinaDisplay)
	{
		[_searchChain addObject:kCCFileUtilsiPhone5HD];
		[_searchChain addObject:kCCFileUtilsiPhoneHD];
		[_searchChain addObject:kCCFileUtilsiPhone5];
		[_searchChain addObject:kCCFileUtilsiPhone];
	}
	else if (device == kCCiPhoneRetinaDisplay)
	{
		[_searchChain addObject:kCCFileUtilsiPhoneHD];
		[_searchChain addObject:kCCFileUtilsiPhone5HD];
		[_searchChain addObject:kCCFileUtilsiPhone];
		[_searchChain addObject:kCCFileUtilsiPhone5];
	}
	else if (device == kCCiPhone5)
	{
		[_searchChain addObject:kCCFileUtilsiPhone5];
		[_searchChain addObject:kCCFileUtilsiPhone];
	}
	else if (device == kCCiPhone)
	{
		[_searchChain addObject:kCCFileUtilsiPhone];
		[_searchChain addObject:kCCFileUtilsiPhone5];
	}
	
#elif defined(__CC_PLATFORM_MAC)
	if (device == kCCMacRetinaDisplay)
	{
		[_searchChain addObject:kCCFileUtilsMacHD];
		[_searchChain addObject:kCCFileUtilsMac];
	}
	else if (device == kCCMac)
	{
		[_searchChain addObject:kCCFileUtilsMac];
	}
#endif	
	
	[_searchChain addObject:kCCFileUtilsDefault];
}

-(NSString*) pathForResource:(NSString*)resource ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
	// Create full file name with extension)
	NSString* fileName = NULL;
	if (ext && ![ext isEqualToString:@""])
	{
		fileName = [resource stringByAppendingPathExtension:ext];
	}
	else
	{
		fileName = resource;
	}
	
	NSFileManager* fm = [NSFileManager defaultManager];
	
	// Append sub path
	if (subpath && ![subpath isEqualToString:@""])
	{
		fileName = [fileName stringByAppendingPathComponent:subpath];
	}
			
	// Default to non resolution directory
	if ([fm fileExistsAtPath:fileName])
	{
		return fileName;
	}
	
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
		NSString *imageDirectory = [path stringByDeletingLastPathComponent];
		
		// If the file does not exist it will return nil.
		ret = [self pathForResource:[newName lastPathComponent]
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
	NSString *newName = path;
	
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
	else if( [_fileManager fileExistsAtPath:newName] )
		ret = newName;
	
	if( ! ret )
		CCLOGINFO(@"cocos2d: CCFileUtils: file not found: %@", [newName lastPathComponent] );
	
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
	NSAssert(NO, @"Should not reach here");
	return kCCResolutionUnknown;
}


-(NSString*) fullPathIgnoringResolutionsFromRelativePath:(NSString*)relPath
{
	if ([relPath isAbsolutePath])
		return relPath;
	
	NSString* path = [_fullPathNoResolutionsCache objectForKey:relPath];
	if (path)
		return path;
	
	if ([_fileManager fileExistsAtPath:relPath])
	{
		// Save in cache
		[_fullPathNoResolutionsCache setObject:path forKey:relPath];
		
		return path;
	}
	
	// Default to normal resource directory
	path = [_bundle pathForResource:[relPath lastPathComponent]
							 ofType:nil
						inDirectory:[relPath stringByDeletingLastPathComponent]];
	
	// Save in cache
	if (path)
		[_fullPathNoResolutionsCache setObject:path forKey:relPath];
	
	return path;
}

-(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType
{
	NSAssert(relPath != nil, @"CCFileUtils: Invalid path");
	
	CCCacheValue *value = [_fullPathCache objectForKey:relPath];
	if( value ) {
		*resolutionType = value.resolutionType;
		return value.fullpath;
	}
	
	NSString *ret = @"";
	

	// Search with Suffixes
	for( NSString *device in _searchChain ) {

		if( _searchMode == kCCFileUtilsSearchSuffix ) {
			// Search using suffixes
			NSString *suffix = [_suffixesDict objectForKey:device];
			ret = [self getPath:relPath forSuffix:suffix];
			*resolutionType = [self resolutionTypeForKey:suffix inDictionary:_suffixesDict];
		} else {
			// Search in subdirectories
			NSString *directory = [_directoriesDict objectForKey:device];
			ret = [self getPath:relPath forDirectory:directory];
			*resolutionType = [self resolutionTypeForKey:directory inDictionary:_directoriesDict];
		}

		if( ret )
			break;
	}
	
	if( ! ret ) {
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


-(void) setEnableFallbackSuffixes:(BOOL)enableFallbackSuffixes
{
	[self setEnableFallbackChain:enableFallbackSuffixes];
}

-(void) setEnableFallbackChain:(BOOL)enableFallbackChain
{
	if( _enableFallbackChain != enableFallbackChain ) {
		
		_enableFallbackChain = enableFallbackChain;
		
		[self buildSearchChain];
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


// XXX: Optimization: This should be called only once
-(NSInteger) runningDevice
{
	NSInteger ret=-1;

#ifdef __CC_PLATFORM_IOS
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		ret = (CC_CONTENT_SCALE_FACTOR() == 2) ? kCCiPadRetinaDisplay : kCCiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		// From http://stackoverflow.com/a/12535566
		BOOL isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
		
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
			ret = isiPhone5 ? kCCiPhone5RetinaDisplay : kCCiPhoneRetinaDisplay;
		} else
			ret = isiPhone5 ? kCCiPhone5 : kCCiPhone;
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
	NSString *withoutSuffix = [_removeSuffixCache objectForKey:path];
	if( withoutSuffix )
		return withoutSuffix;
	
	// Initial value should be non-nil
	NSString *ret = @"";
	
	NSInteger device = [self runningDevice];
	
#ifdef __CC_PLATFORM_IOS
	if( device == kCCiPadRetinaDisplay )
		ret = [self removeSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPadHD] fromPath:path];
	
	if( device == kCCiPad || (_enableFallbackChain && !ret) )
		ret = [self removeSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPad] fromPath:path];
	
	if( device == kCCiPhoneRetinaDisplay || (_enableFallbackChain && !ret) )
		ret = [self removeSuffix:[_suffixesDict objectForKey:kCCFileUtilsiPhoneHD] fromPath:path];
	
	if( device == kCCiPhone || !ret )
		ret = path;	

#elif defined(__CC_PLATFORM_MAC)
	if( device == kCCMacRetinaDisplay )
		ret = [self removeSuffix:[_suffixesDict objectForKey:kCCFileUtilsMacHD] fromPath:path];

	if( device == kCCMac|| !ret )
		ret = [self removeSuffix:[_suffixesDict objectForKey:kCCFileUtilsMac] fromPath:path];

#endif // __CC_PLATFORM_MAC
	
	if( ret )
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

#elif defined(__CC_PLATFORM_MAC)

-(BOOL) macRetinaDisplayFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:kCCFileUtilsMacHD]];
}

-(BOOL) macFileExistsAtPath:(NSString*)path
{
	return [self fileExistsAtPath:path withSuffix:[_suffixesDict objectForKey:kCCFileUtilsMac]];
}

#endif // __CC_PLATFORM_MAC

@end
