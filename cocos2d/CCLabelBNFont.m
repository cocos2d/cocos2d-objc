/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Zhengrong Zang
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
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "CGPointExtension.h"
#import "CCSpriteFrameCache.h"
#import "CCLabelBNFont.h"

// Equal function for targetSet.
typedef struct _KerningHashElement
{	
	int				key;		// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	int				amount;
	UT_hash_handle	hh;
} tKerningHashElement;


#pragma mark -
#pragma mark CCLabelBNFont
@implementation CCLabelBNFont

#pragma mark -
#pragma mark LabelBNFont - Purge Cache
+(void) purgeCachedData {
	FNTConfigRemoveCache();
}

#pragma mark -
#pragma mark LabelBNFont - Creation & Init
+(id)spriteWithTexture:(CCTexture2D*)texture {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithFile:(NSString*)filename {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id)spriteWithCGImage:(CGImageRef)image key:(NSString*)key {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id) spriteWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithTexture:(CCTexture2D*)texture {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithFile:(NSString*)filename {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id)initWithSpriteFrameName:(NSString*)spriteFrameName {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

- (id) initWithCGImage:(CGImageRef)image key:(NSString*)key {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect {
    NSAssert(NO, @"Invalid init, you have to use labelWithString");
	return nil;
}

+(id) labelWithString:(NSString *)string fntFile:(NSString *)fntFile {
	return [[[self alloc] initWithString:string fntFile:fntFile] autorelease];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile {	
	[configuration_ release]; // allow re-init
	configuration_ = FNTConfigLoadFile(fntFile);
	[configuration_ retain];
    
	NSAssert(configuration_, @"Error creating config for LabelBNFont");
	
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:configuration_->atlasName_];

    if (frame) {
        if ((self = [super initWithSpriteFrame:frame])) {
            [self setString:theString];
        }
    }
	else if ((self = [super initWithFile:configuration_->atlasName_])) {
    	[self setString:theString];
    }
    
	return self;
}

-(void) dealloc {
	[string_ release];
	[configuration_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark LabelBNFont - Atlas generation
-(int) kerningAmountForFirst:(unichar)first second:(unichar)second {
	int ret = 0;
	unsigned int key = (first<<16) | (second & 0xffff);
	
	if (configuration_->kerningDictionary_) {
		tKerningHashElement *element = NULL;
		HASH_FIND_INT(configuration_->kerningDictionary_, &key, element);
		
		if (element) {
			ret = element->amount;
        }
	}
    
	return ret;
}

-(void) createFontChars {
	NSInteger nextFontPositionX = 0;
	NSInteger nextFontPositionY = 0;
	unichar prev = -1;
	NSInteger kerningAmount = 0;
	
	CGSize tmpSize = CGSizeZero;
    
	NSInteger longestLine = 0;
	NSUInteger totalHeight = 0;
	NSUInteger quantityOfLines = 1;
	NSUInteger stringLen = [string_ length];
	
    if (!stringLen) {
		return;
    }
    
	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(NSUInteger i = 0; i < stringLen - 1; i++) {
		unichar c = [string_ characterAtIndex:i];
        
		if (c == '\n') {
			quantityOfLines++;
        }
	}
	
	totalHeight = configuration_->commonHeight_ * quantityOfLines;
	nextFontPositionY = -(configuration_->commonHeight_ - configuration_->commonHeight_ * quantityOfLines);
	
	for(NSUInteger i = 0; i < stringLen; i++) {
		unichar c = [string_ characterAtIndex:i];
		NSAssert( c < kCCBMFontMaxChars, @"LabelBMFont: character outside bounds");
		
		if (c == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= configuration_->commonHeight_;
			continue;
		}
        
		kerningAmount = [self kerningAmountForFirst:prev second:c];
		
		ccBMFontDef fontDef = configuration_->BMFontArray_[c];
        
        CGRect rect1 = CC_RECT_POINTS_TO_PIXELS(self.textureRect);
		CGRect rect2 = fontDef.rect;
        rect2.origin.x += rect1.origin.x;
        rect2.origin.y += rect1.origin.y;
        CGRect rect3 = CC_RECT_PIXELS_TO_POINTS(rect2);
		
		CCSprite *fontChar = (CCSprite*) [self getChildByTag:i];

		if (!fontChar) {
			fontChar = [[CCSprite alloc] initWithTexture:self.texture rect:rect3];
			[self addChild:fontChar z:0 tag:i];
			[fontChar release];
		}
		else {
			// reusing fonts
			[fontChar setTextureRectInPixels:rect2 rotated:NO untrimmedSize:rect2.size];
			
			// restore to default in case they were modified
			fontChar.visible = YES;
			fontChar.opacity = 255;
		}
		
		float yOffset = configuration_->commonHeight_ - fontDef.yOffset;
		fontChar.positionInPixels = ccp( 
                            (float)nextFontPositionX + 
                                        fontDef.xOffset + 
                                        fontDef.rect.size.width * 0.5f + 
                                        kerningAmount,
                            (float)nextFontPositionY + 
                                        yOffset - 
                                        rect2.size.height * 0.5f);
        
		// update kerning
		nextFontPositionX += configuration_->BMFontArray_[c].xAdvance + kerningAmount;
		prev = c;
        
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
        
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:color_];
        
		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if (opacity_ != 255 && opacity_ != 0) {
			[fontChar setOpacity: opacity_];
        }
        
		if (longestLine < nextFontPositionX) {
			longestLine = nextFontPositionX;
        }
	}
    
	tmpSize.width = longestLine;
	tmpSize.height = totalHeight;
    
	[self setContentSizeInPixels:tmpSize];
    [super setOpacity:0];
    [super setDirty:NO];
}

#pragma mark -
#pragma mark LabelBNFont - CCLabelProtocol protocol
- (void) setString:(NSString*) newString {	
	[string_ release];
	string_ = [newString copy];
    
	CCNode *child;
	CCARRAY_FOREACH(children_, child) {
    	child.visible = NO;
    }
    
	[self createFontChars];
}

-(NSString*) string {
	return string_;
}

-(void) setCString:(char*)label {
	[self setString:[NSString stringWithUTF8String:label]];
}

#pragma mark -
#pragma mark LabelBNFont - RGBA protocol
// don't show parent of LabelBNFont
-(void) setOpacity:(GLubyte) anOpacity {
    [super setOpacity:0];
    CCSprite *child;
    CCARRAY_FOREACH(children_, child) {
        [child setOpacity:anOpacity];
    }
}

-(void) setColor:(ccColor3B)color3 {
    [super setColor:color3];
    
	CCSprite *child;
	CCARRAY_FOREACH(children_, child) {
    	[child setColor:color3];
    }
}

@end
