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
#import "CCNode.h"


@implementation CCNodeRegistry

static CCNodeRegistry *sharedRegistry_=nil;

+ (CCNodeRegistry *) sharedRegistry
{
    @synchronized(self)
    {
        if (!sharedRegistry_)
            sharedRegistry_ = [[CCNodeRegistry alloc] init];
    }
    
	return sharedRegistry_;
}

+(id)alloc
{
	NSAssert(sharedRegistry_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedRegistry
{
    @synchronized(self)
    {
        [sharedRegistry_ release];
        sharedRegistry_ = nil;
    }
}

-(id) init
{
	if( (self=[super init]) ) {
		nodes_ = [[NSMutableDictionary alloc] initWithCapacity: 20];
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | num of nodes =  %i | nodes = %@>", [self class], self, [nodes_ count], nodes_];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	
	[nodes_ release];
	[super dealloc];
}

-(CCNode*) nodeByName:(NSString*)name
{
    return [[nodes_ objectForKey:name] nonretainedObjectValue];
}

-(void) node: (CCNode *) aNode didChangeNameTo: (NSString *) newName previousName: (NSString *) prevName
{
    if (prevName)
    {
        // Allow removing node from registry only by itself.
        // When replacing scene - nodes from old scene will dealloc AFTER
        // nodes from new will be added.
        // So if nodes from OLD scene have names equal to some nodes from NEW
        // scene - they will remove new nodes from Registry, and this shouldn't happen.
        CCNode *nodeToRemove = [[nodes_ objectForKey:prevName] nonretainedObjectValue];
        if (nodeToRemove == aNode)
        {
            [nodes_ removeObjectForKey: prevName];
        }
    }
    
    if (newName && aNode)
    {
        NSValue *value = [NSValue valueWithNonretainedObject:aNode];
        [nodes_ setObject: value forKey:newName];
    }
}

@end

