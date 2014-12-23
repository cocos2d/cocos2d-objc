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


#import "ccTypes.h"

#import "Platforms/CCGL.h"


@class CCSpriteFrame;
@class CCImage;


typedef NS_ENUM(NSUInteger, CCTextureType){
    CCTextureType2D,
    CCTextureTypeCube,
};


typedef NS_ENUM(NSUInteger, CCTextureFilter){
    CCTextureFilterMipmapNone,
    CCTextureFilterNearest,
    CCTextureFilterLinear,
};

typedef NS_ENUM(NSUInteger, CCTextureAddressMode){
    CCTextureAddressModeClampToEdge,
    CCTextureAddressModeRepeat,
    CCTextureAddressModeRepeatMirrorred,
};

extern NSString * const CCTextureOptionGenerateMipmaps;
extern NSString * const CCTextureOptionMinificationFilter;
extern NSString * const CCTextureOptionMagnificationFilter;
extern NSString * const CCTextureOptionMipmapFilter;
extern NSString * const CCTextureOptionAddressModeX;
extern NSString * const CCTextureOptionAddressModeY;


@interface CCTexture : NSObject
{
    @private
    CGSize _sizeInPixels;
    CGSize _contentSize;
    CCTextureType _type;
}

-(instancetype)initWithImage:(CCImage *)image options:(NSDictionary *)options;

+(instancetype)textureWithFile:(NSString*)file;

+(instancetype)none;

@property(nonatomic, readonly) BOOL isPOT;
@property(nonatomic, readonly) CCTextureType type;

@property(nonatomic, readonly) CGSize sizeInPixels;
@property(nonatomic, readwrite) CGFloat contentScale;
@property(nonatomic, readonly) CGSize contentSize;

@property(nonatomic, readonly) CCSpriteFrame *spriteFrame;

@end
