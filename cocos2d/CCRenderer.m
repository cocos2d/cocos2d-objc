/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "cocos2d.h"
#import "CCRenderer_private.h"


const NSString *CCBlendFuncSrcColor = @"CCBlendFuncSrcColor";
const NSString *CCBlendFuncDstColor = @"CCBlendFuncDstColor";
const NSString *CCBlendEquationColor = @"CCBlendEquationColor";
const NSString *CCBlendFuncSrcAlpha = @"CCBlendFuncSrcAlpha";
const NSString *CCBlendFuncDstAlpha = @"CCBlendFuncDstAlpha";
const NSString *CCBlendEquationAlpha = @"CCBlendEquationAlpha";


@implementation CCBlendMode

static NSSet *CCBLEND_SHARED_KEYS = nil;
static NSMutableDictionary *CCBLEND_CACHE = nil;

// Default modes
static NSDictionary *CCBLEND_DISABLED = nil;
static NSDictionary *CCBLEND_ALPHA = nil;
static NSDictionary *CCBLEND_PREMULTIPLIED_ALPHA = nil;
static NSDictionary *CCBLEND_ADD = nil;
static NSDictionary *CCBLEND_MULTIPLY = nil;

+(void)initialize
{
	CCBLEND_SHARED_KEYS = [NSDictionary sharedKeySetForKeys:@[
		CCBlendFuncSrcColor,
		CCBlendFuncDstColor,
		CCBlendEquationColor,
		CCBlendFuncSrcAlpha,
		CCBlendFuncDstAlpha,
		CCBlendEquationAlpha,
	]];
	
	CCBLEND_CACHE = [[NSMutableDictionary alloc] init];
	
	// Add the default modes
	CCBLEND_DISABLED = [self blendModeWithOptions:@{}];
	
	CCBLEND_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_SRC_ALPHA),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_PREMULTIPLIED_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_ADD = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE),
	}];
	
	CCBLEND_MULTIPLY = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_DST_COLOR),
		CCBlendFuncDstColor: @(GL_ZERO),
	}];
}

+(NSDictionary *)blendModeWithOptions:(NSDictionary *)options
{
	// Try the raw options dictionary before normalizing.
	NSDictionary *blendMode = CCBLEND_CACHE[options];
	if(blendMode) return blendMode;
	
	NSNumber *src = (options[CCBlendFuncSrcColor] ?: @(GL_ONE));
	NSNumber *dst = (options[CCBlendFuncDstColor] ?: @(GL_ZERO));
	NSNumber *equation = (options[CCBlendEquationColor] ?: @(GL_FUNC_ADD));
	
	NSDictionary *normalized = @{
		CCBlendFuncSrcColor: src,
		CCBlendFuncDstColor: dst,
		CCBlendEquationColor: equation,
		
		// Assume they meant non-separate blending if they didn't fill in the keys.
		CCBlendFuncSrcAlpha: (options[CCBlendFuncSrcAlpha] ?: src),
		CCBlendFuncDstAlpha: (options[CCBlendFuncDstAlpha] ?: dst),
		CCBlendEquationAlpha: (options[CCBlendEquationAlpha] ?: equation),
	};
	
	blendMode = CCBLEND_CACHE[normalized];
	if(blendMode == nil){
		// Add to the cache.
		CCBLEND_CACHE[options] = normalized;
		CCBLEND_CACHE[normalized] = normalized;
		
		blendMode = normalized;
	}
	
	return blendMode;
}

+(NSDictionary *)disabledMode
{
	return CCBLEND_DISABLED;
}

+(NSDictionary *)alphaMode
{
	return CCBLEND_ALPHA;
}

+(NSDictionary *)premultipliedAlphaMode
{
	return CCBLEND_PREMULTIPLIED_ALPHA;
}

+(NSDictionary *)addMode
{
	return CCBLEND_ADD;
}

+(NSDictionary *)multiplyMode
{
	return CCBLEND_MULTIPLY;
}

@end


@implementation CCRenderState

@end


@implementation CCRenderer {
	NSDictionary *_blendMode;
}

-(instancetype)init
{
	if((self = [super init])){
		
	}
	
	return self;
}

-(void)setBlendMode:(NSDictionary *)blendMode;
{
	if(blendMode == _blendMode) return;
	
	if(blendMode == CCBLEND_DISABLED){
		glDisable(GL_BLEND);
	} else {
		glEnable(GL_BLEND);
		
		glBlendFuncSeparate(
			[blendMode[CCBlendFuncSrcColor] unsignedIntValue],
			[blendMode[CCBlendFuncDstColor] unsignedIntValue],
			[blendMode[CCBlendFuncSrcAlpha] unsignedIntValue],
			[blendMode[CCBlendFuncDstAlpha] unsignedIntValue]
		);
		
		glBlendEquationSeparate(
			[blendMode[CCBlendEquationColor] unsignedIntValue],
			[blendMode[CCBlendEquationAlpha] unsignedIntValue]
		);
	}
	
	_blendMode = blendMode;
}

@end
