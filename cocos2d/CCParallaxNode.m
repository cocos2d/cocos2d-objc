/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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

#import "CCParallaxNode.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "AutoMagicCoding/AutoMagicCoding/NSObject+AutoMagicCoding.h"

@interface CGPointObject : NSObject
{
	CGPoint	ratio_;
	CGPoint offset_;
	CCNode *child_;	// weak ref
}
@property (nonatomic,readwrite) CGPoint ratio;
@property (nonatomic,readwrite) CGPoint offset;
@property (nonatomic,readwrite,assign) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize ratio = ratio_;
@synthesize offset = offset_;
@synthesize child=child_;

+(id) pointWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	return [[[self alloc] initWithCGPoint:ratio offset:offset] autorelease];
}
-(id) initWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	if( (self=[super init])) {
		ratio_ = ratio;
		offset_ = offset;
	}
	return self;
}
@end

@implementation CCParallaxNode

@synthesize parallaxArray = parallaxArray_;

-(id) init
{
	if( (self=[super init]) ) {
		parallaxArray_ = ccArrayNew(5);		
		lastPosition = CGPointMake(-100,-100);
	}
	return self;
}

- (void) dealloc
{
	if( parallaxArray_ ) {
		ccArrayFree(parallaxArray_);
		parallaxArray_ = nil;
	}
	[super dealloc];
}

-(void) addChild:(CCNode*)child z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert(NO,@"ParallaxNode: use addChild:z:parallaxRatio:positionOffset instead");
}

-(void) addChild: (CCNode*) child z:(NSInteger)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObject *obj = [CGPointObject pointWithCGPoint:ratio offset:offset];
	obj.child = child;
	ccArrayAppendObjectWithResize(parallaxArray_, obj);
	
	CGPoint pos = self.position;
	pos.x = pos.x * ratio.x + offset.x;
	pos.y = pos.y * ratio.y + offset.y;
	child.position = pos;
	
	[super addChild: child z:z tag:child.tag];
}

-(void) removeChild:(CCNode*)node cleanup:(BOOL)cleanup
{
	for( unsigned int i=0;i < parallaxArray_->num;i++) {
		CGPointObject *point = parallaxArray_->arr[i];
		if( [point.child isEqual:node] ) {
			ccArrayRemoveObjectAtIndex(parallaxArray_, i);
			break;
		}
	}
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	ccArrayRemoveAllObjects(parallaxArray_);
	[super removeAllChildrenWithCleanup:cleanup];
}

-(CGPoint) absolutePosition_
{
	CGPoint ret = position_;
	
	CCNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}
	
	return ret;
}

/*
 The positions are updated at visit because:
   - using a timer is not guaranteed that it will called after all the positions were updated
   - overriding "draw" will only precise if the children have a z > 0
*/
-(void) visit
{
//	CGPoint pos = position_;
//	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	CGPoint pos = [self absolutePosition_];
	if( ! CGPointEqualToPoint(pos, lastPosition) ) {
		
		for(unsigned int i=0; i < parallaxArray_->num; i++ ) {

			CGPointObject *point = parallaxArray_->arr[i];
			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;			
			point.child.position = ccp(x,y);
		}
		
		lastPosition = pos;
	}
	
	[super visit];
}

#pragma mark CCParallaxNode - AutoMagicCoding Support

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    NSArray *nodeKeys = [super AMCKeysForDictionaryRepresentation];
    NSArray *parallaxNodeKeys = [NSArray arrayWithObjects:
                                 @"lastPosition",
                                 @"parallaxArrayForAMC",
                                 nil];
    return [nodeKeys arrayByAddingObjectsFromArray: parallaxNodeKeys];
}

- (AMCFieldType) AMCFieldTypeForValueWithKey:(NSString *)aKey
{
    if ([aKey isEqualToString:@"parallaxArrayForAMC"])
    {
        return kAMCFieldTypeCollectionArrayMutable;
    }
    else
        return [super AMCFieldTypeForValueWithKey:aKey];
}

- (NSArray *) parallaxArrayForAMC
{
    if (parallaxArray_ && parallaxArray_->num)
    {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity: parallaxArray_->num];
        
        for( unsigned int i=0;i < parallaxArray_->num;i++) 
        {
            CGPointObject *point = parallaxArray_->arr[i];
            
            NSUInteger childIndex = [children_ indexOfObject: point.child];
            NSString *ratioString = [point AMCEncodeStructWithValue: [point valueForKey:@"ratio"] withName: @"CGPoint"];
            NSString *offsetString = [point AMCEncodeStructWithValue: [point valueForKey:@"offset"] withName: @"CGPoint"];
            
            NSDictionary *pointDict = 
            [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:
                                                  [NSNumber numberWithUnsignedInteger:childIndex], 
                                                  ratioString, 
                                                  offsetString, 
                                                  nil]
                                        forKeys:[NSArray arrayWithObjects:
                                                 @"childIndex", 
                                                 @"ratioString", 
                                                 @"offsetString", 
                                                 nil]
             ];
            [array addObject:pointDict];
        }
        
        return array;
    }
    
    return nil;
}

- (void) setParallaxArrayForAMC:(NSArray *)parallaxPointDictsArray
{
    parallaxArray_ = ccArrayNew( [parallaxPointDictsArray count]);
    for (NSDictionary *pointDict in parallaxPointDictsArray)
    {
        CGPointObject *obj = [CGPointObject pointWithCGPoint:CGPointZero offset:CGPointZero];
        
        NSUInteger childIndex = [[pointDict objectForKey:@"childIndex"] unsignedIntegerValue];
        [obj setValue: [obj AMCDecodeStructFromString:[pointDict objectForKey:@"ratioString"] withName:@"CGPoint"] forKey:@"ratio"];
        [obj setValue: [obj AMCDecodeStructFromString:[pointDict objectForKey:@"offsetString"] withName:@"CGPoint"] forKey:@"offset"];        
        
        obj.child = [children_ objectAtIndex: childIndex];
        ccArrayAppendObjectWithResize(parallaxArray_, obj);
    }
}

-(void) prepareChildrenAfterAMCLoad
{
    // Add children from loaded children array.
    // It can be a little bit slower, but it's more stable.
    if ([children_ count])
    {
        CCArray *loadedChildren = children_;
        ccArray *loadedParallaxArray = parallaxArray_;
        
        children_ = [[CCArray alloc] initWithCapacity: [loadedChildren count]];
        parallaxArray_ = ccArrayNew([loadedChildren count]);
        
        // Re-add all children.
        NSUInteger i = 0;
        for (CCNode *child in loadedChildren)
        {
            CGPointObject *obj = parallaxArray_->arr[i];
            CGPoint ratio = obj.ratio;
            CGPoint offset = obj.offset;
            
            [self addChild: child z: child.zOrder parallaxRatio: ratio positionOffset: offset];
            ++i;
        }
        
        [loadedChildren release];
        ccArrayFree(loadedParallaxArray);
    }
    else
    {
        NSLog(@"children = %@", children_);
    }
}

@end
