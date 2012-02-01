/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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


#import "CCTextureCache.h"
#import "CCSpriteFrame.h"
#import "ccMacros.h"
#import "AutoMagicCoding/NSObject+AutoMagicCoding.h"
#import "CCSpriteFrameCache.h"

@implementation CCSpriteFrame
@synthesize rotated = rotated_, offsetInPixels = offsetInPixels_, texture = texture_;
@synthesize originalSizeInPixels=originalSizeInPixels_;
@synthesize name = name_;

+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [[[self alloc] initWithTexture:texture rect:rect] autorelease];
}

+(id) frameWithTexture:(CCTexture2D*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[[self alloc] initWithTexture:texture rectInPixels:rect rotated:rotated offset:offset originalSize:originalSize] autorelease];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CGRect rectInPixels = CC_RECT_POINTS_TO_PIXELS( rect );
	return [self initWithTexture:texture rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:rectInPixels.size];
}

-(id) initWithTexture:(CCTexture2D*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) ) {
		self.texture = texture;
		rectInPixels_ = rect;
		rect_ = CC_RECT_PIXELS_TO_POINTS( rect );
		rotated_ = rotated;
		offsetInPixels_ = offset;
		originalSizeInPixels_ = originalSize;
	}
	return self;	
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | TextureName=%d, Name = %@, Rect = (%.2f,%.2f,%.2f,%.2f)> rotated:%d", [self class], self,
			texture_.name,
            self.name,
			rect_.origin.x,
			rect_.origin.y,
			rect_.size.width,
			rect_.size.height,
			rotated_
			];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
	[texture_ release];
    self.name = nil;
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTexture:texture_ rectInPixels:rectInPixels_ rotated:rotated_ offset:offsetInPixels_ originalSize:originalSizeInPixels_];
	return copy;
}

-(CGRect) rect
{
	return rect_;
}

-(CGRect) rectInPixels
{
	return rectInPixels_;
}

-(void) setRect:(CGRect)rect
{
	rect_ = rect;
	rectInPixels_ = CC_RECT_POINTS_TO_PIXELS( rect_ );
}

-(void) setRectInPixels:(CGRect)rectInPixels
{
	rectInPixels_ = rectInPixels;
	rect_ = CC_RECT_PIXELS_TO_POINTS(rectInPixels);
}

- (BOOL) isEqual:(id)object
{
    CCSpriteFrame *other = (CCSpriteFrame *) object;
    if (![other isKindOfClass:[CCSpriteFrame class]])
        return NO;
    
    if (self.name != other.name)
        return NO;
    
    // Texture's are equal pointers, or they both have equal, non-nil keys.
    if (self.texture != other.texture && !( self.texture.key && self.texture.key == other.texture.key) )
        return NO;
    
    if (!CGRectEqualToRect(self.rect, other.rect))
        return NO;
    
    if (!CGRectEqualToRect(self.rectInPixels, other.rectInPixels))
        return NO;
    
    if (self.rotated != other.rotated)
        return NO;
    
    if (!CGPointEqualToPoint(self.offsetInPixels, other.offsetInPixels))
        return NO;
    
    if (!CGSizeEqualToSize(self.originalSizeInPixels, other.originalSizeInPixels))
        return NO;    
    
    return YES;
}

#pragma mark AutoMagicCoding Support

+ (BOOL) AMCEnabled
{
    return YES;
}

- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    // Get name of loading sprite frame.
    NSString *name = [aDict objectForKey:@"name"];
    if ([name isKindOfClass:[NSString class]])
    {
        // Find existing frame with same name.
        CCSpriteFrame *existingFrameWithSameName = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: name];
        if (existingFrameWithSameName)
        {
            // On debug - warn developer if existing & loading frames with same names arent equal.
#if COCOS2D_DEBUG 
            
            if ( (self = [super initWithDictionaryRepresentation: aDict]) )
            {
                if (![self isEqual: existingFrameWithSameName])
                {
                    CCLOG(@"WARNING: Loading spriteFrame \"%@\" isn't equal to existing spriteFrame with same name in CCSpriteFrameCache. Ignoring new one and using cached version! New = %@ Cached = %@", self.name, self, existingFrameWithSameName);
                }
            }
#endif
            
            // Return existing sprite frame.
            [self release];
            return [existingFrameWithSameName retain]; 
            //< init must return NSObject with +1 refCount.
        }
        else // Create new and save it in SpriteFrameCache
        {
            self = [super initWithDictionaryRepresentation: aDict];
            if (self)
            {
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:self name:self.name];
            }
            
            return self;
        }
    }
    
    // Noname sprite frame - simply create new.
    return [super initWithDictionaryRepresentation: aDict];
}

@end
