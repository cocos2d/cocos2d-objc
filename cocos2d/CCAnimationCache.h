/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

/** Singleton that manages the Animations.
 It saves in a cache the animations. You should use this class if you want to save your animations in a cache.

 Before v0.99.5, the recommend way was to save them on the CCSprite. Since v0.99.5, you should use this class instead.
 
 @since v0.99.5
 */
@interface CCAnimationCache : NSObject {

	NSMutableDictionary *animations_;
}

/** Retruns ths shared instance of the Animation cache */
+ (CCAnimationCache *) sharedAnimationCache;

/** Purges the cache. It releases all the CCAnimation objects and the shared instance.
 */
+(void)purgeSharedAnimationCache;

/** Adds a CCAnimation with a name.
 */
-(void) addAnimation:(CCAnimation*)animation name:(NSString*)name;

/** Deletes a CCAnimation from the cache.
 */
-(void) removeAnimationByName:(NSString*)name;

/** Returns a CCAnimation that was previously added.
 If the name is not found it will return nil.
 You should retain the returned copy if you are going to use it.
 */
-(CCAnimation*) animationByName:(NSString*)name;

@end
