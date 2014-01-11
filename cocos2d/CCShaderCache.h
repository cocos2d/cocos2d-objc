/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

#import <Foundation/Foundation.h>
#import "ccMacros.h"
#ifdef __CC_PLATFORM_IOS
#import <OpenGLES/ES2/gl.h>
#endif // __CC_PLATFORM_IOS

@class CCGLProgram;

/** CCShaderCache
 Singleton that stores manages GL shaders
 */
@interface CCShaderCache : NSObject {

	NSMutableDictionary	*_programs;

}

/** returns the shared instance */
+ (CCShaderCache *)sharedShaderCache;

/** purges the cache. It releases the retained instance. */
+(void)purgeSharedShaderCache;

/** loads the default shaders */
-(void) loadDefaultShaders;

/* returns a GL program for a given key */
-(CCGLProgram *) programForKey:(NSString*)key;

/* adds a CCGLProgram to the cache for a given name */
- (void) addProgram:(CCGLProgram*)program forKey:(NSString*)key;

@end

