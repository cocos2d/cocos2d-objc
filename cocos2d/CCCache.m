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

@implementation CCCacheEntry
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

- (void)preload:(id<NSCopying>)key
{
    [self objectForKey:key];
}

//------------------------------------------------------------------------------

-(id)rawObjectForKey:(id<NSCopying>)key
{
    CCCacheEntry *entry = [_cacheList objectForKey:key];
		return entry.publicObject;
}

- (CCCacheEntry *)entryForKey:(id<NSCopying>)key
{
    CCCacheEntry *entry = [_cacheList objectForKey:key];
    
    if (entry == nil)
    {
        // Create the cached entry with the shared data.
        entry = [[CCCacheEntry alloc] init];
        entry.sharedData = [self createSharedDataForKey:key];
        
        [_cacheList setObject:entry forKey:key];
    }
    
    return entry;
}

- (id)objectForKey:(id<NSCopying>)key
{
    CCCacheEntry *entry = [self entryForKey:key];
		
    id object = entry.publicObject;
    if (object == nil)
    {
        // Create the public object from the shared data.
        object = entry.publicObject = [self createPublicObjectForSharedData:entry.sharedData];
    }
    
    return object;
}

- (void)makeAlias:(id<NSCopying>)alias forKey:(id<NSCopying>)key
{
    CCCacheEntry *entry = [self entryForKey:key];
    [_cacheList setObject:entry forKey:alias];
}

- (BOOL)keyExists:(id<NSCopying>)key
{
    return([_cacheList objectForKey:key] != nil);
}

//------------------------------------------------------------------------------

- (void)flush
{
    // iterate keys
    for (id key in [_cacheList allKeys])
    {
        CCCacheEntry *entry = [_cacheList objectForKey:key];
        
        // if entry has no live public objects, delete the entry
        if (entry.publicObject == nil)
        {
            // If the entry's shared data hasn't been disposed of by another alias, do it now.
            if(entry.sharedData != nil)
            {
                [self disposeOfSharedData:entry.sharedData];
                entry.sharedData = nil;
            }
            
            [_cacheList removeObjectForKey:key];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Override in specific CCCache implementations
//------------------------------------------------------------------------------

// creates the data associated with the key
// this could ex. be a CCTextureInfo class for use with creating textures

- (id)createSharedDataForKey:(id<NSCopying>)key
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

//------------------------------------------------------------------------------
// create the object, based on data
// it is obviously important, that the cache does not perform costly operations, but rely on the data

- (id)createPublicObjectForSharedData:(id)data
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

//------------------------------------------------------------------------------
// dispose the underlying data
// this could ex be disposal of the CCTextureInfo class, used when creating textures

- (void)disposeOfSharedData:(id)data
{
    NSAssert(NO, @"Subclasses must override this method");
}

//------------------------------------------------------------------------------

@end
