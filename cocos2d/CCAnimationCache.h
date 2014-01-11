/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
 *
 */

#import <Foundation/Foundation.h>

@class CCAnimation;

/**
 Singleton that manages the CCAnimation cache.
 */
@interface CCAnimationCache : NSObject {

    // Animation cache dictonary.
	NSMutableDictionary *_animations;
}

/** Animation cache shared instance. */
+(CCAnimationCache *) sharedAnimationCache;


/// -----------------------------------------------------------------------
/// @name Animation Cache Management
/// -----------------------------------------------------------------------

/** Purges the animation cache. */
+(void) purgeSharedAnimationCache;

/**
 *  Add the specified animation with name values to the animation cache.
 *
 *  @param animation Animation object.
 *  @param name      Animation key name.
 */
-(void) addAnimation:(CCAnimation*)animation name:(NSString*)name;

/**
 *  Remove animation from cache using specified key value name.
 *
 *  @param name Animation key name.
 */
-(void) removeAnimationByName:(NSString*)name;

/**
 *  Returns a CCAnimation object from the specified key name value.
 *
 *  @param name Animation key name.
 *
 *  @return CCAnimation object.
 */
-(CCAnimation*) animationByName:(NSString*)name;

/**
 *  Add animation to cache using the specified dictionary.
 *
 *  @param dictionary Animation dictionary.
 */
-(void) addAnimationsWithDictionary:(NSDictionary *)dictionary;

/**
 *  Add an animation to cache using the specified plist file.
 *
 *  @param plist file resource path.
 */
-(void) addAnimationsWithFile:(NSString *)plist;

@end
