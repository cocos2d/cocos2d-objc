/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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

#import "CCCache.h"

//------------------------------------------------------------------------------
#pragma mark - Cache entry class
//------------------------------------------------------------------------------

@interface CCCacheEntry : NSObject
{
    __weak id _object;
    __strong id _sharedData;
}

+ (instancetype)entryWithObject:(id)object sharedData:(id)data;

- (id)object;

@end

@implementation CCCacheEntry

+ (instancetype)entryWithObject:(id)object sharedData:(id)data
{
    return [[self alloc] initWithObject:object sharedData:data];
}

- (instancetype)initWithObject:(id)object sharedData:(id)data
{
    self = [super init];
    NSAssert(self, @"Unable to create class CCCacheEntry");
    
    // initialize
    _object = object;
    _sharedData = data;
    
    //done
    return self;
}

- (id)object
{
    return _object;
}

- (id)sharedData
{
    return _sharedData;
}

@end

//------------------------------------------------------------------------------

@implementation CCCache 
{
    NSMutableDictionary *_cacheList;
}

//------------------------------------------------------------------------------
#pragma mark - Cache creation
//------------------------------------------------------------------------------

+ (instancetype)cache
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    NSAssert(self, @"Unable to create class CCCache");

    // initialize
    _cacheList = [NSMutableDictionary dictionary];
    
    // done
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Basic cache functionality
//------------------------------------------------------------------------------

- (void)preload:(NSString *)key
{
    [self objectForKey:key];
}

//------------------------------------------------------------------------------

- (id)objectForKey:(NSString *)key
{
    CCCacheEntry *entry = [_cacheList objectForKey:key];
    
    if (entry == nil)
    {
        // create a spanking new entry
        
        // get data
        id data = [self createSharedDataForKey:key];
        
        // create new cache entry
        CCCacheEntry *newEntry = [CCCacheEntry entryWithObject:[self createObjectForData:data] sharedData:data];
        [_cacheList setObject:newEntry forKey:key];
        
        // return object
        return   newEntry.object;
    }
    else if (entry.object == nil)
    {
        // entry was found, but no objects are alive
        
        // make a copy of data, and remove old entry
        id data = entry.sharedData;
        [_cacheList removeObjectForKey:key];
        
        // create new cache entry
        CCCacheEntry *newEntry = [CCCacheEntry entryWithObject:[self createObjectForData:data] sharedData:data];
        [_cacheList setObject:newEntry forKey:key];
        
        // return object
        return   newEntry.object;
    }
    
    // object found and alive
    return entry.object;
}

//------------------------------------------------------------------------------

- (void)flush
{
    // iterate keys
    for (NSString *key in _cacheList.allKeys)
    {
        CCCacheEntry *entry = [_cacheList objectForKey:key];
        
        // if entry has no live objects, dispose of data and delete entry
        if (entry.object == nil)
        {
            [self disposeObjectForData:entry.sharedData];
            [_cacheList removeObjectForKey:key];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Override in specific CCCache implementations
//------------------------------------------------------------------------------

// creates the data associated with the key
// this could ex. be a GLKTextureInfo class for use with creating textures

- (id)createSharedDataForKey:(NSString *)key
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

//------------------------------------------------------------------------------
// create the object, based on data
// it is obviously important, that the cache does not perform costly operations, but rely on the data

- (id)createObjectForData:(id)data
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

//------------------------------------------------------------------------------
// dispose the underlying data
// this could ex be disposal of the GLKTextureInfo class, used when creating textures

- (void)disposeObjectForData:(id)data
{
    NSAssert(NO, @"Subclasses must override this method");
}

//------------------------------------------------------------------------------

@end






























