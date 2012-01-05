/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Stepan Generalov.
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
@class CCNode;

/** Singleton that holds pointers to named CCNode objects.
 It called Registry because it doesn't cache(retain) anything.
 You should use this class if you want to get ANY named node from ANY place.
 To save pointer to a node (without retaining it) - use CCNode's name property.
 
 @since v1.1+ ("feature-amc" branch)
 */
@interface CCNodeRegistry : NSObject
{
	NSMutableDictionary *nodes_;
}

/** Retruns shared instance of the node registry. */
+ (CCNodeRegistry *) sharedRegistry;

/** Purges the registry. Removes all pointers to CCNodes, but doesn't release 
 * them nor changes their names.
 */
+(void)purgeSharedRegistry;

/** Returns a CCNode that's name is equal to given.
 If the name is not found it will return nil.
 You should retain the returned node if you are going to use it after some time
 (treat it as __autoreleasing ).
 */
-(CCNode*) nodeByName:(NSString*)name;

@end

/** Private interface for CCNode to access CCNodeRegistry. */
@interface CCNodeRegistry (CCNodesPrivateInterface)

/** Notifies registry about any changes (new, rename, remove) in node's name.
 * Adds node to registry if node without name have set it's name to non-nil (new).
 * Changes key in nodes_ dictionary for given node if it's previous name (non-nil)
 * was changed to another one (rename).
 * Removes node from registry if it's name was changed to nil (removed).
 *
 * NEVER retains nor releases any node.
 * Usually you don't need to call this method directly - 
 * use CCNode's name property instead.
 */
-(void) node: (CCNode *) aNode didChangeNameTo: (NSString *) newName previousName: (NSString *) prevName;

@end

